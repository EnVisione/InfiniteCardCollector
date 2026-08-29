# Phase 002 Runtime Architecture

## Status and Scope

Phase 002 implements the first local playable and recoverable vertical slice. A blank profile can open one Classic Starter Pack, receive five server generated card instances, acknowledge the saved reveal through the first valid deck interaction, equip cards, submit one guided Formation, receive one durable reward, and render the resulting authoritative state in 2D and 3D.

The local Vinegar Studio path is verified with in memory storage. The deterministic profile, transaction, migration, inventory, network, renderer, and shutdown suites pass. Isolated Roblox DataStore interruption and rejoin evidence remains mandatory before Phase 002 can integrate.

This phase does not implement general packs, Joker equip, Arcana, Grade Ink, timed Formation Rush rounds, tasks, duels, trading, purchases, analytics, or public release. Their network IDs were reserved in this phase and are enabled by later phase extensions.

## Runtime Topology

The Rojo project maps these boundaries:

| Roblox boundary | Repository source | Ownership |
| --- | --- | --- |
| `ReplicatedStorage.Shared` | `src/shared/` | Immutable catalogs, configuration, math, network contracts, profile schema, serializer, and renderer view model. |
| `ServerScriptService.Server` | `src/server/` | Profiles, storage adapters, transactions, inventory, deck, packs, Formation orchestration, network routing, and lifecycle. |
| `StarterPlayerScripts.Client` | `src/client/` | Authoritative message state, intent submission, 2D and 3D adapters, component pools, preload bounds, virtualization, and the local slice interface. |
| `ServerStorage.Assets.CardFrames` | `default.project.json` | Server controlled Classic card fixture. |
| `ServerStorage.Assets.PackModels` | `default.project.json` | Server controlled Classic Starter Pack fixture. |
| `StarterGui.App.AppRoot` | `default.project.json` | Responsive screen root populated by `ClientApp`. |

`Bootstrap.server.luau` first preserves the Phase 001 shared calculation checks, then starts `Phase002Runtime`. The runtime publishes the three sanitized Deck Set card frame fixtures, their three neutral fallback fixtures, and their three pack fixtures to `ReplicatedStorage.PresentationAssets`, creates one `ClientAction` and one `ServerMessage` remote, chooses its storage adapter, constructs services, attaches player lifecycle and heartbeat work, and registers a bounded shutdown callback.

`ClientBootstrap.client.luau` preserves the Phase 001 client projection check, then starts `ClientApp`. The application requests bootstrap state, displays only server projections, and enables mutation controls only while the snapshot is writable.

## Storage Selection

The runtime selects storage from Roblox identity, not an environment variable.

| Runtime identity | Adapter | Behavior |
| --- | --- | --- |
| Studio with `game.GameId == 0` | `MemoryProfileAdapter` | Isolated local memory. Restarting play starts a blank profile. No Roblox DataStore is contacted. |
| Nonzero universe ID | `RobloxProfileAdapter` | `DataStoreService:GetDataStore("infinite_card_collector_profile_v1")` through `UpdateAsync`. |

All keys use the internal prefix `profile_v1:` followed by the numeric user ID string. Gameplay services consume `ProfileStore` and `InventoryStore`; they do not call DataStore directly or depend on the compact saved layout.

## Network Compatibility Surface

The action and envelope versions are 1. Every envelope contains exactly `version`, `action`, `requestId`, and `payload`. Request IDs contain 16 through 64 ASCII letters, digits, or underscores. Stable IDs use lowercase letters, digits, underscores, periods, and colons within the field specific bound.

The complete registry contains 25 actions. Eleven routes are currently available. The other 14 preserve their launch schemas and return `feature.unavailable` after validation and rate limiting. Phase 003 adds earned Deck Set opening, saved Joker or Arcana choices, server-authoritative Grade Ink progression, one-card Arcana application, and protected card salvage over the original network contract.

