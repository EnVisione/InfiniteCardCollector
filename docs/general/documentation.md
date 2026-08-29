# Technical Overview

## Status

InfiniteCardCollector is a Roblox game project with integrated Phase 000, Phase 001, and Phase 002 foundations and an active Phase 003 launch collection and interface phase. The repository contains deterministic development commands, a verified Linux tool bootstrap, reproducible Rojo generation, exact launch catalogs, versioned configuration, pure calculations, a versioned network boundary, compact profiles, session leases, exact once transactions, owned cards, a 52 slot deck, one recoverable Starter Pack, one guided reward, and a minimal authoritative client interface. It is playable for verification but is not published or ready for players.

## Product Boundary

The game is an original active card collector. A player owns one permanent deck with fifty two rank and suit slots, equips up to five deck wide Jokers, and earns cards through active Formation Rush rounds and short task stations. Passive and offline rewards supplement active play. Direct trading is planned but must remain feature flagged until item duplication, disconnect, and storage recovery tests pass.

The launch contract is limited to three Deck Sets. The complete content destination is preserved separately so launch implementation does not need to support all content at once.

## Source of Truth

Use this order when documents disagree:

1. The current owner request.
2. The [initial release plan](plan.md), its registered phase plans, manifest, and handoff.
3. The [complete future plan](full_plan.md) for explicitly deferred scope.
4. The [launch foundation](../implementation/launch-foundation.md) for the intended first release.
5. The [content catalog](content-catalog.md) for stable content names, IDs, counts, and first balance targets.
6. The [product vision](product-vision.md) for the long term destination.
7. Implemented source and passing tests after implementation begins.
8. This technical overview and the root README.

Phase 000, Phase 001, and Phase 002 are integrated and signed. Phase 003 is active on its sequential phase branch. Its inherited deterministic and isolated Vinegar Studio recovery paths pass. The Phase 003 entry packet freezes the current plan identities, launch counts, toolchain, isolated environment, artifact, and evidence topology before content implementation. The future plan does not authorize deferred content for the initial release.

## Implemented Foundation

The repository pins Rojo v7.7.0, Rokit v1.2.0, StyLua v2.5.2, Selene v0.31.0, and Lune v0.10.5. `rokit.toml` is the managed tool resolution contract. `config/tool-artifacts.json` records the selected Linux and Windows artifacts, archive and executable hashes, licenses, provenance, reviewed command surfaces, and security dispositions.

The platform bootstrap scripts download archives to temporary storage, verify size, SHA 256, SHA 512, and archive layout before extraction, then seed Rokit with the verified binaries. `lune run verify-tools` independently checks the resolved path, exact executable bytes, version output, platform artifact, and provenance fields. It rejects a missing, changed, or PATH shadowed executable.

`default.project.json` maps the foundation and Phase 002 slice:

- `src/shared/` becomes `ReplicatedStorage/Shared`.
- `src/server/` becomes `ServerScriptService/Server`.
- `src/client/` becomes `StarterPlayer/StarterPlayerScripts/Client`.
- `ServerStorage/Assets` contains one Rojo mapped Classic card frame fixture and one Classic Starter Pack fixture while reserving future asset families.
- `StarterGui/App/AppRoot` is a scale based transparent GUI root.

The shared bootstrap contract contains immutable foundation metadata. The server and client bootstraps preserve the Phase 001 authoritative and projected calculation comparison. The server then starts the Phase 002 runtime, and the client starts the minimal application. The runtime creates one action remote, one message remote, profile and transaction services, inventory and deck services, the Starter Pack and guided Formation routes, player lifecycle, heartbeat work, bounded shutdown, and sanitized presentation fixtures. Trading, purchases, general pack routes, timed rounds, tasks, duels, and public release remain closed.

StyLua covers every tracked Luau file in `src/` and `lune/`. Selene uses the committed, normalized `roblox.yml` standard library with `roblox-std-source = "pinned"`, so ordinary linting performs no standard library update. The Lune harness provides deterministic test IDs and ordering, repository bounded paths, supervised child process timeouts, isolated generated fixtures, stable error IDs, and nonzero failure exits.

The exact setup, command, output, cleanup, and recovery contract is in [development setup](../operations/development-setup.md). Test cases and negative fixtures are in the [Phase 000 test procedure](../test/phase-000-toolchain.md). Current evidence is summarized in the [foundation evidence record](../verification/phase-000-foundation.md).

