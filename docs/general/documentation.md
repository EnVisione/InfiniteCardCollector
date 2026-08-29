# Technical Overview

## Status

InfiniteCardCollector is a Roblox game project with a completed Phase 000 foundation and an active Phase 001 shared calculation layer. The repository contains deterministic development commands, a verified Linux tool bootstrap, reproducible Rojo generation, exact launch catalogs, versioned configuration, pure formation detection, checked score math, Joker handlers, and client safe projections. It is not yet a playable game. This document separates implemented pure contracts from planned stateful gameplay.

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

Phase 000 is integrated and tagged. Phase 001 implements only owner shared data and pure calculations. Profiles, persistence, network actions, services, controllers, interface workflows, and live gameplay remain assigned to later phases. The future plan does not authorize deferred content for the initial release.

## Implemented Foundation

The repository pins Rojo v7.7.0, Rokit v1.2.0, StyLua v2.5.2, Selene v0.31.0, and Lune v0.10.5. `rokit.toml` is the managed tool resolution contract. `config/tool-artifacts.json` records the selected Linux and Windows artifacts, archive and executable hashes, licenses, provenance, reviewed command surfaces, and security dispositions.

The platform bootstrap scripts download archives to temporary storage, verify size, SHA 256, SHA 512, and archive layout before extraction, then seed Rokit with the verified binaries. `lune run verify-tools` independently checks the resolved path, exact executable bytes, version output, platform artifact, and provenance fields. It rejects a missing, changed, or PATH shadowed executable.

`default.project.json` currently maps only the minimum foundation:

- `src/shared/` becomes `ReplicatedStorage/Shared`.
- `src/server/` becomes `ServerScriptService/Server`.
- `src/client/` becomes `StarterPlayer/StarterPlayerScripts/Client`.
- Declarative folders reserve `ServerStorage/Assets` without placing tool or test content in the runtime.
- `StarterGui/App/AppRoot` is a scale based transparent GUI root.

The shared bootstrap contract contains immutable foundation metadata. The Phase 001 server bootstrap also evaluates one frozen shared fixture as the authoritative result. The client bootstrap projects that same shared calculation through the client safe adapter. These bootstraps record verification attributes only. They do not create a remote, profile, reward mutation, purchase, pack operation, live round, or trade.

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

## Planned Runtime

- Platform: Roblox.
- Language: typed Luau with strict mode for shared domain modules, server services, and client controllers.
- Editor: Roblox Studio.
- Authority: server authoritative inventory, RNG, scoring, rewards, progression, trading, and purchases.
- Persistence: Roblox DataStore with session ownership, `UpdateAsync`, schema migrations, idempotent operations, and persistent trade journals.
- Ephemeral coordination: MemoryStore only where temporary cross server coordination is eventually required.

Later phases add server services, controllers, persistence, networking, owned instances, live gameplay, and interface workflows behind the implemented foundation and shared calculation boundaries. Phase 001 integration and its signed tag must close before Phase 002 consumes these contracts.

## Planned Product Module Map

The intended source layout is fully specified in the launch foundation. Its primary boundaries are:

- `ReplicatedStorage/Shared/Catalogs/` for stable data definitions.
- `ReplicatedStorage/Shared/Math/` for pure card and formation calculations.
- `ReplicatedStorage/Shared/Net/` for action schemas and stable errors.
- `ServerScriptService/Server/Services/` for authoritative state and mutations.
- `StarterPlayerScripts/Client/Controllers/` for presentation and player intent.
- `StarterGui/App/` for responsive interface surfaces.
- `ServerStorage/Assets/` for server controlled card, pack, and Joker assets.

Catalogs contain data and handler references. Pure math cannot access persistence, remotes, UI, or mutable player state. Services own authoritative mutations. Client controllers render server messages and submit narrow intent.

## Planned Initialization

1. Validate catalogs and configuration.
2. Register remotes and action schemas.
3. Start analytics, policy, security, profile, and transaction services.
4. Start inventory, collection, random, pack, deck, progression, Arcana, and Joker services.
5. Start formation, task, boost, duel, trade, and leaderboard services.
6. Attach player lifecycle, autosave, network routing, and shutdown handling.
7. Accept actions only after profile load, recovery, and policy checks succeed.

