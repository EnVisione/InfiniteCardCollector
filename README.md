# InfiniteCardCollector

InfiniteCardCollector is an original Roblox card collection game. Players fill a permanent fifty two slot deck, unlock card forms with Arcana, equip deck wide Jokers, and use their collection in rapid formation challenges, active task stations, friend battles, and safe direct trades.

The project is currently in preimplementation design. It is not yet playable. The repository preserves the full product destination and a deliberately smaller launch foundation built around Classic, Radioactive, and Astral Deck Sets.

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
- [Toolchain troubleshooting](docs/troubleshooting/toolchain.md)
- [GitHub wiki](https://github.com/EnVisione/InfiniteCardCollector/wiki)

## Development Status

Phase 000 is complete and Phase 001 is active. The repository contains the reproducible foundation toolchain plus strict typed launch catalogs, versioned balance and economy configuration, checked rational arithmetic, all twelve pure formation detectors, a data driven twenty four Joker registry, authoritative calculation traces, and client safe projections. It is still not a playable game. Profiles, persistent inventory, packs, remotes, UI, active rounds, trading, purchases, and publication are not implemented.

The pinned tools are Rojo v7.7.0, Rokit v1.2.0, StyLua v2.5.2, Selene v0.31.0, and Lune v0.10.5. Linux x86_64 local and clean environment verification pass. The complete command contract also passes on clean hosted Windows x86_64 and hosted Linux. The qualified Vinegar Studio route passed Phase 000 acceptance by running the actual Windows Roblox Studio binary under Vinegar and Wine with the reviewed Rojo plugin and live MCP connection. This result does not claim official native Linux Studio support. Phase 001 deterministic evidence is recorded in [the catalog and calculation evidence](docs/verification/phase-001-calculation-contracts.md).

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
