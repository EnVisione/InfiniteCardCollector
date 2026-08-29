# Phase 002 Blank Account Recovery Workflow

## Purpose

This is the highest fidelity Phase 002 workflow. It proves that profile creation, Starter Pack ownership, reveal state, deck edits, guided reward, shutdown, session release, and rejoin recover the exact committed state.

Local memory Studio execution is useful preflight but cannot satisfy the isolated Roblox DataStore gate.

## Environment Record

Before the run, record:

* Source commit.
* Branch.
* Catalog, configuration, action, envelope, profile schema, codec, receipt, renderer, and fixture versions.
* Vinegar, Wine, Roblox Studio deployment, Rojo plugin, Rojo CLI, Rokit, StyLua, Selene, and Lune versions.
* Sanitized universe ID, place ID, place version, job identity fingerprint, and DataStore API permission state.
* Test account ID fingerprint. Do not store the raw account session or credential.

The isolated experience must be owner controlled, nonproduction, noncommerce, and unavailable to the public. Enabling Studio API access or publishing a test place requires the owner's exact authorization.

## Frozen Expected State

The deterministic reference performs these durable operations:

1. Blank acquire at revision 0.
2. Starter Pack commit at revision 1 with five cards and pending state `committed`.
3. Four deck equips at revisions 2 through 5. The first matching card interaction moves the pending reveal to `acknowledged`.
4. Guided Monosuit reward at revision 6.
5. Release and rejoin with the same stable gameplay state.

The exact deterministic fixture uses IDs `evidence_card_01` through `evidence_card_05`. A real Studio run uses opaque runtime IDs, so compare the sorted UID set and hashes captured from that same run rather than expecting these fixture strings.

## Interruption Matrix

Run one clean workflow, then repeat with an interruption at every boundary:

| Boundary | Before commit expectation | After commit expectation |
| --- | --- | --- |
| Profile creation | No writable profile is exposed. | One version 1 profile with revision 0 and one lease. |
| Starter mutation | No cards, claim, receipt, barrier, or pending result. | Five owned cards, revision 1, one receipt, one barrier, pending state `committed`. |
| Starter response | Retry cannot create cards. | Same operation returns the exact stored result. |
| Reveal acknowledgement | Rejoin reopens committed result. | First valid equip stores `acknowledged` in the same deck transaction. |
| Deck mutation | Prior deck map remains. | One additional valid slot, one revision, one receipt, no ownership change. |
| Deck response | Retry cannot equip twice or advance revision. | Same operation returns exact stored result. |
| Guided reward mutation | Balance and revision remain unchanged. | One configured reward, one revision, one receipt, one barrier, one calculation trace. |
| Guided response | Retry cannot pay twice. | Same operation returns the exact stored result. |
| Dirty flush | Last persisted revision remains authoritative. | Staged state is durable before lease release. |
| Shutdown drain | New transactions are rejected. | All completed transactions persist and matching leases clear within 25 seconds. |
| Session collision | Second healthy writer is rejected. | Expired lease reconciles pending state before reassignment. |

## Comparison Packet

At each checkpoint record only sanitized hashes and declared values:

* Stable gameplay profile hash with volatile heartbeat, job, token, and last seen fields excluded.
* Saved representation hash and encoded byte count.
* Revision.
* Sorted UID set hash.
* Provenance hash.
* Discovery hash.
* Active deck hash.
* Pending pack state, catalog version, card ID hash, and result reference hash.
* Balance map hash.
* Full receipt and replay barrier hashes.
* Guided calculation trace hash.
* Writable state and sanitized session fingerprint.

The final preleave and postrejoin stable gameplay profile hashes must be identical. Card conservation must remain five. Active deck count must remain four. Reward replay must not change Cash or revision.

## Hostile Checks During the Workflow

Submit and verify no mutation for:

* Stale profile revision.
* Reused request ID with another valid payload.
* Unknown payload field.
* Foreign card UID.
* Duplicate submitted UID.
* Wrong deck slot.
* Invalid guided mode.
* Request above its token bucket.
* Second healthy session.

Every correlatable rejection must preserve request ID and action ID. Logs must contain only stable action and reason codes with bounded retry or stage context.

## Local Studio Preflight

The local memory workflow currently passes opening, committed reveal, acknowledgement, four deck edits, Monosuit reward, exact replay, valid replay conflict, stale state, malformed unknown field correlation, 2D and 3D rendering, static low graphics rendering, and an empty console.

Because local play resets memory on restart, it does not prove DataStore rejoin, real `UpdateAsync` throttling, lease survival across server jobs, or isolated shutdown recovery.

## Completion Rule

Do not mark `P002-TASK-014` complete until the owner authorized isolated experience passes every interruption row, the comparison packet matches, the console and logs are clean, and no public access, commerce, trading, or unrelated experience state changed.
