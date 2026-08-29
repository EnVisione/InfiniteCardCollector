# Phase 001 Catalog and Calculation Test Procedure

## Purpose

This procedure verifies the Phase 001 launch catalog, configuration, safe arithmetic, formation detection, Joker registry, calculation trace, economy projection, and Studio comparison contracts. It is nondestructive. It does not use DataStore, MemoryStore, remotes, purchases, trades, or Roblox publication.

The test contract is bound to `catalogVersion = 1`, `configVersion = 1`, and `fixtureVersion = 1`. A change to any of those versions, any Phase 001 source, the golden hash file, or a pinned Phase 000 tool invalidates the dependent evidence.

## Prerequisites

- Complete the reviewed setup in [Development Setup](../operations/development-setup.md).
- Run from the repository root with the exact tools resolved through Rokit.
- Keep generated files under `build/`; they are evidence outputs and remain untracked.
- For Studio proof, use the qualified Vinegar Studio route recorded by Phase 000 or native Roblox Studio on a currently supported operating system.
- Bind Rojo only to `127.0.0.1:34872`.

## Deterministic Command Sequence

Run the gates in this order:

```console
lune run verify-tools
stylua --check .
selene .
lune run test
rojo sourcemap default.project.json --output build/infinite-card-collector.sourcemap.json
rojo build default.project.json --output build/infinite-card-collector.rbxlx
lune run artifact
lune run docs
lune run secrets
lune run ci
```

Run `lune run test` and `lune run ci` twice from an unchanged worktree. Both runs must exit zero and produce the same Phase 001 canonical hashes.

## Automated Test Inventory

`lune run test` runs the eleven retained Phase 000 tests and these sixteen Phase 001 tests in stable ID order:

| Test ID | Coverage |
| --- | --- |
| `P001-TEST-001` | Shared launch entry point, catalog, config, and fixture versions. |
| `P001-TEST-002` | Exact enabled counts, selected content, key builders, and immutable validator snapshot. |
| `P001-TEST-003` | Rank, suit, identity, form, Edition, Grade, Tier, Trait, and affinity axes. |
| `P001-TEST-004` | Twenty four launch Jokers, twelve Arcana, disabled future content, handlers, assets, and rarity distribution. |
| `P001-TEST-005` | Currency sources, sinks, caps, transfer rules, prices, reasons, active ratio, and reserved Soul Fragments. |
| `P001-TEST-006` | Exact integer weights, boundary buckets, pity thresholds, stale pity rejection, and frozen roll records. |
| `P001-TEST-007` | Checked integer and rational arithmetic, half up rounding, caps, overflow, underflow, fractional values, `NaN`, and infinity. |
| `P001-TEST-008` | All twelve formations, applicable sizes, near misses, exhaustive canonical permutations, overlap, duplicate instances and slots, dense array shape, malformed cards, and stale targets. |
| `P001-TEST-009` | Stable best result, full score components, gameplay caps, and map insertion order invariance. |
| `P001-TEST-010` | Every launch Joker, all 276 pairs, representative five slot build, sixth slot rejection, and unknown Joker rejection. |
| `P001-TEST-011` | Validator negatives across count, ID, reference, handler, asset, balance, cap, conflict, weight, version, and disabled content classes. |
| `P001-TEST-012` | Client safe catalog, economy, and calculation projections, filtering, authority, trace redaction, order, and deep immutability. |
| `P001-TEST-013` | Canonical showcase card through ordinary catalog and calculation paths without an identity specific branch. |
| `P001-TEST-014` | Stale versions, malformed trusted state, nonfinite inputs, count mismatch, arithmetic failure, and cap boundaries. |
| `P001-TEST-015` | Declared stage vocabulary and order, all twelve Trait behaviors, Adaptive rank overrides, Resilient failure intent, matched formation overlap effects, dominant affinity enhancement, Joker state intents, stale counters, conflict handling, enhancement, and slot order invariance. |
| `P001-TEST-016` | Canonical report generation and SHA 256 comparison with the tracked golden hash contract. |

The expected summary is:

```text
test summary, 27 passed, 0 failed
```

Any failed test blocks Studio comparison and every later gate.

## Generated Phase 001 Reports

`P001-TEST-016` writes canonical JSON reports under `build/phase001/`:

