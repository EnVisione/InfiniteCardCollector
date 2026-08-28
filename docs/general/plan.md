# InfiniteCardCollector Initial Public Release Plan

> **Plan ID:** PLAN-MASTER
> **Plan status:** VALIDATED WITH KNOWN EXTERNAL BLOCKER
> **Project state:** EXISTING
> **Planning subject:** InfiniteCardCollector from its documentation-only preimplementation state through a controlled first public Roblox release, with the exhaustive long-term 52 by 52 destination preserved as a registered future aspect
> **Plan profile:** software_product
> **Requirement prefix:** CORE

## 1. Project Identity

```text
Project: InfiniteCardCollector
Requested artifact: authoritative_plan
Repository root: /home/envy/Projects/InfiniteCardCollector
Starting branch: envy/core-phase-000
Starting commit: ef6b0ed648f66ab3035cce5245cd0ab3b9679059
Authoritative remote:
origin
https://github.com/EnVisione/InfiniteCardCollector.git
Remote ref: origin/envy/core-phase-000
Remote commit: ef6b0ed648f66ab3035cce5245cd0ab3b9679059
Repository visibility: public
Package metadata: absent
Project maturity: documentation-only preimplementation design
```

The repository identity is matched. At the locked update revision, local branch `envy/core-phase-000` and remote branch `origin/envy/core-phase-000` resolve to commit `ef6b0ed648f66ab3035cce5245cd0ab3b9679059`, and the public remote resolves to `EnVisione/InfiniteCardCollector`. The repository began as documentation-only preimplementation design; the locked update revision contains the Phase 000 toolchain, typed Luau bootstrap, manifests, executable harness, and verification evidence, while gameplay remains preimplementation.

Public release in this plan means publication of the Roblox experience. It does not authorize changing the GitHub repository's current public visibility.

## 2. Planning Subject and Source Roles

The planning subject is the InfiniteCardCollector software product through its first controlled public Roblox release. The launch foundation is a requirements source, the content catalog is the identity contract, the product vision is the postlaunch destination, and repository evidence describes current state. None of those artifacts substitutes for this dependency-ordered authoritative plan.

| ID | Role | Subject | Source | Intended use |
|---|---|---|---|---|
| SRC-001 | owner_request | InfiniteCardCollector initial public release authority, exhaustive future vision disposition, and later GitHub synchronization | Owner-approved planning brief | Lock the planning subject, requested artifacts, public completion endpoint, trading gate, optional future disposition, and repository synchronization obligation. |
| SRC-002 | status | InfiniteCardCollector product identity, foundation scope, maturity, originality boundary, and repository status | README.md | Establish the documentation-only current state and public-facing launch summary. |
| SRC-003 | reference | Canonical tracked documentation topology and navigation rules | docs/README.md | Preserve documentation ownership, links, indexing, and GitHub wiki boundaries. |
| SRC-004 | requirements | Current technical state and proposed InfiniteCardCollector architecture, persistence, networking, security, and verification boundaries | docs/general/documentation.md | Ground the software architecture, state ownership, compatibility, and current-state evidence. |
| SRC-005 | requirements | Complete InfiniteCardCollector product destination and expansion lifecycle | docs/general/product-vision.md | Define enduring product invariants and the registered future aspect without making the full destination an initial-release blocker. |
| SRC-006 | requirements | Stable names, IDs, counts, content families, effects, and first balance targets | docs/general/content-catalog.md | Lock launch and end-state content identity contracts and provide the exhaustive future content matrix. |
| SRC-007 | requirements | First public release gameplay, architecture, state, security, implementation order, tests, and publication gates | docs/implementation/launch-foundation.md | Serve as the primary requirements source for every mandatory initial-release requirement and phase. |
| SRC-008 | reference | Repository-specific execution, verification, documentation, Git, and safety constraints | AGENTS.md | Constrain plan execution, sequential phase integration, verification depth, and repository hygiene. |
| SRC-009 | repository_evidence | Sanitized local and remote repository identity | git status, git rev-parse, git remote, gh repo view, and git ls-remote observed at the locked intake revision | Pin repository root, branch, commit, public remote identity, default branch, and matching remote commit. |
| SRC-010 | reference | Authoritative plan semantics and validation contract | Plan Creator contract | Define stable IDs, requirement contracts, phase topology, prerequisites, evidence, splitting, and handoff rules. |
| SRC-011 | reference | Software product profile contract | Plan Creator software product profile | Require complete coverage of all ten software product profile areas. |
| SRC-012 | reference | Locked intake schema | Plan Creator intake schema | Define the normalized owner decisions, scope, identity, profile matrix, and prerequisites. |
| SRC-013 | reference | Authoritative master plan structure | Plan Creator master plan template | Define the master plan section and traceability structure. |
| SRC-014 | reference | Registered aspect plan structure | Plan Creator aspect plan template | Structure full_plan.md as a registered future aspect with independent lifecycle detail. |
| SRC-015 | reference | Mandatory per-phase execution blueprint structure | Plan Creator phase blueprint template | Define the complete phase execution plans under docs/general/phases. |
| SRC-016 | owner_request | Qualified Phase 000 Roblox Studio acceptance through Vinegar and Wine on Linux | Current direct owner Plan Creator invocation | Authorize the actual Windows Roblox Studio binary under Vinegar and Wine to satisfy Phase 000 Studio acceptance when every locked evidence gate passes. |
| SRC-017 | existing_plan | Current authoritative InfiniteCardCollector product contract and contiguous phase topology | docs/general/plan.md, docs/general/plan.index.json, docs/general/plan.handoff.json, and all registered phase plans | Preserve existing stable IDs, canonical ownership, unrelated scope, phase sequence, and completion endpoint. |
| SRC-018 | audit_evidence | Verified Phase 000 Vinegar Studio synchronization and bootstrap evidence | docs/verification/phase-000-foundation.md, docs/test/phase-000-toolchain.md, config/environment.json, and revision ef6b0ed648f66ab3035cce5245cd0ab3b9679059 | Ground the exact Vinegar, Wine, Studio, plugin, loopback, synchronization, resynchronization, bootstrap, console, and topology acceptance fields. |
| SRC-019 | status | Live Studio MCP reachability and active immutable goal state | Live Roblox Studio MCP discovery and docs/plan/goal.md | Require MCP connection evidence while preserving the saved goal unchanged and keeping CORE-PHASE-000 active. |

## 3. Purpose, Users, Workflows, and Intended Outcome

InfiniteCardCollector is an original Roblox card collection game built around one permanent fifty-two-slot deck. A new player opens earned packs, chooses which Deck Set version occupies each rank and suit slot, improves individual cards through Grades, Power Tiers, Traits, and Arcana-unlocked Editions, equips up to five deck-wide Jokers, and uses the collection in short active challenges and social play.

The first public release serves:

- New players who need a readable first pack, a useful deck decision, and Formation Rush within the first two minutes.
- Returning collectors who need durable inventory, permanent discovery, transparent passive return progress, and recoverable pending operations.
- Active players who need responsive Formation Rush, four task stations, explainable scoring, and frequent earned rewards.
- Friends who need same-server no-stake competition and safe direct trading when its independent gate passes.
- Operators who need deterministic builds, feature controls, rollback, sanitized diagnostics, analytics, moderation evidence, and exact recovery procedures.

The observable outcome is the completion endpoint locked in the intake:

> A controlled public Roblox release of the three Deck Set InfiniteCardCollector foundation passes every mandatory initial release gate, with direct trading enabled only if its separate safety and production authorization gates pass and otherwise visibly disabled.

The public build must make opening, choosing, improving, using, and showing cards satisfying with only Classic, Radioactive, and Astral. Additional catalog volume cannot substitute for a weak foundation.

## 4. Evidence-Based Current State

| Area | Evidence class | Finding | Evidence |
|---|---|---|---|
| Repository identity | VERIFIED | Local root, public remote, default branch, and starting commits match the locked identity | `git rev-parse`, `git remote`, `gh repo view`, and `git ls-remote` at the intake revision |
| Product definition | OBSERVED | Product, launch boundary, content identities, architecture, and verification expectations are documented | SRC-002 through SRC-007 |
| Runtime at original intake | OBSERVED | No Roblox place or playable implementation existed at the locked starting revision | SRC-002, SRC-004, repository inventory at the locked starting revision |
| Toolchain at original intake | OBSERVED | Exact versions were locked by prerequisites, but no project manifest or executable commands existed at the locked starting revision | SRC-004, SRC-007, EXT-001 through EXT-005 |
| Persistence and networking | PROPOSED | Service boundaries, schemas, state machines, security rules, and recovery contracts are specified but unimplemented | SRC-004, SRC-007 |
| Tests at original intake | OBSERVED | Required test classes were specified, but no automated or Studio test harness existed at the locked starting revision | SRC-004, SRC-007, SRC-008 |
| Assets | OBSERVED | Originality requirements and content families are specified, but launch art, audio, UI, and place assets are absent | SRC-002, SRC-005 through SRC-007 |
| Roblox release environment | UNKNOWN | Universe, place, publisher, service, commerce, and cohort evidence is not yet available | EXT-006 through EXT-013 |
| GitHub access | OBSERVED | Authenticated repository and Project mutation capability is available for later synchronization | EXT-014 |
| Phase 000 candidate | VERIFIED | The current phase branch implements the pinned toolchain, strict source boundaries, deterministic harness, reproducible artifact, Linux and Windows command-line verification, and hosted Linux and Windows CI | SRC-018; revision `ef6b0ed648f66ab3035cce5245cd0ab3b9679059` |
| Qualified Vinegar Studio route | VERIFIED | The actual Windows Roblox Studio binary under the recorded Vinegar and Wine environment passes MCP reachability, loopback synchronization, controlled resynchronization and revert, client and server bootstrap, clean project console, and built-versus-synchronized topology parity | SRC-016, SRC-018, SRC-019, DEC-015; revision `ef6b0ed648f66ab3035cce5245cd0ab3b9679059` |

No gameplay behavior is `VERIFIED`. The Phase 000 minimum bootstrap proves only the repository toolchain and Studio synchronization contract. A document, proposed schema, or target value is evidence of intent, not proof that the game behaves that way.

## 5. Software Product Contract and Profile Coverage

| Profile area | Status | Source | Contract location | Rationale |
|---|---|---|---|---|
| inputs and outputs | covered | SRC-005, SRC-006, SRC-007 | Product Inputs, Outputs, and Observable Workflows | The product vision, content catalog, and launch foundation define player inputs, server outputs, interfaces, actions, schemas, content, and observable first-release behavior. |
| component architecture | covered | SRC-004, SRC-007 | Architecture and Ownership Boundaries | The technical overview and launch foundation define shared modules, services, controllers, UI surfaces, dependency direction, state ownership, data flow, and trust boundaries. |
| state and persistence | covered | SRC-004, SRC-007 | State, Persistence, Transactions, and Recovery | The sources define durable and transient state, schema versioning, session ownership, UpdateAsync writes, migrations, journals, retries, corruption handling, size budgets, and recovery. |
| failure taxonomy | covered | SRC-007 | Failure Taxonomy and Recovery Contract | The launch foundation defines invalid input, service failure, storage failure, authorization failure, partial completion, retryability, quarantine, safe mode, rollback, and operator evidence. |
| versioning | covered | SRC-006, SRC-007, SRC-018, DEC-008, DEC-015 | Versioning and Compatibility | Stable IDs, catalog versions, configuration versions, profile schemas, operation receipts, migrations, tool artifacts, and public compatibility boundaries are explicitly covered. Qualified Vinegar acceptance is bound to exact Vinegar, Wine, Studio, Rojo CLI, plugin, mapping, candidate, and MCP identities. |
| security | covered | SRC-004, SRC-007, SRC-008 | Security, Privacy, and Abuse Boundaries | The sources define server authority, payload validation, rate limits, ownership checks, privacy, secret handling, trade safety, policy checks, moderation evidence, and adversarial tests. |
| test system | covered | SRC-007, SRC-008, SRC-016, SRC-018, SRC-019, DEC-015 | Verification Strategy and Evidence Matrix | Pure, integration, Studio, multiclient, migration, security, failure injection, performance, accessibility, recovery, and real-workflow verification are required. Phase 000 Studio acceptance has two explicit highest-fidelity routes, and the Vinegar route requires exact environment identity and complete real Studio behavior evidence. |
| release lifecycle | external prerequisite | EXT-006, EXT-007, EXT-008, EXT-009, EXT-010, EXT-012, EXT-013 | Rollout, Rollback, Publication, and Production Acceptance | Build, private soft launch, controlled public rollout, observability, rollback, documentation, and production acceptance are defined, while external Roblox identities, permissions, authorizations, cohort evidence, and commerce access remain prerequisites. |
| generalization | covered | SRC-005, SRC-006, SRC-007 | Data-Driven Generalization and Future Aspect Boundary | The architecture must represent launch fixtures without special cases, scale through data-driven catalogs, support all required devices, and preserve the exhaustive future aspect without implementing it early. |
| determinism | covered | SRC-006, SRC-007 | Deterministic Calculations and Idempotent State | Identical normalized inputs must produce stable formation results, score traces, RNG records, migrations, operation receipts, pack recovery, and trade settlement outcomes. |

### Product Inputs, Outputs, and Observable Workflows

