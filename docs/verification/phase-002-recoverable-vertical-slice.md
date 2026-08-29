# Phase 002 Recoverable Vertical Slice Evidence

## Scope

This completed record covers `CORE-REQ-004` through `CORE-REQ-008` and `P002-TASK-001` through `P002-TASK-015`. It records the Phase 002 branch implementation, deterministic evidence, local Vinegar Studio execution, isolated Roblox recovery, GitHub integration, signed tagging, and wiki synchronization.

It does not claim general pack opening, progression, tasks, duels, trading, commerce, analytics, or public release.

## Current Result

The Phase 002 candidate implements network contract version 1, profile and compact codec version 1, receipt and replay barrier version 1, renderer version 1, one writable session model, bounded retry and shutdown, exact once transactions, card and Joker ownership boundaries, the 52 slot deck, a recoverable Classic Starter Pack, one guided Monosuit reward, and one shared 2D and 3D renderer foundation.

The deterministic repository suite passes 52 tests with 0 failures. StyLua and Selene are clean. Rojo builds the mapped card and pack fixtures. Local and isolated Vinegar Studio pass the complete vertical slice and an empty project console.

The isolated Roblox gate is now exercised against the owner authorized private universe and place listed below. The published candidate remains private and the prior place version was preserved. This evidence is limited to the authorized test account and does not establish production readiness.

## Protected Contract Audit

| Contract | Observed value |
| --- | --- |
| Saved goal SHA 256 | `fbe125681fc52b42131aa7aa1f4f61902d33c7912adc982ebcb7dbd87cff2f69` |
| Goal state | Unchanged. |
| Active phase | `CORE-PHASE-002` |
| Phase branch | `envy/core-phase-002` |
| Phase 001 merge | `c22280c3dbb1935afcedfa7278b27c1b6a9dc78f` |
| Phase 001 signed tag | `phase-001` |
| Catalog version | 1 |
| Configuration version | 1 |
| Action and envelope version | 1 |
| Profile schema and codec version | 1 |
| Receipt and replay barrier version | 1 |
| Renderer version | 1 |

Protected plan files and `docs/plan/goal.md` have no Phase 002 execution diff.

## Deterministic Report Hashes

`lune run phase002-evidence` regenerates canonical reports under ignored `build/phase002/`. `P002-TEST-025` compares them with `tests/phase002/expected-hashes.json`.

| Report | SHA 256 |
| --- | --- |
| Actions and errors | `b19a524d3845670a8fb6f8df9d28a88183adfb87f2fabcceaf5d67e84b57ccd6` |
| Failure stages | `c0686124dd4d6ad7588f475ec909b33db37bc25fceb5a137bc7aa514b2168535` |
| Migrations | `87d1bb9db7e635352b4bf6c0ce05a35a1e42bccea6d9a280b609a45a49a540f2` |
| Profile sizes | `c321df047d7257d29dc7aaf8b34b62dd291945714dff4f6120f49995387e8c60` |
| Recovery | `3826e97c8c78e48c4c30357bb7e9e2df8b09b68667f536a645d401f2652229bf` |
| Renderer | `2c067a309e254dd84bbe6df1f25de2f25ae92e5ea115930be229076d89381d11` |

## Action and Error Inventory

The generated network report contains 24 actions, 9 currently available handlers, and 50 stable error codes. The Phase 003 pack and progression extension adds earned pack opening, saved choices, Grade Ink application, `pack.insufficient_currency`, `pack.choice_invalid`, `pack.choice_unavailable`, and progression validation while preserving the versioned action and validation contracts. Every action records mode, exact schema, maximum encoded bytes, maximum depth, maximum nodes, profile and writable requirements, rate capacity, refill amount, refill period, availability, and handler ID.

The complete hostile matrix constructs a valid minimum payload and invalid shape or boundary payloads for all 24 actions. Gateway tests prove deterministic validation, independent token buckets, unavailable route handling, readiness, writable state, authorization, protected routing, safe request correlation, and no mutation on rejection.

## Profile Size Evidence

| Fixture | Cards | Encoded bytes | Classification |
| --- | ---: | ---: | --- |
| Blank version 1 | 0 | 885 | Healthy. |
| Last measured before warning | 2,200 | 976,763 | Healthy. |
| Warning crossing | 2,300 | 1,021,141 | Warning. |
| Last measured before block | 3,300 | 1,462,418 | Warning. |
| Block crossing | 3,400 | 1,506,780 | Blocked. |

The blocked saved representation hash is `cca9f29b1d03648cb6119c390891664cd0df83839136bc35e923064b054cee1c`.

The exact blocked commit test proves `profile.too_large`, unchanged durable adapter bytes, unchanged session revision, and retained writable authority for the prior valid state.

## Migration Evidence

