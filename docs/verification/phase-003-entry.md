# Phase 003 Entry and Baseline Evidence

## Scope

This packet records `P003-TASK-001` for `CORE-PHASE-003`. It freezes the approved Phase 002 integration, current registered plan identities, immutable goal digest, launch counts, toolchain, isolated Studio environment, clean baseline, source asset inventory, and evidence topology before Phase 003 implementation begins. It does not claim any Phase 003 asset, pack, progression, Joker, or surface work is implemented.

The machine readable companion is [the Phase 003 entry manifest](phase-003-entry-manifest.json).

## Entry result

The Phase 003 branch `envy/core-phase-003` starts at `origin/main` commit `2f446b6c8167089eaa6f75f6a3d632b7004f2c04`. Phase 002 is integrated through merge commit `1ae97cfcec79427ff7849d83d0ecd39e31aebf72`, signed annotated tag `phase-002` verifies and points to that commit, and provenance synchronization is integrated in pull request 17 at the current branch base. Required Phase 002 checks passed. Private independent review was unavailable and is recorded as nonblocking.

The saved goal remains byte unchanged at SHA 256 `fbe125681fc52b42131aa7aa1f4f61902d33c7912adc982ebcb7dbd87cff2f69`. The current plan files are coherent and identify `CORE-PHASE-003` as the next mandatory phase. The current master and registered plan files reflect the authorized Vinegar plan revision, so their hashes differ from the goal's creation time plan and plan set hashes. This is authorized plan digest drift, not a goal revision conflict. The goal file was not edited.

## Inherited contract and count checks

| Contract | Observed value |
| --- | --- |
| Catalog, configuration, fixture | Version 1 |
| Action, envelope, profile schema, profile codec, receipt, renderer | Version 1 |
| Launch Deck Sets | 3, Classic, Radioactive, Astral |
| Base identities | 156 |
| Enabled Editions | 4, Normal, Foil, Golden, Steel |
| Permanent forms | 624 |
| Grades and Power Tiers | 11 and 11 |
| Launch Traits | 12 |
| Launch Jokers | 24, distributed 8 Common, 5 Uncommon, 4 Rare, 3 Epic, 2 Legendary, 2 Mythic |
| Launch Arcana | 12 |
| Formation presentations | 12 |
| Enabled Souls | 0 |

These values are validated by the Phase 001 catalog contract and the combined 52 test suite. Phase 002 preserves the typed action and message registry, profile and transaction boundaries, inventory and deck contracts, renderer view model, virtualization, and recovery packet consumed by this phase.

## Tool and runtime baseline

The approved tools are Rokit 1.2.0, Rojo 7.7.0, StyLua 2.5.2, Selene 0.31.0, and Lune 0.10.5. The approved Rojo server address is loopback `127.0.0.1:34872`. The baseline command results are:

| Command | Result |
| --- | --- |
| `lune run verify-tools` | Passed, all five tools and pinned executable hashes verified |
| `stylua --check .` | Passed |
| `selene .` | Passed, 0 errors, 0 warnings, 0 parse errors |
| `lune run test` | Passed, 52 tests, 0 failures |
| `lune run phase002-evidence` | Passed, six stable report hashes |
| `lune run artifact` | Passed, artifact hashes recorded below |
| `lune run docs` | Passed, 33 Markdown files |
| `lune run secrets` | Passed, 139 repository paths |
| `lune run ci` | Passed, all nine gates |

The reproducible artifact is `build/infinite-card-collector.rbxlx`, 312867 bytes, SHA 256 `20ec34e1787dc2f0594681899a8e7b6a27012f07d66b4458129ff27f2f2e7b35`, and SHA 512 `54f3d00835ad32cfaa86a275921394819367c592a9134954b7baecc02ba90b387fce8b76d8fe4aff8e9bafa49b1a11b8464ebd7d538a9d5422f6e2ce5c9e4438`. Its source input, source map, project map, and instance inventory hashes are recorded in the companion manifest.

The selected real Studio route is qualified Vinegar 1.9.4 running Wine 11.16 and Roblox Studio deployment `version-268c7d941ba34c1a`, client `0.736.0.7361346`, with the reviewed Rojo 7.7.0 plugin and live MCP connection. The authorized isolated target is private universe `1808549145` and private place `5183598846`; Studio API access is saved and the runtime selected `isolated_data_store`. Studio context reports place version 0, so that value is retained with its context rather than treated as a production release version.

## Source asset and evidence inventory

No phase owned source asset directory or asset records exist at entry. The current artifact contains only the two inherited mapped fixture models, `ClassicFrameFixture` and `ClassicStarterPackFixture`. Their presence is an upstream recovery fixture, not Phase 003 completion evidence. `P003-TASK-002` must freeze the asset identity, provenance, fallback, reference, preload, pool, and budget contract before any new source asset is produced or imported.

Existing evidence covers the Phase 000 toolchain and qualified Studio route, Phase 001 catalog and calculation contracts, and Phase 002 local and isolated recovery. Phase 003 asset, pack, progression, Joker, responsive surface, accessibility, and expanded Studio evidence remains pending in dependency order. The exact next task is `P003-TASK-002`.

## Entry gate

`P003-TASK-001` passes. No mandatory entry blocker remains. The open Dependabot pull request is unrelated to the phase branch and does not alter the pinned toolchain or current plan. Phase 003 remains incomplete until its required content and presentation work and every downstream evidence gate pass.
