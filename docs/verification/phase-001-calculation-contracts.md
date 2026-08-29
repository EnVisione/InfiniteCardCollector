# Phase 001 Catalog and Calculation Evidence

## Scope

This rolling evidence record covers `CORE-REQ-002`, `CORE-REQ-003`, and `CORE-REQ-013` on `envy/core-phase-001`. It records the implemented shared launch catalog, versioned configuration, deterministic calculation layer, client safe projection, and nondestructive Studio comparison. It does not claim that profiles, packs, progression mutations, networking, UI, active rounds, trading, purchases, or publication are implemented.

## Current Result

The Phase 001 candidate implements the complete pure launch contract at `catalogVersion = 1`, `configVersion = 1`, and `fixtureVersion = 1`. Formatting and static analysis are clean. The deterministic suite passes 27 tests, including all twelve formations, all twenty four launch Jokers, all 276 Joker pairs, a five slot build, validator negatives, safe number boundaries, exact pity boundaries, projection authority, table order invariance, and the ordinary path showcase card.

The nondestructive Vinegar Studio comparison passes with equal server and client results and an empty project console. Final candidate integration evidence is recorded below when run against the phase head. The phase remains incomplete until every required command, pull request, merge, signed tag, and wiki gate passes.

## Implemented Contract

| Area | Verified candidate behavior |
| --- | --- |
| Versions | Catalog, configuration, and fixture versions are each 1 and are carried by validation, calculations, roll records, projections, and reports. |
| Launch counts | 3 Deck Sets, 156 base identities, 4 Editions, 624 forms, 11 Grades, 11 Power Tiers, 12 Traits, 24 Jokers, 12 Arcana, 12 formations, and 0 enabled Souls. |
| Stable identity | IDs are lowercase stable slugs. Identity, slot, and form keys are deterministic. Retired IDs cannot collide with current IDs. Numeric balance data is separate from stored content identity. |
| Validation | Counts, order, IDs, references, assets, handlers, stages, parameters, caps, conflicts, weights, economy declarations, feature state, and future disabled sentinels fail closed with stable IDs. |
| Random contract | Power Tier and Joker rarity weights total exactly 100000. Roll records preserve base and selected buckets, versions, pity state, and whether a forced upgrade occurred. |
| Arithmetic | Checked integer and rational operations use half up rounding, reject nonfinite and fractional trusted inputs, and stay at or below 999999999999999. |
| Formations | All twelve detectors normalize dense arrays of one to five submitted cards, reject duplicate instances, duplicate rank and suit slots, mapped submissions, and malformed state, return ordered candidates, select the configured best base result, and apply only declared stackable bonuses. |
| Calculation | One shared pipeline applies face value, Edition, Grade, Tier, Trait, affinity, formation multiplier, deck wide Joker groups, personal boost, server event boost, mode modifier, and named caps in declared order. Card scoped stages repeat in canonical submission order before aggregate stages. |
| Jokers | Twenty four launch definitions resolve through typed handlers. The registry enforces five slots, stage subscriptions, parameter schemas, caps, conflicts, stable execution groups, enhancement, and typed state intents. |
| Projection | Client safe catalogs and calculations are deep copied, deeply frozen, launch filtered, versioned, ordered for display, and stripped of private trace details and server only anti abuse data. |
| Economy | Eight currency contracts declare sources, sinks, transfer rules, caps, and stable reasons. Soul Fragments remain disabled and inert. Active baseline is 100 units per minute and passive is 18 percent, satisfying the five to one boundary. |

## Exact Launch Counts

| Family | Expected | Candidate |
| --- | ---: | ---: |
| Deck Sets | 3 | 3 |
| Base identities | 156 | 156 |
| Editions | 4 | 4 |
| Permanent forms | 624 | 624 |
| Grades | 11 | 11 |
| Power Tiers | 11 | 11 |
| Traits | 12 | 12 |
| Jokers | 24 | 24 |
| Arcana | 12 | 12 |
| Formations | 12 | 12 |
| Enabled Souls | 0 | 0 |

The Joker rarity distribution is exactly 8 Common, 5 Uncommon, 4 Rare, 3 Epic, 2 Legendary, and 2 Mythic.

## Deterministic Golden Hashes

The tracked hash contract is `tests/phase001/expected-hashes.json`. These values are SHA 256 hashes of canonical report data, not raw file bytes.