| Value | SHA 256 or result |
| --- | --- |
| Legacy fixture | `568eeaaa026e7fc539c9af69ce9399cfd7e946c2b79b7c416a56413bdf71254a` |
| Migrated domain | `676b7a6ff7d24cdb21294bf71dc2f7d97392615dfd56243367c9c9227ee79909` |
| Migrated saved form | `ca50058a5b029d09edd77f6c178830ca482a3f7dc92065e303e6874e98271a5f` |
| Repeated normalization | `ca50058a5b029d09edd77f6c178830ca482a3f7dc92065e303e6874e98271a5f` |
| Preserved state | 345 Cash and one owned card. |

Malformed and unsupported fixtures retain the original adapter value and return stable quarantine codes.

## Representative Recovery Hashes

The deterministic operation chain starts from a blank stable profile hash of `8bb8c6839b1fdeddebd367aa3d5bb2d0e1d4a9b14b96bf40f86a795fc17e0537`.

### Starter Pack

| Evidence | Value |
| --- | --- |
| Revision | 1 |
| Result | `3e81b7f965fcfcee463bc8b37eb289843a6fc4998d2385165c9313394f41c14e` |
| Replay result | `a1fc2b51de5487c7a0302719fdcdfd5f0d9b7f1f0cf635dda895805c196c4f07` |
| Receipt | `bf89c3770d73aacccb22e71f468c126b2631aef606c45d5f523d76e23e1530b0` |
| Fingerprint | `9501cf21396db928f9a5aa68e8376e05b401127fe246126f3e6f525c716b14ed` |
| Result reference | `e621a9628b9da5bdd14371b9d1ce57af6784d98efd46115b4284be0524d43fd2` |
| Provenance list | `c0142d06d08e4b2c22439b061e66d4d0afc36f1eb92b5fa1272dc1bf3e6fa9ff` |
| After profile | `17ba874522816c227af070021bb53d2c041bf4eadc0964e8c4a90e3ff0c1573e` |
| Initial pending state | `committed` |
| Catalog version | 1 |
| Conserved fixture IDs | `evidence_card_01` through `evidence_card_05` |

The same operation ID returns the stored result and does not create a sixth card. Rejoin before acknowledgement returns `committed`. The first valid deck interaction moves the same result to `acknowledged` atomically.

### Deck

Four equip operations commit revisions 2 through 5. Their exact result hashes are:

| Revision | SHA 256 |
| ---: | --- |
| 2 | `adcd2f5aba336a8c13e03a2a0c2a2da6ca406fac9dddba733d504b03b96092bc` |
| 3 | `9ff9df7d7a30b28e2abb2440715437bf755f71bdd1231c7c5476b8ffbe3fb7c2` |
| 4 | `290813449b26805b600cd4856080c6eae9c0dcd3373cfc409baf106e917fc843` |
| 5 | `3344bce76d544e17dd2adbd798ad992e9e37d8afb14c80c7c82bf816399e3b4d` |

The final active deck hash is `354394e67dd122458577deee1426112e2e4b46bc298a955830d8e5f0da5c3974`.

### Guided Reward

| Evidence | Value |
| --- | --- |
| Code | `formation.reward_committed` |
| Formation | `monosuit` |
| Revision | 6 |
| Cash | 73 |
| Result | `8e7a59806cfc9d5e29a9a15b8fe495607f8b38966bf04f7ca336a339aed29fdf` |
| Replay result | `4decfbc2752acd4e277e1cb1dfc9625b1a9189d0977fbeff81b32342bb15e4e4` |
| Receipt | `063af59b6b7de0b7e81e740520d63672afca5e345013eb9bda914d39b4a97024` |
| Fingerprint | `600842a4fdbc573d99f92c571068c9143396a057e1de779d7e446c5b226857dd` |
| Calculation projection | `109af2af0d6ef70f67570d61504bf084f86e8898e88f74bbb015307f16d3163e` |

The final stable gameplay profile and the rejoined stable gameplay profile both hash to `7e47c1f7d70721f4b8c27e2c1fcd8ca30164dd4616612265e107030bafe97691`. Five cards remain conserved and four remain equipped.

## Failure and Shutdown Evidence

Precommit injection at `before_validation`, `before_apply`, `after_apply`, `before_receipt`, and `before_commit` leaves revision 0, Cash 0, and no receipt for the fixture operation.

Postcommit injection at `after_commit` and `before_response` reports a committed failure. Same ID replay returns the one stored result with revision 1 and Cash 5.

Profile retry evidence observes 250 and 500 millisecond delays before recovery. Retry exhaustion retains unchanged durable state, leaves the session ready but not writable, rejects further staging, and reports one remaining unreleased session. A shutdown whose next retry sleep would cross the deadline returns `deadlineExceeded = true` without oversleeping. Transaction drain stops at its declared 0.1 second fixture deadline.

