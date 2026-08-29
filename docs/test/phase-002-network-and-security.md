# Phase 002 Network and Security Tests

## Purpose

This procedure verifies `P002-TASK-002`, `P002-TASK-003`, and the network portions of `P002-TASK-011` through `P002-TASK-014`. It covers the complete 25 action launch registry. Eleven routes are available after the Phase 003 extensions and the remaining routes stay fail closed.

## Prerequisites

Run from the repository root with the Phase 000 pinned tool environment. Confirm the current branch is the active Phase 002 branch and that `docs/plan/goal.md` has SHA 256 `fbe125681fc52b42131aa7aa1f4f61902d33c7912adc982ebcb7dbd87cff2f69`.

## Deterministic Commands

```console
stylua --check .
selene .
lune run test
lune run phase002-evidence
```

The full test run must report 65 passed and 0 failed. The relevant named cases are:

| Test | Coverage |
| --- | --- |
| `P002-TEST-001-action-and-error-registries` | Registry and error versions, 25 unique actions, frozen schemas, available handler coverage, and 54 declared error codes. |
| `P002-TEST-002-envelope-happy-paths` | Valid bootstrap, pack, deck, Formation, and binder envelopes. |
| `P002-TEST-003-envelope-and-schema-rejection` | Unknown fields, missing fields, malformed IDs, wrong types, integer bounds, and action specific schema rejection. |
| `P002-TEST-004-envelope-resource-limits` | Depth, node, encoded byte, cyclic value, invalid key, and nonfinite number rejection. |
| `P002-TEST-005-token-bucket-boundaries` | Exact capacity, depletion, refill, retry delay, user isolation, action isolation, and user cleanup. |
| `P002-TEST-006-gateway-order-and-fail-closed` | Validation before rate and route work, unavailable actions, profile readiness, writable state, authorization, missing handlers, protected calls, and safe correlation. |
| `P002-TEST-020-projection-privacy-and-client-authority` | Session, receipt, provenance, and raw profile redaction plus stale, duplicate, malformed, read only, and maintenance client state. |
| `P002-TEST-021-complete-action-hostile-and-rate-matrix` | One valid boundary fixture and one hostile fixture for every registered action plus every bucket boundary. |

## Required Assertions

For each action, verify all of these outcomes:

1. The valid minimum payload reaches its declared policy.
2. An unknown field returns `network.unknown_field`.
3. A wrong scalar type returns `network.type_invalid`.
4. A value below or above its bound returns `network.bounds_invalid`.
5. A collection below or above its bound returns `network.bounds_invalid`.
6. A nonfinite number returns `network.number_nonfinite` before service routing.
7. The first request above bucket capacity returns `network.rate_limited` with a bounded retry delay.
8. An unavailable action returns `feature.unavailable` and never invokes a service.
9. A profile required action returns `profile.not_ready` before authorization when no session is ready.
10. A writable action returns `profile.read_only` when the session is in safe mode.
11. A denied player returns `permission.denied`.
12. A route exception or malformed route result returns `internal.fail_closed`.

Every rejection with a syntactically safe request ID and action ID must echo both fields. An invalid request ID must not be reflected.

## Studio Correlation Check

In the qualified Vinegar Studio session, start local play and submit one envelope with a valid request ID but an extra `instanceId` field on `deck.unequip_card`.

Expected response:

```text
ok = false
code = network.unknown_field
action = deck.unequip_card
requestId = the original safe request id
```

Then reuse one committed Formation request ID with another otherwise valid payload. Expected response is `request.replay_conflict`, with no balance or revision change.

Inspect the client snapshot and console. It must not contain the session token, job ID, raw profile, receipt map, replay barrier, owner ID, provenance, arbitrary client text, another player inventory, or hidden server trace fields.

## Failure Handling

Do not weaken a schema, raise a collection bound, skip rate limiting, reorder validation, or expose internal details to make a negative fixture pass. Correct the lowest validation or routing boundary, then rerun all network, client authority, transaction, Studio, and isolated recovery checks.

An unavailable isolated place does not waive these deterministic checks. A passing local hostile matrix does not replace the isolated Roblox workflow.