Linux x86_64 local and clean environment acceptance passes. Clean Windows x86_64 acceptance passes on the recorded GitHub hosted `windows-2025` runner. Phase 000 Studio acceptance is satisfied by the selected qualified Vinegar route. It runs the actual Windows Roblox Studio binary under Vinegar and Wine with the exact reviewed Rojo plugin, live MCP connection, loopback synchronization, controlled resynchronization and revert, client and server bootstrap, clean project console, and topology parity. This result makes no official native Linux Studio support claim.

## Implemented Phase 001 Shared Contracts

`ReplicatedStorage.Shared.LaunchContract` is the only aggregate entry point. It validates and freezes `LaunchCatalog` and `LaunchConfig`, exposes the client safe launch projection, evaluates a normalized calculation, and projects an authoritative result for presentation. The aggregate has no DataStore, remote, UI, or mutable service dependency.

The shared layout is:

- `Types/LaunchTypes.luau` defines the normalized cards, formations, score components, trace entries, state intents, and result shapes.
- `Catalogs/LaunchCatalog.luau` owns stable identities, display metadata, launch enablement, handler IDs, asset contract IDs, and deterministic slot, identity, and form key builders.
- `Catalogs/LaunchValidator.luau` enforces exact counts, IDs, order, references, handlers, assets, parameters, caps, conflicts, weight tables, economy declarations, and disabled future boundaries.
- `Config/LaunchConfig.luau` owns every numeric balance value, stage order, feature flag, limit, economy value, odds table, pity threshold, anti abuse parameter, mode multiplier, and gameplay cap.
- `Math/SafeNumber.luau` provides checked integer arithmetic and rational multiplication with half up rounding and the launch maximum `999999999999999`.
- `Math/FormationDetector.luau` normalizes one to five cards, detects all valid candidates, selects the configured highest priority base, and carries only explicitly declared stackable bonuses.
- `Math/RollContract.luau` evaluates ordered integer weight buckets and records base selection, final selection, versions, pity state, and forced upgrade state.
- `Math/JokerRegistry.luau` resolves the twenty four enabled launch Jokers through data driven handlers, declared stages, parameters, caps, conflicts, enhancement, and typed state intents.
- `Math/ScoreCalculator.luau` runs the declared stage pipeline, emits a stable trace for every applied operation, enforces named caps, and fails without trusted components when input is invalid.
- `Projection/ClientProjection.luau` deep copies, filters, redacts, and freezes the client catalog, economy, and calculation views.
- `Fixtures/Phase001Fixtures.luau` provides the frozen ordinary path showcase fixture used by pure and Studio comparisons.

### Catalog and Version Boundaries

The current contract uses `catalogVersion = 1`, `configVersion = 1`, and `fixtureVersion = 1`. It contains exactly 3 launch Deck Sets, 156 base identities, 4 Editions, 624 forms, 11 Grades, 11 Power Tiers, 12 Traits, 24 Jokers, 12 Arcana, 12 formations, and no enabled Soul. The launch Joker rarity distribution is 8 Common, 5 Uncommon, 4 Rare, 3 Epic, 2 Legendary, and 2 Mythic.

Stable identity data does not contain numeric tuning. Definitions refer to a balance record with the same stable ID. Changing a multiplier, price, threshold, weight, pity value, cap, or anti abuse value requires a configuration version change rather than a new inventory identity. Future sentinels remain representable but are removed from enabled projections and cannot be resolved as launch content.

### Formation and Calculation Order

Ranks use values 2 through 14. A submission is a dense array containing one to five unique instance IDs, unique rank and suit slots, and valid rank, suit, Deck Set, Edition, Grade, Tier, and optional Trait IDs. Perfect Sum additionally requires a finite integer target from 1 through 70. An Adaptive card may provide one adjacent rank override for formation detection while retaining its original face value for scoring. Empty deck positions are represented as Blanks only through the explicit blank contract and never score as cards.

The calculation declares these stages in order:

```text
validate input
joker registry
before formation detection
formation detection
after formation detected
before card contribution
face value
edition
grade
power tier
trait
affinity
card joker additive
card joker multiplicative
after card contribution
before formation multiplier
formation multiplier
deck joker additive
deck joker multiplicative
personal active boost
server event boost
mode modifier
gameplay cap
after formation reward
finalize result
```

