# Phase 001 Execution Plan

> **Plan ID:** PLAN-PHASE-001
> **Phase ID:** CORE-PHASE-001
> **Owner:** shared calculation layer
> **Classification:** MANDATORY
> **Master plan:** [plan.md](../plan.md)
> **Phase sequence:** 001 of 009

## Purpose and Ownership

This phase establishes the complete owner-shared launch data and pure calculation contract. Its outcome is a versioned, validated representation of the three launch Deck Sets and every enabled launch content family, deterministic detection of all twelve Card Formations, exact and bounded score and economy math, and a data-driven registry for the twenty-four launch Joker effects. Every accepted calculation emits an explainable, replayable trace tied to the exact catalog and configuration versions that produced it.

The canonical requirements are `CORE-REQ-002`, `CORE-REQ-003`, and `CORE-REQ-013`. The master plan owns product scope, requirement authority, phase topology, owner decisions, external prerequisites, and the global completion endpoint. This file owns only the dependency-ordered execution blueprint and measurable closure gates for `CORE-PHASE-001`. It does not change, narrow, expand, or report progress inside the master plan or any other protected plan artifact.

## Evidence-Based Entry State

| Evidence class | Area | Finding | Source or command | Freshness condition |
|---|---|---|---|---|
| OBSERVED | Repository maturity | At the frozen planning revision, the repository contains design documentation but no Roblox runtime, Luau source tree, manifests, or executable test harness. | `docs/general/plan.md`, repository inventory at `8b16f8e3678a25d13d9bb811447c0c3f321e6b5b` | Invalidated when `CORE-PHASE-000` merges runtime scaffolding, manifests, or test infrastructure. |
| PROPOSED | Tool and source contracts | `CORE-PHASE-000` is responsible for the exact tools, source boundaries, commands, local harness, build artifact, and CI foundation required by this phase. | `CORE-PHASE-000`, `CORE-REQ-001`, `EXT-001` through `EXT-005` | Must be replaced by verified merge, tag, command, and CI evidence before implementation begins. |
| OBSERVED | Launch content boundary | Launch contains exactly three Deck Sets, 156 base identities, four Editions, 624 permanent forms, eleven Grades, eleven Power Tiers, twelve Traits, twenty-four Jokers, twelve Arcana, and twelve formations. | `DEC-003`, `CORE-REQ-002`, `docs/general/content-catalog.md`, `docs/implementation/launch-foundation.md` | Invalidated by an authorized change to any cited source that changes this product contract. |
| OBSERVED | Stable identity contract | Stored content identities use lowercase stable IDs; display names may change, retired IDs cannot be reused, and balance changes cannot reinterpret inventory identity. | `docs/general/content-catalog.md`, `docs/implementation/launch-foundation.md` | Invalidated by any stable ID, key format, or compatibility rule change. |
| OBSERVED | Formation and score intent | Face values, twelve formation families, best-base selection, explicitly stackable bonuses, card contribution axes, global score axes, explainable traces, and the below-`10^15` launch bound are specified. | `docs/general/product-vision.md`, `CORE-REQ-003` | Invalidated by a formation rule, scoring stage, multiplier group, tie-break, rounding, cap, or number representation change. |
| OBSERVED | Economy intent | Server configuration owns integer prices, rewards, currency sources and sinks, odds, limits, passive rate, feature state, anti-farming rules, and reason IDs; clients receive display projections only. | `CORE-REQ-013`, `DEC-006`, `DEC-010`, `docs/implementation/launch-foundation.md` | Invalidated by any configuration schema, balance version, source, sink, cap, cadence, or active-versus-passive rule change. |
| PROPOSED | Runtime proof | No phase-owned runtime behavior is verified at planning time. Pure, property, golden, integration, and Studio comparison evidence must be created during execution. | `docs/general/plan.md`, `AGENTS.md` | Replaced only by evidence tied to the merged phase commit, catalog version, configuration version, tool versions, and artifact hash. |

## Scope Boundaries

### Included Scope

- `CORE-REQ-002`: Define typed, versioned launch catalogs and projections for exactly Classic, Radioactive, and Astral; thirteen ranks; four suits; 156 base identities; Normal, Foil, Golden, and Steel; 624 forms; all eleven Grades; all eleven Power Tiers; the first twelve Traits; the selected twenty-four Jokers; the selected twelve Arcana; all twelve formations; feature, odds, limit, effect-handler, and balance references; and deterministic validation.
- `CORE-REQ-003`: Implement pure rank, slot, identity, form, affinity, Edition, Grade, Power Tier, Trait, formation, score-stage, cap, conflict, and trace contracts. Detect every valid launch formation, reject invalid or ambiguous input safely, select the configured best base result, apply only declared bonuses, and produce table-order-invariant results.
- `CORE-REQ-013`: Define the versioned integer economy contract for Cash, Joker Tickets, Arcana Dust, Grade Ink, Trait Essence, Duel Tokens, Ascension Fragments, and reserved Soul Fragments, including sources, sinks, transfer prohibition, caps, prices, rewards, pity, cadence, passive rate, anti-farming parameters, analytics reason IDs, and client-safe display projections.
- `DEC-003`: Enforce the exact launch content boundary and prevent future catalog entries from becoming launch-enabled through client knowledge or malformed configuration.
- `DEC-006`: Keep gameplay randomness earned, integer-weighted, disclosed, deterministic under a supplied server seed, and independent from paid random power.
- `DEC-010`: Prove through frozen representative fixtures that ordinary active rewards are at least five times the normalized passive baseline.
- The phase-owned portion of the Joker system: typed definitions, handler registration, stage subscriptions, parameters, caps, conflicts, five-slot calculation input, and pure effects and traces for all twenty-four launch Jokers. Instance ownership, binding, progression, and user-facing Joker workflows remain downstream.

### Explicit Exclusions

- `CORE-REQ-004` through `CORE-REQ-008`: Network routing, hostile remote validation, durable profiles, transaction persistence, inventory ownership, deck mutation, and the reusable renderer belong to `CORE-PHASE-002`. This phase supplies their immutable shared contracts and test fixtures only.
- `CORE-REQ-009` through `CORE-REQ-012` and `CORE-REQ-014`: Final assets, pack operations, progression mutations, Arcana consumption, owned Joker instance behavior, five-slot equip mutation, and responsive collection surfaces belong to `CORE-PHASE-003`. This phase does not claim those workflows complete.
- `CORE-REQ-015` through `CORE-REQ-026`: Onboarding, complete Formation Rush state, tasks, passive return, social modes, trade, commerce, operations, release hardening, publication, and final synchronization remain in their assigned later phases.
- `FUT-001` through `FUT-015`: Remaining Deck Sets, Editions, Traits, Jokers, Arcana, Souls, large-number migration, and other registered future work remain excluded. Reserved types or disabled records may preserve compatibility but cannot enable future content.
- `NG-001` through `NG-010`: Protected material, casino or wagering presentation, paid random gameplay power, player currency transfer, client authority, passive-first progression, and public GitHub publication remain prohibited.
- Persistent mutation, DataStore access, remotes, UI, mutable services, presentation timing, player authorization, asset production, and production rollout are not owned by pure catalog, configuration, or calculation modules.

## Phase Contract

### CORE-PHASE-001 — Launch Catalog, Configuration, and Deterministic Calculation Contracts

**Objective:** Implement exact launch catalogs, versioned feature and balance configuration, bounded deterministic number and score math, all twelve launch formations, affinities, Editions, Grades, Power Tiers, Traits, and a data-driven twenty-four-Joker effect registry, with validator reports, property proof, golden traces, and no special case for the canonical showcase card.
**Owner:** shared calculation layer
**Dependencies:** CORE-PHASE-000, DEC-003, DEC-006, DEC-010
**Canonical requirements:** CORE-REQ-002, CORE-REQ-003, CORE-REQ-013
**Documentation and release impact:** Update the implemented architecture, content and balance contracts, exact verification commands, test procedures, verification index, and current repository status in the tracked documentation. Produce no release or publication action.
**Next transition:** `CORE-PHASE-002`

**Entry criteria**