## Renderer Evidence

| Evidence | Value |
| --- | --- |
| Layer order | `deck_set`, `suit`, `rank`, `edition`, `grade`, `power_tier`, `trait`, `status` |
| Normal view model | `23d7c98f62ef6455028a5f430c932bdb0d957dedb1075a0430772904561ebcfd` |
| Static low graphics view model | `b94e79a3a6601a7c966631047082fc2249b0e2d8915a5ab482285a84deb6177b` |
| 2D and 3D semantic layers | Equal. |
| Status combination fixture | 5 readable statuses. |
| Static animation | Disabled. |
| Static flashing | Disabled. |
| Binder stress fixture | 10,000 items and 17 visible cells. |
| Bounded preload | Two fixtures. |

The Rojo mapped fixtures are `ClassicFrameFixture` with three parts and `ClassicStarterPackFixture` with two parts.

## Local Vinegar Studio Evidence

The local comparison used Vinegar 1.9.4, Kombucha `kombucha-stable+20260824153321` reporting Wine 11.16, Roblox Studio LIVE deployment `version-268c7d941ba34c1a`, client `0.736.0.7361346`, Rojo plugin v7.7.0, Rojo CLI v7.7.0, and loopback `127.0.0.1:34872`. MCP addressed Studio instance `2569b3b1-e417-4f64-82e0-d081b44128b0`, named `infinite-card-collector.rbxlx`.

The Edit DataModel reported `game.GameId = 0` and `game.PlaceId = 0`, so the runtime correctly selected `local_memory` and never contacted DataStore.

### Blank Fixture

The blank client reported:

```text
status = ready. bootstrap.ready.
cash = 0
cards = 0
equipped = 0
revision = 0
storage = local_memory
preload = ready
model = PackModel3D
accessible name = Classic Starter Pack
visible binder cells = 0
```

Capture ID: `phase002_classic_pack_fixture`.

### Integrated Slice

The final local rerun committed five consecutive Classic cards of one suit, acknowledged the reveal on the first valid equip, equipped four cards, and submitted a guided Monosuit through the hardened receipt and profile validator. The authoritative client result reported:

```text
starter = pack.starter_committed
pending = acknowledged
equips = deck.card_equipped at revisions 2 through 5
formation = formation.reward_committed
formation id = monosuit
cash = 106
revision = 6
cards = 5
equipped = 4
replay = true at revision 6
conflicting valid replay = request.replay_conflict
unknown field = network.unknown_field
rejection correlation = true
generated request id = request_bootstrap_1072019241_398225418
generated request id length = 38
generated request id schema = valid
```

The local reward differs from the deterministic evidence fixture because the Studio operation seed includes its runtime user and request identity. Both paths use the same configured calculation and transaction boundary.

The normal view showed five virtualized 2D rows and one pooled 3D card with eight semantic layers. The static low graphics fixture reported `lowGraphics = true`, `animated = false`, `flashing = false`, the same readable identity, and eight layers. The UI generated a fresh two part random request identity through the production button path, and the server returned it without alteration.

Capture IDs: `phase002_normal_renderer_clean` and `phase002_static_low_graphics`.

The Studio console was empty. Play stopped cleanly and returned to Edit mode.

## Candidate Artifact

The finalized local source input produces the following reproducible candidate:

| Evidence | Value |
|---|---|
| Place artifact | `build/infinite-card-collector.rbxlx` |
| Artifact size | `312867` bytes |
| Artifact SHA 256 | `20ec34e1787dc2f0594681899a8e7b6a27012f07d66b4458129ff27f2f2e7b35` |
| Artifact SHA 512 | `54f3d00835ad32cfaa86a275921394819367c592a9134954b7baecc02ba90b387fce8b76d8fe4aff8e9bafa49b1a11b8464ebd7d538a9d5422f6e2ce5c9e4438` |
| Source map SHA 256 | `7b3e63a9875512b7a9e91ecf885972bbacfe5117c9ed974f0979b4466dc39f21` |
| Instance inventory SHA 256 | `1948dd6c603625dbb5875de1c2558be1fba489791bdac0e49fc248e38884586c` |
| Project map SHA 256 | `1a465cef38b2d3d8f8d32c6ad9578203ddba634592064f73d119ada84fb0f477` |
| Normalized source input SHA 256 | `de0570babbc25f61efb63f0dd779f1030419c27d16c3b97511f35a7050a910a9` |
| Built fixture inventory | Three Classic card frame parts and two Classic Starter Pack parts. |
| Local CI | Two consecutive unchanged candidate runs each passed all nine gates with zero failures. |