Every accepted result carries all matching formation candidates, the selected base formation, five output components, typed state intents, catalog and config versions, and an ordered explainable trace. Card scoped stages repeat in canonical submission order before aggregate stages. An overlap uses the configured best base while matched formation effects may inspect the complete candidate set. It never multiplies all matching formation bases. The only launch stackable formation bonus is `perfect_sum_accuracy`, a `1.10x` multiplier applied when Perfect Sum is one of the matches, including when a higher base formation wins.

### Exact Arithmetic and Failure Behavior

Trusted counts, values, weights, thresholds, components, numerators, and denominators are finite integers. Rational multiplication rounds half up after each declared operation. The safe layer rejects a zero denominator, a negative trusted value, a fractional integer, `NaN`, infinity, underflow, overflow, or a result above the launch maximum. The score layer then enforces named component caps: Cash `999999999999`, Power and Guard `999999999999999`, and pack progress and Grade experience `1000000`.

Catalog or configuration construction fails with a stable `P001-CATALOG`, `P001-CONFIG`, or `P001-BALANCE` assertion before the aggregate contract becomes available. Runtime detectors, rolls, Joker evaluation, calculation, and projection use their own stable `P001` reason families. A rejected calculation exposes no trusted component result.

### Economy and Random Projection

The economy contract declares Cash, Joker Tickets, Arcana Dust, Grade Ink, Trait Essence, Duel Tokens, Ascension Fragments, and reserved disabled Soul Fragments. Every currency has a transfer rule, cap, sources, sinks, and stable reason IDs. Clients receive prices, visible caps, odds, pity, early protection, and the active and passive rates. They do not receive server only anti abuse configuration.

Power Tier and Joker weights each total exactly `100000`. Trait chance is `10000` of `100000`. Roll boundaries are inclusive by ordered cumulative bucket and are preserved in the roll record. Pity can raise a selected bucket to its configured minimum but cannot relabel the underlying base bucket. A stale pity counter or version fails closed.

The normalized active baseline is 100 units per minute and passive is 18 percent. This is 5.55 times more efficient for active play and passes the required five to one boundary. These are versioned first tuning values, not evidence of a live player economy.

The repeatable test procedure is [Phase 001 catalog and calculation tests](../test/phase-001-calculation-contracts.md). Candidate hashes and current evidence are in [Phase 001 catalog and calculation evidence](../verification/phase-001-calculation-contracts.md).

## Implemented Phase 002 Runtime

The runtime targets Roblox and uses strict typed Luau for shared domain modules, server services, and client controllers. Roblox Studio is the editor. The qualified Linux route runs the Windows Studio binary through Vinegar and Wine. The runtime makes no native Linux Studio support claim.

`Phase002Runtime` selects `MemoryProfileAdapter` only when Studio has `game.GameId == 0`. A nonzero universe uses `RobloxProfileAdapter` and `UpdateAsync` against the version 1 profile store. The in memory adapter is local test isolation, not persistence evidence.

### Module Map

- `src/shared/Network/` owns the frozen 24 action registry, 43 stable errors, exact schemas, resource bounds, and deterministic envelope validation.
- `src/shared/Profile/` owns the readable profile domain, compact codec, canonical values, migration registry, and storage policy.
- `src/shared/Rendering/` owns the shared card presentation model.
- `src/server/Storage/` owns memory and Roblox adapters, the profile lifecycle, and the inventory storage interface.
- `src/server/Transactions/` owns exact once profile mutation, versioned receipts, replay barriers, compaction, response recovery, and shutdown drain.
- `src/server/Inventory/` owns card and Joker creation, collection history, flags, locks, eligibility, conservation, and the 52 slot deck.
- `src/server/Packs/` owns the recoverable Classic Starter Pack slice.
- `src/server/Formation/` owns the guided orchestration that calls the Phase 001 calculation contract without saving directly.
- `src/server/Network/` owns token buckets and the fail closed gateway.
- `src/server/Projection/` owns bounded client snapshots and binder pages.
- `src/client/State/` owns presentation only correlated message state.
- `src/client/Rendering/` owns 2D and 3D adapters, the component pool, bounded preload, and binder virtualization.
- `src/client/Application/` owns the minimal local interface and narrow intent submission.

The complete service and data flow is documented in [Phase 002 runtime architecture](../implementation/phase-002-runtime.md).

### Initialization