| Action | Mode | Profile | Writable | Rate bucket | Phase 002 route |
| --- | --- | --- | --- | --- | --- |
| `bootstrap.request` | Read only | No | No | 4, plus 1 every 3 seconds | Available. |
| `pack.open` | Durable idempotent | Yes | Yes | 2, plus 1 every 5 seconds | Classic Starter Pack and earned Deck Set Packs. |
| `pack.choose` | Durable idempotent | Yes | Yes | 2, plus 1 every 5 seconds | Saved Joker and Arcana offer choices. |
| `deck.equip_card` | Durable idempotent | Yes | Yes | 6, plus 2 every 3 seconds | Available. |
| `deck.unequip_card` | Durable idempotent | Yes | Yes | 6, plus 2 every 3 seconds | Available. |
| `joker.equip` | Durable idempotent | Yes | Yes | 4, plus 1 every 4 seconds | Unavailable. |
| `joker.unequip` | Durable idempotent | Yes | Yes | 4, plus 1 every 4 seconds | Unavailable. |
| `arcana.apply` | Durable idempotent | Yes | Yes | 2, plus 1 every 5 seconds | Available through ArcanaService. |
| `grade.apply_ink` | Durable idempotent | Yes | Yes | 2, plus 1 every 5 seconds | Available through ProgressionService. |
| `inventory.set_flags` | Durable idempotent | Yes | Yes | 8, plus 2 every 2 seconds | Available. |
| `inventory.salvage` | Durable idempotent | Yes | Yes | 4, plus 1 every 3 seconds | Available through ProgressionService. |
| `formation.start` | Ephemeral idempotent | Yes | No | 3, plus 1 every 5 seconds | Unavailable. |
| `formation.redraw` | Ephemeral idempotent | Yes | No | 4, plus 1 every 3 seconds | Unavailable. |
| `formation.submit` | Durable idempotent | Yes | Yes | 6, plus 2 every 2 seconds | Guided Classic mode only. |
| `task.start` | Ephemeral idempotent | Yes | No | 4, plus 1 every 4 seconds | Unavailable. |
| `task.action` | Durable idempotent | Yes | Yes | 8, plus 2 every 2 seconds | Unavailable. |
| `duel.invite` | Ephemeral idempotent | Yes | No | 2, plus 1 every 8 seconds | Unavailable. |
| `duel.respond` | Ephemeral idempotent | Yes | No | 3, plus 1 every 5 seconds | Unavailable. |
| `duel.submit` | Ephemeral idempotent | Yes | No | 6, plus 2 every 2 seconds | Unavailable. |
| `trade.request` | Ephemeral idempotent | Yes | No | 2, plus 1 every 8 seconds | Unavailable. |
| `trade.respond` | Ephemeral idempotent | Yes | No | 3, plus 1 every 5 seconds | Unavailable. |
| `trade.set_offer` | Ephemeral idempotent | Yes | No | 4, plus 1 every 2 seconds | Unavailable. |
| `trade.set_ready` | Ephemeral idempotent | Yes | No | 4, plus 1 every 2 seconds | Unavailable. |
| `trade.cancel` | Ephemeral idempotent | Yes | No | 4, plus 1 every 2 seconds | Unavailable. |
| `binder.page` | Read only | Yes | No | 10, plus 5 every second | Available with `newest` ordering. |

The generated action report records every exact payload field, integer and collection bound, encoded payload bound, maximum depth, maximum node count, rate bucket, authority state, and handler ID. It is regenerated with:

```console
lune run phase002-evidence
```

### Validation Order

`NetworkGateway` applies this order:

1. Validate the global envelope shape, version, action syntax, request identity, payload structure, finite numbers, depth, nodes, and estimated encoded bytes.
2. Resolve the registered action and validate its exact payload schema, required fields, optional fields, scalar bounds, collection bounds, and unknown fields.
3. Consume the action specific token bucket.
4. Reject an unavailable action.
5. Check profile readiness and writable state.
6. Check the current player authorization boundary.
7. Route through a protected call and validate the route result shape.
8. Return the original safe request ID and action ID on every correlatable response, including validation rejection.

The stable error registry contains 54 codes. Phase 003 adds earned pack, progression, and Arcana errors without changing the existing action envelope. Display text is not part of this machine contract. A malformed request cannot reach a service, and a service exception becomes `internal.fail_closed` without exposing internal data.

## Profile Version 1

`ProfileSchema` is the readable domain model. `ProfileCodec` converts it to a compact saved representation. Service code never reads compact keys.

