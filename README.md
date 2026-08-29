# InfiniteCardCollector

InfiniteCardCollector is an original Roblox card collection game. Players fill a permanent fifty two slot deck, unlock card forms with Arcana, equip deck wide Jokers, and use their collection in rapid formation challenges, active task stations, friend battles, and safe direct trades.

The project is in active foundation development. A local Phase 002 vertical slice can create a profile, open a recoverable Classic Starter Pack, equip cards, submit one guided Formation, receive one durable reward, and render authoritative state in 2D and 3D. It is not published or ready for players. The repository preserves the full product destination and a deliberately smaller launch foundation built around Classic, Radioactive, and Astral Deck Sets.

## Foundation Scope

The first public version is designed around:

- Three original Deck Sets and 156 base card identities.
- Four Editions and 624 permanent card forms.
- Eleven Grades, eleven Power Tiers, and twelve launch Traits.
- Twenty four launch Jokers with a maximum of five equipped.
- Twelve one card Arcana transformations.
- Formation Rush, four short active tasks, same server Friend Clash, and feature flagged direct trading.
- Earned random gameplay packs with published odds and guaranteed cosmetic monetization.

The complete end goal expands to fifty two Deck Sets, 37,856 permanent card forms, 120 Jokers, 36 Arcana, 24 Traits, and 12 Souls.

## Documentation

- [Documentation index](docs/README.md)
- [Technical overview](docs/general/documentation.md)
- [Initial release plan](docs/general/plan.md)
- [Complete future plan](docs/general/full_plan.md)
- [Final product vision](docs/general/product-vision.md)
- [Complete content catalog](docs/general/content-catalog.md)
- [Launch foundation and implementation specification](docs/implementation/launch-foundation.md)
- [Development setup](docs/operations/development-setup.md)
- [Phase 000 test procedure](docs/test/phase-000-toolchain.md)
- [Phase 001 catalog and calculation test procedure](docs/test/phase-001-calculation-contracts.md)
- [Phase 002 runtime architecture](docs/implementation/phase-002-runtime.md)
- [Phase 002 blank account recovery workflow](docs/test/phase-002-recovery-workflow.md)
- [Phase 002 recoverable vertical slice evidence](docs/verification/phase-002-recoverable-vertical-slice.md)
- [Toolchain troubleshooting](docs/troubleshooting/toolchain.md)
- [Profile and recovery troubleshooting](docs/troubleshooting/profile-and-recovery.md)
- [GitHub wiki](https://github.com/EnVisione/InfiniteCardCollector/wiki)

## Development Status

Phase 000, Phase 001, and Phase 002 are integrated and signed. Phase 003 is active on `envy/core-phase-003`. The repository now contains the reproducible foundation toolchain, strict launch catalogs, deterministic calculations, a versioned network surface, compact profile persistence, single writer sessions, exact once transactions, owned card and Joker boundaries, a 52 slot deck, a recoverable Classic Starter Pack, one guided reward path, and a minimal authoritative client interface.

The deterministic suite passes 63 tests. The local and isolated Vinegar Studio paths pass opening, reveal recovery and acknowledgement, four deck edits, one guided Monosuit reward, exact replay, valid conflict rejection, hostile request correlation, real DataStore interruption, shutdown, session collision, exact rejoin, normal rendering, static low graphics rendering, progression thresholds, Trait choice and replacement, and a clean console. Phase 003 now includes registered Classic, Radioactive, and Astral fixture selection, neutral fallbacks, the 624 form composition registry, special content asset identities for all launch Jokers, Arcana, packs, and collection surfaces, deterministic manifest build inventory validation, a server-authoritative Deck Set Pack service with five card grants, configured Tier rolls, pity, provenance, classifications, staged reveal controls, and pending results, server-authoritative Joker and Arcana offer packs with saved three-choice state and exact grants, and nonregressing Grade and Trait progression. Phase 003 entry evidence is recorded in [the Phase 003 entry packet](docs/verification/phase-003-entry.md), [the asset contract evidence](docs/verification/phase-003-asset-contract.md), [the Deck Set identity evidence](docs/verification/phase-003-deckset-identities.md), [the compositional card asset evidence](docs/verification/phase-003-composition.md), [the special content asset evidence](docs/verification/phase-003-special-content.md), [the pack service evidence](docs/verification/phase-003-pack-service.md), [the pack reveal evidence](docs/verification/phase-003-pack-reveal.md), and [the progression evidence](docs/verification/phase-003-progression.md). The complete launch collection and responsive surfaces remain planned work.

The pinned tools are Rojo v7.7.0, Rokit v1.2.0, StyLua v2.5.2, Selene v0.31.0, and Lune v0.10.5. Linux x86_64 local and clean environment verification pass. The complete command contract also passes on clean hosted Windows x86_64 and hosted Linux. The qualified Vinegar route runs the actual Windows Roblox Studio binary under Vinegar and Wine with the reviewed Rojo plugin and live MCP connection. This result does not claim official native Linux Studio support. Phase 001 evidence is recorded in [the catalog and calculation evidence](docs/verification/phase-001-calculation-contracts.md), and current Phase 002 evidence is in [the recoverable vertical slice record](docs/verification/phase-002-recoverable-vertical-slice.md).

Start with the [development setup](docs/operations/development-setup.md). After bootstrapping the reviewed artifacts, run:

```console
lune run ci
```

## Originality and Safety

InfiniteCardCollector uses standard playing card ranks and suits with original art, names, interfaces, effects, sounds, and branding. It must not include Pokémon, anime, Balatro, or other protected franchise assets. The active game uses original Card Formations rather than poker, blackjack, betting, or wagering presentation.

## Support

Use the [issue tracker](https://github.com/EnVisione/InfiniteCardCollector/issues) for reproducible defects and scoped feature proposals. Remove credentials, private information, and unfiltered logs before attaching evidence.

## License

No public license has been granted. All rights are reserved unless a license is added later.