1. Load and validate the Phase 001 catalog, configuration, and calculation contract.
2. Publish the Classic, Radioactive, and Astral card and pack presentation fixtures from `ServerStorage` to a bounded client folder. Dynamic selection remains a Phase 003 renderer task.
3. Create one `ClientAction` and one `ServerMessage` remote.
4. Select the memory or Roblox profile adapter from the universe identity.
5. Construct migrations, profile storage, inventory storage, collection, inventory, deck, pack, guided Formation, transaction, token bucket, and gateway services.
6. Acquire one session per player before exposing writable state.
7. Attach action routing, heartbeat, player release, transaction drain, and bounded profile shutdown.
8. Start the client state and request bootstrap.

An unavailable service, malformed profile, foreign session, failed storage retry, invalid route, or unavailable feature closes its mutation path with a stable code.

### Network and Authority

The launch action inventory is frozen at 24 IDs. Phase 002 enables bootstrap, Starter Pack open, deck equip, deck unequip, inventory flags, guided Formation submit, and binder page. Later actions validate their frozen schema and return `feature.unavailable`.

The gateway validates envelope shape, exact action schema, encoded size, depth, node count, finite numbers, bounds, rate, availability, profile state, writable state, authorization, and route result in deterministic order. Every safe correlatable rejection returns the original request and action identity.

The client supplies intent only. It cannot supply a trusted card definition, pack result, reward, score, Grade, Tier, Trait, owner, timestamp, receipt, session, or writable state.

### Profiles, Sessions, and Transactions

Profile schema version 1 contains the complete launch domain boundary. `ProfileCodec` serializes a separate compact representation with sorted currencies and discovery IDs. Strict decode rejects unknown fields, missing ownership references, duplicate pending identities, contradictory rank, suit, slot, or content identity fields, malformed receipts, receipt and barrier mismatch, impossible deck state, invalid settings, and unsupported versions.

The profile policy warns at 1,000,000 encoded bytes and blocks writes above 1,500,000 bytes. The deterministic realistic fixture crosses those boundaries at 2,300 and 3,400 cards respectively.

Each writable session uses one opaque token with job ID, place version, and heartbeat. Acquisition, heartbeat, commit, dirty flush, and release use `UpdateAsync` with token and revision checks. A healthy second writer fails. An expired lease requires pending operation reconciliation before reassignment. Bounded retry exhaustion keeps the profile read only and preserves the durable value.

Every durable operation stores receipt version 1, operation kind, canonical fingerprint, exact result, result reference, revision, and a matching replay barrier. Reuse with the same fingerprint returns the stored result. Reuse with another fingerprint returns `request.replay_conflict`. Full receipts compact after 256 entries while replay barriers remain. Cyclic service results and commit time schema exceptions fail closed, preserve durable state, and release the per profile transaction lane for the next valid operation.

Shutdown closes new transactions, drains active work, flushes dirty profiles, and clears matching leases within one 25 second wall deadline.

### Inventory and Recoverable Slice

Card and Joker UIDs are opaque, server generated, and collision checked against current and pending ownership. Provenance is immutable. Discovery is permanent. Removal protects favorites, wishlists, locks, equipped cards, and the last copy.

The deck contains exactly 52 rank and suit slots. Equip validates owner, content, lock, UID uniqueness, slot identity, occupancy, and expected profile revision. It changes only loadout references.

The free Starter Pack commits five Classic cards and one pending result at revision 1. Rejoin reopens a committed reveal. The first successful equip of a result card acknowledges that reveal inside the deck transaction without adding a hidden remote. A guided four card Formation calls the Phase 001 score contract and commits one Cash reward with the same exact once protections.

### Renderer and Client State

One view model provides Deck Set, suit, rank, Edition, Grade, Power Tier, Trait, and status layers to both 2D and 3D adapters. Trade lock, general lock, favorite, wishlist, new, and unavailable content remain readable without relying on color. Missing content uses a neutral fallback.

The client clones the two Rojo mapped fixture models through a component pool, preloads only those two fixtures, and virtualizes binder rows. Low graphics, reduced motion, and reduced flash remove nonessential animation while keeping all semantic layers.

Client state rejects lower revisions and malformed messages. Read only and maintenance responses retain presentation but remove writable authority.

## Planned Runtime Beyond Phase 003

Later phases implement the full asset catalog, responsive interaction surfaces, timed Formation Rush rounds, tasks, progression, Joker and Arcana mutation, Friend Clash, trading journals, analytics, live operations, release verification, and controlled public access. Reserved action IDs are not evidence that those services exist.

Inventory currently occupies one compact profile document behind `InventoryStore`. Before realistic profiles approach platform limits, a journaled sharding migration must replace the physical layout without changing gameplay service APIs.

