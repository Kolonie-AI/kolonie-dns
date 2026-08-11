-- The three tables that carry the service, and the two rules the schema has to
-- encode rather than leave to the API.  `kolonie-dns#11`.
--
-- `docs/architecture.md` names the three: `holders`, `names`, `tombstones`.
-- They sit in the same database as PowerDNS's own (`001-powerdns.sql`), which is
-- what makes a record write a transaction rather than a distributed operation
-- (N-002).
--
-- ## The two rules that are here rather than in application code
--
-- **A released name is never reissued** (N-013).  A tombstone is not a soft
-- delete, and the uniqueness constraint has to consider tombstoned labels or the
-- rule is one bug away from being broken.  How that is done is the one design
-- decision in this file worth reading twice, and it is under `names` below.
--
-- **The clock runs on use, not on issuance.**  A name answering queries is doing
-- its job even if its holder has not called the API in months, so `last_used_at`
-- is what the sweeper reads and `issued_at` is bookkeeping.
--
-- ## What is deliberately not here
--
-- **No query log** (N-028).  `last_used_at` is a single moving timestamp, not a
-- history: it says a name was used, never which resolver asked or when else.
-- Writing it is an overwrite.
--
-- **Nothing about who held a tombstoned name.**  A tombstone records the label
-- and the fact of release.  That shape is chosen for the erasure question the
-- register lists as open — a citizen exercising the Colony's erasure right wants
-- its rows gone, and a tombstone that names nobody is the version that survives
-- the answer whichever way `kolonie-docs/governance/erasure.md` settles it.

BEGIN;

-- `gen_random_uuid()`, in core since PostgreSQL 13 but behind this extension in
-- the images that carry the older contrib set.  Requested rather than assumed.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- --------------------------------------------------------------------------
-- What a label may be (N-024)
-- --------------------------------------------------------------------------
-- One function, called from every place the rule is enforced.  A grammar that
-- lives only in application code is a grammar one code path forgets, and a
-- grammar written out twice in SQL is two grammars within a month.
--
-- **The `xn--` clause is the load-bearing half.**  Refusing non-ASCII is easy and
-- almost pointless on its own: punycode labels *are* ASCII, so a validator that
-- only rejects the characters lets `xn--bcher-kva` through and a browser renders
-- it back into the very characters the rule was meant to exclude.  The pattern
-- refuses every `??--` prefix rather than `xn--` alone, because RFC 5891 reserves
-- that whole shape — a future prefix would otherwise arrive as a new
-- bypass of a rule that was already written.
CREATE FUNCTION label_is_valid(label text) RETURNS boolean
  LANGUAGE sql IMMUTABLE PARALLEL SAFE
  RETURN label ~ '^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$'   -- 3–63, no edge hyphen
     AND label !~ '^..--';                              -- IDNA-reserved prefixes

COMMENT ON FUNCTION label_is_valid(text) IS
  'N-024: lowercase a-z, digits and hyphen; 3-63 characters; no leading or '
  'trailing hyphen; no internationalised name and no punycode.';

-- --------------------------------------------------------------------------
-- holders
-- --------------------------------------------------------------------------
-- A holder may or may not be a Kolonie citizen (N-011: membership is not the
-- gate).  `tier` is what citizenship buys — the name, the record types, the
-- count, the persistence (N-012) — and it is the only thing that reads on the
-- Kolonie side.
CREATE TYPE holder_tier AS ENUM ('free', 'citizen');

CREATE TABLE holders (
  id                      uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  tier                    holder_tier NOT NULL DEFAULT 'free',

  -- Who this is on the Kolonie side, when it is anybody.  NULL is the ordinary
  -- case: an anonymous caller is a holder with no citizenship and it stays one.
  kolonie_agent_id        text        UNIQUE,

  -- N-026: hashed at rest, rotatable, and not the name's identity — which is why
  -- it lives here and not on `names`, and why rotating it touches no name.
  key_hash                text        NOT NULL,
  key_rotated_at          timestamptz,

  -- The cached citizenship answer's age.  `docs/interface-kolonie.md` makes the
  -- lookup cacheable with a maximum age, and the sweeper refreshes what has
  -- passed it.  **A failed lookup never writes here**, because a holder is never
  -- released on one (N-013 makes a release irreversible).
  citizenship_checked_at  timestamptz,

  created_at              timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT a_citizen_is_somebody_over_there
    CHECK (tier <> 'citizen' OR kolonie_agent_id IS NOT NULL)
);