- The complete current protected plan set and deterministic handoff are reread and validated with `CORE-PHASE-001` as the next authorized phase. The saved goal remains unchanged and its own creation digest matches its recorded value; goal-recorded plan and plan-set digests are creation-time provenance and do not reject an otherwise valid current plan set.
- The `CORE-PHASE-000` pull request is merged through GitHub, its merge commit is present on `origin/main`, and its signed annotated phase tag is verified.
- The phase branch is created from that verified `origin/main` commit, not from the historical phase branch, and no later phase branch is stacked.
- The exact Phase 000 setup, formatting, lint, test, build, Studio synchronization, artifact, and CI commands pass on the phase entry commit.
- The source boundaries provide strict typed shared Catalogs, Config, Math, Types, and tests without requiring DataStore, remotes, UI, or mutable service access from the calculation layer.
- The current `docs/general/content-catalog.md`, `docs/general/product-vision.md`, `docs/implementation/launch-foundation.md`, `DEC-003`, `DEC-006`, and `DEC-010` are reread and remain semantically consistent with the current validated plan set and phase intake. Any material contract mismatch stops implementation for plan conflict review; digest drift alone does not.

**Implementation scope**

- CORE-REQ-003, CORE-REQ-013: `CORE-REQ-002`: Create complete typed launch catalogs, version identifiers, stable key builders, enabled projections, handler references, validation rules, snapshots, and negative fixtures.
- `CORE-REQ-003`: Create exact formation detection, normalized calculation input, fixed and checked multiplier arithmetic, stage-ordered card and formation scoring, affinity and launch content effects, conflict resolution, caps, and traces.
- `CORE-REQ-013`: Create complete versioned economy, balance, odds, limits, passive, cadence, anti-farming, and reason-code definitions with integer validation and client-safe projections.
- CORE-REQ-002: Define pure shared interfaces consumed by later server, client preview, persistence, inventory, pack, progression, Joker, formation, duel, analytics, and verification work without implementing those consumers early.

**Execution order**

1. `P001-TASK-001` verifies entry evidence and freezes the phase-owned schema, version, stable-ID, and compatibility contracts. This task traces to CORE-REQ-002.
2. `P001-TASK-002` implements rank, suit, Deck Set, slot, base identity, and form catalogs and exact generated launch counts. This task traces to CORE-REQ-002.
3. `P001-TASK-003` implements Edition, Grade, Power Tier, Trait, and affinity catalogs and their pure typed parameters. This task traces to CORE-REQ-002.
4. `P001-TASK-004` implements the selected Joker and Arcana catalogs, handler references, launch enablement, and five-slot calculation input contract. This task traces to CORE-REQ-002.
5. `P001-TASK-005` implements versioned feature, limit, balance, and economy configuration with all sources, sinks, caps, transfer rules, anti-abuse rules, and reason IDs. This task traces to CORE-REQ-002.
6. `P001-TASK-006` implements integer RNG weights, exact totals, pity and early-protection configuration contracts, and deterministic roll records. This task traces to CORE-REQ-002.
7. `P001-TASK-007` implements safe launch integer and rational multiplier primitives with explicit rounding, cap, overflow, underflow, and nonfinite behavior. This task traces to CORE-REQ-002.
8. `P001-TASK-008` implements the twelve formation definitions and pure normalized detectors with stable best-result and tie-break rules. This task traces to CORE-REQ-002.
9. `P001-TASK-009` implements the documented stage-ordered scoring engine for rank, Edition, Grade, Power Tier, Trait, affinity, formation, Joker, boost, and mode components. This task traces to CORE-REQ-002.
10. `P001-TASK-010` implements the data-driven handlers, stages, caps, conflicts, and trace explanations for all twenty-four launch Jokers. This task traces to CORE-REQ-002.
11. `P001-TASK-011` implements catalog, configuration, handler, reference, and enabled-projection validation with fail-closed diagnostics and negative fixtures. This task traces to CORE-REQ-002.
12. `P001-TASK-012` builds the property, boundary, pairwise, representative five-Joker, golden trace, table-order, and active-versus-passive fixture suite. This task traces to CORE-REQ-002.
13. `P001-TASK-013` proves later-consumer compatibility through pure integration and nondestructive Studio server-versus-client projection comparisons. This task traces to CORE-REQ-002.
14. `P001-TASK-014` updates ordinary tracked documentation and assembles the phase completion packet without modifying protected plan artifacts. This task traces to CORE-REQ-002.

**Required evidence**

- Deterministic catalog and configuration snapshots containing both versions and exact enabled counts.
- Validator success output plus negative fixtures for every count, identity, reference, handler, value, weight, cap, conflict, and disabled-content failure class.
- Pure unit and property results for all formations, stage ordering, exact arithmetic, safe bounds, rounding, table-order invariance, conflicts, and caps.
- Golden calculation traces for every launch Joker and representative Normal, Foil, Golden, Steel, Grade, Power Tier, Trait, affinity, boost, mode, and multi-pattern interaction.
- Pairwise launch Joker fixtures and representative five-Joker builds that exercise enhancement, conflict, cap, non-score hooks, and slot-order invariance.
- Frozen economy source-and-sink report, integer-weight report, anti-farming boundary report, and active-versus-passive comparison proving the required ratio.
- Nondestructive Studio comparison showing the authoritative shared result and client-safe display projection agree for the same frozen fixtures while the client cannot provide trusted amounts.
- Formatting, static analysis, pure test, integration test, Studio, build, documentation-link, secret, final-diff, and artifact-inventory results using Phase 000 commands.

**Exit criteria**

- Enabled launch snapshots prove exactly three Deck Sets, 156 base identities, four Editions, 624 forms, eleven Grades, eleven Power Tiers, twelve Traits, twenty-four Jokers in the required rarity distribution, twelve Arcana, twelve formations, and no enabled Soul.
- Every stable ID is unique and lowercase, every cross-reference and handler resolves, every enabled record is reachable through ordinary data, and every disabled record fails closed.
- All twelve formations accept valid canonical fixtures and reject near misses, duplicates, illegal ranks, illegal sizes, malformed values, and ambiguous state according to stable rules.
- Identical normalized input and versions produce byte-equivalent result and trace snapshots regardless of map insertion or table iteration order.
- The scoring engine declares and proves stage order, additive and multiplicative groups, conflict precedence, rounding, caps, and safe launch bounds; overflow, underflow, fractional integer, `NaN`, and infinity fixtures fail without a trusted result.
- All twenty-four launch Joker definitions resolve through the registry and have fixed expected traces; a sixth calculation slot, unknown handler, illegal parameter, unresolved conflict, and uncapped accumulating effect are rejected.
- Every launch currency has declared sources, sinks, transfer rule, cap, and stable reason IDs, including a fail-closed reserved Soul Fragment contract; all prices, rewards, odds, pity, and anti-farming values are versioned integers.
- Frozen representative active rewards are at least five times the normalized passive baseline.
- The canonical `Golden LR Infernal Ace of Radioactive Spades, Fortune trait` is represented and scored using the same catalog fields, key builders, handlers, and stages as every other card, with no identity-specific conditional or fixture-only path.
- All phase-owned deterministic, integration, Studio, build, documentation, and inspection gates pass, and no known mandatory phase-owned defect remains.
- The phase pull request is merged, `origin/main` contains its merge commit, and the signed annotated phase tag is pushed before `CORE-PHASE-002` begins.

## Inputs and Upstream Contracts