| Report | SHA 256 |
| --- | --- |
| Balance | `bea4cf05df6d6035bb9070224c68eeec3937ece3afcbd3c80fbd4655fb8726f7` |
| Catalog | `6d02a0237d2a9a0b93e880db9a5dda970a2e498612e1c788c025bc8d84bd182c` |
| Configuration | `71c0bec171423e5a8f9f4f6dd579112c0ff7872ac4caa775ac30e981345681ee` |
| Economy | `2b86ff305e60b5380fa4e61806545eb3137cc6e3831dab895385cb0a1d7f6e7a` |
| Formations | `1c5473a5af073aef7c646ff801803edd6043e7fdf02920430cbeb0e9d1a643ed` |
| Interactions | `5ac14c736fd88888e9f67cb00e30d03e57fbfef8fd93dd1562c92ad2763de952` |
| Jokers | `730a1c0c2ebb1bdbff402219095d213a22a75508cc215c137a09ea86b59f8390` |
| Showcase | `c6e0c19857397f6061430e8ab1cdb5ae7c6337c30d8f6bf45a5f4bbf89c5feda` |
| Validator | `2a9736003644a32edfe8fad87b498e3c59e14a376c5608135f4e330a267fbf4d` |

Generated reports remain ignored under `build/phase001/`. They are regenerated by the test suite from tracked source and compared with the tracked expected hashes.

## Candidate Artifact

The reviewed Phase 000 artifact pipeline produced these reproducible Phase 001 candidate identities from the mapped runtime sources:

| Artifact | SHA 256 | SHA 512 |
| --- | --- | --- |
| `build/infinite-card-collector.rbxlx` | `ec0f30d3bb5357e257a839e7435f62bf96fb299f40e3a08fa213eae1041315d8` | `b35e54c5a60fc88172a0d4c12b855ae98a9507d2cb5423b03fbdd459e7fa693a446baab39d5ec21a3af5060b9e0de7d3a09db3b3a8974ac95377a62e04d9e1d6` |
| Instance inventory | `504aa4c82a78c68b38cc9a93f67b59b90483145b6579c48a5606e0e42e695b80` | `af88055e74fd679ece44f96ff86c4cf91f47f723b4d04bfa86ecfa754dfe750cbee0203d0e7fae8b62104f94a136f26957f58fc10d920d69f2a198ef219095ff` |
| Project map | `245b28857ab6abf2e77139a89224b2437f5ebd251a7f205dfe433abfe75b1e8f` | `bac0bd83626fbce73570a20009acaf6f6df60cf2b7c430952334eb5808223b4d8d6b0490e0436d8bd0860ed33e4e4ae5c0c045c04b8589fa34f498efb7e5338d` |
| Source map | `be5905dddf9fb1ce8c09c83513772c379dcb1495bc06f6b24fcd0ab5a7a5fbe2` | `401c6803fbd634040b30880a1605a9e4bc5f94daf0a40b8e5d456436b77ec1cdc2dfaaf36afd0ad32425e46410196a98787f42e2df102462c249b95494b038fe` |

The normalized mapped source input digest is `035a14e566b08df70e17f1a27456205c7cc919aa0a6b0e85e48ba55e24f8c7b2`. The artifact contains 36 intended instances and no test, CI, provenance, local environment, or development tool subtree.

## Formation and Calculation Evidence

- Canonical valid and near miss fixtures cover every formation and each applicable submission size.
- Input permutations produce the same ordered candidates, selected formation, components, state intents, and trace.
- A result that satisfies Crown Run and Perfect Sum selects Crown Run's `8.00x` base and applies the explicit `perfect_sum_accuracy` `1.10x` bonus. It does not multiply all detected bases together.
- Sequence and Monosuit use `1.80x`, `2.80x`, and `4.00x` for three, four, and five cards.
- Affinity thresholds are 13, 26, 39, and 52 active cards with 5, 10, 15, and 25 percent strength.
- Golden Dividend enhances the Golden Edition Cash contribution at the Edition stage. Joker Union enhances the eligible effect once without recursion.
- Overclock emits a 35 percent speed intent and applies a 25 percent Guard penalty. Packstorm rejects a stale success counter and emits a three pack intent only at its configured threshold.
- Adaptive accepts one adjacent rank override only for the submitted Adaptive card, keeps the original face value for scoring, and emits a typed consumption intent. Resilient emits its one use streak protection intent only after an otherwise valid submission fails formation detection.
- Full Spectrum, Crown Engine, and Astral affinity inspect the full matched formation set rather than only the winning formation. Set Resonator enhances only the dominant Deck Set at its maximum reached affinity tier.
- Every golden Joker trace uses only declared stage vocabulary. The `before_formation_multiplier` subscription is recorded before the formation multiplier is applied.
- Accepted results and traces are deeply immutable. Rejected calculations return a stable reason and no trusted component result.