Public client inputs are narrow intent envelopes containing an action ID, request ID, and action-specific payload. Launch actions cover bootstrap, packs, deck edits, Joker edits, Arcana, Grade Ink, flags, Formation Rush, tasks, Friend Clash, direct trading, and paged binder requests. The server validates type, shape, size, enum membership, ownership, permission, state, timing, rate, and spatial context before any mutation.

Outputs are authoritative snapshots, narrow patches, committed pack contents, stable error codes, calculation traces, transaction receipts, trade receipts, collection records, analytics reason codes, and presentation state. Another player's private inventory and hidden hand never become public outputs.

The primary user-visible workflows are:

1. Join with a blank or existing profile and recover every pending durable operation.
2. Open earned packs and receive only server-committed results.
3. Equip one valid card instance per rank and suit slot.
4. Play Formation Rush and task stations for active progress.
5. Apply progression to one eligible, confirmed target without destroying prior progress.
6. Inspect, wishlist, favorite, lock, showcase, and compare cards.
7. Play a same-server no-stake Friend Clash.
8. Trade only when eligibility, safety, and enablement gates permit it.
9. Purchase only guaranteed declared products and recover exact-once grants.
10. Leave and return without losing committed cards, currencies, pity, choices, receipts, or prepared recovery state.

### 5.2 Component Architecture

The planned source boundary is:

```text
ReplicatedStorage/Shared
  Catalogs, Config, Math, Net, Types
ServerScriptService/Server
  Services and Bootstrap.server.luau
ServerStorage/Assets
  CardFrames, PackModels, JokerProps, and server-controlled content
StarterPlayerScripts/Client
  Controllers and ClientBootstrap.client.luau
StarterGui/App
  Responsive product surfaces
```

Catalogs contain stable data and handler references. Pure calculation modules cannot access mutable player state, DataStore, remotes, UI, or services. Server services own mutations. Client controllers render authoritative messages and submit intent. UI surfaces consume controller state rather than bypassing service or network contracts.

### 5.3 State, Persistence, Transactions, and Recovery

Durable state includes schema version, profile revision, timestamps, active seconds, currencies, card and Joker instances, Arcana stacks, reserved Souls state, active loadouts, permanent discovery, best records, pity, pending packs, boosts, daily and tutorial state, trade history, processed operations, settings, and moderation state.

Transient state includes live Formation Rush rounds, task seeds, invite state, active Friend Clash rounds, editable trade offers, rate-limit buckets, UI state, and cached presentation. Transient state cannot become ownership authority.

Profile writes use `UpdateAsync`, a writable session token, bounded retry with jitter, dirty batching, immediate transaction saves where required, pure repeatable migrations, and read-only safe mode after repeated failure. Permanent multi-profile trade state uses a persistent journal. MemoryStore may coordinate temporary presence but never owns permanent items.

Each mutation is idempotent by operation ID. Replaying the same operation returns the committed result. A repeated ID with conflicting input is rejected. Server shutdown stops new mutations, journals or completes active operations, saves dirty profiles, releases sessions, and preserves exact recovery evidence.

### 5.4 Failure Taxonomy and Recovery Contract

| Failure class | Detection | Required behavior | Recovery and evidence |
|---|---|---|---|
| Invalid client input | Schema, bounds, ownership, state, timing, or rate failure | Reject without mutation, return a stable code and narrow refreshed state | Sanitized action ID, reason code, severity, and rate state |
| Profile load failure | DataStore error, malformed payload, migration failure, or active session | Do not create a blank overwrite; show retry and safe leave | Load stage, schema, lock owner, retry count, quarantined fixture |
| Loss of writable session | Heartbeat or ownership mismatch | Enter read-only safe mode and stop rewards and mutations | Session token, heartbeat age, revision, recovery result |
| Transaction save failure | Commit or receipt write does not complete | Preserve precondition state or the exact durable pending operation | Operation ID, before and after revision, retry and recovery trace |
| Committed pack disconnect | Client disappears after contents commit | Reopen the exact saved result | Pending pack operation, result hash, catalog version |
| Catalog or configuration defect | Missing ID, handler, reference, count, or invalid value | Fail closed before actions or disable only affected acquisition with a neutral fallback | Catalog and config versions, validation report, disabled IDs |
| External service failure | Roblox service unavailable, throttled, or permission denied | Retry only idempotent work, degrade safely, and stop unsafe actions | Service, code, retry state, feature state, operator alert |
| Trade partial completion | Journal prepared or settlement sides differ | Lock involved items and reconcile before writable play | Trade ID, offer hash, state, side settlements, receipts |
| Purchase callback repetition | Duplicate receipt delivery | Return the existing exact-once grant result | Product ID, receipt identity, operation receipt, profile revision |
| Release regression | Launch metric, safety, performance, or integrity threshold fails | Stop widening access or execute rollback | Frozen runbook, threshold signal, place version, rollback evidence |

### 5.5 Versioning and Compatibility

- Tool versions are exact external artifact contracts under EXT-001 through EXT-005.
- Stable content IDs are lowercase slugs and are never reused for different identities.
- Display names may change without changing stored IDs.
- Catalog and configuration versions accompany pending offers, diagnostics, and calculation traces.
- Profile schemas migrate forward through pure, repeatable, fixture-tested functions.
- Operation receipts, trade journals, request envelopes, and stable error codes are versioned compatibility surfaces.
- Disabled content stops new acquisition without deleting ownership.
- Launch storage exposes profile and inventory interfaces that permit later journaled sharding without changing gameplay service APIs.
- Before values approach unsafe Luau integer precision, the future aspect introduces a deterministic normalized large-number representation.

### 5.6 Security, Privacy, and Abuse Boundaries

The client never supplies a trusted reward, price, score, card result, Grade, Power Tier, Trait, timestamp, hand, item owner, policy result, receipt outcome, or trade settlement. Every remote rejects nonfinite values, negative counts, fractional integers where integers are required, oversized collections, excessive nesting, unknown IDs, duplicate instance IDs, stale round IDs, foreign instances, and invalid action rates.

Credentials, tokens, raw profiles, private logs, and unfiltered player text never enter source, analytics, diagnostics, issues, or documentation. Launch trading has no custom player text. Security signals use stable sanitized codes and cannot create an irreversible penalty from one uncorroborated signal. Impossible ownership or currency state is quarantined with evidence instead of silently deleted.

### 5.7 Test System

Verification proceeds from deterministic low-level proof to real Roblox behavior:

1. Formatting and static analysis.
2. Catalog, pure math, property, migration, and transaction tests.
3. Local integration tests across services and typed envelopes.
4. Roblox Studio server and client integration paths.
5. Multiclient Friend Clash and trade paths.
6. Failure injection for persistence, shutdown, replay, ordering, and every trade state.
7. Device, accessibility, memory, frame-rate, payload, profile-size, and eight-player load checks.
8. Frozen release-candidate artifact inspection and private soft launch.
9. Separately authorized production purchase smoke and conditional trade smoke.
10. Controlled public rollout, observation, rollback readiness, and plan-wide closure.

Lower-fidelity proof cannot replace a required Studio, multiclient, recovery, device, private-launch, or production check.

### 5.8 Release Lifecycle

The lifecycle moves from local readiness through implementation, release-candidate hardening, private soft launch, production authorization, controlled public rollout, observation, and closure. Each global phase integrates through a sequential phase branch and merge commit before the next begins. Emergency controls can disable individual content, acquisition, salvage, Arcana, Grade upgrades, passive rewards, Friend Clash rewards, trading, announcements, and products without deleting committed ownership.

Trading has two valid public states. If all deterministic, multiclient, failure-injection, and production authorization gates pass, `TradeEnabled` may be true. Otherwise new trade requests remain false and the booth clearly states that trading is coming later. Prepared journals must remain recoverable in either state.

### Data-Driven Generalization and Future Aspect Boundary

Classic, Radioactive, and Astral are launch fixtures, not hard-coded branches. The same catalog, renderer, score stages, persistence types, network schemas, and service interfaces must represent additional Deck Sets and content without duplicating service logic. The exhaustive destination is preserved in [full_plan.md](full_plan.md) as `PLAN-FULL`. It is mandatory to preserve and register, but every FUT item remains excluded from this plan's completion endpoint unless a later explicit owner decision promotes it.

### Deterministic Calculations and Idempotent State

Identical validated catalogs, configuration versions, player state, operation IDs, seeds, and ordered inputs must produce identical normalized formation detection, calculation traces, pack records, pity transitions, migrations, transaction receipts, trade reconciliation, and leaderboard normalization. Table iteration order, presentation timing, reconnects, repeated callbacks, and duplicate requests cannot change committed outcomes.

## 6. Mandatory Scope

| ID | Mandatory outcome |
|---|---|
| CORE-REQ-001 | Pinned executable Roblox and Luau toolchain |
| CORE-REQ-002 | Exact launch catalogs and configuration |
| CORE-REQ-003 | Deterministic calculations and traces |
| CORE-REQ-004 | Server-authoritative network and security contract |
| CORE-REQ-005 | Durable profiles, migrations, sessions, and storage boundary |
| CORE-REQ-006 | Idempotent transaction and recovery kernel |
| CORE-REQ-007 | Inventory, collection, ownership, and deck invariants |
| CORE-REQ-008 | Reusable layered card renderer |
| CORE-REQ-009 | Complete original launch asset set |
| CORE-REQ-010 | Earned packs, odds, pity, choices, and recovery |
| CORE-REQ-011 | Card progression, Arcana, Editions, and salvage |
| CORE-REQ-012 | Twenty-four launch Jokers and five-slot effects |
| CORE-REQ-013 | Versioned economy and antiabuse configuration |
| CORE-REQ-014 | Complete responsive user surfaces |
| CORE-REQ-015 | Blank-profile onboarding and first-session timing |
| CORE-REQ-016 | Full Formation Rush loop |
| CORE-REQ-017 | Four active tasks and boosts |
| CORE-REQ-018 | Active-first passive, offline, and retention progress |
| CORE-REQ-019 | Same-server Friend Clash |
| CORE-REQ-020 | Feature-flagged safe direct trading |
| CORE-REQ-021 | Guaranteed product grants and policy compliance |
| CORE-REQ-022 | Analytics, moderation, feature controls, and operations |
| CORE-REQ-023 | Device, accessibility, and performance support |
| CORE-REQ-024 | Complete verification and release-candidate hardening |
| CORE-REQ-025 | Private soft launch, controlled public release, and acceptance |
| CORE-REQ-026 | Continuous documentation and GitHub synchronization |

## 7. Optional or Future Scope

All items are `excluded` from the initial-release endpoint and are detailed without promotion in [full_plan.md](full_plan.md).

| ID | Excluded future outcome |
|---|---|
| FUT-001 | Remaining forty-nine Deck Sets and all 2,704 base identities |
| FUT-002 | Diamond through Unknown Editions and all 37,856 permanent forms |
| FUT-003 | Remaining twelve Traits |
| FUT-004 | Remaining ninety-six Jokers |
| FUT-005 | Remaining twenty-four Arcana |
| FUT-006 | All twelve Souls and Soul Packs |
| FUT-007 | Cooperative Boss Table and boss seasons |
| FUT-008 | Cross-server matchmaking and population-supported ratings |
| FUT-009 | Escrowed cross-server listing market |
| FUT-010 | Expanded spectators, wishlists, clubs or crews, and social live operations |
| FUT-011 | Story chapters, dialogue quests, or a larger world after explicit promotion |
| FUT-012 | Inventory sharding and deterministic large-number migration |
| FUT-013 | Multiple loadouts, endgame album rewards, and final leaderboards |
| FUT-014 | Expanded daily, weekly, event, and cosmetic season systems |
| FUT-015 | Later direct-trading enablement if launch uses the disabled fallback |

## 8. Non-Goals

| ID | Explicit exclusion |
|---|---|
| NG-001 | Protected franchise assets, identities, interfaces, or imitation branding |
| NG-002 | Poker, blackjack, casino, betting, wagering, stakes, chips, dealers, jackpots, or cash-out presentation |
| NG-003 | Paid random gameplay packs, hidden luck, purchasable odds, leaderboard power, or random power requirements |
| NG-004 | Real-money trading, Robux value display, player currency transfer, or wagered inventory |
| NG-005 | Client authority over inventory, RNG, scores, rewards, progression, purchases, trades, or persistence |
| NG-006 | Passive, offline, unattended, or held-input play as the strongest progression path |
| NG-007 | Additional content volume used to compensate for an unhealthy core loop |
| NG-008 | A guarantee of popularity, discovery rank, retention, spending, or audience size |
| NG-009 | Full 52 by 52 destination completion as an initial-release gate |
| NG-010 | Changing the GitHub repository's current public visibility as part of Roblox publication |

## 9. Owner Decisions

### DEC-001 — Initial-release authority

**Status:** RESOLVED
**Selected choice:** docs/general/plan.md is the authoritative initial public release plan and completion authority.
**Rationale:** The launch requires one clear endpoint and one global phase sequence.
**Affected requirements:** CORE-REQ-001, CORE-REQ-002, CORE-REQ-003, CORE-REQ-004, CORE-REQ-005, CORE-REQ-006, CORE-REQ-007, CORE-REQ-008, CORE-REQ-009, CORE-REQ-010, CORE-REQ-011, CORE-REQ-012, CORE-REQ-013, CORE-REQ-014, CORE-REQ-015, CORE-REQ-016, CORE-REQ-017, CORE-REQ-018, CORE-REQ-019, CORE-REQ-020, CORE-REQ-021, CORE-REQ-022, CORE-REQ-023, CORE-REQ-024, CORE-REQ-025, CORE-REQ-026
**Supersedes:** none