| Input or contract | Provider | Required state | Validation | Failure behavior |
|---|---|---|---|---|
| Current protected plan set, deterministic handoff, and saved goal | Plan Creator and Goal Creator | The complete current plan set validates, the handoff represents that plan set, active work authorizes `CORE-PHASE-001`, and the saved goal is unchanged. Goal-recorded plan and plan-set digests remain creation-time provenance. | Reread the master and every registered plan through EOF, validate the current manifest and handoff, and compare the saved goal's own digest with its recorded creation digest. | Stop with `GOAL_REVISION_CONFLICT` only if the saved goal's own digest changed. Stop for plan revision handling when the current plan set or handoff is invalid or materially conflicts; do not rewrite or rebind the goal. |
| Phase 000 integration | `CORE-PHASE-000` | Merge commit is on `origin/main`, signed phase tag exists, and exact tools and commands pass. | GitHub merge and tag verification, fetch, commit ancestry, clean command rerun. | Do not create or use the Phase 001 branch; return to Phase 000 closure. |
| Launch content boundary | `DEC-003`, `SRC-006`, `SRC-007` | Exact launch families, selected IDs, counts, and future exclusions are available and internally consistent. | Generated count and identity matrix compared with the cited sources. | Fail planning or implementation review; never guess a product identity or enable future content. |
| Randomness and monetization boundary | `DEC-006` | Earned random gameplay, visible odds, persistent pity, and no paid random power remain authoritative. | Configuration and enabled-product projection review. | Reject the configuration and block its consumers. |
| Active-first boundary | `DEC-010` | Frozen fixtures must show at least a five-to-one active-to-passive efficiency ratio. | Deterministic comparison using the same configuration version and normalized time basis. | Block phase exit and retune versioned balance configuration. |
| Exact source and test commands | `CORE-PHASE-000`, `CORE-REQ-001`, `EXT-001` through `EXT-005` | Rojo, Rokit, StyLua, Selene, and Lune versions and commands match the pinned artifacts. | Version output, checksums, command transcript, and CI caller comparison. | Stop; do not accept evidence from a mismatched tool or command. |
| Content catalog | `docs/general/content-catalog.md` | Stable names, IDs, effects, counts, and balance targets match the pinned source. | Catalog snapshot and source digest. | Stop on identity conflict; route balance ambiguity to explicit versioned configuration without changing identity. |
| Product score contract | `docs/general/product-vision.md` | Face values, twelve formation families, contribution axes, best-base selection, and below-`10^15` launch bound are preserved. | Golden source fixtures and architecture review. | Fail closed and report the conflicting rule or missing required parameter. |
| Launch implementation contract | `docs/implementation/launch-foundation.md` | Launch selections, economy drafts, source structure, Joker stages, validation, and verification obligations are available. | Source digest and requirement-to-task traceability. | Stop for a material contradiction; do not silently select a different launch item. |

## Outputs and Downstream Contracts

| Output or contract | Consumer | Guaranteed state | Compatibility or versioning | Evidence |
|---|---|---|---|---|
| Catalog snapshot and typed definitions | Phases 002 through 009 | Exact enabled launch identities, stable IDs, key formats, counts, references, and future-disabled records. | `catalogVersion` accompanies snapshots and traces; IDs are never reused; display labels do not affect identity. | Snapshot hash, validator report, count report, negative fixtures. |
| Configuration snapshot and display projection | Server services, client controllers, analytics, operations | Exact features, limits, prices, rewards, caps, odds, pity, cadence, anti-farming, and client-safe display values. | `configVersion` is independent from `catalogVersion`; any behavior change increments the applicable version. | Snapshot hash, projection comparison, source-and-sink and weight reports. |
| Stable key and normalized domain types | Profile, Inventory, Collection, Deck, Pack, Progression, Formation, Duel, and Trade services | Slot, base identity, form, rank, suit, content ID, multiplier, calculation input, result, and trace types reject malformed state. | Stored keys remain stable; incompatible schema changes require migration rather than reinterpretation. | Type checks, round-trip fixtures, malformed-input tests. |
| Safe number and multiplier layer | Every economy and score consumer | Nonnegative launch integers and exact rational multipliers use checked operations, one rounding contract, and a result bound below `10^15`. | A representation change is incompatible and belongs to `FUT-012`; launch callers cannot bypass checked arithmetic. | Boundary and property tests, overflow and nonfinite rejection report. |
| Formation detector | Formation service, onboarding, Friend Clash, client preview | All twelve formations use canonical rank and suit rules, deterministic multi-pattern detection, best-base selection, and explicit stackable bonuses. | Formation IDs and detector semantics are versioned content contracts. | Valid, near-miss, duplicate, invalid-rank, permutation, and golden fixtures. |
| Calculation engine and trace schema | Formation, Joker, task, duel, analytics, inspect, and verification consumers | One stage order calculates separate Cash, Power, Guard, pack progress, and Grade experience components and explains every accepted or rejected step. | Trace schema, stage IDs, reason IDs, and versions are compatibility surfaces; display may summarize but not reinterpret them. | Golden traces, table-order property tests, Studio projection comparison. |
| Launch Joker registry and pure handlers | Joker service and calculation engine | Exactly twenty-four enabled definitions resolve to registered handlers with parameters, stages, caps, conflicts, and five-slot calculation behavior. | Joker IDs remain stable; numeric tuning changes configuration, not handler identity or owned identity. | Handler inventory, per-Joker traces, pairwise and five-Joker fixtures. |
| Economy reason and mutation contract | Transaction and Analytics services | Every later currency mutation can report previous balance, integer delta, reason ID, resulting balance, operation ID, config version, and sanitized context. | Reason IDs are stable and versioned; services may not accept a client amount or price. | Pure receipt/event projection fixtures and downstream interface tests. |
| Phase 001 completion packet | `CORE-PHASE-002`, verification system, repository operations | Merged artifact identities, commands, tests, traces, reports, docs, review, merge, and tag evidence are complete and internally consistent. | Any relevant source, version, schema, configuration, tool, or artifact change invalidates affected evidence. | Packet audit, current-plan and handoff validation, and saved-goal digest verification. |

## Work Packages