## Security and Privacy

- The Phase 002 gateway validates type, shape, estimated bytes, depth, nodes, finite numbers, exact fields, bounds, permission, profile state, ownership, and rate for every registered client action.
- Durable Phase 002 mutations use operation IDs, versioned receipts, matching replay barriers, and exact result recovery.
- Never store credentials or raw private logs in the repository, analytics, or diagnostics.
- Never expose another player's private inventory or hidden hand.
- Avoid custom trade text at launch. Any later player text must use Roblox filtering.
- Keep trading disabled until settlement and recovery tests prove one effective owner per item.
- Keep random gameplay packs earned. If paid random items ever enter scope, treat policy checks, odds disclosure, purchase receipts, and trading restrictions as a new reviewed contract.

## Performance Direction

Launch servers target eight players. Phase 002 pools its card and pack models, virtualizes binder rows, and preloads exactly two fixture models. The profile size gate warns at 1,000,000 encoded bytes and blocks above 1,500,000 bytes. Passive income remains planned and must use timestamp calculations rather than per frame server work. Formation detection remains bounded to an eight card hand and a maximum five card submission.

## Development and Verification

The foundation command interface is implemented. From a bootstrapped repository root, use:

```console
lune run ci
```

That gate verifies tool integrity, formatting, linting, deterministic tests, source map generation, two build reproducibility, documentation, secrets, and artifact integrity. The generated candidate files remain ignored under `build/`. See [development setup](../operations/development-setup.md) for each direct command and its failure recovery.

The combined suite now passes 58 tests. Phase 001 coverage includes catalog counts, stable IDs, all formation detectors, deterministic scoring, exact odds and pity records, Joker combinations, safe arithmetic, economy projections, and active to passive balance. Phase 002 adds every action schema, hostile inputs, rates, profiles, migrations, size boundaries, sessions, retry, safe mode, shutdown, transactions, receipts, failure injection, inventory, deck, Starter Pack recovery, guided reward, client authority, renderer semantics, pooling, virtualization, preload, and deterministic evidence hashes. Phase 003 adds the versioned asset manifest schema, provenance and fallback validation, budget enforcement, deterministic invalidation fixtures, and three Deck Set visual identity records for all 156 base identities.

The current local Vinegar Studio path passes the blank pack fixture, committed reveal, acknowledgement, four deck edits, guided reward, exact replay, request conflict, hostile correlation, normal rendering, static low graphics rendering, and a clean console. The owner authorized isolated DataStore interruption and rejoin workflow remains mandatory.

Phase 003 entry and asset contract evidence is recorded in [the Phase 003 entry packet](../verification/phase-003-entry.md), [the Phase 003 asset contract record](../verification/phase-003-asset-contract.md), and [the Phase 003 manifest snapshot](../verification/phase-003-asset-manifest.json). [The Deck Set identity evidence](../verification/phase-003-deckset-identities.md) records the three visual systems, 156 base identity records, and six procedural fixtures. The version 1 manifest validator now freezes source and built identities, hashes, provenance, review, fallbacks, references, preload groups, pool groups, and measured budgets before new launch assets are produced. It does not claim that the complete launch bundle exists.

Later gameplay phases must extend verification to cover general pack pity, one card Arcana application, permanent Edition unlocks, Grade progression, timed rounds, tasks, multi client Friend Clash, trade settlement failure injection, touch, controller, mobile layout, broader performance, and production release gates.

Do not claim a feature is complete before its specified deterministic checks and manual Roblox Studio paths pass.

## Documentation Maintenance

Update the root README when setup, supported tools, public behavior, or release status changes. Update this overview when architecture, persistence, networking, configuration, or compatibility changes. Update the content catalog only through an approved product contract change. Add focused testing and verification documents when executable systems exist.

## Known Limitations

- The repository contains a local playable foundation slice and an active Phase 003 entry baseline, not a complete game loop or public experience.
- Phase 003 remains incomplete until the full launch asset, pack, progression, Joker, responsive surface, accessibility, Studio, isolated recovery, and integration gates pass.
- InfiniteCardCollector is the selected public name, but its final trademark, Roblox experience search, logo, icon, and asset clearance remain release prerequisites.
- Balance values are starting hypotheses and require live analytics.
- General packs, progression, timed rounds, tasks, duels, trading, purchases, analytics, and end scale inventory sharding are designed but unimplemented.
- Popularity cannot be guaranteed; onboarding and retention targets require soft launch evidence.