### DEC-002 — Exhaustive future destination

**Status:** RESOLVED
**Selected choice:** docs/general/full_plan.md is mandatory to author and register as a future aspect, but its execution remains excluded from initial-release completion.
**Rationale:** The 52 by 52 destination has an independent lifecycle and substantial content matrix.
**Affected requirements:** none
**Supersedes:** none

### DEC-003 — Initial content boundary

**Status:** RESOLVED
**Selected choice:** The launch contains three Deck Sets, 156 base identities, four Editions, 624 forms, eleven Grades, eleven Power Tiers, twelve Traits, twenty-four Jokers, twelve Arcana, twelve formations, and four active tasks.
**Rationale:** This is the smallest foundation that exercises every essential collection and active-play axis.
**Affected requirements:** CORE-REQ-002, CORE-REQ-009, CORE-REQ-010, CORE-REQ-011, CORE-REQ-012, CORE-REQ-013, CORE-REQ-014, CORE-REQ-015, CORE-REQ-016, CORE-REQ-017, CORE-REQ-018
**Supersedes:** none

### DEC-004 — Completion endpoint

**Status:** RESOLVED
**Selected choice:** A controlled public Roblox release closes the plan only after private soft launch and every mandatory initial-release gate pass.
**Rationale:** Code completion without real release evidence does not prove the product endpoint.
**Affected requirements:** CORE-REQ-024, CORE-REQ-025, CORE-REQ-026
**Supersedes:** none

### DEC-005 — Trading release gate

**Status:** RESOLVED
**Selected choice:** Trading is enabled only after every safety and production authorization gate passes; otherwise the public release proceeds with trading visibly disabled.
**Rationale:** Public inventory safety is stronger than feature completeness.
**Affected requirements:** CORE-REQ-020, CORE-REQ-024, CORE-REQ-025
**Supersedes:** none

### DEC-006 — Randomness and monetization

**Status:** RESOLVED
**Selected choice:** Gameplay packs are earned with visible odds and persistent pity; monetization is limited to guaranteed cosmetics and declared convenience without paid random power.
**Rationale:** The model preserves transparent progression and avoids paid randomized gameplay power.
**Affected requirements:** CORE-REQ-010, CORE-REQ-013, CORE-REQ-021
**Supersedes:** none

### DEC-007 — Originality and presentation

**Status:** RESOLVED
**Selected choice:** All branding, art, audio, interfaces, effects, and writing are original, and the game uses Card Formations without casino, poker, betting, or wagering presentation.
**Rationale:** Standard ranks and suits are generic building blocks, while every expressive product layer must be original and policy-safe.
**Affected requirements:** CORE-REQ-008, CORE-REQ-009, CORE-REQ-014, CORE-REQ-025
**Supersedes:** none

### DEC-008 — Server authority

**Status:** RESOLVED
**Selected choice:** The server owns inventory, RNG, scoring, rewards, progression, transactions, trades, purchases, policy decisions, and durable state; clients submit narrow intent and render results.
**Rationale:** Every valuable or persistent outcome crosses an untrusted client boundary.
**Affected requirements:** CORE-REQ-003, CORE-REQ-004, CORE-REQ-005, CORE-REQ-006, CORE-REQ-007, CORE-REQ-010, CORE-REQ-011, CORE-REQ-012, CORE-REQ-013, CORE-REQ-014, CORE-REQ-015, CORE-REQ-016, CORE-REQ-017, CORE-REQ-018, CORE-REQ-019, CORE-REQ-020, CORE-REQ-021, CORE-REQ-022
**Supersedes:** none

### DEC-009 — Permanent progress

**Status:** RESOLVED
**Selected choice:** Edition unlocks, discovery, Grade progress, pity rewards, instance identity, and ownership cannot silently regress or be destroyed by ordinary progression or balance changes.
**Rationale:** Permanent collection progress is a core product promise.
**Affected requirements:** CORE-REQ-005, CORE-REQ-006, CORE-REQ-007, CORE-REQ-010, CORE-REQ-011, CORE-REQ-020
**Supersedes:** none

### DEC-010 — Active-first progression

**Status:** RESOLVED
**Selected choice:** Active play remains the primary path and must be at least five times as efficient as the passive baseline in verification fixtures.
**Rationale:** Pack opening, deck decisions, tasks, and formations are the game; waiting is supplementary.
**Affected requirements:** CORE-REQ-013, CORE-REQ-016, CORE-REQ-017, CORE-REQ-018
**Supersedes:** none

### DEC-011 — Device and accessibility coverage

**Status:** RESOLVED
**Selected choice:** Every required activity supports touch, mouse, keyboard, controller, reduced motion, reduced flash, low graphics, readable rarity cues, and small-screen layouts.
**Rationale:** The public Roblox experience must not make one input device or intense visual effects mandatory.
**Affected requirements:** CORE-REQ-008, CORE-REQ-014, CORE-REQ-015, CORE-REQ-016, CORE-REQ-017, CORE-REQ-019, CORE-REQ-020, CORE-REQ-023, CORE-REQ-024
**Supersedes:** none

### DEC-012 — Expansion gate

**Status:** RESOLVED
**Selected choice:** Expansion begins only after onboarding, retention, storage, exploit, trade, and device metrics demonstrate a healthy foundation.
**Rationale:** Additional content cannot repair a weak or unsafe core loop.
**Affected requirements:** CORE-REQ-022, CORE-REQ-025
**Supersedes:** none

### DEC-013 — Public brand

**Status:** RESOLVED
**Selected choice:** InfiniteCardCollector is the owner-selected public name. The name, logo, icon, thumbnails, and related public assets must still pass trademark, Roblox experience search, originality, provenance, policy, and owner acceptance gates before publication.
**Rationale:** The owner has resolved the public name while preserving the independent clearance and asset-quality gates required for a safe release.
**Affected requirements:** CORE-REQ-009, CORE-REQ-025, EXT-007
**Supersedes:** none

### DEC-014 — Documentation and GitHub synchronization

**Status:** RESOLVED
**Selected choice:** Tracked documentation remains canonical, the wiki remains a navigation surface, and GitHub Issues, Project, milestones, pull requests, tags, and documentation are synchronized later without changing protected plan artifacts during execution.
**Rationale:** Execution evidence belongs in ordinary project and GitHub records, not in the pinned plan set.
**Affected requirements:** CORE-REQ-001, CORE-REQ-024, CORE-REQ-025, CORE-REQ-026
**Supersedes:** none

### DEC-015 — Qualified Phase 000 Vinegar Studio acceptance

**Status:** RESOLVED
**Selected choice:** Yes. The qualified Vinegar route independently satisfies the Phase 000 Studio gate when exact Vinegar, Wine, Studio, Rojo CLI and plugin, MCP connection, loopback synchronization, controlled resynchronization, client and server bootstrap, clean project console, and built-versus-synchronized topology parity evidence all pass. This does not claim official native Linux Studio support.
**Rationale:** The tested Vinegar path executes the actual Windows Studio binary and exercises the same project mapping, plugin protocol, client and server bootstraps, and synchronized DataModel. Exact evidence protects the acceptance boundary without requiring an unrelated workstation solely to repeat the already exercised Phase 000 runtime path.
**Affected requirements:** CORE-REQ-001
**Supersedes:** The Phase 000 native-only Studio acceptance restriction. It does not change later production, device, multiclient, or public release gates.

## 10. External Prerequisites

| ID | Prerequisite | Affected requirements | Availability | Authorization | Required external action |
|---|---|---|---|---|---|
| EXT-001 | Rojo v7.7.0 artifact contract | CORE-REQ-001, CORE-REQ-008, CORE-REQ-009, CORE-REQ-014, CORE-REQ-024 | available | not required | Preserve the mandatory artifact evidence contract below; no blocker is active |
| EXT-002 | Rokit v1.2.0 artifact contract | CORE-REQ-001, CORE-REQ-024 | available | not required | Preserve the mandatory artifact evidence contract below; no blocker is active |
| EXT-003 | StyLua v2.5.2 artifact contract | CORE-REQ-001, CORE-REQ-024 | available | not required | Preserve the mandatory artifact evidence contract below; no blocker is active |
| EXT-004 | Selene 0.31.0 artifact contract | CORE-REQ-001, CORE-REQ-004, CORE-REQ-024 | available | not required | Preserve the mandatory artifact evidence contract below; no blocker is active |
| EXT-005 | Lune v0.10.5 artifact contract | CORE-REQ-001, CORE-REQ-002, CORE-REQ-003, CORE-REQ-024 | available | not required | Preserve the mandatory artifact evidence contract below; no blocker is active |
| EXT-006 | Roblox universe, place, publisher permissions, and service access | CORE-REQ-004, CORE-REQ-005, CORE-REQ-006, CORE-REQ-010, CORE-REQ-015, CORE-REQ-016, CORE-REQ-017, CORE-REQ-018, CORE-REQ-019, CORE-REQ-020, CORE-REQ-021, CORE-REQ-022, CORE-REQ-023, CORE-REQ-024, CORE-REQ-025 | unknown | unknown | Provide the mandatory environment identities, permissions, service access, and smoke evidence; known blocker approved |
| EXT-007 | Final public brand and trademark clearance | CORE-REQ-009, CORE-REQ-025 | unavailable | not required | Produce and clear the mandatory final public identity and provenance packet; known blocker approved |
| EXT-008 | Private soft launch authorization | CORE-REQ-025 | unavailable | not authorized | Approve the exact private soft launch scope below; known blocker approved |
| EXT-009 | Public rollout authorization | CORE-REQ-025 | unavailable | not authorized | Approve the exact public rollout scope below; known blocker approved |
| EXT-010 | Production purchase smoke authorization | CORE-REQ-021 | unavailable | not authorized | Approve the exact destructive purchase smoke scope below; known blocker approved |
| EXT-011 | Production trade smoke authorization | CORE-REQ-020 | unavailable | not authorized | Approve only if trading is an enablement candidate; this optional prerequisite does not block the disabled endpoint |
| EXT-012 | Soft launch cohort, test accounts, and representative device coverage | CORE-REQ-015, CORE-REQ-019, CORE-REQ-020, CORE-REQ-023, CORE-REQ-024, CORE-REQ-025 | unknown | not required | Provide the mandatory cohort, accounts, device matrix, and completed evidence; known blocker approved |
| EXT-013 | Roblox product IDs, receipt testing, policy information, and commerce access | CORE-REQ-021, CORE-REQ-022, CORE-REQ-025 | unknown | unknown | Provide the mandatory product, permission, policy, receipt, and commerce evidence; known blocker approved |
| EXT-014 | GitHub write, Project, wiki, and repository settings permissions | CORE-REQ-026 | available | authorized | Preserve verified EnVisione access and required scopes; no blocker is active |

The unavailable endpoint prerequisites are explicitly accepted as known blockers. They do not weaken dependent scope or permit false completion.

### Artifact Evidence Contract for EXT-001 through EXT-005

Each artifact prerequisite binds exactly these evidence fields: `exact_version`, `authoritative_source`, `sha256`, `sha512`, `compatibility`, `license_provenance`, and `security_review`.

| ID | Exact version and authoritative source | Compatibility evidence | Required provenance and security evidence |
|---|---|---|---|
| EXT-001 | Rojo v7.7.0 from `https://github.com/rojo-rbx/rojo/releases/tag/v7.7.0` | Synchronizes the pinned project model with the selected Roblox Studio release and repository layout | Selected artifact identity, SHA-256, SHA-512, license, upstream provenance, release review, dependency review, executable provenance, and integration-surface review |
| EXT-002 | Rokit v1.2.0 from `https://github.com/rojo-rbx/rokit/releases/tag/v1.2.0` | Installs and resolves the pinned tool manifest reproducibly on the supported environment | Selected artifact identity, SHA-256, SHA-512, license, provenance, release review, download-source review, and managed-tool execution review |
| EXT-003 | StyLua v2.5.2 from `https://github.com/JohnnyMorganz/StyLua/releases/tag/v2.5.2` | Formats every Luau source set deterministically and passes the repository formatting check | Selected artifact identity, SHA-256, SHA-512, license, provenance, parser and formatter review, and repository-access review |
| EXT-004 | Selene 0.31.0 from `https://github.com/Kampfkarren/selene/releases/tag/0.31.0` | Analyzes the selected Luau and Roblox standard library contract and passes the full source tree | Selected artifact identity, SHA-256, SHA-512, license, provenance, release review, standard-library review, configuration review, and repository-access review |
| EXT-005 | Lune v0.10.5 from `https://github.com/lune-org/lune/releases/tag/v0.10.5` | Executes catalog, formation, score, migration, and property tests deterministically | Selected artifact identity, SHA-256, SHA-512, license, provenance, release review, runtime-capability review, filesystem and process review, and test-boundary review |

Version output and both checksums must be captured for the exact platform artifact before phase evidence is accepted.

### EXT-006 — Roblox Environment and Access

Required evidence is the exact universe ID, private test place ID, release place ID, owner identity, publisher role, and permission proof for private and public publishing, version rollback, DataStore, MemoryStore, PolicyService, MarketplaceService, analytics, and configuration. Isolated service-access smoke tests must succeed without exposing credentials or raw profiles.