| Task ID | Requirement IDs | Work | Inputs and dependencies | Outputs | Affected components or interfaces | Verification |
|---|---|---|---|---|---|---|
| P001-TASK-001 | `CORE-REQ-002`, `CORE-REQ-003`, `CORE-REQ-013` | Verify phase entry and define the typed schema, catalog and configuration version fields, stable-ID grammar, key compatibility rules, and immutable calculation input and output boundaries. | Phase 000 packet, current protected plan set and handoff, immutable saved goal, `DEC-003`, `DEC-006`, `DEC-010` | Entry record and shared domain contract | Shared Types, Catalogs, Config, Math, test fixtures | Type checks, version mismatch tests, key round trips, current-plan and handoff validation, saved-goal digest proof |
| P001-TASK-002 | `CORE-REQ-002` | Define Classic, Radioactive, Astral, thirteen ranks, four suits, slot keys, generated base identities, and generated Normal, Foil, Golden, and Steel form keys. | P001-TASK-001, content catalog | Exact 3, 52-per-set, 156-identity, 624-form snapshot | Shared Catalogs and key builders | Exact counts, uniqueness, lowercase IDs, cross-product, duplicate and malformed-key fixtures |
| P001-TASK-003 | `CORE-REQ-002`, `CORE-REQ-003` | Define four Editions, eleven Grades and XP thresholds, eleven Power Tiers, first twelve Traits, and three launch affinity definitions and parameters. | P001-TASK-001, P001-TASK-002, product and content contracts | Typed progression and affinity catalogs | Catalogs, Card Math, affinity interface | Exact values and counts, monotonic thresholds, handler references, cap and representative contribution fixtures |
| P001-TASK-004 | `CORE-REQ-002`, `CORE-REQ-003` | Define the exact twenty-four launch Jokers by rarity and twelve launch Arcana, handler IDs, parameters, conflicts, launch enablement, and five-slot calculation input schema. | P001-TASK-001, selected lists in launch foundation | Joker and Arcana snapshots and handler inventory | Joker and Arcana catalogs, effect registry interface | Rarity totals, exact selected IDs, unknown handler, illegal parameter, sixth-slot, disabled-entry fixtures |
| P001-TASK-005 | `CORE-REQ-002`, `CORE-REQ-013` | Define versioned feature, limit, balance, economy, reward, passive, cadence, and anti-farming configuration, including every launch currency source, sink, cap, transfer rule, and reason ID. | P001-TASK-001 through P001-TASK-004, `DEC-006`, `DEC-010` | Complete server configuration and client-safe projection | Shared Config, economy contract, analytics reason interface | Source-and-sink coverage, integer and cap validation, projection redaction, active/passive and social-cap boundary fixtures |
| P001-TASK-006 | `CORE-REQ-002`, `CORE-REQ-013` | Encode Deck Set and Joker Pack odds in integer units, Trait chance, pity boundaries, early protection, and reproducible roll-record fields. | P001-TASK-005, published odds and pack rules | Integer-weight tables and deterministic RNG contract | Odds and balance configuration, Random service interface | Exact totals, boundaries before/at/after pity, malformed weight, seed replay, and table-order tests |
| P001-TASK-007 | `CORE-REQ-003`, `CORE-REQ-013` | Implement checked launch integers, exact rational multipliers, deterministic rounding, comparison, addition, scaling, caps, and serialization rejection. | P001-TASK-001, below-`10^15` contract | Safe number primitives and stable formatted projection input | Shared Math and Types | Zero, one, cap-minus-one, cap, cap-plus-one, underflow, fractional, denominator, overflow, `NaN`, infinity, and algebraic property tests |
| P001-TASK-008 | `CORE-REQ-002`, `CORE-REQ-003` | Define and detect Single, Twin, Twin Pair, Triple, Sequence, Monosuit, Court, Spectrum, Full Cluster, Quad, Crown Run, and Per&#102;ect Sum under normalized inputs. | P001-TASK-002, P001-TASK-003, P001-TASK-007 | Formation definitions, detector, result ordering, best-base and explicit-bonus contract | Formation catalog and detector | Valid hands, near misses, sizes one through five, duplicate instances, invalid ranks, permutations, multi-pattern and tie fixtures |
| P001-TASK-009 | `CORE-REQ-003` | Implement the exact calculation stage pipeline for card contributions, separate reward components, formation selection and multiplier, Jokers, boosts, mode modifiers, caps, and trace emission. | P001-TASK-003, P001-TASK-005, P001-TASK-007, P001-TASK-008 | Deterministic score result and trace engine | Card Math, calculation registry, trace schema | Stage-order, group, precedence, rounding, cap, table-order, reconnect-independent, and representative axis fixtures |
| P001-TASK-010 | `CORE-REQ-002`, `CORE-REQ-003` | Implement registered pure effect handlers for all twenty-four launch Jokers, including score, detection, affinity, streak, redraw, task, event-trigger, and drawback behavior. | P001-TASK-004, P001-TASK-005, P001-TASK-008, P001-TASK-009 | Complete launch effect registry | Joker effect handlers and calculation hooks | One golden trace per Joker, pairwise matrix, representative five-slot builds, conflict, cap, no-recursion, and neutral-fallback fixtures |
| P001-TASK-011 | `CORE-REQ-002`, `CORE-REQ-013` | Implement aggregate catalog and configuration validation, enabled projection validation, deterministic snapshots, and stable fail-closed diagnostic codes. | P001-TASK-002 through P001-TASK-010 | Validator, count report, reference report, diagnostics | Catalog validator, config validator, test tooling | Every required negative fixture fails before actions; valid snapshot is stable across repeated and reordered loads |
| P001-TASK-012 | `CORE-REQ-002`, `CORE-REQ-003`, `CORE-REQ-013` | Complete unit, property, golden, economy, active/passive, showcase-card, and regression fixtures and prove deterministic reruns. | P001-TASK-011 | Frozen phase fixture corpus and reports | Shared tests and verification artifacts | Full suite repeated from clean state; snapshot hashes, seed replay, mutation testing of critical validator branches |
| P001-TASK-013 | `CORE-REQ-003`, `CORE-REQ-013` | Exercise shared contracts through later-consumer test doubles and nondestructive Studio server-versus-client display comparisons without adding mutable gameplay ownership. | P001-TASK-012, Phase 000 Studio harness | Integration compatibility and Studio evidence | Server calculation adapter, client projection adapter, test harness | Same fixtures and versions yield matching projections; client-supplied price or reward is ignored or rejected; no service dependency leaks into Math |
| P001-TASK-014 | `CORE-REQ-002`, `CORE-REQ-003`, `CORE-REQ-013` | Update ordinary documentation, rerun every affected gate, inspect the complete diff and built artifact, and assemble merge, review-capability, tag, and downstream handoff evidence. | P001-TASK-013 | Phase completion packet and `CORE-PHASE-002` handoff | Documentation, verification records, repository operations | Documentation link check, full clean rerun, secret and artifact inspection, required checks, recorded independent-review capability disposition, any obtained review resolved, merge and signed-tag verification |

### Ordering, Parallelism, and Recovery by Task

- `P001-TASK-001` is strictly first. A changed saved-goal digest, invalid current plan set or handoff, failed Phase 000 integration, tool failure, or source-contract conflict stops the phase. Recovery is to restore the verified input or obtain authorized plan handling without modifying or rebinding the saved goal; plan digest drift alone does not stop work, and no downstream work may proceed while a real gate fails.
- `P001-TASK-002` must precede every content consumer. `P001-TASK-003` and `P001-TASK-004` may proceed in parallel after the shared types and key rules are stable. Invalid generated counts or keys are corrected in catalog data and rerun from generation; snapshots are never hand-edited to hide drift.
- `P001-TASK-005` may begin after the content IDs it references are frozen. `P001-TASK-006` depends on its weight, pity, and limit schemas. A balance failure rolls back only the unaccepted configuration version and its derived snapshots; stable identity records remain unchanged.
- `P001-TASK-007` may proceed in parallel with catalog population after `P001-TASK-001`, but it must close before detectors, scoring, or effects can be accepted. Unsafe arithmetic has no saturation fallback unless a named configuration cap is intentionally applied and traced.
- `P001-TASK-008` depends on rank and number contracts. It may run in parallel with late economy fixture work. A detector ambiguity is resolved through the documented best-base and tie-break contract, never through table iteration order.
- `P001-TASK-009` begins only after number, content, formation, and configuration interfaces are stable. Any stage-order change invalidates all dependent traces and requires a full rerun from card-contribution fixtures upward.
- `P001-TASK-010` begins after the registry and scoring hooks exist. Independent Joker handlers may be implemented in parallel, but the pairwise and representative five-Joker suite is serialized against one frozen registry. A recursive enhancer, unresolved conflict, or missing cap disables the affected definition and blocks phase exit.
- `P001-TASK-011` aggregates every prior contract and is fail closed. A valid partial subset cannot authorize launch actions. Recovery corrects the source catalog, config, or registry, increments a behavior version when required, regenerates all derived artifacts, and reruns dependent tests.
- `P001-TASK-012` and `P001-TASK-013` require the complete validated snapshot. A fixture update must be justified by an authorized source or intentional versioned tuning change; blindly accepting new golden output is prohibited.
- `P001-TASK-014` is strictly last. Any code, catalog, configuration, documentation, tool, or artifact change after packet creation invalidates the relevant packet entries. Merge and tag recovery follows repository rules; `CORE-PHASE-002` remains blocked until `origin/main` and the signed tag are verified.

## Architecture and Implementation Boundaries

### Ownership and Dependency Direction

The shared catalog layer owns immutable identity and definition data. Shared configuration owns versioned server balance and client-safe projections. Shared Math owns pure normalization, formation detection, checked arithmetic, effect evaluation, and trace construction. Shared Types owns domain and compatibility schemas. None of these layers may read DataStore, remotes, UI state, wall-clock time, mutable player services, or global randomness.

Dependency direction is one way:

```text
Shared Types
    ↓
Catalogs and Config
    ↓
Safe Math, Formation Detector, and Effect Registry
    ↓
Calculation Result and Trace
    ↓
later server authority and client display consumers
```

Catalogs cannot call handlers. Definitions reference registered handler IDs, and the calculation registry resolves them against an explicit allowed set during validation. Handlers receive immutable normalized context and return typed effect contributions or state intents. They cannot mutate input, inventory, currency, round state, or another handler's result.

### Launch Identity and Version Contract