The final artifact manifest was regenerated from the verified Phase 002 merge commit `1ae97cfcec79427ff7849d83d0ecd39e31aebf72`. The source input SHA 256 and artifact SHA 256 and SHA 512 remain unchanged from the candidate table above. The regenerated main worktree passed all nine CI gates.

## Isolated Roblox Gate

The bounded isolated procedure is [Phase 002 blank account recovery workflow](../test/phase-002-recovery-workflow.md), SHA 256 `d73898941e8482cf8770708601afa0d627fb9a71eb3c02e3bfbb5331386d99c7`.

The owner authorized the private universe `1808549145` and private place `5183598846`. Creator Hub reported Studio API access saved successfully. The candidate was opened in Vinegar Roblox Studio through the authenticated Creator Hub flow and saved with the Studio confirmation `Saved new changes in RoADMINISTRATOR's Place to Roblox.` The Studio server reported `game.GameId = 1808549145`, `game.PlaceId = 5183598846`, and `Phase002StorageMode = isolated_data_store`. The test used the isolated Studio DataStore path and did not use the local memory adapter.

### Authorized isolated run

| Checkpoint | Result |
| --- | --- |
| Blank bootstrap | `bootstrap.ready`, revision 0, cash 0, cards 0, writable true. |
| Starter Pack commit | `pack.starter_committed`, revision 1, five cards, pending state `committed`. |
| Deck edits | Four legal equips committed revisions 2 through 5. The same pending reveal moved to `acknowledged`. |
| Guided request correction | External `modeId = formation_rush` correctly rejected as `formation.invalid`. The route contract requires `guided_classic`; the corrected request committed `monosuit` at revision 6 with 62 cash. |
| Exact reward replay | Replayed request returned `formation.reward_committed`, revision 6, reward cash 62, with no additional mutation. |
| Conflicting replay | Same request ID with a changed round ID returned `request.replay_conflict`. |
| Hostile payload | An extra field returned `network.unknown_field` and did not mutate the profile. |
| Stale revision | A formation request using revision 5 after revision 6 returned `state.stale` and did not mutate the profile. |
| Dirty shutdown and release | Stopping Studio Play mode completed the real server close path and returned to Edit mode without a console error. |
| Concurrent lease collision | A second `ProfileStore` writer used the same DataStore key while the primary session was healthy and returned `session.conflict` with no profile mutation. |
| Expired lease recovery | The authorized probe moved the stored heartbeat beyond the session expiry window. A new writer reclaimed the profile successfully, then released its temporary lease. |
| Response loss and replay | The first response for a new formation request was intentionally ignored. Retrying the same request returned `formation.reward_committed` at revision 7 with reward cash 62, and the profile advanced only once. |
| Exact rejoin | After the probes and a clean Play stop, a new Play session returned `bootstrap.ready`, revision 7, cash 124, five cards, four equipped cards, pending state `acknowledged`, writable true, and `isolated_data_store`. |
| Presentation | Screen capture `ScreenCapture_3` showed the private test UI with cash 124, five cards, four equipped cards, revision 7, isolated storage, acknowledged reveal, and readable card rows. |

The run proves real `UpdateAsync` writes, committed reveal recovery, acknowledgement, deck edits, reward replay, rejection correlation, healthy concurrent collision rejection, expired lease recovery, ignored response replay, shutdown release, and exact rejoin for the authorized private test.

## Completion Gates

Phase 002 completion gates passed against one unchanged candidate:

1. Two complete local CI runs.
2. Final deterministic report hashes.
3. Final reproducible artifact and inspection.
4. Clean local Vinegar Studio path.
5. Owner authorized isolated DataStore interruption and rejoin path.
6. Complete documentation and link checks.
7. Secret and full diff inspection.
8. Phase issue, milestone, and roadmap synchronization.
9. Required GitHub checks and private independent review capability disposition.
10. Pull request 16 merge commit `1ae97cfcec79427ff7849d83d0ecd39e31aebf72` on `main`.
11. Signed annotated `phase-002` tag on that merge commit.
12. Postmerge wiki synchronization at commit `7a231b6a0d09dbc855252852eda7e78017b3f552`.

Phase 002 is complete and integrated. The next mandatory phase is `CORE-PHASE-003`; see [the Phase 003 entry packet](phase-003-entry.md).

## Evidence Invalidation

A change to action IDs, schemas, rates, errors, validation order, profile or codec shape, migration, size policy, session timing, retry, storage adapter, receipt or barrier fields, transaction stages, UID or provenance rules, deck eligibility, pending state, reward calculation, renderer layers, fixture assets, preload bound, virtualization, client authority, shutdown order, tool versions, Studio environment, or isolated place identity invalidates its dependent evidence. Rerun from the lowest affected layer through deterministic tests, report hashes, artifact generation, Studio, isolated recovery, documentation, CI, review, merge, tag, and wiki gates.