### EXT-007 — Brand Clearance

Required evidence is the final owner-selected public name, logo, icon, and asset identities; recorded trademark and Roblox search results; originality and provenance review for the final launch presentation; and owner acceptance before the release artifact freezes.

### Authorization Scope for EXT-008 through EXT-011

Every authorization binds exactly `runbook_digest`, `artifact_identities`, `systems`, `operations`, `operators`, `time_window`, and `rollback`. Approval for one operation cannot authorize another.

| ID | Runbook and artifacts | Systems and allowed operations | Operators and time window | Rollback |
|---|---|---|---|---|
| EXT-008 | SHA-256 of the frozen private soft launch runbook; exact commit, build, config, catalog, universe, and private place IDs | Private release environment, production-format persistence, analytics, feature configuration, and controls; publish frozen build, restrict audience, apply frozen config, run approved smoke paths, collect sanitized evidence | Named publisher and release operators; explicit soft-launch start and end | Restore prior place version or close access, disable new economy actions, preserve committed state, retain diagnostics |
| EXT-009 | SHA-256 of the frozen public rollout runbook; exact commit, build, catalog, config, universe, place, metadata, icon, thumbnails, and flags | Audience controls, release place, production persistence, analytics, commerce, moderation, flags, rollback; widen access, apply approved metadata and config, observe gates, execute thresholds | Named publisher and release operators; explicit rollout and observation window | Restrict access or restore prior place version, disable unsafe features, preserve state, show approved maintenance state, retain evidence |
| EXT-010 | SHA-256 of the frozen purchase smoke runbook; exact commit, place version, product IDs, grant definitions, receipt schema, test accounts, and expected receipts | MarketplaceService, receipt processing, profile storage, transaction receipts, product flags, commerce diagnostics; approved purchases, duplicate delivery, rejoin restore, exact-once inspection | Named purchaser, publisher, and reviewer; bounded timestamps and transaction limit | Disable products, stop new grants, preserve receipts, reconcile incomplete operations, perform approved remediation |
| EXT-011 | SHA-256 of the frozen trade smoke runbook; exact commit, place version, trade config, test accounts, disposable instances, journals, and receipts | Trade service, production-format profiles, journals, reconciliation, flags, diagnostics; one approved offer, settlement, replay, disconnect or recovery, ownership and receipt inspection | Named participants, publisher, and reviewer; bounded timestamps and one test inventory | Disable new trades, preserve and reconcile prepared journals, restore approved test ownership under the runbook, retain evidence |

EXT-011 is not mandatory for the endpoint because DEC-005 permits a visibly disabled trading state.

### EXT-012 — Cohort and Device Coverage

Required evidence is a sanitized cohort manifest with participation consent; dedicated blank, migrated, purchase, duel, and trade account roles; a device matrix covering phone, tablet, desktop, keyboard, mouse, controller, reduced motion, reduced flash, color assistance, and low graphics; and completed soft-launch funnel, performance, crash, persistence, social, trade, and recovery evidence tied to the frozen candidate.

### EXT-013 — Commerce Access

Required evidence is the exact product IDs, guaranteed contents, prices, enabled regions, configuration version, public display copy, product management permissions, receipt and analytics access, PolicyService results, and successful isolated receipt, duplicate-delivery, rejoin-restore, disabled-product, and recovery tests.

### EXT-014 — GitHub Capability

Required evidence is the authenticated `EnVisione` identity, repository and Project mutation scopes, and read and write access for `EnVisione/InfiniteCardCollector` Issues, pull requests, milestones, roadmap Project, Actions, settings, releases, and wiki without exposing token material.

## 11. Architecture and Ownership Boundaries

| Component | Canonical ownership | Provides | Must not own |
|---|---|---|---|
| Shared catalogs | Content identities and enabled definitions | Stable data, versions, handler references, validation inputs | Mutable player state or service calls |
| Shared configuration | Economy, odds, features, limits, and balance | Versioned server values and display projections | Client authority or hidden mutable state |
| Shared calculation layer | Pure deterministic domain logic | Slot keys, formations, scores, traces, number normalization | Persistence, remotes, UI, mutable services |
| Network gateway | Client envelope validation and routing | Typed action schemas, rate limits, stable responses | Business mutations outside service methods |
| Profile service | Session and profile lifecycle | Load, lock, migrate, save, safe mode, shutdown | Gameplay calculations |
| Transaction service | Idempotent economy mutations | Operation receipts, revisions, retries, exact-once results | UI animation |
| Inventory service | Instance authority | Creation, lookup, provenance, locks, eligibility | RNG decisions |
| Collection service | Permanent discovery and records | Form grids, best records, completion state | Current ownership authority |
| Deck service | Active loadout | Fifty-two-slot validation and server preview inputs | Instance creation |
| Random service | Server RNG | Odds, pity evaluation, reproducible result records | Presentation timing |
| Pack service | Pack operations | Purchase, committed result, reveal and pending choice recovery | Score calculations |
| Progression service | Grade, Trait, salvage, and deterministic improvement | Validated progression changes | Pack purchases |
| Arcana service | One-card transformation | Eligibility, previews, confirmed applications | Client target authority |
| Joker service | Five-slot modifier system | Registry, conflicts, effect stages, Joker progress | Formation state ownership |
| Formation service | Active round authority | Hand, draw, detection, score, rewards, traces | Direct profile writes |
| Task service | Active task authority | Seeds, discrete actions, validation, outcomes | Input rendering |
| Boost service | Timed effects | Stacking, replacement, extension, expiration | Currency storage |
| Duel service | Same-server Friend Clash | Invitations, snapshots, rounds, caps, disconnect behavior | Stakes, trades, or wagers |
| Trade service | Direct-trade lifecycle | Offers, locks, journals, settlement, receipts, reconciliation | Real-money value |
| Analytics service | Sanitized evidence | Funnels, economy events, diagnostics, health metrics | Raw private text or profiles |
| Security service | Abuse controls | Limits, anomaly evidence, quarantine decisions | Irreversible punishment from one signal |
| Policy and purchase boundary | Policy and guaranteed commerce | Eligibility, product definition, receipts, restore | Paid random gameplay power |
| Client controllers | Presentation orchestration | Local input, authoritative state rendering, previews | Trusted outcomes |
| UI surfaces | Responsive interaction | Accessible product workflows | Service or persistence bypasses |
| Release operations | Artifact and environment lifecycle | Freeze, publish, observe, rollback, evidence | Scope changes or plan mutation |

### Initialization Order

1. Load and validate catalogs and configuration.
2. Register typed remotes and action schemas.
3. Start analytics, policy, security, profile, and transaction boundaries.
4. Start inventory, collection, random, pack, deck, progression, Arcana, and Joker services.
5. Start formation, task, boost, duel, trade, and leaderboard services.
6. Attach player lifecycle, autosave, network routing, and shutdown handling.
7. Accept an action only after that player's profile, recovery journal, policy state, and bootstrap snapshot are ready.

A required initialization failure closes economy actions and gives the player a safe maintenance exit. It never opens a partially initialized mutation path.

## 12. Requirements

### CORE-REQ-001 — Reproducible Roblox Development and Release Toolchain

**Behavior:** The repository pins and documents an executable Roblox Studio and typed Luau workflow using Rojo v7.7.0, Rokit v1.2.0, StyLua v2.5.2, Selene 0.31.0, and Lune v0.10.5, with exact setup, synchronization, formatting, linting, testing, build, Studio, packaging, and publication commands. Phase 000 Studio acceptance may use either native Roblox Studio on a platform currently supported by Roblox or the actual Windows Roblox Studio binary running through a qualified Vinegar and Wine environment on Linux under DEC-015.
**Owner:** repository toolchain
**Contributors:** release operations and documentation operations
**Dependencies:** DEC-001, DEC-008, DEC-015, EXT-001, EXT-002, EXT-003, EXT-004, EXT-005
**Lifecycle stage:** readiness
**Production verification:** none
**Release impact:** MVP

**Acceptance criteria**

- Clean Linux and Windows command-line environments can install the exact tools from the locked manifest and reproduce the documented version output. Windows command-line portability remains mandatory regardless of the Studio acceptance route.
- Formatting, linting, deterministic tests, project build, Studio synchronization, and release artifact creation each have one exact noninteractive command and defined expected output.
- A real Studio instance passes the Phase 000 runtime gate through either native Roblox Studio on a platform currently supported by Roblox or the qualified actual Windows Studio binary under Vinegar and Wine. The qualified route passes only when exact Vinegar, Wine, Studio deployment and client, Rojo CLI and plugin, MCP connection, loopback address, clean synchronization, controlled resynchronization and revert, client and server bootstrap, clean project console, built-versus-synchronized topology parity, and candidate-revision binding all match the accepted packet.
- The qualified Vinegar route makes no claim that Roblox Studio is natively or officially supported on Linux. A missing, mismatched, stale, or failed required field leaves the Studio gate open rather than falling back to a lower-fidelity substitute.
- The source layout enforces shared, server, client, asset, test, and tooling boundaries without requiring manual untracked edits.
- CI invokes the same pinned commands and rejects formatting, lint, test, build, documentation, secret, or artifact-integrity failures.

**Required evidence**

- Version output, authoritative sources, SHA-256, SHA-512, compatibility, license provenance, and security review for EXT-001 through EXT-005.
- A clean-environment command transcript and generated release-candidate artifact manifest tied to one commit.
- A Studio acceptance packet identifying the selected route and exact Studio channel, deployment and client; Rojo CLI and reviewed plugin; loopback address; clean synchronization; controlled source update, resynchronization, and revert; minimum client and server bootstrap; clean project console; built model, source map, and synchronized DataModel topology parity; and binding to the candidate revision. The qualified Vinegar route additionally records exact Vinegar and Wine identities and live MCP connection evidence.
- CI results proving all repository gates use the pinned workflow.

### CORE-REQ-002 — Exact Launch Catalogs and Configuration

**Behavior:** Versioned data catalogs and configuration define exactly three launch Deck Sets, 156 base identities, four enabled Editions, 624 permanent forms, eleven Grades, eleven Power Tiers, twelve Traits, twenty-four Jokers, twelve Arcana, twelve formations, launch currencies, odds, prices, limits, feature flags, and every referenced effect handler.
**Owner:** shared catalog layer
**Contributors:** shared configuration and content asset pipeline
**Dependencies:** CORE-REQ-001, DEC-003
**Lifecycle stage:** change
**Production verification:** none
**Release impact:** MVP

**Acceptance criteria**

- Catalog validation proves exact counts, unique stable IDs, valid references, legal effect parameters, required assets, and handler availability.
- Launch-disabled entries remain representable but cannot be acquired, equipped, scored, purchased, or exposed by a modified client.
- Balance changes modify versioned configuration rather than inventory identity.
- The canonical showcase card can be represented through ordinary data fields without a special case.

**Required evidence**

- Deterministic catalog snapshot and validator output tied to the release commit.
- Negative fixtures for duplicate IDs, missing assets, invalid references, illegal counts, and unknown handlers.
- Generated launch-count report matching SRC-006 and SRC-007.

### CORE-REQ-003 — Deterministic Formation and Effect Calculations

**Behavior:** Pure typed modules detect every valid launch Card Formation, calculate card contributions and output in one documented stage order, apply Editions, Grades, Power Tiers, Traits, affinities, Jokers, boosts, and mode rules, enforce caps, and emit an explainable trace.
**Owner:** shared calculation layer
**Contributors:** Joker service and formation service
**Dependencies:** CORE-REQ-001, CORE-REQ-002
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** MVP

**Acceptance criteria**

- All twelve formations accept valid submissions and reject near misses, duplicate instances, invalid ranks, and illegal submission sizes.
- A submission satisfying multiple patterns receives the configured best base reward plus only explicitly stackable bonuses.
- Identical normalized state produces the same result and trace regardless of table iteration order, client preview, reconnect, or presentation timing.
- Calculation stages declare additive and multiplicative groups, conflicts, precedence, caps, and safe number bounds.

**Required evidence**

- Pure unit and property tests for formation boundaries, stage order, caps, conflicts, and table-order invariance.
- Golden calculation traces for every launch Joker and representative Edition, Grade, Tier, Trait, affinity, boost, and mode interaction.
- Nondestructive Studio comparison between server output and client presentation for frozen fixtures.

### CORE-REQ-004 — Server-Authoritative Network and Security Contract

**Behavior:** One typed client action boundary and one typed server message boundary accept only registered actions and validate payload type, shape, depth, size, finite numbers, enums, permissions, ownership, state, timing, spatial context, request identity, and action-specific rate before routing intent.
**Owner:** network gateway
**Contributors:** Security service and every action-owning server service
**Dependencies:** CORE-REQ-001, DEC-008, EXT-004
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** MVP

**Acceptance criteria**

- Every public client action has an exact schema, maximum payload, state and permission preconditions, token-bucket limit, stable success response, and stable error response.
- Unknown actions, illegal fields, nonfinite values, oversized payloads, stale state, duplicate foreign instances, impossible timing, and another player's private instances fail without mutation.
- Server messages never disclose unrelated inventories, hidden hands, raw profiles, credentials, or arbitrary client text.
- Repeated request IDs are idempotent or rejected as conflicting according to the action contract.

**Required evidence**