The domain profile contains versions, revision, timestamps, active seconds, eight currency balances, card and Joker maps, Arcana stacks, reserved Souls state, active loadouts, permanent discovery, best records, pity, pending packs, boosts, daily state, tutorial state, trade history, processed receipts, replay barriers, player settings, moderation state, and an optional session lease.

Strict validation enforces:

* Exact top level and nested field sets.
* Finite nonnegative integers where required.
* Dense unique arrays.
* Existing ownership references for deck cards, active Jokers, pending pack cards, and the active Soul.
* Structural card identity consistency. Every slot key equals its stored rank and suit, and every content identity equals its stored Deck Set and slot key. Unknown owned content can still use the neutral fallback, but contradictory identity fields are malformed.
* One pending pack record for each acquired card instance.
* Exact card, Joker, provenance, flag, lock, session, settings, tutorial, daily, receipt, and replay barrier shapes.
* Receipt version 1, operation kind, result reference, successful bounded result, revision, and matching replay barrier.
* At most 256 full receipts in canonical order while durable replay barriers remain after compaction.

The compact codec sorts currency pairs and all permanent discovery IDs. It rejects unknown compact fields, duplicate or unsorted discovery IDs, and malformed pair arrays. `ProfileCodec.measure` uses the exact canonical saved representation.

The profile policy warns at 1,000,000 bytes and blocks writes above 1,500,000 bytes. A blocked write leaves the durable value and writable in memory revision unchanged.

## Session and Persistence Lifecycle

Every acquired profile receives one opaque session token plus job ID, place version, and heartbeat time. The token is never projected to clients.

`ProfileStore` uses `UpdateAsync` for acquisition, heartbeat, immediate transaction commit, dirty flush, and release. Each durable write compares both the token and the persisted revision. A healthy foreign token returns `session.conflict`. An expired token runs the pending operation reconciler before atomic reassignment.

Retry uses at most six attempts, starting at 250 milliseconds and doubling up to 4,000 milliseconds, with deterministic bounded jitter supplied by the runtime. Retry exhaustion closes the mutation gate and retains the local session in read only safe mode. It does not replace a malformed document with a blank profile.

Ordinary staged changes may wait 30 seconds before flush. Pack, deck, flag, and guided reward operations use the immediate transaction path. Shutdown creates one 25 second wall deadline, stops new transactions, drains the transaction boundary for the remaining time, flushes dirty profiles, and releases session tokens within the same deadline. Incomplete drain or release state is recorded on sanitized server attributes.

## Transaction Contract

`TransactionService` serializes one mutation per profile. The durable operation contains a request identity, operation kind, normalized payload, expected revision, optional result reference, and an apply function owned by the route.

Before mutation, the service computes a canonical fingerprint from the operation kind and payload. A matching full receipt returns the exact stored result with `replayed = true`. A matching compacted barrier returns its stable code, revision, and result reference. A reused operation ID with another fingerprint returns `request.replay_conflict` without mutation.

A successful commit records:

* Receipt version 1.
* Operation kind.
* Canonical fingerprint.
* Exact successful result including its committed revision.
* Stable result reference.
* A matching durable replay barrier.

The profile revision advances once. The entire profile is persisted before success is returned. Failures before commit leave revision, ownership, balances, pending results, and receipts unchanged. Failures after commit return a bounded committed failure, and the same operation ID recovers the exact result.

An internal cyclic result or commit time profile validation exception fails closed without exposing the error, clears the per profile transaction lane, preserves the durable profile, and permits the next independently valid operation. This protects recovery from an implementation defect without converting malformed state into a successful receipt.

Failure injection covers `before_validation`, `before_apply`, `after_apply`, `before_receipt`, `before_commit`, `after_commit`, and `before_response`.

## Inventory, Collection, and Deck

`InventoryStore` is the current inventory boundary. Launch still stores inventory in one profile document, but pack, deck, Formation, projection, and collection code consume the interface rather than assuming that physical layout.

Cards and Jokers receive opaque server generated IDs. Generation checks current card and Joker ownership plus all pending pack identities and retries at most 16 candidates. Creation records immutable origin type, origin ID, creation time, and instance version.

Collection discovery is permanent history. Removing an owned instance does not remove discovery. Best records increase monotonically.