## Economy and Random Evidence

- Power Tier weights are exactly `66000`, `20000`, `8000`, `3500`, `1500`, `650`, `250`, `80`, `15`, `4`, and `1` in ascending Tier order.
- Joker rarity weights are exactly `55000`, `25000`, `12000`, `5000`, `2500`, and `500`.
- Trait chance is 10000 of 100000.
- Power Tier pity thresholds are 20 for Rare, 100 for Legendary, and 500 for Mythic. Joker pity thresholds are 20 for Epic and 100 for Legendary.
- The normalized active baseline is 100 per minute. Passive is 18 per minute, for an active to passive ratio of 5.55 to 1.
- The same opponent receives one full eligible reward, two reduced rewards at 25 percent, and no later reward under the frozen launch anti abuse contract.

## Automated Verification

The exact rerun procedure is [Phase 001 Catalog and Calculation Test Procedure](../test/phase-001-calculation-contracts.md).

Current deterministic result:

```text
test summary, 27 passed, 0 failed
```

Final completion requires two unchanged `lune run ci` passes, matching canonical report hashes, reproducible Rojo artifacts, documentation and secret checks, and a clean final diff inspection tied to the phase head.

## Studio Comparison

The Phase 001 Studio gate passed through the exact Phase 000 qualified environment: Vinegar 1.9.4, Kombucha `kombucha-stable+20260824153321` reporting Wine 11.16, Roblox Studio LIVE deployment `version-268c7d941ba34c1a` and client `0.736.0.7361346`, the reviewed Rojo v7.7.0 plugin, Rojo CLI v7.7.0, and loopback `127.0.0.1:34872`. MCP addressed connected Studio instance `2569b3b1-e417-4f64-82e0-d081b44128b0`, named `infinite-card-collector.rbxlx`.

The synchronized Edit DataModel contained all Phase 001 shared folders and modules. A local play session exposed Client and Server DataModels. The server bootstrap's shared authoritative fixture result and local client's safe projection reported these equal attributes:

| Attribute | Server | Client |
| --- | ---: | ---: |
| `BootstrapContractVersion` | 1 | 1 |
| `CatalogVersion` | 1 | 1 |
| `ConfigVersion` | 1 | 1 |
| `LaunchIdentityCount` | 156 | 156 |
| `LaunchFormCount` | 624 | 624 |
| `Phase001FormationId` | `crown_run` | `crown_run` |
| `Phase001Cash` | 154155 | 154155 |
| `Phase001Power` | 29260 | 29260 |
| `Phase001Guard` | 24160 | 24160 |
| `Phase001TraceEntries` | 128 | 128 |
| `BootstrapState` | `ready` | `ready` |

An additional client audit found 24 projected Jokers, no `fifth_law`, no Soul projection, no anti abuse projection, no private trace details, and a deeply frozen catalog and Joker array. It observed the `perfect_sum_accuracy` bonus and accepted `crown_run` result. The server validator snapshot was deeply frozen and reported 3 Deck Sets, 156 identities, 4 Editions, 624 forms, 11 Grades, 11 Tiers, 12 Traits, 24 Jokers, 12 Arcana, 12 formations, 1 explicit stackable bonus, and 0 enabled Souls.

The project console was empty during and after play. Stopping the session returned Studio to Edit mode, retained the synchronized Phase 001 topology, and performed no DataStore, MemoryStore, remote, purchase, trade, or publication operation.

## Candidate and Integration Closure

The final packet must record the phase branch head, artifact SHA 256 and SHA 512, source map and input hashes, two clean CI transcripts, Studio comparison, pull request, required checks, independent review capability disposition, merge commit on `origin/main`, signed annotated `phase-001` tag, issue and roadmap state, and post merge wiki synchronization.

## Evidence Invalidation

A change to catalog or config versions, launch identities, balance, weights, pity, safe arithmetic, formation rules, stage order, Joker definitions or handlers, projection filtering, fixture data, bootstrap source, project mapping, tool versions, Studio environment, or expected hashes invalidates its dependent evidence. Rerun from the lowest changed layer through deterministic tests, Studio comparison, artifact generation, documentation, secrets, and final inspection.