- Schema and routing inventory covering every launch action.
- Automated hostile-input and rate-limit fixtures for every action.
- Studio server logs containing only sanitized action IDs, stable reason codes, and bounded evidence.

### CORE-REQ-005 — Durable Profile Lifecycle and Storage Compatibility

**Behavior:** Versioned profiles load through `UpdateAsync`, acquire one writable session, migrate pure repeatable schemas, save transactionally, remain within size budgets, enter read-only safe mode after unrecoverable writes, and expose storage interfaces that permit later journaled inventory sharding.
**Owner:** Profile service
**Contributors:** Inventory service, Transaction service, and release operations
**Dependencies:** CORE-REQ-001, DEC-008, DEC-009, EXT-006
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** MVP

**Acceptance criteria**

- A healthy session token prevents a second writable session, while an expired session requires recovery and journal reconciliation before reassignment.
- Reapplying every migration to an already migrated fixture produces the same normalized profile without ownership, currency, discovery, pity, or receipt loss.
- Realistic stress fixtures remain below 1,500,000 encoded bytes and warn at 1,000,000 bytes.
- Repeated save failure stops new rewards and mutations without overwriting the last durable profile.
- Shutdown stops new mutations, completes or journals active work, saves dirty profiles, and releases sessions within the platform window.

**Required evidence**

- Old-schema, current-schema, malformed, maximum-size, session-collision, throttle, retry, safe-mode, and shutdown fixtures.
- Serialized size reports and round-trip equality checks.
- Nondestructive isolated Roblox service-access and rejoin results tied to EXT-006.

### CORE-REQ-006 — Idempotent Transaction and Recovery Kernel

**Behavior:** Every pack, choice, reward, Arcana use, Grade update, salvage, deck edit, purchase grant, and other economy mutation executes through one operation envelope, checks preconditions, applies once, records a compact receipt, advances revision, and returns the same committed result on retry.
**Owner:** Transaction service
**Contributors:** Profile service and action-owning services
**Dependencies:** CORE-REQ-005, DEC-008, DEC-009
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** MVP

**Acceptance criteria**

- Repeating the same operation ID and identical payload never creates a second mutation.
- Reusing an operation ID with conflicting data fails without changing state.
- A failed precommit save preserves the prior balances and inventory; a committed operation reopens the exact result after disconnect.
- Receipt retention, compaction, and expiry cannot allow an old operation to execute again.

**Required evidence**

- Property tests for duplicate, reordered, concurrent, throttled, interrupted, and conflicting operations.
- Failure injection before validation, mutation, receipt recording, save, response, and client acknowledgement.
- Exact before profile, after profile, revision, receipt, and recovery hashes for representative operations.

### CORE-REQ-007 — Inventory, Collection, Ownership, and Deck Invariants

**Behavior:** Every playing card and Joker instance has one opaque server-generated identity, one effective owner, immutable provenance, versioned fields, controlled locks, permanent discovery, best records, and eligibility rules; the active deck accepts one owned instance for each rank and suit slot.
**Owner:** Inventory service
**Contributors:** Collection service and Deck service
**Dependencies:** CORE-REQ-002, CORE-REQ-005, CORE-REQ-006, DEC-009
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** MVP

**Acceptance criteria**

- Exactly one owned instance may occupy a slot key, and equipping never changes or duplicates ownership.
- Permanent discovery remains after an item is traded or salvaged, while current ownership updates accurately.
- Favorites, wishlist matches, trade locks, equipped items, active transformation targets, and the last owned copy are protected from unintended salvage or mutation.
- Content disablement prevents new use or acquisition according to policy without deleting existing ownership.
- Collection grids use compact stable encoding and round trip without bit loss.

**Required evidence**

- Instance creation, provenance, equip, unequip, duplicate, salvage, lock, discovery, transfer, and rejoin tests.
- Foreign-instance and duplicate-instance security fixtures for every inventory action.
- Ownership conservation assertions across every transaction and recovery path.

### CORE-REQ-008 — Reusable Layered Card Rendering System

**Behavior:** One data-driven renderer composes Deck Set art, suit, rank, Edition, Grade, Power Tier, Trait, and state overlays for 2D and 3D product surfaces, with pooled components, virtualized lists, static low-graphics replacements, and no gameplay authority.
**Owner:** card rendering system
**Contributors:** content asset pipeline and client application
**Dependencies:** CORE-REQ-001, CORE-REQ-002, DEC-007, DEC-011
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** MVP

**Acceptance criteria**

- The same card data renders consistently on the opening table, pack reveal, binder, deck, inspect panel, Formation Rush, Friend Clash, trade panel, showcase, and thumbnails.
- Edition, Grade, Power Tier, Trait, lock, favorite, new, wishlist, and trade state remain readable without relying only on color, sound, particles, or tilt.
- Binder and inventory surfaces render only visible entries and recycle components under large fixtures.
- Low graphics, reduced motion, reduced flash, and muted audio preserve all gameplay information.

**Required evidence**

- Golden visual fixtures for every launch layer and status combination.
- Device screenshots and frame, memory, allocation, pooling, and virtualization measurements.
- Nondestructive visual comparison across all consuming surfaces.

### CORE-REQ-009 — Complete Original Launch Asset Set

**Behavior:** The release artifact contains complete original and provenance-reviewed visual, audio, interface, world, pack, card, Joker, Arcana, icon, thumbnail, and metadata assets for the enabled launch experience, with every catalog reference resolved and no protected franchise material.
**Owner:** content asset pipeline
**Contributors:** card rendering system, client application, and release operations
**Dependencies:** CORE-REQ-002, CORE-REQ-008, DEC-007, DEC-013, EXT-007
**Lifecycle stage:** change
**Production verification:** none
**Release impact:** MVP

**Acceptance criteria**

- Classic, Radioactive, and Astral each provide fifty-two recognizable identities, a frame and suit treatment, pack wrapper, reveal sound, binder page, mastery presentation, and affinity cues.
- Normal, Foil, Golden, Steel, all launch Grades, all launch Power Tiers, all launch Traits, twenty-four Jokers, and twelve Arcana have complete presentation assets.
- Every asset has an identity, source, provenance or license, catalog reference, device fallback, and content review result.
- Originality, Community Standards, metadata, trademark, and Roblox search reviews find no unresolved blocker.

**Required evidence**

- Asset manifest with stable IDs, hashes, provenance, catalog references, fallbacks, and review status.
- Automated missing-reference and duplicate-identity report.
- Signed originality and policy review packet tied to the frozen release artifact and EXT-007.

### CORE-REQ-010 — Earned Packs, Published Odds, Pity, and Recovery

**Behavior:** Deck Set Packs grant five committed cards, Joker Packs offer three committed Jokers and one saved choice, and Arcana Packs offer three committed Arcana and one saved choice; all use server RNG, exact disclosed odds, persistent pity, early protection, idempotent operation state, accessible reveals, and disconnect recovery.
**Owner:** Pack service
**Contributors:** Random service, Transaction service, Inventory service, and client application
**Dependencies:** CORE-REQ-002, CORE-REQ-005, CORE-REQ-006, CORE-REQ-007, CORE-REQ-008, CORE-REQ-013, DEC-006, DEC-009
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** MVP

**Acceptance criteria**

- Currency deduction and pack contents commit in one operation before reveal.
- Power Tier weights total exactly one hundred percent in integer units, and pity triggers at the exact configured boundary only after the qualifying result commits.
- Starter and early packs satisfy missing-slot protection without replacing locked or manually selected cards.
- Pending Joker and Arcana choices preserve original offered IDs and survive disconnect, restart, and catalog update.
- Reveal UI shows exact contents, odds, pity, `NEW`, `UPGRADE`, `DUPLICATE`, or `WISHLIST`, and supports skip, reduced motion, reduced flash, muted sound, and reveal-all.

**Required evidence**

- Statistical and deterministic RNG tests, exact weight totals, pity boundary tests, and missing-slot fixtures.
- Failure injection at `created`, `contents_committed`, `revealed`, and `claimed`.
- Nondestructive blank-profile and rejoin workflows in Studio and the isolated Roblox environment.

### CORE-REQ-011 — Nonregressing Card Progression and Arcana

**Behavior:** Cards progress through all launch Grades, Power Tiers, Traits, and Normal, Foil, Golden, and Steel forms; Grade Ink, Trait Essence, Arcana, and salvage apply only to eligible confirmed targets through idempotent transactions and never silently lower, destroy, or replace permanent progress.
**Owner:** Progression service
**Contributors:** Arcana service, Inventory service, Collection service, and Transaction service
**Dependencies:** CORE-REQ-002, CORE-REQ-005, CORE-REQ-006, CORE-REQ-007, DEC-009
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** MVP

**Acceptance criteria**

- Grade promotion is deterministic, occurs once at each threshold, reaches LR, and never moves backward after balance changes.
- A launch Edition Arcana unlocks exactly one selectable form for one identity while prior forms remain available.
- Suit and rank Arcana create or unlock the target identity without deleting the source.
- Trait choices and replacements are explicit, respect locks, and never secretly replace a useful Trait.
- Salvage never consumes a new best result, favorite, wishlist match, traded item, locked item, equipped item, or last currently owned copy.

**Required evidence**

- Threshold, cap, one-target, one-consumption, lock, eligibility, repeated-operation, salvage-protection, and rejoin tests.
- Migration fixtures proving saved Grades, forms, Traits, and provenance survive catalog and balance version changes.
- Nondestructive Studio workflows for every launch Arcana category and progression path.

### CORE-REQ-012 — Five-Slot Launch Joker System

**Behavior:** Players collect and inspect twenty-four named launch Jokers and equip no more than five; each definition references a registered handler and parameters, effect stages are deterministic, conflicts are explicit, duplicates bind only after deliberate choice, and every result is explainable.
**Owner:** Joker service
**Contributors:** shared calculation layer, Inventory service, and client application
**Dependencies:** CORE-REQ-002, CORE-REQ-003, CORE-REQ-007
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** MVP

**Acceptance criteria**

- The enabled catalog contains exactly the selected eight Common, five Uncommon, four Rare, three Epic, two Legendary, and two Mythic launch Jokers.
- A sixth active Joker is rejected, and removing or replacing a Joker updates the server calculation contract atomically.
- Every Joker handler declares its calculation stages, parameters, conflicts, caps, and trace entries.
- Duplicate binding never occurs automatically and cannot consume a favorite, locked, traded, or only owned copy.

**Required evidence**

- Catalog-count, handler-reference, five-slot, duplicate-binding, conflict, cap, and trace tests for all twenty-four launch Jokers.
- Pairwise and representative five-Joker combination fixtures.
- Nondestructive Studio inspection showing server traces and user-facing explanations agree.

### CORE-REQ-013 — Versioned Economy and Antiabuse Configuration

**Behavior:** Server configuration owns integer prices, rewards, currencies, pity, caps, pack cadence, boost rules, passive rates, reward eligibility, anti-farming, and analytics reason IDs; client requests never supply trusted values.
**Owner:** shared configuration
**Contributors:** Transaction service, Analytics service, and gameplay services
**Dependencies:** CORE-REQ-001, CORE-REQ-002, CORE-REQ-005, CORE-REQ-006, DEC-006, DEC-010
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** MVP

**Acceptance criteria**

- Cash, Joker Tickets, Arcana Dust, Grade Ink, Trait Essence, Duel Tokens, Ascension Fragments, and reserved Soul Fragments have declared sources, sinks, transfer rules, caps, and reason codes.
- Prices and rewards are versioned integers and cannot underflow, overflow the launch bound, or be derived from client display values.
- Social reward caps and same-opponent diminishing returns prevent repeat farming without blocking unrewarded private play.
- Active reward fixtures produce at least five times the normalized passive baseline.
- Every currency change records previous balance, integer delta, reason ID, resulting balance, operation ID, and sanitized context.

**Required evidence**

- Source-and-sink coverage, boundary, underflow, overflow, cap, anti-farming, cadence, and active-versus-passive tests.
- Economy configuration snapshot and migration compatibility report.
- Nondestructive analytics comparison between committed receipts and emitted currency events.

### CORE-REQ-014 — Complete Responsive Product Surfaces

**Behavior:** The client application presents authoritative state through a responsive HUD, opening table, binder, deck builder, card inspect, Arcana Lab, Joker Stage, showcase, Formation Rush, tasks, Friend Clash, trade, settings, tutorial, and recovery surfaces.
**Owner:** client application
**Contributors:** card rendering system, network gateway, and server services
**Dependencies:** CORE-REQ-004, CORE-REQ-007, CORE-REQ-008, DEC-011
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** MVP

**Acceptance criteria**

- Every surface renders server state, sends only registered intent, handles pending and failure states, and never invents a successful mutation.
- The HUD prioritizes Cash, one focused secondary currency, pack progress, boost, task, and next goal without crowding a phone screen.
- Binder and deck views distinguish discovered, currently owned, active, duplicate, missing, favorite, wishlist, lock, and tradable state.
- Trade confirmation shows exact items, only-copy warnings, offer revision, readiness, countdown, connection state, and immutable receipt without relying on color alone.
- Settings include all audio, motion, flash, graphics, reveal, auto-equip, social request, color assistance, UI scale, and tutorial replay controls defined by SRC-007.

**Required evidence**

- Controller and UI state tests for success, pending, stale, retry, read-only, disabled-feature, and maintenance paths.
- Screenshot and interaction matrix for phone, tablet, desktop, touch, mouse, keyboard, controller, color assistance, and accessibility settings.
- Nondestructive end-to-end navigation using authoritative server messages.