-- --------------------------------------------------------------------------
-- names — and the uniqueness that has to consider tombstoned labels
-- --------------------------------------------------------------------------
-- **A row here is every label this service has ever issued, held or released.**
-- Releasing a name does not delete its row; it clears the holder and writes a
-- tombstone beside it.  N-013 says exactly this — *"the row stays as a
-- tombstone"* — and it is also the only version where the uniqueness constraint
-- considers tombstoned labels for free: the primary key already refuses a label
-- that has ever been taken, without anybody remembering to look in a second
-- table.
--
-- The alternative shapes were both rejected:
--
--   * *Delete the row, keep a tombstone row* — then uniqueness lives in two
--     tables and no constraint spans them.  PostgreSQL cannot express a primary
--     key across two tables, so the rule would come down to a trigger somebody
--     can drop, which is the *"one bug away"* the issue names.
--   * *One `labels` table with a status column* — one table where
--     `docs/architecture.md` names three, and it puts the release facts in the
--     same row as the holder facts, which is the opposite of what the erasure
--     question wants.
CREATE TABLE names (
  label         text        PRIMARY KEY,

  -- NULL means nobody holds it.  Every tombstoned label is in that state, and
  -- the trigger below is what keeps the two facts from disagreeing.
  holder_id     uuid        REFERENCES holders(id) ON DELETE RESTRICT,

  issued_at     timestamptz NOT NULL DEFAULT now(),

  -- The clock, and it runs on use.  Resolution counts as use, which is the whole
  -- point: measuring only API writes would release names that are working, which
  -- is the failure the 30-day rule exists to avoid causing.
  last_used_at  timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT label_grammar CHECK (label_is_valid(label))
);

CREATE INDEX names_holder_idx ON names(holder_id);
CREATE INDEX names_last_used_idx ON names(last_used_at);

-- --------------------------------------------------------------------------
-- tombstones
-- --------------------------------------------------------------------------
-- **The foreign key is the guard, not the bookkeeping.**  `ON DELETE RESTRICT`
-- means a tombstoned name's row cannot be deleted while its tombstone stands, so
-- the one move that would free the label for reissue — deleting the row and
-- inserting it again — is refused by the database rather than by a convention.
--
-- There is no `holder_id` here and that is the design, not an omission.  See the
-- header.
CREATE TYPE release_reason AS ENUM (
  'clock',          -- 30 days of disuse on the free tier
  'holder',         -- the holder gave it up
  'taken-down'      -- a red line, decided by a person
);

CREATE TABLE tombstones (
  label        text           PRIMARY KEY REFERENCES names(label) ON DELETE RESTRICT,
  released_at  timestamptz    NOT NULL DEFAULT now(),
  reason       release_reason NOT NULL
);

-- --------------------------------------------------------------------------
-- reserved names (N-015)
-- --------------------------------------------------------------------------
-- **A list, not a classifier**, so a maintainer can always answer *why did this
-- get refused* with a word.  `reason` is `NOT NULL` because a reserved label
-- whose reason nobody wrote down is a refusal nobody can defend a year later.
--
-- The grammar is deliberately *not* applied to this column.  The list holds
-- strings this service refuses, and some of them — `_psl`, `_acme-challenge` —
-- are labels the *zone* uses that N-024 would not admit as a name at all.  A
-- constraint here would forbid writing down why a label nobody can take is
-- nobody's, which is the question a reader actually arrives with.
CREATE TABLE reserved_names (
  label   text PRIMARY KEY,
  reason  text NOT NULL,

  CONSTRAINT reserved_names_are_lowercase CHECK (label = lower(label))
);

