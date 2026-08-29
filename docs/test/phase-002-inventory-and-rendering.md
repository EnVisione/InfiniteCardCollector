# Phase 002 Inventory and Renderer Tests

## Purpose

This procedure verifies card and Joker identity, provenance, ownership, discovery, deck invariants, presentation projection, shared renderer semantics, component pooling, binder virtualization, bounded preload, readable fallback, and low graphics behavior.

## Commands

```console
stylua --check .
selene .
lune run test
lune run phase002-evidence
rojo build default.project.json --output build/infinite-card-collector.rbxlx
```

## Ownership and Deck Matrix

| Test | Required behavior |
| --- | --- |
| `P002-TEST-014-inventory-provenance-and-deck-invariants` | Collision retry, immutable provenance, owner checks, all 52 stable slots, wrong slot rejection, occupied slot rejection, duplicate active instance rejection, unequip, and permanent discovery. |
| `P002-TEST-015-starter-pack-atomic-recovery` | Exactly five server generated cards, five unique slots, pending identity collision coverage, result retention, acknowledgement, and rejoin conservation. |
| `P002-TEST-019-guided-formation-authority-and-reward` | Formation input originates from current owned instances, not client supplied card properties. |
| `P002-TEST-024-collection-joker-and-removal-protection` | Card and Joker collision checks, permanent discovery, monotonic best records, favorite and active deck removal protection, last copy protection, trade lock projection, and compact discovery round trip. |

For every creation fixture, compare the count before and after, the UID set, current owner, identity ID, slot key, provenance, discovery bit, pending references, and receipt. A forced collision must never overwrite an existing card, Joker, or pending result.

Deck verification enumerates the Cartesian product of 13 rank IDs and 4 suit IDs. Each expected key must exist exactly once. Equip changes only `activeDeck`; it cannot alter ownership, provenance, Edition, Grade, Tier, Trait, discovery, or pending result.

## Renderer Matrix

| Test | Required behavior |
| --- | --- |
| `P002-TEST-017-renderer-layers-and-accessible-fallbacks` | Fixed eight layer order, lock and trade status, readable symbols and text, 2D and 3D semantic equality, low graphics static state, and neutral missing content fallback. |
| `P002-TEST-018-renderer-pooling-and-virtualization` | Component reset and reuse, foreign release rejection, visible range bounds, a 10,000 card binder fixture, and two item preload maximum. |
| `P002-TEST-020-projection-privacy-and-client-authority` | Projection removes owner, provenance, session, receipts, and raw profile authority. |
| `P002-TEST-025-deterministic-evidence-packet` | Normal and static view model hashes, adapter equivalence, virtualization count, layer order, and preload fixture contract. |

The required layer order is:

```text
deck_set
suit
rank
edition
grade
power_tier
trait
status
```

The current bounded preload contains only `ClassicFrameFixture` and `ClassicStarterPackFixture`. The 10,000 item deterministic binder window renders 17 cells for the frozen viewport, offset, cell height, and overscan fixture.

## Studio Visual Procedure

1. Confirm the Edit DataModel contains `ServerStorage.Assets.CardFrames.ClassicFrameFixture` with three parts and `ServerStorage.Assets.PackModels.ClassicStarterPackFixture` with two parts.
2. Start local play through the qualified Vinegar Studio connection.
3. Confirm the blank snapshot displays `PackModel3D`, the accessible label `Classic Starter Pack`, `PreloadState = ready`, and zero binder cells.
4. Open the Starter Pack and confirm five rows plus a `CardModel3D` using eight semantic layers.
5. Confirm the reveal is visibly marked pending before the first valid deck interaction and acknowledged after it.
6. Confirm 2D rows and the 3D preview describe the same rank, suit, Edition, Grade, and Tier.
7. Apply the test only low graphics fixture through the production view model and 3D adapter. Confirm `lowGraphics = true`, `animated = false`, `flashing = false`, eight layers, and readable card identity.
8. Capture normal and static low graphics screenshots.
9. Inspect the console. It must be empty.
10. Stop play and confirm Studio returns to Edit mode.

Current local capture IDs are `phase002_classic_pack_fixture`, `phase002_normal_renderer_clean`, and `phase002_static_low_graphics`.

## Failure Handling

A missing layer, disabled record, or missing fixture must show a neutral readable placeholder and must not invent ownership. A preload failure sets the client attribute to `degraded` and emits only the bounded diagnostic `P002-CLIENT-005`.

If pool creation, virtualization, or low graphics semantics change, rerun the deterministic renderer packet, local Studio normal and static captures, artifact inspection, and isolated recovery workflow.