### CORE-REQ-015 — Blank-Profile Onboarding and First Session

**Behavior:** A blank profile opens one free five-card pack within thirty seconds, understands the fifty-two-slot deck, submits a guided Single and Twin within two minutes, completes Suit Sorter and opens a second pack within five minutes, then discovers binder, Joker, Arcana, collection, wishlist, and same-server social goals through dismissible normal play.
**Owner:** onboarding system
**Contributors:** Pack service, Deck service, Formation service, Task service, client application, and Analytics service
**Dependencies:** CORE-REQ-010, CORE-REQ-012, CORE-REQ-014, CORE-REQ-016, CORE-REQ-017, EXT-006, EXT-012
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** MVP

**Acceptance criteria**

- A player is never trapped in a long modal tutorial, may dismiss guidance, and can rediscover every action later.
- Starter cards occupy five unique slots, early missing-slot protection fills the documented thresholds, and auto-equip never replaces a locked or manually chosen card.
- Every tutorial checkpoint persists, reopens correctly after disconnect, and does not duplicate rewards.
- The next useful action is visible after each reward screen.
- Frozen private-launch evidence meets the initial first-pack and first-Formation timing and completion thresholds or blocks widening access.

**Required evidence**

- Blank, interrupted, resumed, skipped, completed, and migrated tutorial fixtures.
- Nondestructive Studio and isolated-environment first-session recordings on required input paths.
- Sanitized onboarding funnel and timing report tied to the release candidate.

### CORE-REQ-016 — Complete Formation Rush Loop

**Behavior:** The server runs a sixty-second Formation Rush state machine with an authoritative seed, round ID, ordered draw pile, eight-card hand, discard pile, redraws, one-to-five-card submissions, all twelve formations, streaks, prompts, timing, calculation traces, and committed rewards.
**Owner:** Formation service
**Contributors:** shared calculation layer, Deck service, Joker service, Transaction service, and client application
**Dependencies:** CORE-REQ-003, CORE-REQ-004, CORE-REQ-007, CORE-REQ-012, CORE-REQ-013
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** MVP

**Acceptance criteria**

- Blanks appear only when the active deck cannot supply the required hand and contribute no rank, suit, output, Tier, Trait, or Edition.
- Used cards enter discard, refill is deterministic, and reshuffling remains inside the same round state.
- Stale round IDs, cards outside the hand, duplicate cards, illegal counts, expired timing, nonwritable profiles, and rate violations fail without consuming cards or rewards.
- Server and client previews agree for valid state, while the server remains authoritative.
- Round rewards commit idempotently and recover after disconnect or shutdown.

**Required evidence**

- Pure and integration tests for every state, formation, draw boundary, reshuffle, redraw, streak, prompt, timeout, rejection, reward, and recovery path.
- Nondestructive Studio workflows for full rounds on required devices and accessibility settings.
- Calculation traces and operation receipts tied to identical frozen round fixtures.

### CORE-REQ-017 — Four Active Tasks and Timed Boosts

**Behavior:** Suit Sorter, Sequence Bench, Arcana Trace, and Grade Press use server-generated seeds, targets, start times, plausible timing, ordered discrete actions, bounded rewards, accessible alternatives, and saved timed boosts with deterministic stacking and expiration.
**Owner:** Task service
**Contributors:** Boost service, Transaction service, client application, and Security service
**Dependencies:** CORE-REQ-004, CORE-REQ-006, CORE-REQ-013, CORE-REQ-014, DEC-011
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** MVP

**Acceptance criteria**

- Correct play grants the documented focused currency and boost, while a miss reduces only local efficiency and never erases all progress or downgrades a card.
- The client reports actions rather than final rewards, and impossible order, speed, rate, or membership earns no reward and records a bounded security signal.
- Touch targets, remappable keyboard controls, controller navigation, broad timing zones, static reduced-motion paths, and an untimed alternative are usable.
- A stronger same-type boost replaces a weaker boost, repeat boosts extend to a cap, active-only boosts pause offline, and absolute expiration survives rejoin.

**Required evidence**

- Seed, action-order, timing, rate, lag-tolerance, reward-bound, boost-stack, expiration, reconnect, and exploit fixtures for every task.
- Nondestructive Studio completion on every required device and accessibility mode.
- Sanitized task and boost analytics matching committed receipts.

### CORE-REQ-018 — Active-First Passive, Offline, and Retention Progress

**Behavior:** Equipped cards produce bounded passive table value, offline return uses trusted timestamps and a four-hour cap, daily goals and collection rewards create visible next actions, and all passive systems remain substantially weaker than ordinary active play.
**Owner:** retention system
**Contributors:** Boost service, Collection service, Transaction service, and Analytics service
**Dependencies:** CORE-REQ-005, CORE-REQ-006, CORE-REQ-007, CORE-REQ-013, CORE-REQ-014, DEC-010
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** MVP

**Acceptance criteria**

- Offline reward shows trusted duration, applied rate, cap, version, and exact committed result.
- Offline time cannot roll Power Tiers, apply Arcana, promote Grades, trade, earn duel rating, or trigger active-only effects.
- Timestamp rollback, future time, repeated claims, version changes, and long absences cannot exceed configured caps.
- Active fixtures earn at least five times the normalized passive baseline.
- Missing a day does not erase valuable permanent progress or require a punitive streak reset.

**Required evidence**

- Time-boundary, timezone-independent, repeated-claim, clock-skew, cap, boost, rejoin, and version-migration tests.
- Active-versus-passive comparison report for frozen representative decks.
- Nondestructive offline-return workflow and matching analytics receipt.

### CORE-REQ-019 — Same-Server Friend Clash Without Stakes

**Behavior:** Eligible same-server players may invite, accept, snapshot loadouts, and play a best-of-five Power or Fair Friend Clash with shared prompts, authoritative submissions, disconnect handling, anti-farming reward caps, and no wager or inventory transfer.
**Owner:** Duel service
**Contributors:** Formation service, Transaction service, client application, and Analytics service
**Dependencies:** CORE-REQ-003, CORE-REQ-004, CORE-REQ-007, CORE-REQ-013, CORE-REQ-014, CORE-REQ-016, EXT-012
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** MVP

**Acceptance criteria**

- Invitations expire after thirty seconds, either player can decline without penalty, and loadouts lock only for the match snapshot.
- Power mode uses collection strength, while Fair mode normalizes Grade, Power Tier, and Edition multipliers without changing legal card choices or deterministic rule interactions.
- Disconnect before round two cancels rewards; later disconnect follows the configured grace and result contract.
- Same-opponent rewards diminish and stop at the cap, while private rematches remain playable without rewards.
- Match completion never transfers an item or uses stake, bet, wager, or winner-take-all currency.

**Required evidence**

- Two-client invite, decline, timeout, accept, full match, disconnect, reconnect, rematch, cap, replay, stale request, and hostile input tests.
- Fair-versus-Power normalization traces from frozen loadouts.
- Nondestructive multiclient Studio and private-environment results tied to EXT-012.

### CORE-REQ-020 — Feature-Flagged Direct Trading and Recovery

**Behavior:** Eligible same-server players may trade allowed instances through server-owned offers, exact revisions, lock validation, readiness reset, countdown, persistent journal, idempotent two-profile settlement, receipts, history, and recovery; new trades remain visibly disabled unless every enablement gate passes.
**Owner:** Trade service
**Contributors:** Profile service, Transaction service, Inventory service, client application, and Security service
**Dependencies:** CORE-REQ-004, CORE-REQ-005, CORE-REQ-006, CORE-REQ-007, CORE-REQ-014, DEC-005
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** MVP

**Acceptance criteria**

- Eligibility, account age, active time, tutorial, profile state, item lock, offer limit, cooldown, and countdown are server configuration and server validated.
- Any offer edit clears both Ready states, and the exact offer hash shown during countdown matches the prepared journal.
- One instance has one effective owner; prepared or settling items cannot be equipped, altered, salvaged, packed, or retraded.
- Every interruption from requested through completed either cancels before prepare or reconciles the exact prepared transfer once.
- The public build exposes either a fully gated enabled state or a clearly disabled state that rejects new requests while preserving prepared recovery.

**Required evidence**

- Two-client tests and failure injection for both disconnects, server stop, write failure, replay, reordering, locked-item mutation, rejoin, and reconciliation at every state.
- Conservation proof showing exactly one effective owner and matching receipts for every completed or recovered fixture.
- Feature-disabled tests proving no new journal or lock can begin.
- EXT-011 authorization and bounded production smoke only if trading is proposed for enablement.

### CORE-REQ-021 — Guaranteed Purchases and Exact-Once Receipts

**Behavior:** The launch sells only guaranteed cosmetics and declared convenience, displays exact contents before purchase, evaluates applicable policy information, processes receipts idempotently, restores durable entitlements, and never sells random gameplay power, hidden luck, trade currency, or inventory recovery.
**Owner:** purchase boundary
**Contributors:** Policy service, Transaction service, Profile service, client application, and Analytics service
**Dependencies:** CORE-REQ-004, CORE-REQ-005, CORE-REQ-006, CORE-REQ-007, CORE-REQ-014, DEC-006, EXT-010, EXT-013
**Lifecycle stage:** change
**Production verification:** destructive
**Destructive approval prerequisite:** EXT-010
**Release impact:** stable release

**Acceptance criteria**

- Every enabled product has a stable product ID, exact guaranteed grant, display copy, price, policy contract, restore behavior, and emergency disable control.
- A duplicate or delayed receipt grants no second entitlement and returns the committed result.
- Rejoin, server restart, profile migration, product disablement, and callback reordering preserve exact ownership and receipt state.
- No launch product changes gameplay pack odds, grants hidden luck, sells random power, transfers currency, erases another player's progress, or charges for recovery.

**Required evidence**

- Isolated receipt, duplicate, delayed, reordered, interrupted, disabled, policy, restore, and migration tests under EXT-013.
- Frozen product catalog and guaranteed-content inspection.
- Separately authorized production purchase smoke and exact reconciliation packet under EXT-010.

### CORE-REQ-022 — Analytics, Feature Controls, Moderation, and Operations

**Behavior:** Server services emit sanitized onboarding, economy, pack, collection, progression, formation, task, duel, trade, purchase, persistence, error, and security evidence; operators can observe health, disable unsafe features, preserve recovery, and use versioned rollback configuration.
**Owner:** Analytics service
**Contributors:** Security service, release operations, and every emitting service
**Dependencies:** CORE-REQ-004, CORE-REQ-005, CORE-REQ-006, CORE-REQ-013
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** stable release

**Acceptance criteria**

- Event schemas use stable IDs and bounded properties and never include raw player text, authentication data, full inventory dumps, raw profiles, or unrelated private state.
- Currency and transaction events reconcile to receipts and profile revisions.
- Operators can disable individual content, packs, purchase, salvage, Arcana, Grade, passive rewards, Friend Clash rewards, trading, announcements, and products without deleting ownership or blocking prepared recovery.
- Dashboards expose first-pack and Formation funnels, failures, save health, crashes, duplication, trade recovery, performance, and release thresholds.
- Quarantined profiles and impossible values are excluded from public boards and retain evidence for review.

**Required evidence**

- Event-schema validation, redaction tests, receipt-to-event reconciliation, and volume-bound tests.
- Feature-control tests for each emergency path and neutral fallback.
- Dashboard, alert, leaderboard, moderation, diagnostics, and rollback configuration inspection tied to the release candidate.

### CORE-REQ-023 — Device, Accessibility, and Performance Contract

**Behavior:** Every mandatory activity remains readable and completable on representative mobile, tablet, desktop, touch, mouse, keyboard, and controller paths, with reduced motion, reduced flash, muted reveal audio, color assistance, UI scaling, low graphics, bounded server work, and acceptable eight-player performance.
**Owner:** client application
**Contributors:** card rendering system, server services, verification system, and content asset pipeline
**Dependencies:** CORE-REQ-008, CORE-REQ-014, CORE-REQ-015, CORE-REQ-016, CORE-REQ-017, CORE-REQ-019, CORE-REQ-020, DEC-011, EXT-012
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** stable release

**Acceptance criteria**

- Important rarity, selection, confirmation, warning, and trade information uses text and symbols in addition to color, motion, sound, particles, or tilt.
- Timing tasks provide broad targets and an untimed alternative; reduced settings do not hide required state.
- Binder pages virtualize, cards and effects pool, preload remains bounded, passive work avoids frame loops, and formation detection remains bounded to eight cards and five submissions.
- Profile size, payload size, server script time, client frame rate, peak memory, asset loading, and eight-player contention stay within recorded release budgets.
- No required text clips or confirmation detail disappears on the smallest supported layout.

**Required evidence**

- EXT-012 device and account matrix with completed workflow records.
- Frame-time, memory, allocation, payload, profile-size, load, and eight-player test reports.
- Accessibility review, screenshots, controller focus traces, reduced-setting comparisons, and manual experience review.

### CORE-REQ-024 — Complete Verification and Release-Candidate Hardening