-- --------------------------------------------------------------------------
-- One refusal, with one answer
-- --------------------------------------------------------------------------
-- N-024: the reserved-name list *"is checked in the same place and at the same
-- moment as the label grammar … because a name that passes one and fails the
-- other must fail with one answer rather than two."*
--
-- So both are here, in one trigger, raising one error whose `HINT` says which
-- rule refused it.  The `label_grammar` CHECK on the table is the same rule
-- through the same function — one definition, two enforcement points — and it
-- stands because a CHECK covers the paths a trigger can be disabled on.
--
-- **The third refusal is the reissue**, and it is here rather than beside the
-- other two because a caller cannot tell the three apart from outside and should
-- not have to: the label is unavailable, and the hint says why.
CREATE FUNCTION refuse_unavailable_label() RETURNS trigger
  LANGUAGE plpgsql AS $$
DECLARE
  why text;
BEGIN
  IF NOT label_is_valid(NEW.label) THEN
    RAISE EXCEPTION 'label % is not a valid name', NEW.label
      USING ERRCODE = 'check_violation',
            HINT = 'N-024: lowercase, digits and hyphen, 3-63 characters, no '
                   'edge hyphen, and no internationalised or punycode label.';
  END IF;

  SELECT reason INTO why FROM reserved_names WHERE label = NEW.label;
  IF FOUND THEN
    RAISE EXCEPTION 'label % is reserved', NEW.label
      USING ERRCODE = 'check_violation',
            HINT = 'N-015: ' || why;
  END IF;

  -- Only on the paths that would hand the label to somebody.  A sweeper writing
  -- `last_used_at` on a tombstoned row is harmless and is not a reissue.
  IF NEW.holder_id IS NOT NULL
     AND EXISTS (SELECT 1 FROM tombstones WHERE label = NEW.label) THEN
    RAISE EXCEPTION 'label % was released and is never reissued', NEW.label
      USING ERRCODE = 'check_violation',
            HINT = 'N-013: a tombstone is permanent. The name resolves to '
                   'nothing and belongs to no one.';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER names_refuse_unavailable
  BEFORE INSERT OR UPDATE OF label, holder_id ON names
  FOR EACH ROW EXECUTE FUNCTION refuse_unavailable_label();

-- The same rule from the other side.  Writing a tombstone for a label somebody
-- still holds would leave the two facts disagreeing, and the disagreement is
-- exactly what a later `UPDATE … SET holder_id` would not notice.
CREATE FUNCTION refuse_tombstoning_a_held_name() RETURNS trigger
  LANGUAGE plpgsql AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM names WHERE label = NEW.label AND holder_id IS NOT NULL) THEN
    RAISE EXCEPTION 'label % is still held', NEW.label
      USING ERRCODE = 'check_violation',
            HINT = 'Clear names.holder_id in the same transaction. A tombstone '
                   'beside a live holder is two answers to one question.';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER tombstones_refuse_held
  BEFORE INSERT OR UPDATE ON tombstones
  FOR EACH ROW EXECUTE FUNCTION refuse_tombstoning_a_held_name();

-- --------------------------------------------------------------------------
-- The clock, readable in one place
-- --------------------------------------------------------------------------
-- What the sweeper reads.  A view rather than a query the sweeper carries,
-- because the release rule is a policy and a policy written into one program is
-- a policy the second program gets wrong.
--
-- **A citizen's name is not in here at all** — persistence is one of the things
-- citizenship buys (N-012), and the 30-day clock exists to stop the free tier
-- accumulating abandoned rows rather than to reclaim anything.
--
-- **A name whose holder's citizenship could not be confirmed is not in here
-- either.**  The clock does not run on an unreachable lookup, because N-013
-- makes a release irreversible: `tier` is what it was last known to be, and a
-- failed check writes nothing.
CREATE VIEW names_due_for_release AS
  SELECT n.label, n.last_used_at, n.holder_id
    FROM names n
    JOIN holders h ON h.id = n.holder_id
   WHERE h.tier = 'free'
     AND n.last_used_at < now() - INTERVAL '30 days'
     AND NOT EXISTS (SELECT 1 FROM tombstones t WHERE t.label = n.label);

-- The one write the resolution feed makes.  A function rather than an `UPDATE`
-- in three programs, and an overwrite rather than an append — N-028 again.
CREATE FUNCTION note_name_used(a_label text) RETURNS void
  LANGUAGE sql AS $$
  UPDATE names SET last_used_at = now() WHERE label = a_label;
$$;

COMMIT;
