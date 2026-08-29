# Phase 002 Profile and Transaction Tests

## Purpose

This procedure verifies profile schema version 1, the compact saved representation, pure migrations, single writer sessions, retry and safe mode behavior, exact once transactions, receipt compaction, replay barriers, and bounded shutdown.

## Commands

```console
stylua --check .
selene .
lune run test
lune run phase002-evidence
```

Generated reports are written under ignored `build/phase002/`. Their tracked SHA 256 contract is `tests/phase002/expected-hashes.json`.

## Profile and Migration Matrix

| Test | Required behavior |
| --- | --- |
| `P002-TEST-007-profile-blank-round-trip-and-size` | Blank defaults, deterministic compact round trip, strict unknown field rejection, card slot and content identity consistency, discovery ordering, realistic warning crossing, realistic block crossing, blocked write preservation. |
| `P002-TEST-008-profile-migrations-repeat-and-preserve` | Legacy version 0 to version 1 migration, currency and card preservation, repeated normalization equality, malformed quarantine, unsupported future version rejection. |
| `P002-TEST-009-canonical-value-determinism` | Map order independence, isolated copies, nonfinite rejection, and cycle rejection. |
| `P002-TEST-010-profile-session-lifecycle` | First acquisition, healthy collision rejection, heartbeat, expired lease reconciliation, replaced writer closure, release, and durable session removal. |
| `P002-TEST-011-profile-quarantine-and-storage-failure` | Malformed byte preservation, no blank overwrite, bounded storage retry, and no partial creation. |
| `P002-TEST-022-profile-retry-dirty-flush-and-shutdown` | Exact retry schedule, timed dirty flush, shutdown persistence, read only safe mode, retained failed session, shared deadline, and lock release accounting. |

Use these exact size boundaries:

| Boundary | Classification |
| ---: | --- |
| Less than 1,000,000 bytes | Healthy. |
| 1,000,000 through 1,500,000 bytes | Warning. |
| More than 1,500,000 bytes | Blocked. |

The realistic deterministic fixture currently crosses warning at 2,300 cards and 1,021,141 bytes. It crosses the publication block at 3,400 cards and 1,506,780 bytes. The last measured warning fixture before the block is 1,462,418 bytes. These are evidence values for the current schema, not product capacity promises.

## Receipt and Replay Matrix

| Test | Required behavior |
| --- | --- |
| `P002-TEST-012-idempotent-transaction-and-rejoin` | One commit, one revision, exact replay, conflicting fingerprint rejection, stale revision rejection, persisted receipt, versioned receipt validation, and receipt to barrier equality. |
| `P002-TEST-013-transaction-failure-and-compaction` | Per profile serialization, receipt retention, compacted replay barrier, old replay recovery, old conflicting replay rejection, cyclic result containment, commit time schema failure containment, and transaction lane recovery. |
| `P002-TEST-015-starter-pack-atomic-recovery` | Five cards, unique slots, exact result reference, committed reopen, reveal acknowledgement, no second claim, no duplicate retry, rejoin conservation. |
| `P002-TEST-019-guided-formation-authority-and-reward` | Owned card projection, configured score, one Cash reward, duplicate rejection, and no direct save path. |
| `P002-TEST-023-transaction-stage-failure-and-response-recovery` | Every precommit and postcommit failure stage plus bounded transaction drain. |
| `P002-TEST-025-deterministic-evidence-packet` | Tracked report hashes, exact final and rejoin state equality, and realistic size evidence. |

Every full receipt must contain version 1, operation kind, canonical fingerprint, successful bounded result, result reference, and committed revision. Its replay barrier must match all compatibility fields. Full receipt order is dense, unique, and limited to 256. A compacted operation retains its durable barrier.

## Failure Injection

Inject each stage independently:

```text
before_validation
before_apply
after_apply
before_receipt
before_commit
after_commit
before_response
```

The first five stages must leave durable and in memory revision, currency, ownership, pending state, receipt, and replay barrier unchanged. The last two stages may report a bounded committed failure. Repeating the same operation identity must return the exact committed result without another revision or reward.

## Shutdown Procedure

1. Acquire one writable profile.
2. Stage a deterministic change without flushing.
3. Begin shutdown and reject new transactions.
4. Drain active transactions within the shared 25 second wall deadline.
5. Force dirty persistence.
6. Clear the matching session token through `UpdateAsync`.
7. Report released and remaining profiles.

If retry would cross the deadline, do not sleep past it. Return `storage.unavailable`, retain the unreleased session evidence, and keep mutation authority closed.

## Recovery Rules

Never delete a malformed document, clear a foreign healthy lock, change an operation ID, remove a replay barrier, or replace an oversized profile with blank state. Preserve the durable bytes, close writable play, record only sanitized codes and hashes, correct the lowest migration or storage boundary, and rerun the entire dependent matrix.