**Behavior:** The frozen release candidate passes every required formatting, static, pure, integration, Studio, multiclient, migration, hostile-input, persistence, transaction, failure-injection, performance, accessibility, rollback, artifact, documentation, and manual experience gate without a known mandatory defect.
**Owner:** verification system
**Contributors:** all product components and release operations
**Dependencies:** CORE-REQ-001, CORE-REQ-002, CORE-REQ-003, CORE-REQ-004, CORE-REQ-005, CORE-REQ-006, CORE-REQ-007, CORE-REQ-008, CORE-REQ-009, CORE-REQ-010, CORE-REQ-011, CORE-REQ-012, CORE-REQ-013, CORE-REQ-014, CORE-REQ-015, CORE-REQ-016, CORE-REQ-017, CORE-REQ-018, CORE-REQ-019, CORE-REQ-020, CORE-REQ-021, CORE-REQ-022, CORE-REQ-023, EXT-012
**Lifecycle stage:** change
**Production verification:** nondestructive
**Release impact:** stable release

**Acceptance criteria**

- Every requirement has deterministic proof and the highest-fidelity applicable real workflow.
- Every public remote passes wrong-type, missing-field, oversized, stale, duplicate, reordered, high-frequency, and foreign-instance tests.
- Persistence passes throttle, collision, migration, shutdown, safe-mode, and recovery tests.
- Trading passes its full failure matrix or remains in the accepted disabled state.
- The final place artifact contains only intended source, assets, metadata, and configuration and no credentials, caches, debug output, machine paths, or unrelated files.
- Manual review finds the first pack understandable, next action visible, rarity readable, controls usable, binder responsive, trade details stable, and prohibited gambling presentation absent.

**Required evidence**

- Requirement-to-test matrix and complete command results tied to the frozen commit and artifact hashes.
- Studio and multiclient recordings, failure-injection reports, device evidence, performance reports, and manual review packet.
- Final diff, artifact inventory, secret scan, provenance report, documentation link check, and release-gate audit.

### CORE-REQ-025 — Private Soft Launch, Public Rollout, and Acceptance

**Behavior:** Release operations freeze an original and policy-reviewed candidate, obtain scoped authorization, run a private soft launch, stop for decisive product or safety failures, execute a controlled public Roblox rollout, verify production funnels and integrity, and preserve rollback until the plan-wide endpoint is proven.
**Owner:** release operations
**Contributors:** product owner, verification system, Analytics service, and documentation operations
**Dependencies:** CORE-REQ-020, CORE-REQ-021, CORE-REQ-022, CORE-REQ-023, CORE-REQ-024, DEC-004, DEC-005, DEC-013, EXT-006, EXT-007, EXT-008, EXT-009, EXT-010, EXT-012, EXT-013
**Lifecycle stage:** post-change
**Production verification:** nondestructive
**Release impact:** stable release

**Acceptance criteria**

- The final name, logo, icon, thumbnails, assets, sounds, metadata, Community Standards review, provenance, and search clearance pass before publication.
- Private soft launch proves blank-profile first pack and Formation Rush, save integrity, crash health, device performance, feature controls, rollback, and no decisive fixable onboarding failure.
- Public rollout uses only the frozen artifacts, systems, operations, operators, time window, and rollback bound by EXT-009.
- Production validation finds no known profile loss, item duplication, infinite reward, currency underflow, unhandled receipt, unsafe remote, inaccessible required path, or unmonitored critical failure.
- Trading is enabled only when all trade gates including EXT-011 pass; otherwise the visibly disabled state is verified.
- The final public endpoint remains healthy through the runbook's observation window or rolls back without claiming completion.

**Required evidence**

- EXT-006 through EXT-010, EXT-012, and EXT-013 evidence packets.
- Private soft-launch report, frozen artifact manifest, launch decision record, public rollout transcript, production health evidence, and rollback readiness inspection.
- Nondestructive blank production profile, funnel, feature-state, analytics, accessibility, persistence, and recovery checks after rollout.

### CORE-REQ-026 — Continuous Documentation and GitHub Synchronization

**Behavior:** Tracked documentation remains accurate and canonical, execution evidence is recorded outside the protected plan set, protected plan changes occur only through a current direct owner-authorized Plan Creator pass, and GitHub Issues, roadmap Project, milestones, phase branches, pull requests, checks, reviews, merge commits, signed tags, releases, and wiki navigation remain synchronized with actual verified state. The saved goal remains immutable, and execution under it rereads the current authoritative plan set after an authorized plan revision.
**Owner:** documentation operations
**Contributors:** repository operations and every phase owner
**Dependencies:** DEC-014, EXT-014
**Lifecycle stage:** continuous
**Production verification:** none
**Release impact:** stable release

**Acceptance criteria**

- Behavior, architecture, schemas, commands, compatibility, tests, operations, troubleshooting, and release status are documented only after implementation evidence exists.
- Each phase starts from the latest approved `origin/main`, integrates through a merge-commit pull request, waits for required checks and review, and receives a signed annotated phase tag after merge.
- The next phase never starts before the previous merge is present on `origin/main` and its tag is pushed.
- Issues, Project status, milestones, pull requests, documentation, releases, and wiki navigation agree with the merged repository state.
- `plan.md`, `full_plan.md`, registered phase plans, `plan.index.json`, and `plan.handoff.json` remain authoritative product-contract inputs rather than status diaries and may change only during a current direct owner-authorized Plan Creator pass. A saved goal remains immutable; its recorded plan and plan-set digests are creation-time provenance rather than runtime locks.

**Required evidence**

- Documentation diff and link-check results for every phase completion packet.
- GitHub identity, scope, issue, Project, milestone, pull request, check, review, merge, tag, release, and wiki verification under EXT-014.
- Final synchronization audit proving no protected plan artifact changed outside a current direct owner-authorized Plan Creator pass, every authorized plan revision is represented by the current validated plan set and deterministic handoff, and the saved goal itself retained its original digest.

## 13. Phased Roadmap

The master owns the global sequence, canonical requirement ownership, and concise gates. Each linked file contains the sole canonical full phase declaration and execution blueprint. No phase may execute before the complete validated plan set and Goal Creator handoff exist.

| Phase ID | Objective | Owner | Dependencies | Canonical requirements | Entry summary | Exit summary | Next transition | Execution blueprint |
|---|---|---|---|---|---|---|---|---|
| CORE-PHASE-000 | Establish the reproducible toolchain, source boundaries, exact commands, local harness, and CI foundation | repository toolchain | DEC-001, DEC-008, DEC-015, EXT-001, EXT-002, EXT-003, EXT-004, EXT-005 | CORE-REQ-001 | The current validated plan set and immutable saved goal describe the same project, active phase, and endpoint; goal-recorded plan digests remain creation-time provenance | Clean Linux and Windows command-line setup reproduces all tool versions and formatting, lint, test, build, artifact, and CI commands, and either native supported-platform Studio or the qualified actual Windows Studio binary under Vinegar and Wine passes the complete Studio acceptance packet without a mandatory defect | CORE-PHASE-001 | [Phase 000](phases/plan-phase-000.md) |
| CORE-PHASE-001 | Implement exact catalogs, configuration, deterministic formations, scores, effects, traces, and economy contracts | shared calculation layer | CORE-PHASE-000, DEC-003, DEC-006, DEC-010 | CORE-REQ-002, CORE-REQ-003, CORE-REQ-013 | Phase 000 is merged and tagged; exact tool and source contracts pass | Catalog counts and references are exact, all pure tests and property tests pass, and the showcase card uses ordinary data | CORE-PHASE-002 | [Phase 001](phases/plan-phase-001.md) |
| CORE-PHASE-002 | Build the server-authoritative network, durable profile and transaction kernel, inventory and deck boundaries, renderer foundation, and recoverable vertical slice | Profile service | CORE-PHASE-001, DEC-008, DEC-009, EXT-006 | CORE-REQ-004, CORE-REQ-005, CORE-REQ-006, CORE-REQ-007, CORE-REQ-008 | Phase 001 is merged and tagged; pure contracts and service interfaces are frozen | A blank account opens, equips, scores, disconnects at each step, rejoins, and recovers exact state; storage, network, security, and renderer gates pass | CORE-PHASE-003 | [Phase 002](phases/plan-phase-002.md) |
| CORE-PHASE-003 | Complete all launch assets, packs, progression, Jokers, and responsive collection surfaces | content asset pipeline | CORE-PHASE-002, DEC-003, DEC-007, DEC-009 | CORE-REQ-009, CORE-REQ-010, CORE-REQ-011, CORE-REQ-012, CORE-REQ-014 | Phase 002 is merged and tagged; vertical-slice persistence and rendering are proven | All 624 forms are reachable, every launch content count and asset resolves, pity and choices recover, progression never regresses, and all collection surfaces pass | CORE-PHASE-004 | [Phase 003](phases/plan-phase-003.md) |
| CORE-PHASE-004 | Complete onboarding, Formation Rush, four tasks, boosts, passive return, and active-first retention | Formation service | CORE-PHASE-003, DEC-010, DEC-011, EXT-006 | CORE-REQ-015, CORE-REQ-016, CORE-REQ-017, CORE-REQ-018 | Phase 003 is merged and tagged; complete launch content and surfaces are available | First-session timing is achievable, every active loop and recovery path passes, required inputs work, and active rewards exceed the passive baseline by at least five times | CORE-PHASE-005 | [Phase 004](phases/plan-phase-004.md) |
| CORE-PHASE-005 | Deliver safe same-server Power and Fair Friend Clash | Duel service | CORE-PHASE-004, EXT-012 | CORE-REQ-019 | Phase 004 is merged and tagged; authoritative formation and device paths pass | Two clients complete, disconnect, reconnect, rematch, and hit reward caps without stakes, transferred inventory, private-state leakage, or a mandatory defect | CORE-PHASE-006 | [Phase 005](phases/plan-phase-005.md) |
| CORE-PHASE-006 | Implement direct-trade settlement and freeze the `enablement_candidate` or `visibly_disabled` readiness state while `TradeEnabled` remains false | Trade service | CORE-PHASE-005, DEC-005 | CORE-REQ-020 | Phase 005 is merged and tagged; two-client harness, persistence, and inventory conservation are stable | All mandatory isolated trade states, recovery, accessibility, and security gates pass; readiness is exact and Phase 009 retains sole ownership of `EXT-011` production enablement | CORE-PHASE-007 | [Phase 006](phases/plan-phase-006.md) |
| CORE-PHASE-007 | Complete guaranteed commerce, policy, analytics, moderation, feature controls, and rollback operations | Analytics service | CORE-PHASE-006, DEC-006, EXT-010, EXT-013 | CORE-REQ-021, CORE-REQ-022 | Phase 006 is merged and tagged; trade readiness is frozen and `TradeEnabled` is false | Guaranteed products grant exactly once including authorized production smoke, observability reconciles to receipts, and every emergency control and rollback configuration passes | CORE-PHASE-008 | [Phase 007](phases/plan-phase-007.md) |
| CORE-PHASE-008 | Harden the complete release candidate across devices, accessibility, performance, security, persistence, recovery, artifacts, and manual experience | verification system | CORE-PHASE-007, EXT-012 | CORE-REQ-023, CORE-REQ-024 | Phase 007 is merged and tagged; all product components and operations controls are implemented | The frozen candidate passes every deterministic and highest-fidelity gate, contains no known mandatory defect, and is eligible for authorized private soft launch | CORE-PHASE-009 | [Phase 008](phases/plan-phase-008.md) |
| CORE-PHASE-009 | Clear the final brand, execute private soft launch and controlled public rollout, verify the endpoint, synchronize documentation and GitHub, and close the plan | release operations | CORE-PHASE-008, DEC-004, DEC-005, DEC-013, DEC-014, EXT-006, EXT-007, EXT-008, EXT-009, EXT-010, EXT-012, EXT-013, EXT-014 | CORE-REQ-025, CORE-REQ-026 | Phase 008 is merged and tagged; candidate, runbooks, permissions, cohort, products, brand, and rollback evidence are frozen | Public production gates and observation pass, trading is safely enabled or visibly disabled, documentation and GitHub agree with merged state, and the plan-wide Definition of Done closes | final plan-wide completion | [Phase 009](phases/plan-phase-009.md) |

Global phase numbers are contiguous and cannot be skipped, reordered, reserved, or reused. A phase cannot close while a known mandatory phase-owned defect remains. Future work never authorizes stacking a later branch before the current phase merge and tag are complete.

## 14. Verification Strategy and Evidence Matrix