The removal policy protects favorite, wishlist, equipped, locked, and last copy cards. Card projection exposes only presentation identity, slot, Edition, Grade, Tier, optional Trait, favorite, wishlist, general lock, and trade lock status. It excludes owner IDs and provenance.

`DeckService` precomputes the exact 52 rank and suit slot keys. Equip requires an owned, eligible, enabled card whose stable slot matches the requested slot. It rejects an occupied slot, duplicate active instance, foreign instance, lock, disabled content, wrong slot, and stale profile revision. Equip and unequip change references only.

## Starter Pack Recovery

The free Starter Pack is an ordinary `pack.open` transaction. It selects one Classic suit and five consecutive ranks from server random state, creates exactly five collision checked instances, updates discovery, stores the catalog version and exact canonical result reference, marks the tutorial claim, and persists one `committed` pending pack before returning the reveal.

Replaying the same operation returns the stored result. A second operation ID cannot claim another Starter Pack. Rejoining while the pending state is `committed` returns the five card IDs so the client can reopen the reveal.

The frozen launch action inventory has no separate acknowledgement action. The first successful `deck.equip_card` interaction with a card from the saved result atomically moves that pending state to `acknowledged`. Closing before that interaction leaves it committed and recoverable. This keeps acknowledgement durable without adding a hidden or incompatible remote.

## Guided Formation Reward

The Phase 002 Formation route accepts exactly four owned unique card instances, the `guided_classic` mode ID, one round ID, and the current profile revision. `GuidedFormationService` projects the authoritative owned instances into the frozen Phase 001 calculation contract. It cannot save a profile directly.

A valid calculation applies its configured Cash reward inside the same transaction that stores the receipt and replay barrier. Duplicate, foreign, locked, invalid count, no match, stale revision, response loss, and request conflict cases fail without duplicate reward.

## Renderer and Client Authority

`CardViewModel` is the single presentation model for both adapters. Its fixed order is Deck Set, suit, rank, Edition, Grade, Power Tier, Trait, and status. Status includes readable symbols and text for general lock, trade lock, favorite, wishlist, new, and unavailable content.

Missing or disabled presentation data creates a neutral readable placeholder and `Content Unavailable` status. It does not invent ownership or hide the failure.

`CardRenderer2D` and `CardRenderer3D` preserve identical semantic layers and accessible names. The client resolves each enabled card through the registered Deck Set visual system and clones its mapped frame fixture from the bounded presentation folder. Unknown or disabled data uses the matching neutral fallback fixture. `ComponentPool` recycles card and pack models. `VirtualizedBinder` renders only the visible window with overscan. `PreloadManifest` still permits exactly the Classic card and Starter Pack fixtures because the complete dynamic preload policy is owned by the remaining Phase 003 presentation work.

Low graphics, reduced motion, and reduced flash independently disable nonessential animation or flashing without removing semantic layers. The current Classic fixture uses a static material fallback and readable labels.

`ClientState` accepts only correlated server messages and authoritative snapshots. Lower revision snapshots cannot replace newer state. Duplicate results remain stable. Read only, session conflict, storage unavailable, malformed profile, and not ready messages remove writable authority from the retained presentation snapshot. The client never infers a successful pack, deck edit, or reward.

## Verification and Recovery

Use the focused procedures:

* [Network and security tests](../test/phase-002-network-and-security.md)
* [Profile and transaction tests](../test/phase-002-profile-and-transactions.md)
* [Inventory and renderer tests](../test/phase-002-inventory-and-rendering.md)
* [Blank account recovery workflow](../test/phase-002-recovery-workflow.md)
* [Profile and recovery troubleshooting](../troubleshooting/profile-and-recovery.md)
* [Phase 002 evidence](../verification/phase-002-recoverable-vertical-slice.md)

The deterministic rerun is:

```console
stylua --check .
selene .
lune run test
lune run phase002-evidence
rojo build default.project.json --output build/infinite-card-collector.rbxlx
```

The complete repository gate remains:

```console
lune run ci
```

Do not interpret local memory recovery as isolated DataStore proof. Phase 002 cannot integrate until the owner authorized isolated universe workflow passes all required interruption, shutdown, session collision, and rejoin comparisons.
