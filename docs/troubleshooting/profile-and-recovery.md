# Profile and Recovery Troubleshooting

## Safety Rules

Never delete ownership, replace a profile with blank state, clear a healthy foreign lease, remove a replay barrier, regenerate an operation ID, retry a committed mutation under a new ID, or expose raw profile data in an issue or log.

Capture stable reason codes, revisions, operation IDs only when sanitized, profile and receipt hashes, encoded byte counts, retry counts, and environment identity. Keep credentials, session tokens, raw profiles, arbitrary player text, and unrelated player state private.

## Profile Does Not Load

Check the player `ProfileState` attribute and the client stable code.

| Code | Meaning | Safe response |
| --- | --- | --- |
| `profile.not_ready` | Acquisition is not complete. | Keep mutation controls disabled and retry bootstrap with a new request ID after the bounded wait. |
| `session.conflict` | Another healthy token owns the profile or the durable token changed. | Do not clear it. Confirm the other job state and wait for normal release or expiry. |
| `storage.unavailable` | Bounded retries failed or the shutdown deadline expired. | Keep the session read only. Preserve durable state and inspect service health and retry evidence. |
| `profile.malformed` | Strict migration or decode failed. | Quarantine the original bytes and reproduce with a sanitized fixture. Never create a replacement profile. |
| `profile.unsupported_schema` | Stored schema is newer than this server understands. | Stop writable play and deploy a compatible server or reviewed forward migration. |
| `profile.too_large` | Exact compact representation exceeds 1,500,000 bytes. | Block the write, preserve the previous durable revision, and optimize or shard without deleting data. |

## Migration Quarantine

1. Record the stable error and a hash of the original saved document.
2. Confirm `UpdateAsync` returned the same current value.
3. Reproduce with a sanitized fixture under the migration test harness.
4. Correct only the pure migration or strict decoder.
5. Prove repeated migration produces the same saved hash.
6. Rerun ownership, pending pack, receipt, size, session, shutdown, and isolated rejoin tests.

Do not normalize away an unknown value merely to pass validation.

## Session Collision

A healthy token is less than 120 seconds old. A second server must receive `session.conflict` and must not expose a writable snapshot.

For an expired token, obtain a fresh durable read, reconcile every pending pack and replay barrier, then atomically assign the new token. If reconciliation cannot prove safety, return read only state. Do not manually clear the token.

## Read Only Safe Mode

Safe mode follows retry exhaustion, token loss, malformed state, or shutdown. The client retains its last presentation snapshot but forces `writable = false`. Pack, deck, flag, and reward controls remain disabled.

Recovery requires a new verified acquisition or an operator corrected service condition. Do not change the client snapshot to writable without a server message carrying a writable authoritative snapshot.

## DataStore Throttling

The store retries at 250, 500, 1,000, 2,000, and 4,000 milliseconds before the sixth attempt, plus bounded jitter capped by the same maximum. Record attempts and delays.

During shutdown, do not begin a sleep that would cross the shared deadline. An incomplete release remains visible in the shutdown result and must be reconciled on the next acquisition.

## Pending Starter Pack Reopens

State `committed` means ownership and the exact result are durable but the reveal has not received a valid followup card interaction. Bootstrap should project the pending card IDs and the client should reopen the reveal.

The first successful equip of one result card changes the state to `acknowledged` in that deck transaction. If rejoin still shows `committed`, verify that the equip itself committed and that the request did not fail with stale state, wrong slot, foreign instance, lock, or response loss.

Never open another Starter Pack to recover presentation.

## Conflicting Request ID

`request.replay_conflict` means the request ID already committed with another operation kind or payload fingerprint. Preserve the original receipt and barrier. Return the conflict without mutation. The client must create a new request ID only for a genuinely new intent, not to repeat the original mutation.

## Impossible Ownership

Duplicate UIDs, a pending card referenced by two pack operations, missing owned references, changed provenance, foreign owner data, negative currency, an active deck reference to a missing card, or a receipt and barrier mismatch are quarantine conditions.

Stop writable play, hash the affected structures, preserve the original saved bytes, and reproduce with a sanitized fixture. Do not silently select one owner, drop one card, clear a deck slot, or rewrite provenance.

## Renderer Fallback

Missing or disabled presentation data should produce an unavailable layer and readable `Content Unavailable` status. It must not block ownership recovery or fabricate a valid content identity.

If bounded preload fails, the client records `PreloadState = degraded` and emits `P002-CLIENT-005`. Verify that only the two Phase 002 fixture models are requested, that Rojo synchronized both source models, and that the interface remains readable with static materials.

## Shutdown Recovery

Shutdown first closes new transaction entry, drains active operations for the remaining wall time, flushes dirty profiles, and releases matching session tokens. Inspect:

```text
Phase002ShutdownState
Phase002ShutdownTransactionsRemaining
Phase002ShutdownProfilesRemaining
```

An incomplete state is not permission to clear locks. Start the next isolated server, allow expired lease reconciliation, retry the same operation identities, and compare the exact stable profile, receipt, pending result, ownership, deck, and balance hashes.