| Requirement family | Static or unit | Integration | Real behavior | Security and recovery | Evidence artifact |
|---|---|---|---|---|---|
| CORE-REQ-001 | Version, config, command, route-selection, identity-binding, and documentation checks | Clean Linux and Windows setup, artifact build, MCP discovery, loopback sync, and controlled resync | Native supported-platform Studio or qualified actual Windows Studio under Vinegar and Wine, with client and server bootstrap, clean project console, and topology parity | Tool and plugin provenance, exact Vinegar and Wine identity for the qualified route, loopback-only connection, stale-evidence rejection, and secret boundaries | Tool manifest, hashes, command transcripts, Studio acceptance packet bound to the candidate revision, and CI results |
| CORE-REQ-002, CORE-REQ-003, CORE-REQ-013 | Catalog, math, property, cap, and configuration tests | Service consumers use one normalized contract | Frozen score and economy fixtures in Studio | Invalid data and overflow rejection | Catalog snapshot, validator report, calculation traces |
| CORE-REQ-004 through CORE-REQ-007 | Schema, migration, receipt, and ownership tests | Network, profile, transaction, inventory, and deck services | Blank account, rejoin, collision, safe mode | Hostile input, throttle, replay, shutdown, conservation | Profile hashes, receipts, recovery packet |
| CORE-REQ-008, CORE-REQ-009, CORE-REQ-014 | Asset, reference, renderer, and controller tests | Every UI consumes authoritative state | Device and accessibility workflows | Stale, pending, disabled, and maintenance behavior | Asset manifest, screenshots, performance report |
| CORE-REQ-010 through CORE-REQ-012 | Odds, pity, progression, target, lock, and Joker tests | Packs, inventory, progression, collection, and score traces | Open, choose, transform, equip, disconnect, rejoin | Replay, catalog update, failed save, foreign instance | Pending records, receipts, traces, recordings |
| CORE-REQ-015 through CORE-REQ-018 | Tutorial, round, task, time, boost, and reward tests | Full first session and active loop | Required inputs, devices, accessibility, offline return | Stale state, impossible input, time skew, shutdown | Funnel, timing, reward comparison, Studio recordings |
| CORE-REQ-019, CORE-REQ-020 | Duel and trade state tests | Two-client matches, offers, settlement, recovery | Same-server social workflows | Disconnect, replay, reorder, write failure, locked mutation | Match traces, journals, receipts, conservation report |
| CORE-REQ-021, CORE-REQ-022 | Product, policy, receipt, event, flag, and redaction tests | Commerce, profile, analytics, diagnostics, rollback | Authorized purchase smoke and operator controls | Duplicate receipts, disabled product, failed service | Product manifest, receipt packet, dashboard evidence |
| CORE-REQ-023, CORE-REQ-024 | Accessibility, performance, secret, artifact, and documentation checks | Eight-player candidate and full regression suite | Device matrix and manual experience review | Hostile input, persistence failure, rollback rehearsal | Candidate manifest and complete verification packet |
| CORE-REQ-025, CORE-REQ-026 | Release and synchronization preflight | Private launch and public rollout systems | Blank production profile and public experience | Threshold aborts, access restriction, place rollback | Runbooks, authorization, rollout, observation, GitHub audit |

Required evidence is invalidated by a relevant source change, catalog or configuration version change, tool version change, schema change, action contract change, artifact change, environment identity change, feature-flag change, runbook change, permission change, or fix that alters the exercised path. Invalidated evidence must be rerun from the lowest affected layer through every dependent real workflow.

## 15. Compatibility, Migration, Rollout, Rollback, and Recovery

### Compatibility

- Stable IDs, slot keys, form keys, instance identities, provenance, discovery, receipts, journal IDs, public action IDs, stable error codes, and saved schema fields are compatibility contracts.
- Display labels, balance values, and presentation may change only through versioned configuration and cannot reinterpret existing ownership.
- New content uses data and handler registrations through existing interfaces rather than copied services.
- Clients with unknown or incompatible action versions fail safely and receive a supported update path.
- Phase 000 Studio acceptance has two independent real-Studio routes: native Roblox Studio on a platform currently supported by Roblox, or the actual Windows Roblox Studio binary running through a qualified Vinegar and Wine environment on Linux. The qualified route is accepted only for the exact recorded environment and complete DEC-015 evidence packet. It does not claim official native Linux Studio support.
- The qualified route records exact Vinegar, Wine, Studio deployment and client, Rojo CLI and plugin, live MCP connection, loopback address, clean synchronization, controlled resynchronization and revert, client and server bootstrap, clean project console, built-versus-synchronized topology parity, and candidate revision. A relevant change invalidates the packet and requires reacceptance through either route.
- Windows command-line portability remains an independent mandatory requirement and cannot be replaced by Wine execution or the Studio packet.

### Migration

- Every schema migration is pure, forward-only, repeatable, fixture-tested, and ownership preserving.
- A migration failure quarantines the profile and prevents a blank overwrite.
- Inventory sharding is not implemented at launch, but the profile and inventory interfaces preserve its future migration boundary under FUT-012.
- The launch refuses publication if realistic profiles exceed the 1,500,000-byte gate.

### Rollout, Rollback, Publication, and Production Acceptance

1. Freeze source commit, toolchain, catalogs, configuration, assets, product definitions, feature flags, metadata, and runbooks.
2. Complete the phase 008 candidate packet.
3. Obtain EXT-008 and run the private soft launch within its scope.
4. Fix any mandatory defect, invalidate affected evidence, rebuild, and repeat the required gates.
5. Obtain EXT-009 and EXT-010 for the exact frozen candidate and approved production operations.
6. Obtain EXT-011 only if direct trading is an enablement candidate.
7. Widen public access through the frozen runbook and observe every release threshold.

### Rollback and Recovery

Rollback restricts audience or restores the prior place version, disables unsafe acquisition and mutation paths, preserves committed profiles, pending packs, receipts, and prepared trade journals, shows an approved maintenance state, and retains evidence. Rollback never deletes ownership or replays an operation with a new ID. Public access does not resume until the failing invariant is corrected and all invalidated gates pass again.

## 16. Documentation, Operations, and Release Gates

- `README.md` reflects actual setup, public behavior, supported tools, release state, and support paths.
- `docs/README.md` indexes the master, future aspect, technical overview, implementation, test, verification, operations, release, and troubleshooting documents that exist.
- `docs/general/documentation.md` reflects implemented architecture, persistence, networking, compatibility, and commands.
- Focused test procedures and verified evidence live under `docs/test/` and `docs/verification/` after those artifacts exist.
- Runbooks define environment identities, permissions, artifact hashes, operations, thresholds, operators, windows, and rollback.
- Public metadata, icon, thumbnails, title, description, product copy, policy state, and originality review match the frozen release.
- Analytics, diagnostics, moderation, feature flags, rollback values, support guidance, and recovery tools are active before public access widens.
- GitHub Issues, Project, milestones, pull requests, checks, merge commits, signed tags, releases, and wiki navigation are synchronized after approved merges.

## 17. Risks and Failure Boundaries

| Risk | Impact | Prevention | Detection | Recovery |
|---|---|---|---|---|
| Core loop is not engaging | Content expansion wastes effort | Three-set boundary and early vertical slice | Funnel, timing, voluntary replay, soft-launch behavior | Improve first ten minutes before FUT work |
| Profile loss or overwrite | Permanent collection damage | Session ownership, UpdateAsync, migrations, safe mode | Revision, lock, save, migration, and recovery evidence | Stop mutations, quarantine, restore durable state, reconcile receipts |
| Duplicate or missing item | Economy and trust failure | Idempotent operations, one-owner invariant, journals, locks | Conservation checks, security signals, support receipts | Disable affected path, lock items, reconcile exact ownership |
| Pack or purchase replay | Duplicate grants or lost value | Committed pending results and exact-once receipts | Operation and receipt comparison | Return committed result or reconcile under receipt evidence |
| Trade partial settlement | Cross-profile loss or duplication | Prepared journal and idempotent steps | Journal state, side settlement, ownership scan | Disable new trades and reconcile before writable play |
| Client exploit | Illicit rewards or state exposure | Server authority, validation, rate limits, least disclosure | Stable security signals and anomaly dashboards | Reject, refresh narrow state, quarantine impossible state |
| Storage growth | Save failure near platform limit | Compact encoding, size budgets, sharding interface | Stress fixtures and production size bands | Block release or acquisition, then execute FUT-012 migration |
| Numeric precision loss | Incorrect endgame comparisons | Launch value bound and deterministic stage math | Boundary and normalization tests | Cap affected systems and execute FUT-012 large-number migration |
| Device overload | Poor mobile experience | Pooling, virtualization, bounded preload and server work | Frame, memory, payload, and eight-player tests | Reduce effects, disable costly content, optimize and rerun |
| Inaccessible confirmation | Accidental or blocked action | Text and symbols, scale, controller focus, reduced settings | Device and accessibility review | Block release and correct the surface |
| Brand or policy conflict | Publication delay or removal | Originality boundary and clearance prerequisite | Trademark, Roblox search, metadata, Standards review | Replace conflicting assets before artifact freeze |
| Qualified Vinegar Studio evidence drifts or is mistaken for official Linux support | Phase 000 closes on stale runtime evidence or documentation overstates platform support | Bind every required DEC-015 field to one candidate revision, retain the native supported-platform route, and state the qualified support boundary explicitly | Vinegar, Wine, Studio, plugin, MCP, loopback, synchronization, resynchronization, bootstrap, console, topology, or candidate identity mismatch | Invalidate the packet and rerun the complete qualified route, or complete the native supported-platform Studio route; never waive a missing field |
| External authorization absent | Endpoint cannot be exercised | Typed EXT contracts and approved blocker status | Preflight reports missing evidence | Remain externally blocked without weakening scope |
| Release regression | Public player harm | Private soft launch, staged rollout, thresholds, feature controls | Production dashboards and smoke checks | Restrict access, restore place, disable features, preserve state |

## 18. Definition of Done

The plan is complete only when all of the following are true:

- A controlled public Roblox release of the three Deck Set InfiniteCardCollector foundation passes every mandatory initial release gate, with direct trading enabled only if its separate safety and production authorization gates pass and otherwise visibly disabled.
- Every CORE requirement passes every acceptance criterion and required evidence at the required fidelity.
- CORE-PHASE-000 through CORE-PHASE-009 each pass their entry, implementation, verification, exit, integration, and completion packet gates in order.
- Every phase pull request is merged into `main`, required checks and review are resolved, and the merged commit has its signed annotated phase tag.
- The final public Roblox release passes the frozen private and public rollout contracts and observation window.
- Trading is either enabled after every safety and EXT-011 gate or visibly disabled with no new mutation path and preserved recovery.
- No known profile-loss, duplication, infinite reward, currency underflow, unsafe receipt, remote exploit, inaccessible required flow, or other mandatory in-scope defect remains.
- Documentation, release evidence, GitHub state, and wiki navigation match the merged and published state.
- Optional FUT-001 through FUT-015 remain excluded and PLAN-FULL remains nonblocking.
- The protected plan set changes only through a current direct owner-authorized Plan Creator pass and otherwise remains unchanged during execution. The saved goal remains unchanged in every case; its recorded plan digests remain creation-time provenance while execution rereads the current validated plan set.
- The known external blockers named Roblox universe, place, publisher permissions, and service access; Final public brand and trademark clearance; Private soft launch authorization; Public rollout authorization; Production purchase smoke authorization; Soft launch cohort, test accounts, and representative device coverage; and Roblox product IDs, receipt testing, policy information, and commerce access are satisfied with their exact required evidence before endpoint closure.
- Until every mandatory external blocker is satisfied, the terminal state is `NOT COMPLETE — EXTERNALLY BLOCKED`.
- A genuine unavailable external prerequisite leaves the plan externally blocked and never permits mocked evidence or a false completion claim.

## 19. Goal Creator Handoff

```text
Mandatory boundary: CORE-REQ-001 through CORE-REQ-026 and CORE-PHASE-000 through CORE-PHASE-009.
Optional/future disposition: excluded
Locked owner decisions: DEC-001 through DEC-015.
Active phase: CORE-PHASE-000
Next executable action: Reread the updated Phase 000 blueprint, verify the unchanged saved goal and current live plan identity, bind the complete DEC-015 Studio packet to the final candidate revision, rerun every invalidated plan, documentation, artifact, and CI gate from the lowest affected layer, and complete P000-TASK-014 before integration.
Known failing checks: None currently identified in the implemented toolchain or qualified Vinegar Studio path. Phase 000 remains incomplete until the updated candidate audit, pull request integration, merged-main verification, signed phase tag, and post-merge synchronization pass.
Known external blockers: EXT-006, Roblox universe, place, publisher permissions, and service access. EXT-007, Final public brand and trademark clearance. EXT-008, Private soft launch authorization. EXT-009, Public rollout authorization. EXT-010, Production purchase smoke authorization. EXT-012, Soft launch cohort, test accounts, and representative device coverage. EXT-013, Roblox product IDs, receipt testing, policy information, and commerce access. EXT-011 is conditional and does not block a visibly disabled trading release. EXT-001 through EXT-005 and EXT-014 are available.
Completion endpoint: A controlled public Roblox release of the three Deck Set InfiniteCardCollector foundation passes every mandatory initial release gate, with direct trading enabled only if its separate safety and production authorization gates pass and otherwise visibly disabled.
Required evidence gates: Pinned tools and commands; clean Linux and Windows command-line portability; Phase 000 acceptance through native supported-platform Studio or the qualified actual Windows Studio binary under Vinegar and Wine with exact environment, MCP, loopback, synchronization, resynchronization, bootstrap, console, topology, and candidate-revision evidence; exact catalogs; deterministic tests; profile and transaction recovery; complete launch assets; full later Studio and multiclient workflows; trade conservation or disabled fallback; authorized purchase smoke; device and performance evidence; private soft launch; controlled public rollout; production acceptance; documentation; and GitHub synchronization.
```

This authorized plan update does not invoke Goal Creator and does not refresh, rebind, or modify the existing saved goal. Execution under the saved goal rereads the current validated plan set and deterministic `plan.handoff.json`; its recorded plan and plan-set digests remain creation-time provenance, and plan digest drift alone is not a goal conflict. Only a changed saved-goal digest is a goal revision conflict. Goal Creator must consume the final validated handoff and matching current plan-set digest only when creating a goal where none exists, and it must not infer around missing authority, modify this plan set, or promote future scope.
