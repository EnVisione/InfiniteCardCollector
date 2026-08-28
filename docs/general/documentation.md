# Technical Overview

## Status

Project 52 is currently a documentation only Roblox game project. No runtime, Roblox place, Luau modules, dependencies, or build commands are implemented. This document separates current repository facts from the planned architecture in the launch specification.

## Product Boundary

The game is an original active card collector. A player owns one permanent deck with fifty two rank and suit slots, equips up to five deck wide Jokers, and earns cards through active Formation Rush rounds and short task stations. Passive and offline rewards supplement active play. Direct trading is planned but must remain feature flagged until item duplication, disconnect, and storage recovery tests pass.

The launch contract is limited to three Deck Sets. The complete content destination is preserved separately so launch implementation does not need to support all content at once.

## Source of Truth

Use this order when documents disagree:

1. The current owner request.
2. The active implementation plan, when one exists.
3. The [launch foundation](../implementation/launch-foundation.md) for the intended first release.
4. The [content catalog](content-catalog.md) for stable content names, IDs, counts, and first balance targets.
5. The [product vision](product-vision.md) for the long term destination.
6. Implemented source and passing tests after implementation begins.
7. This technical overview and the root README.

No active implementation plan is currently stored in the repository. Repository implementation must not begin until the required plan intake is completed.

## Planned Runtime and Toolchain

- Platform: Roblox.
- Language: typed Luau with strict mode for shared domain modules, server services, and client controllers.
- Editor: Roblox Studio.
- Authority: server authoritative inventory, RNG, scoring, rewards, progression, trading, and purchases.
- Persistence: Roblox DataStore with session ownership, `UpdateAsync`, schema migrations, idempotent operations, and persistent trade journals.
- Ephemeral coordination: MemoryStore only where temporary cross server coordination is eventually required.

Exact Roblox Studio version, source synchronization workflow, package manager, formatter, linter, and test framework remain undecided. Do not add or pin them without the active implementation plan.

## Planned Module Map

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

There are no valid build or test commands yet. The first implementation milestone must establish exact setup, formatting, lint, unit test, Studio integration test, packaging, and publishing procedures. At minimum, verification must cover:

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
- No active implementation plan has been created.
- The Project 52 name is a codename and has not been cleared as a final public brand.
- Balance values are starting hypotheses and require live analytics.
- Trading and end scale inventory sharding are designed but unimplemented.
- Popularity cannot be guaranteed; onboarding and retention targets require soft launch evidence.