| Report | Contents |
| --- | --- |
| `catalog.json` | Versions, enabled counts, ordered IDs, selected launch content, and disabled future boundary. |
| `config.json` | Versioned stages, feature flags, limits, odds, anti abuse rules, modes, and caps. |
| `balance.json` | Edition, Grade, Tier, Trait, affinity, formation, stackable bonus, and Joker tuning. |
| `formations.json` | Ordered formation definitions, legal sizes, multipliers, handlers, priorities, and explicit bonuses. |
| `jokers.json` | One accepted golden calculation for every launch Joker. |
| `interactions.json` | All 276 two Joker combinations and the representative five slot result. |
| `economy.json` | Currency, reason, price, odds, cap, and anti abuse contract. |
| `validator.json` | Accepted versions and covered negative validation classes. |
| `showcase.json` | Ordinary path canonical showcase calculation and full trace. |
| `activePassive.json` | Normalized active and passive values and the five to one acceptance result. |
| `hashes.json` | Canonical SHA 256 values for all tracked golden reports. |

The tracked contract is `tests/phase001/expected-hashes.json`. Do not replace a changed hash merely to make a failure disappear. Review the semantic report diff, confirm that the change is authorized by the live product contract, then update the expected hash and rerun every dependent gate.

## Studio Comparison

1. Start the exact loopback server:

   ```console
   rojo serve default.project.json --address 127.0.0.1 --port 34872
   ```

2. Open the mapped project in the qualified Studio environment and connect the reviewed Rojo v7.7.0 plugin.
3. Confirm the synchronized tree includes `ReplicatedStorage.Shared.Catalogs`, `Config`, `Fixtures`, `Math`, `Projection`, `Types`, and `LaunchContract`.
4. Start a local play session through Studio.
5. Inspect `ServerScriptService.Server` and the local player's `PlayerScripts.Client`.
6. Compare these attributes between the authoritative server result and client safe projection:

   | Attribute | Expected relationship |
   | --- | --- |
   | `CatalogVersion` | Both equal 1. |
   | `ConfigVersion` | Both equal 1. |
   | `LaunchIdentityCount` | Both equal 156. |
   | `LaunchFormCount` | Both equal 624. |
   | `Phase001FormationId` | Both equal `crown_run`. |
   | `Phase001Cash` | Values are equal. |
   | `Phase001Power` | Values are equal. |
   | `Phase001Guard` | Values are equal. |
   | `Phase001TraceEntries` | Counts are equal. |
   | `BootstrapState` | Both equal `ready`. |

7. Confirm the project console contains no Phase 001 assertion, runtime error, or warning produced by project code.
8. Stop play mode and verify the synchronized Edit DataModel still matches the built artifact topology.

The client calculation is a filtered projection of the shared authoritative result. The client does not accept or provide trusted price, reward, score, Tier, Trait, Grade, or random result values.

## Failure Interpretation

- `P001-CATALOG-*` means identity, count, stable ID, asset, handler, reference, or enabled content validation failed.
- `P001-CONFIG-*` means stage, feature, limit, odds, economy, anti abuse, reason, mode, or cap configuration failed.
- `P001-BALANCE-*` means versioned balance data is absent, malformed, uncapped, or inconsistent with its definition.
- `P001-SAFE-*` means exact arithmetic could not produce a trusted bounded integer.
- `P001-FORMATION-*` means submitted cards or target state are malformed, illegal, duplicate, or do not satisfy a stable detector contract.
- `P001-JOKER-*` means registration, slot, stage, parameter, counter, conflict, or effect execution failed.
- `P001-CALC-*` means normalized calculation input, stage execution, version, or cap behavior failed closed.
- `P001-PROJECTION-*` means the client safe view is missing required authoritative data or received an invalid version.
- `P001-STUDIO-*` means the synchronized server or client fixture did not produce an accepted result.

Record the first stable failure ID and repair the lowest failing layer. Do not use Studio success to waive a pure test failure, and do not use pure tests to waive Studio comparison.

## Evidence Invalidation and Recovery

- Catalog identity, count, selected content, or handler changes invalidate catalog, formation, calculation, Joker, projection, Studio, build, and documentation evidence.
- Config or tuning changes invalidate balance, odds, economy, calculation, Joker, active to passive, projection, Studio, and golden hash evidence.
- Arithmetic, detector, registry, scorer, or projection changes invalidate every dependent report and Studio comparison.
- Bootstrap, Rojo project, plugin, Studio, Vinegar, Wine, or tool changes invalidate the corresponding synchronization and artifact evidence.
- An unexplained hash change is a failed gate.

After a correction, rerun from the lowest affected test group through two complete `lune run ci` passes and the Studio comparison.
