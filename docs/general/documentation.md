# Technical Overview

## Status

InfiniteCardCollector is a Roblox game project with an active Phase 000 foundation. The repository contains a minimum strict typed Luau runtime skeleton, deterministic development commands, a verified Linux tool bootstrap, repository tests, and reproducible Rojo project generation. No gameplay system is implemented yet. This document separates implemented foundation behavior from the planned product architecture.

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

Phase 000 foundation implementation is active. Gameplay implementation has not started, and the future plan does not authorize its deferred content for the initial release.

## Implemented Foundation

The repository pins Rojo v7.7.0, Rokit v1.2.0, StyLua v2.5.2, Selene v0.31.0, and Lune v0.10.5. `rokit.toml` is the managed tool resolution contract. `config/tool-artifacts.json` records the selected Linux and Windows artifacts, archive and executable hashes, licenses, provenance, reviewed command surfaces, and security dispositions.

The platform bootstrap scripts download archives to temporary storage, verify size, SHA 256, SHA 512, and archive layout before extraction, then seed Rokit with the verified binaries. `lune run verify-tools` independently checks the resolved path, exact executable bytes, version output, platform artifact, and provenance fields. It rejects a missing, changed, or PATH shadowed executable.

`default.project.json` currently maps only the minimum foundation:

- `src/shared/` becomes `ReplicatedStorage/Shared`.
- `src/server/` becomes `ServerScriptService/Server`.
- `src/client/` becomes `StarterPlayer/StarterPlayerScripts/Client`.
- Declarative folders reserve `ServerStorage/Assets` without placing tool or test content in the runtime.
- `StarterGui/App/AppRoot` is a scale based transparent GUI root.

The shared contract contains immutable bootstrap metadata. The server bootstrap is authoritative and records local readiness only. The client bootstrap reads the shared contract and records presentation readiness only. No remote, persistent state, catalog, reward, currency, purchase, pack, formation, or trade behavior exists.

StyLua covers every tracked Luau file in `src/` and `lune/`. Selene uses the committed, normalized `roblox.yml` standard library with `roblox-std-source = "pinned"`, so ordinary linting performs no standard library update. The Lune harness provides deterministic test IDs and ordering, repository bounded paths, supervised child process timeouts, isolated generated fixtures, stable error IDs, and nonzero failure exits.

The exact setup, command, output, cleanup, and recovery contract is in [development setup](../operations/development-setup.md). Test cases and negative fixtures are in the [Phase 000 test procedure](../test/phase-000-toolchain.md). Current evidence is summarized in the [foundation evidence record](../verification/phase-000-foundation.md).

Linux x86_64 local and clean environment acceptance passes. Clean Windows x86_64 acceptance passes on the recorded GitHub hosted `windows-2025` runner. Native Roblox Studio acceptance remains pending. The exact Rojo plugin passes the recorded Vinegar compatibility workflow, but Vinegar cannot replace native Studio evidence.

## Planned Runtime

- Platform: Roblox.
- Language: typed Luau with strict mode for shared domain modules, server services, and client controllers.
- Editor: Roblox Studio.
- Authority: server authoritative inventory, RNG, scoring, rewards, progression, trading, and purchases.
- Persistence: Roblox DataStore with session ownership, `UpdateAsync`, schema migrations, idempotent operations, and persistent trade journals.
- Ephemeral coordination: MemoryStore only where temporary cross server coordination is eventually required.

Later phases add the planned catalogs, services, controllers, persistence, networking, and gameplay behind the implemented foundation boundaries. Native Studio and Windows acceptance must close before Phase 000 completes.

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

Later gameplay phases must extend verification to cover:

- Catalog counts and stable ID uniqueness.
- Formation detection and deterministic scoring.
- Pack odds, pity, and disconnect recovery.
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

- The repository contains no playable implementation.
- Phase 000 remains incomplete until native Roblox Studio, final audit, pull request checks, review disposition, merge, signed tag, and wiki gates pass.
- InfiniteCardCollector is the selected public name, but its final trademark, Roblox experience search, logo, icon, and asset clearance remain release prerequisites.
- Balance values are starting hypotheses and require live analytics.
- Trading and end scale inventory sharding are designed but unimplemented.
- Popularity cannot be guaranteed; onboarding and retention targets require soft launch evidence.