- Stable content IDs match `^[a-z0-9]+(?:_[a-z0-9]+)*$`; numeric rank IDs `2` through `10` are valid members of that grammar. Display names are not stored identity.
- Deck Set IDs are `classic`, `radioactive`, and `astral`.
- Rank IDs are `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `jack`, `queen`, `king`, and `ace`. Values are 2 through 14 in that order.
- Suit IDs are `hearts`, `diamonds`, `clubs`, and `spades`.
- Slot keys are `<faceRankId>:<suitId>`, base identity keys are `<deckSetId>:<slotKey>`, and form keys are `<baseIdentityKey>:<editionId>`.
- Enabled Edition IDs are `normal`, `foil`, `golden`, and `steel`.
- Grade IDs are `f`, `e`, `d`, `c`, `b`, `a`, `s`, `ss`, `sr`, `ur`, and `lr` with the cataloged multipliers and cumulative XP thresholds.
- Power Tier IDs are `common`, `uncommon`, `rare`, `epic`, `legendary`, `mythic`, `secret`, `infernal`, `celestial`, `chaos`, and `zenith` with the cataloged multipliers.
- Launch Trait IDs are `fortune`, `fierce`, `guardian`, `swift`, `lucky`, `scholar`, `critical`, `resilient`, `radiant`, `adaptive`, `efficient`, and `social`.
- Launch Joker IDs are `pocket_ledger`, `painted_pip`, `paper_shield`, `quick_shuffle`, `red_ribbon`, `black_thread`, `number_cruncher`, `full_binder`, `balanced_scales`, `royal_chorus`, `set_purist`, `golden_dividend`, `streak_keeper`, `full_spectrum`, `set_architect`, `fivefold`, `arcana_adept`, `crown_engine`, `set_resonator`, `overclock`, `joker_union`, `packstorm`, `house_of_fifty_two`, and `archivist`.
- Launch Arcana IDs are `polisher`, `treasury`, `forge`, `heart`, `gem`, `clover`, `spear`, `stair`, `examiner`, `regrader`, `voice`, and `mask`.
- `catalogVersion` identifies identity, reference, and handler-contract snapshots. `configVersion` identifies balance, odds, cap, feature, and stage-parameter snapshots. Both positive versions accompany validation reports, calculation inputs, results, traces, roll records, and client-safe projections.
- Changing display text alone does not change identity. Adding or disabling content, changing a handler contract, or changing calculation semantics changes `catalogVersion`. Changing a numeric balance, odds, cap, cadence, flag, or anti-abuse value changes `configVersion`. Stored identities are never reinterpreted by either change.

### Catalog and Configuration Contract

The enabled projection is derived from validated definitions and server feature configuration. A definition is not enabled merely because its ID exists. Validation proves the exact launch counts, legal cross-references, required handler registration, allowed parameter schema, and absence of future-only dependencies. Future definitions may be represented for compatibility only when `launchEnabled` is false and every acquisition, equip, scoring, purchase, and display projection filters them out.

All numeric effects remain configuration data. Where the sources provide a range or tuning target rather than every intermediate value, execution must freeze a complete value table in the versioned balance snapshot, document the selected values as launch tuning, and cover every entry with golden fixtures. This is implementation-level balance completion, not authority to change a stable identity, required endpoint, or owner decision.

Affinity definitions preserve the launch identities: Classic supports balanced formations, Radioactive supports consecutive successful formations and Cash, and Astral supports exact sums and Crown formations. The four active-card thresholds are 13, 26, 39, and 52. Each affinity handler and parameter set is explicit, bounded, testable, and present in the trace; no Deck Set name check may exist outside the data-driven affinity registry.

### Number, RNG, and Cap Contract

- Trusted currency, reward, score, count, XP, weight, threshold, and cap values are nonnegative integers. Negative, fractional, `NaN`, infinite, missing, or out-of-range values are rejected before calculation.
- The maximum accepted launch result is `999999999999999`, preserving the requirement that saved currency and score remain below `10^15`. Checked addition, subtraction, and scaled multiplication reject any intermediate or final value outside the declared domain before it can become a trusted result.
- Multipliers use an exact integer rational representation with a positive nonzero denominator. Configuration parsing cannot depend on binary floating-point equality. One centralized documented rounding rule applies at named stage boundaries and records the pre-round rational and post-round integer in the trace.
- An intentional gameplay cap is distinct from arithmetic overflow. A gameplay cap may clamp only when its stable cap ID, configured bound, original value, and clamped result appear in the trace. Arithmetic overflow, underflow, invalid denominator, or nonfinite input rejects the calculation and emits no reward.
- Deck Set Pack Power Tier weights use integer units totaling exactly `100000`: `66000`, `20000`, `8000`, `3500`, `1500`, `650`, `250`, `80`, `15`, `4`, and `1` in tier order. Joker Pack rarity weights use the same total: `55000`, `25000`, `12000`, `5000`, `2500`, and `500`. The launch Trait chance is `10000` of `100000` after Tier selection.
- Pity and early protection are deterministic transformations of versioned state and an explicit supplied RNG stream. Weight-table traversal uses catalog order, not hash iteration. The roll record includes seed identity or reproducible RNG record, input pity, selected bucket, output identity, post-commit pity, `catalogVersion`, and `configVersion`.
- The calculation layer never creates a random seed, reads time, or trusts a client roll. Later server services provide the seed or committed roll record.

### Formation and Calculation Contract

Formation input is an ordered array of one through five distinct normalized card views plus the versioned round target and mode context. Map-backed supporting state is converted to stable sorted arrays before evaluation. Sequence order is 2 through Ace with no wrap; Crown Run is the explicit Ten through Ace rule. Blanks have no rank, suit, Edition, Grade, Power Tier, Trait, affinity, or contribution.

The twelve stable formation IDs represent Single, Twin, Twin Pair, Triple, Sequence, Monosuit, Court, Spectrum, Full Cluster, Quad, Crown Run, and Per&#102;ect Sum. A detector returns every matching formation with its configured base multiplier and only explicitly declared stackable bonus references. The primary result is the highest configured base reward; equal values use a frozen formation priority and then stable ID as the final tie-break. It never multiplies all detected patterns together.

The calculation engine uses this stage order:

1. Validate catalog and configuration versions, input shape, uniqueness, legal IDs, finite integer fields, caps, and mode context.
2. Preserve the submitted array order where order is a rule, and sort every unordered supporting collection by stable ID or slot index.
3. Run registered `beforeFormationDetection` effects and record any bounded detection projection without mutating the source cards.
4. Detect all formations, run `afterFormationDetected`, select the best base formation, and resolve only declared stackable bonuses through stable precedence.
5. For each scoring card in canonical submission order, run `beforeCardContribution`, apply face value, Edition component, Grade multiplier, Power Tier multiplier, Trait effect, affinity effect, and declared card-scoped additive then multiplicative groups, then run `afterCardContribution`.
6. Sum checked integer card contributions separately for Cash, Power, Guard, pack progress, and Grade experience.
7. Run `beforeFormationMultiplier`, apply the selected formation multiplier and explicit bonuses, then apply deck-wide Joker additive groups and Joker multiplicative groups after conflict resolution.
8. Apply personal active boosts, server event boosts, and mode modifiers in that order. Souls are a neutral reserved stage at launch and cannot be enabled.
9. Apply named gameplay caps and the centralized rounding contract, then run `afterFormationReward` for trace or bounded derived-result contributions.
10. Finalize the immutable result and trace. Emit `onFormationSuccess` or `onFormationFailure` as typed downstream state intents; pure math never mutates round or profile state.

Every trace records input versions, normalized card and active-Joker IDs, formation candidates, selected formation and tie-break, each stage ID, handler ID, operands, additive or multiplicative group, conflict decision, cap, rounding, result components, and stable reason IDs. A client-facing explanation may omit private or operational details but must be derived from the authoritative trace rather than recalculating the score.

### Joker Effect Registry Contract

Each Joker definition contains stable ID, display label, rarity ID, effect handler ID, typed parameters, subscribed stages, conflicts, caps, launch enablement, and explanation keys. The effect registry is keyed by handler ID, validates parameter schemas before calculation, and produces neutral output only for an intentionally disabled effect with a documented neutral fallback. An unknown or invalid enabled handler fails validation and blocks actions.

The five active Joker inputs are ordered by slot for explanation and slot-sensitive rules, but commutative numeric groups are reduced in stable handler and Joker ID order. Enhancers such as `joker_union` cannot enhance themselves, recursively reapply, or change identity. Threshold reducers cannot lower a threshold below its configured floor. Accumulating effects such as streak, Packstorm, and Archivist require explicit counters and caps. Draw, timing, task, affinity, failure, and reward-event handlers return typed state intents or modifiers; they do not perform service mutations.

The effect test inventory covers every individual launch Joker, every pair, and representative five-slot builds containing direct output, Edition enhancement, affinity threshold and strength changes, timing or Guard drawbacks, streak protection, Packstorm state intent, Joker Union enhancement, and collection-count caps. A sixth slot is invalid. Conflicts resolve through declared stable precedence and are visible in the trace.

### Economy and Anti-Abuse Contract

The economy snapshot declares all enabled launch sources and sinks. Cash funds the three Deck Set Packs. Joker Tickets fund Joker Packs. Arcana Dust funds Arcana Packs. Grade Ink funds deterministic Grade progress. Trait Essence funds Trait choices and removal. Duel Tokens fund declared duel cosmetics and the weekly earned pack. Ascension Fragments are sourced from eligible high-Tier results or salvage and are reserved for a later deterministic promotion consumer. Soul Fragments are schema-reserved with no enabled launch source or sink, a zero launch cap, and rejected mutation while Souls remain disabled.

Each currency has a configured nonnegative cap below the launch number bound, transfer policy `not_tradable`, stable source and sink reason IDs, and allowed context schema. Every later mutation contract contains previous balance, integer delta, reason ID, resulting balance, operation ID, configuration version, and sanitized context. Client projections may show prices, odds, caps, and explanations but cannot supply trusted values back to the server.

Anti-abuse configuration includes per-source reward eligibility, social daily caps, same-opponent diminishing returns and cutoff, cadence limits, duplicate-operation behavior, passive and offline limits, and bounded analytics reason IDs. Repeat caps can stop economy rewards without blocking unrewarded private play. The default passive baseline is 18 percent of normalized ordinary active output, and frozen fixtures must show active output at least five times passive output over the same trusted duration.

## Failure, Recovery, and Edge Cases

The phase is pure and does not own durable partial commits, retries, or concurrent profile mutation. Its recovery model is fail-closed construction: invalid catalogs or configuration never produce an enabled snapshot; invalid calculations never produce a trusted reward; and deterministic reruns with the same validated versions and inputs return the same result. Later services own retry and idempotent mutation around these pure contracts.

| Scenario | Detection | Required behavior | Recovery or rollback | Regression proof |
|---|---|---|---|---|
| Duplicate, malformed, uppercase, or reused stable ID | Catalog grammar, uniqueness, retired-ID, and key validation | Reject snapshot; no affected content is enabled. | Correct the source definition or perform an authorized migration; regenerate derived keys and snapshots. | Duplicate, uppercase, malformed, collision, and retired-ID fixtures. |
| Exact launch count mismatch | Generated count report differs from `DEC-003` | Fail validation and server initialization contract. | Restore required records or correct unintended enablement; never pad with placeholders. | One-too-few, one-too-many, disabled-required, enabled-future fixtures. |
| Missing or invalid reference, handler, parameter, asset reference contract, or conflict target | Aggregate reference validation | Disable affected acquisition and fail full launch validation before actions. | Correct the definition or documented neutral fallback, increment the applicable version, and rerun all dependents. | Unknown ID, handler, stage, parameter type, conflict, and cap fixtures. |
| Future content known to a modified client | Enabled projection contains a future ID or receives an unknown requested ID | Omit from launch display and reject use, acquisition, equip, score, or purchase intent. | Restore server feature projection; preserve any valid preexisting ownership data without activating it. | Modified-client projection and unknown-ID fixtures. |
| Catalog and configuration version mismatch | Input versions differ from validated active snapshots | Reject calculation with a stable stale-version result and no reward. | Fetch the authoritative projection and retry with a new request through later service contracts. | Old catalog/new config and new catalog/old config fixtures. |
| Malformed calculation input | Type, shape, count, duplicate, ID, state, or target validation | Reject before hooks or arithmetic and return no trusted result. | Caller refreshes authoritative state; pure module remains unchanged. | Missing field, extra illegal field, zero/six cards, duplicate instance, invalid rank, blank misuse, and stale target fixtures. |
| `NaN`, infinity, fractional integer, negative value, invalid rational, underflow, or overflow | Safe number constructor and checked operation | Reject the value or calculation; do not clamp arithmetic failure or emit a reward. | Correct the caller or configuration; rerun from validation. | Dedicated boundary fixtures and generated numeric properties. |
| Valid gameplay result exceeds a named cap | Cap stage observes value above configured bound | Clamp only at the named stage and record original, cap ID, cap value, and result. | Retune through a new configuration version if the cap is unhealthy. | At-cap and over-cap golden traces. |
| Multiple formation patterns match | Detector returns more than one candidate | Select highest configured base reward, then frozen priority and stable ID; apply only explicitly stackable bonuses. | Change only through a versioned formation contract and regenerate traces. | Full Cluster, Crown Run, Spectrum, Monosuit, and Per&#102;ect Sum overlap fixtures. |
| Formation near miss, duplicate card, invalid rank, or illegal size | Detector preconditions or candidate rules fail | Reject invalid input or return no successful formation without consuming state. | Later caller preserves hand and rewards; pure rerun remains safe. | Boundary and permutation suite for all twelve formations. |
| Table iteration or insertion order changes | Property test permutes map construction and registry load order | Result and trace remain byte-equivalent. | Replace unordered traversal with canonical ordering; invalidate every dependent golden trace. | Repeated randomized permutation tests. |
| Joker conflict, recursive enhancement, missing cap, or sixth slot | Registry graph and active input validation | Resolve declared conflict once or reject invalid build; never recurse or silently drop an enabled rule. | Correct definition or build and regenerate all affected pairwise and five-slot fixtures. | Conflict graph, recursion, cap, slot, and Joker Union fixtures. |
| Accumulating Joker receives stale or impossible counter state | Typed round context and configured counter bounds | Reject the context; do not infer progression or award an event. | Later Formation service refreshes authoritative state. | Negative, fractional, beyond-cap, reordered, and replayed counter fixtures. |
| Currency source or sink missing, client amount supplied, balance underflow, or cap exceeded | Economy schema and pure mutation projection validation | Reject the definition or projection; no trusted balance result. | Correct versioned config or authoritative service input and rerun. | Source/sink matrix, client-amount, zero-balance, exact-cap, cap-plus-one fixtures. |
| Social reward cap reached | Same-opponent and daily counters reach configured boundary | Return zero economy reward with a stable reason while preserving unrewarded play eligibility. | Counter expires or resets only under authoritative later-service time state. | Before/at/after cap and different-opponent fixtures. |
| Active/passive comparison is below five-to-one | Frozen normalized comparison report | Block phase exit and downstream balance freeze. | Retune versioned active rewards or passive rate, regenerate snapshot, and rerun all economy fixtures. | Representative weak, average, and strong launch deck comparisons. |
| Golden fixture changes unexpectedly | Snapshot hash or trace diff | Treat as a regression, not an automatic fixture update. | Identify authorized source or intended version change; otherwise restore behavior. | Clean double-run and reviewed golden diff. |
| Studio projection disagrees with shared authoritative result | Same fixture yields different displayed components or explanation | Block phase exit; client display cannot become authoritative. | Correct projection adapter or version mismatch and rerun pure plus Studio evidence. | Frozen nondestructive server/client comparison. |
| Dependency or tool becomes unavailable | Version, command, build, or harness preflight fails | Stop affected work and retain last valid artifacts without claiming completion. | Restore exact Phase 000 contract and rerun from the lowest invalidated gate. | Clean-environment command transcript and CI rerun. |

## Verification Matrix

| Requirement or task | Static or unit | Integration | Real workflow or runtime | Negative and recovery | Evidence artifact |
|---|---|---|---|---|---|
| P001-TASK-001 | Strict type checks, ID grammar, key and version tests | Snapshot loader accepts only matching versions | Studio loads the validated shared contract | Digest, version, malformed key, and incompatibility fixtures | Entry record and domain-contract report |
| P001-TASK-002 | Exact cross-product and key tests | Catalog snapshot feeds downstream builders | Studio enumerates 156 identities and 624 forms from the same snapshot | Duplicate, missing, extra, uppercase, malformed, and future-enabled records | Catalog snapshot and generated count report |
| P001-TASK-003 | Value, monotonicity, threshold, parameter, and contribution tests | Card Math consumes only typed progression and affinity records | Frozen representative cards show the same projected components in Studio | Unknown Grade, Tier, Trait, Edition, affinity, illegal threshold and cap | Progression and affinity golden fixtures |
| P001-TASK-004 | Exact selected ID, rarity, count, handler and slot tests | Registry resolves every Joker and Arcana definition | Studio inspection lists the validated launch projection | Unknown handler, illegal params, missing conflict, sixth slot, future entry | Handler inventory and selected-content report |
| P001-TASK-005 | Integer, source, sink, cap, transfer, reason, cadence, and ratio tests | Receipt and event projection test doubles use one config | Studio display uses server-projected prices and limits | Missing source/sink, client amount, underflow, cap, social-farming violations | Economy snapshot and source-and-sink report |
| P001-TASK-006 | Exact `100000` weight totals and deterministic selection tests | Random-service test double consumes the frozen tables | Studio pack-details projection matches the weight table | Negative, fractional, wrong total, boundary, stale pity, reordered table | Integer-weight and pity boundary report |
| P001-TASK-007 | Checked arithmetic and rational properties | Every detector and scorer uses the safe layer | Studio formats accepted bounded results without recalculation | `NaN`, infinity, fraction, negative, denominator zero, underflow, overflow | Numeric boundary and property report |
| P001-TASK-008 | Valid, near-miss, permutation, overlap and tie tests for twelve formations | Score engine consumes normalized detector output | Nondestructive Studio frozen submissions match pure detection | Duplicate instance, invalid rank, illegal size, blank misuse, stale target | Formation fixture matrix |
| P001-TASK-009 | Stage, group, rounding, cap and trace tests | Later-consumer adapters use the same result and trace | Server and client presentation agree in Studio | Stage omission, reordered groups, stale version, overflow, conflicting bonus | Golden calculation trace corpus |
| P001-TASK-010 | Per-handler, pairwise, cap, conflict and five-slot tests | Registry and scorer execute all enabled handlers | Studio explanation agrees with trace for representative builds | Sixth slot, recursion, unknown handler, stale counter, disabled effect | Twenty-four Joker traces and interaction report |
| P001-TASK-011 | Validator branch and stable diagnostic tests | Initialization test refuses invalid aggregate state | Studio fails closed before accepting phase test actions | One negative fixture for every validation class | Validator output and negative-fixture inventory |
| P001-TASK-012 | Full unit, property, golden, showcase and ratio suite | Clean double-run yields identical hashes | Studio rerun uses frozen fixtures and versions | Mutation of critical constraints is detected rather than accepted | Test transcript, snapshot hashes, active/passive report |
| P001-TASK-013 | Adapter dependency and projection checks | Server-authoritative and client-safe contracts compare | Nondestructive Studio comparison on frozen fixtures | Client-supplied price/reward, stale versions, hidden fields, projection drift | Studio recording or transcript and comparison report |
| P001-TASK-014 | Formatting, lint, docs and artifact checks | Complete clean command sequence and CI | Built artifact loads and phase smoke remains green | Secret, cache, debug, machine path, unrelated diff, stale evidence | Completion packet, review, merge commit, signed tag |
| `CORE-REQ-002` | Exact counts, IDs, references, values and handlers | One snapshot serves all test consumers | Validated launch projection loads in Studio | All invalid catalogs and disabled-content paths fail closed | Catalog and configuration snapshots plus validator report |
| `CORE-REQ-003` | Formation, stage, property, cap, conflict and trace proof | Shared result drives server and display adapters | Frozen server and client comparison in Studio | Near miss, duplicate, ordering, malformed number, overflow and conflict proof | Formation matrix and golden trace corpus |
| `CORE-REQ-013` | Source, sink, integer, cap, anti-farming and ratio proof | Receipt and currency-event projections reconcile | Studio displays only authoritative projected values | Client amounts, underflow, overflow, cap and abuse boundaries | Economy report and active/passive comparison |

### Fixtures, Environments, and Rerun Order

- The fixture corpus includes every rank and suit boundary, all three Deck Sets, every enabled Edition, Grade, Power Tier, Trait, affinity, formation, Joker, and Arcana identity, plus disabled future sentinels that must never enter the launch projection.
- Formation fixtures include one valid minimum and maximum example per applicable size, at least one near miss per rule, duplicate-instance and invalid-rank cases, overlap cases, and randomized input and map-order permutations.
- Score fixtures include weak, median, and high launch cards; each separate output component; every stage; zero and cap boundaries; each named conflict and cap; and the canonical showcase card through the ordinary path.
- Joker fixtures include each definition alone, the complete pairwise matrix, and representative five-slot builds that cover additive, multiplicative, Edition, affinity, drawback, streak, counter, task, and event effects.
- Economy fixtures include every source and sink, reserved Soul Fragments, price boundaries, exact and exceeded caps, social daily and same-opponent limits, passive and offline limits, and normalized active-versus-passive comparison over the same duration.
- Pure tests run under the pinned Lune command from Phase 000. Integration tests use only typed test doubles around the shared interfaces. Nondestructive Studio tests use the Phase 000 synchronization and test harness with no production DataStore, purchase, trade, or publication operation.
- Expected results are frozen as catalog snapshot, configuration snapshot, validator diagnostics, count report, source-and-sink report, weight report, formation matrix, calculation traces, and comparison reports. Each artifact records source commit, tool versions, `catalogVersion`, `configVersion`, and fixture version.
- Rerun order is formatting, static analysis, catalog and configuration validation, number unit tests, formation unit and property tests, score and Joker golden tests, economy and ratio tests, integration adapters, Studio comparisons, build, documentation links, secret scan, diff inspection, and artifact inventory. A failure invalidates that layer and every later dependent layer.
- Lower-fidelity proof cannot replace the required Studio server-versus-client comparison. Studio proof cannot replace deterministic pure and property proof.

## Documentation, Operations, and Release

- Update `README.md` only if Phase 001 changes the documented setup, available commands, repository layout, or user-visible current status. Keep planned gameplay labeled as planned until downstream runtime evidence exists.
- Update `docs/general/documentation.md` with the implemented shared types, catalog and configuration versioning, dependency direction, number representation, formation rules, calculation stage order, trace schema, Joker registry, economy contract, failure behavior, and exact commands.
- Update `docs/README.md` when new test or verification records are added so navigation remains complete.
- Reconcile `docs/general/content-catalog.md` and `docs/implementation/launch-foundation.md` only where implemented behavior exposes a documented discrepancy or where exact launch tuning selected under this phase must be recorded. Stable identities and the protected master plan cannot be changed to make implementation convenient.
- Store repeatable procedures under `docs/test/` and verified phase results under `docs/verification/`, following the repository's established index and naming chosen during execution. Record expected output, fixture version, environment, rerun order, decisive failure interpretation, and evidence invalidation rules.
- Record exact formatter, linter, test, Studio, build, documentation, secret, and artifact-inspection commands established by Phase 000. Do not describe a command as verified unless its transcript passes on the phase commit.
- No DataStore migration, production configuration mutation, Roblox publication, commerce operation, player-facing rollout, or release artifact publication occurs in this phase. The built artifact is local or CI verification evidence only.
- Synchronize ordinary issues, milestone, roadmap Project item, phase branch, pull request, checks, review, merge commit, signed tag, and wiki preparation according to repository rules without modifying `plan.md`, `full_plan.md`, any phase plan, `plan.index.json`, `plan.handoff.json`, or the saved goal during execution.
- Wiki publication waits until the approved phase merge. Collaborator access, paid services, and changes to the repository's current public visibility remain unauthorized; existing public read access remains unchanged.

## Risks and Evidence Invalidation

| Risk | Prevention | Detection | Recovery | Evidence invalidated | Reverification |
|---|---|---|---|---|---|
| Launch count or selected-ID drift | Generate enabled projections from stable definitions and validate against `DEC-003`. | Count, selected-ID, and future-enabled reports. | Restore required definitions or correct flags; regenerate all derived artifacts. | Catalog snapshot, reference report, all consumer tests. | Rerun from catalog validation through Studio and build. |
| Balance data becomes identity logic | Keep IDs and handler contracts separate from versioned parameters. | Diff and architecture review find value-specific identity branches. | Move values to Config without changing stored IDs. | Config snapshot, score traces, economy reports. | Rerun configuration, calculation, economy, integration, and Studio gates. |
| Showcase card receives a special case | Generate it through ordinary axes and scan for identity-specific branches. | Showcase fixture differs from the generic constructor or conditional scan finds its combined identity. | Remove the special path and use catalogs and handlers. | Card, catalog, calculation, and showcase evidence. | Rerun key, card, scoring, property, and Studio comparison tests. |
| Floating arithmetic changes results | Use exact rationals, checked integers, named rounding, and a stable stage order. | Cross-run, permutation, and boundary trace differences. | Correct safe math and regenerate reviewed golden traces. | Every dependent score, Joker, economy, and Studio artifact. | Rerun from safe number tests through all calculation consumers. |
| Launch values approach precision limit | Enforce the below-`10^15` result bound and stress fixtures. | Boundary and high-build property tests. | Retune caps or multipliers under a new config version; do not implement `FUT-012` early. | Config, cap, high-build, leaderboard-projection evidence. | Rerun config validation, numeric properties, scores, economy, Studio and build. |
| Formation ambiguity or iteration dependence | Normalize inputs, return all candidates, and use frozen best-base and tie-break rules. | Permutation properties and overlap golden fixtures. | Correct ordering or rule data and increment applicable version. | Formation matrix and every score trace. | Rerun all formation, calculation, Joker and Studio comparisons. |
| Joker enhancer recursion or order sensitivity | One-pass enhancement graph, self-exclusion, explicit groups and precedence. | Pairwise, five-slot, recursion, and shuffled-registry tests. | Correct handler graph or conflict declaration and regenerate traces. | Affected Joker and combination evidence, downstream score evidence. | Rerun full Joker inventory, pairwise matrix, score suite, Studio inspection. |
| Uncapped counter or effect permits infinite reward | Require counter domain, trigger cadence, and cap on accumulating effects. | Generated boundary and long-sequence properties. | Disable affected definition, correct config or handler, and version the change. | Handler validation, traces, economy and active-loop interface evidence. | Rerun validator, handler, long-sequence, economy and integration tests. |
| Economy source or sink is unreachable or abusable | Complete matrix, stable reasons, server-authority interface, social and cadence caps. | Coverage report and abuse-boundary fixtures. | Correct versioned configuration without changing currency identity. | Economy snapshot, reason inventory, ratio and adapter evidence. | Rerun all economy, anti-abuse, integration and Studio projection tests. |
| Active play falls below required ratio | Same-duration frozen representative comparisons. | Ratio report below 5.0. | Retune active rewards or passive rate in a new config version. | Economy snapshot and every reward comparison. | Rerun config validation, economy suite, all dependent golden traces and Studio projection. |
| Future-disabled content leaks | Server-derived enabled projection and unknown-ID rejection. | Modified-client and future-sentinel fixtures. | Restore projection filter and block affected consumer. | Catalog, projection, security-interface and Studio evidence. | Rerun validation, projection, integration, Studio and build. |
| Catalog or config version changes after evidence | Bind every artifact to both versions and source commit. | Packet digest mismatch. | Regenerate all affected snapshots and evidence; never relabel old output. | All artifacts consuming the changed version. | Rerun from the lowest changed catalog, config, handler, or math layer. |
| Tool or command drift | Verify exact Phase 000 versions and use identical local and CI commands. | Version output, checksum, or command mismatch. | Restore pinned artifact and rerun. | All evidence produced by the mismatched tool. | Full clean rerun with exact tools. |
| Studio and pure results diverge | Share result and trace projection, never duplicate calculation on the client. | Frozen server/client comparison. | Correct adapter, serialization, or version selection. | Integration and Studio evidence plus affected display docs. | Rerun pure snapshot, integration, Studio and build. |
| Documentation overstates implementation | Separate implemented pure contracts from planned service and UI workflows. | Documentation review against code and evidence. | Correct ordinary docs before merge. | Documentation and completion packet. | Link check, evidence cross-check, final review. |
| Current plan or goal integrity changes | Reread the complete current plan set and handoff at entry and before merge; verify the saved goal's own creation digest while treating goal-recorded plan digests as provenance. | Invalid manifest or handoff, material product-contract conflict, or changed saved-goal digest. | Stop with `GOAL_REVISION_CONFLICT` only for a changed saved-goal digest. Route an invalid or materially conflicting plan set through owner-authorized plan handling; never overwrite or rebind the goal. | Entire phase authorization and completion packet when a real integrity or contract failure exists; plan digest drift alone invalidates nothing. | Resume after the current plan set and handoff validate and the unchanged saved goal passes its own digest check. |

## Phase Completion Packet

The packet is stored outside the protected plan set and contains all of the following before the phase may close:

- Exact Phase 001 branch head, reviewed pull request, required check results, private independent review capability recorded as available or unavailable, any available review obtained with every actionable finding resolved, merge commit on `origin/main`, and the verified signed annotated phase tag. An unavailable review capability is nonblocking.
- Phase 000 tool versions and command identities, source commit, build artifact identity and hashes, `catalogVersion`, `configVersion`, and fixture version.
- Deterministic catalog and configuration snapshots with hashes and a generated report proving all exact launch counts, selected IDs, rarity distribution, references, handlers, and disabled future boundary.
- Validator success output and the indexed negative-fixture results for duplicate IDs, bad grammar, missing and extra entries, invalid references, unknown handlers, illegal parameters, bad conflicts, missing caps, future enablement, mismatched versions, invalid weights, and invalid economy contracts.
- Safe-number unit and property results covering rounding, checked arithmetic, the launch maximum, gameplay caps, underflow, overflow, fractional inputs, invalid rationals, `NaN`, and infinity.
- Complete formation fixture matrix for all twelve formations, including valid boundaries, near misses, duplicate instances, illegal ranks and sizes, permutations, overlapping patterns, best-base selection, and tie-breaks.
- Golden calculation trace corpus for representative Edition, Grade, Power Tier, Trait, affinity, boost, mode, and multi-pattern behavior, plus the ordinary-path trace for the canonical showcase card.
- Twenty-four individual Joker traces, complete pairwise results, representative five-slot builds, conflict and cap reports, and event-intent evidence for non-score effects.
- Economy source-and-sink, cap, transfer, reason-code, integer-weight, pity, cadence, anti-farming, and active-versus-passive reports, with reserved Soul Fragments proven inert.
- Clean repeated pure and integration test transcripts with matching snapshot hashes, plus nondestructive Studio server-versus-client comparison evidence tied to the same versions.
- Formatter, static analysis, test, Studio, build, documentation-link, secret, final-diff, generated-output, debug-output, machine-path, cache, and built-artifact inventory results.
- Ordinary documentation diffs and navigation updates that describe only implemented contracts and verified commands.
- Issue, milestone, roadmap Project, pull request, review, check, merge, tag, and wiki-preparation state consistent with the merged repository, plus proof that the complete current protected plan set and handoff validate and the saved goal retained its own creation digest. Goal-recorded plan and plan-set digests remain creation-time provenance.
- A downstream handoff naming the exact shared interfaces, versions, snapshot hashes, known neutral fallbacks, invalidation triggers, and the first allowed `CORE-PHASE-002` entry check. No unresolved mandatory Phase 001 defect or deferred Phase 001 requirement may remain.

## Next Transition

`CORE-PHASE-002` may begin only after the Phase 001 pull request is merged through GitHub, all required checks and review findings are resolved, `origin/main` contains the merge commit, the signed annotated Phase 001 tag is pushed and verified, the completion packet passes audit, the complete current protected plan set and handoff validate, and the saved goal's own digest still matches its recorded creation digest. Goal-recorded plan and plan-set digests remain creation-time provenance and do not block this transition merely because the authorized live plan changed.

The first Phase 002 action is to consume the frozen catalog, configuration, safe-number, formation, calculation, Joker-registry, economy, and trace contracts from the verified Phase 001 merge while establishing the server-authoritative network, durable profile, transaction, inventory, deck, and renderer vertical slice. Phase 002 must not reinterpret stable IDs, duplicate calculation logic in services or clients, accept client-supplied trusted values, or begin from the historical Phase 001 branch. Any changed Phase 001 contract invalidates its dependent evidence and requires correction and reintegration before the transition proceeds.