Initialization must fail closed for economy actions when a required catalog, service, or persistent profile is unavailable.

## Planned State Ownership

- DataStore owns permanent profile and transaction state.
- Profile service owns writable session leases and migrations.
- Transaction service owns idempotent economy operations and receipts.
- Inventory service owns instance creation, lookup, locking, and eligibility.
- Formation service owns live hands, draw piles, submissions, and score traces.
- Trade service owns offer state, journals, settlement, and recovery.
- Clients own only local presentation, input state, and nonauthoritative previews.

The client must never provide a trusted item, reward, price, score, Grade, Tier, Trait, timestamp, trade owner, or pack result.

## Planned Data Compatibility

Stable identifiers are lowercase slugs. Saved profiles use schema versions and pure repeatable migrations. Display names may change without changing stable IDs. Content may be disabled without deleting ownership. Every card, Joker, and Soul instance uses a unique server generated ID with provenance and version fields.

Launch storage may begin with a compact single profile document behind storage interfaces. Before content volume threatens the DataStore key limit, inventory must migrate to journaled shards without changing gameplay service APIs.

## Security and Privacy

- Validate type, shape, size, enum membership, permission, state, timing, ownership, and rate for every client action.
- Use operation IDs and persistent receipts for retried economy mutations.
- Never store credentials or raw private logs in the repository, analytics, or diagnostics.
- Never expose another player's private inventory or hidden hand.
- Avoid custom trade text at launch. Any later player text must use Roblox filtering.
- Keep trading disabled until settlement and recovery tests prove one effective owner per item.
- Keep random gameplay packs earned. If paid random items ever enter scope, treat policy checks, odds disclosure, purchase receipts, and trading restrictions as a new reviewed contract.

## Performance Direction

Launch servers target eight players. Card and particle objects should be pooled, binder pages virtualized, and only essential assets preloaded. Passive income uses timestamp calculations rather than per frame server work. Formation detection remains bounded to an eight card hand and a maximum five card submission.

## Development and Verification

The foundation command interface is implemented. From a bootstrapped repository root, use:

```console
lune run ci
```

That gate verifies tool integrity, formatting, linting, deterministic tests, source map generation, two build reproducibility, documentation, secrets, and artifact integrity. The generated candidate files remain ignored under `build/`. See [development setup](../operations/development-setup.md) for each direct command and its failure recovery.

The Phase 001 suite now covers catalog counts, stable IDs, all formation detectors, deterministic scoring, exact odds and pity records, Joker combinations, safe arithmetic, economy projections, and active to passive balance. Later gameplay phases must extend verification to cover:

- Pack transactions, pity persistence, and disconnect recovery.
- Profile migrations and idempotent transactions.
- One card Arcana application and permanent Edition unlocks.
- Server validation for every remote action.
- Multi client Friend Clash and trade behavior.
- Failure injection at every trade settlement state.
- Touch, controller, keyboard, reduced motion, and low graphics paths.
- Mobile performance and DataStore size fixtures.

Do not claim a feature is complete before its specified deterministic checks and manual Roblox Studio paths pass.

## Documentation Maintenance

Update the root README when setup, supported tools, public behavior, or release status changes. Update this overview when architecture, persistence, networking, configuration, or compatibility changes. Update the content catalog only through an approved product contract change. Add focused testing and verification documents when executable systems exist.

## Known Limitations

- The repository contains implemented pure launch contracts but no playable loop.
- Phase 001 remains incomplete until final Studio comparison, final audit, pull request checks, review disposition, merge, signed tag, and wiki gates pass.
- InfiniteCardCollector is the selected public name, but its final trademark, Roblox experience search, logo, icon, and asset clearance remain release prerequisites.
- Balance values are starting hypotheses and require live analytics.
- Trading and end scale inventory sharding are designed but unimplemented.
- Popularity cannot be guaranteed; onboarding and retention targets require soft launch evidence.
