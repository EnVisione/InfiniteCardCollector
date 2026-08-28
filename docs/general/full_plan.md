# InfiniteCardCollector Full 52 by 52 Vision

> **Plan ID:** PLAN-FULL
> **Requirement prefix:** FULL
> **Owner:** InfiniteCardCollector repository
> **Classification:** FUTURE
> **Master plan:** [InfiniteCardCollector Initial Public Release Plan](plan.md)
> **Execution status:** Registered postlaunch aspect, excluded from initial-release completion

## Purpose, Authority, and Nonblocking Boundary

This aspect preserves the complete InfiniteCardCollector destination in one document. It covers every named content family, permanent collection rule, gameplay and social system, scaling boundary, expansion gate, and final completion condition. Its authority comes from the current owner request, [Final Product Vision](product-vision.md), [Card Game Content Catalog](content-catalog.md), and [Launch Foundation](../implementation/launch-foundation.md), in that order after the master plan.

[plan.md](plan.md) remains the sole authority for initial public release completion. The future work in this document is represented by FUT-001 through FUT-015 and remains excluded until a later direct owner decision promotes specific scope. No work package here authorizes starting before the initial public release is merged, published, observed, and judged healthy under DEC-012.

Balance values in this document are first targets and remain versioned configuration. Stable content IDs, identity rules, permanent ownership, and the originality boundary are compatibility contracts. If this aspect and the master disagree about the initial release, the master controls.

## Final Collection Mathematics

```text
13 face ranks × 4 suits = 52 slot identities per Deck Set
52 Deck Sets × 52 slot identities = 2,704 base card identities
2,704 base identities × 14 Editions = 37,856 permanent card forms
```

The completion destination also contains:

- Eleven Grades and eleven Power Tiers as best observed per-instance quality axes.
- Twenty-four Traits as best observed specialties, with zero or one Trait per card.
- One hundred twenty Jokers across six Joker Rarities.
- Thirty-six Arcana discoveries.
- Twelve Souls.
- Permanent discovery, current ownership, provenance, mastery, and best-output records.

The album tracks 37,856 permanent forms, 120 Jokers, 36 Arcana discoveries, and 12 Souls. It does not require every theoretical Grade, Tier, Trait, and statistic combination, which would create millions of unstable checklist entries.

## Permanent Card Identity Contract

The canonical display order is:

```text
[Edition] [Grade] [Power Tier] [Face Rank] of [Deck Set] [Suit], [Trait] trait
```

The showcase example is `Golden LR Infernal Ace of Radioactive Spades, Fortune trait`.

Permanent identity is `Deck Set + Face Rank + Suit`. A permanent form is that identity plus one Edition. Grade, Power Tier, Trait, provenance, locks, and statistics describe an owned instance. The active deck contains one selected owned instance per slot key, where the slot key is `<faceRankId>:<suitId>`.

Face ranks are `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `Jack`, `Queen`, `King`, and `Ace`. Suits are `Hearts`, `Diamonds`, `Clubs`, and `Spades`.

Stable IDs are stored instead of display labels. Retired IDs are never reused. Balance changes do not change identity. Display labels can change without changing saved IDs. Every card, Joker, and Soul instance has a unique server-generated ID, provenance, schema version, and one effective owner. Content can be disabled without deleting ownership.

## FUT-001 — All Fifty-Two Deck Sets

Each Deck Set contains all fifty-two rank and suit identities and has its own frame, suit treatment, pack wrapper, reveal sound, collection page, mastery track, and mild affinity. Affinities guide builds without making one family mandatory.

| No. | ID | Display name | Visual identity | Affinity |
|---:|---|---|---|---|
| 1 | `classic` | Classic | Ivory stock, red and black ink | Balanced formations |
| 2 | `radioactive` | Radioactive | Hazard stripes, green glow, warning stamps | Consecutive successful formations and Cash |
| 3 | `astral` | Astral | Star maps, violet nebulae, silver constellations | Exact sums and Crown formations |
| 4 | `abyssal` | Abyssal | Deep sea black, pressure cracks, blue eyes | Low ranks and controlled risk |
| 5 | `arctic` | Arctic | Frosted glass, pale blue foil, snow | Guard and streak protection |
| 6 | `volcanic` | Volcanic | Basalt, lava veins, ember edges | High ranks and Power |
| 7 | `tempest` | Tempest | Storm clouds, lightning, wind streaks | Draw speed and Sequences |
| 8 | `oceanic` | Oceanic | Waves, pearls, moving caustics | Suit chains |
| 9 | `verdant` | Verdant | Leaves, vines, living borders | Bonuses that grow during a session |
| 10 | `desert` | Desert | Sandstone, heat shimmer, gold dust | Small committed hands |
| 11 | `jungle` | Jungle | Dense foliage, bright wildlife marks | Mixed ranks |
| 12 | `fungal` | Fungal | Bioluminescent caps and spores | Repeated ranks |
| 13 | `crystal` | Crystal | Faceted translucent frames | Grade progression |
| 14 | `clockwork` | Clockwork | Brass gears, springs, precise ticks | Timing and ordered play |
| 15 | `cybernetic` | Cybernetic | Circuit boards, chrome, scanning lines | Joker synchronization |
| 16 | `neon` | Neon | Night streets, saturated signs, reflections | Active tasks |
| 17 | `quantum` | Quantum | Split images, probability trails | Rank flexibility |
| 18 | `galactic` | Galactic | Spiral galaxies and deep space | Mixed Deck Sets |
| 19 | `lunar` | Lunar | Moon phases and cool silver | Black suits |
| 20 | `solar` | Solar | Sun flares and warm gold | Red suits |
| 21 | `eclipse` | Eclipse | Black sun, corona, divided frames | Red and black alternation |
| 22 | `comet` | Comet | Ice tails and motion trails | First and last formations |
| 23 | `royal` | Royal | Velvet, crowns, heraldic filigree | Face cards |
| 24 | `pirate` | Pirate | Maps, rope, weathered treasure | Cash and pack progress |
| 25 | `samurai` | Samurai | Lacquer, ink brushwork, armor plates | Single card precision |
| 26 | `runic` | Runic | Stone tablets and glowing glyphs | Arcana rewards |
| 27 | `alchemical` | Alchemical | Glass vessels and transmutation circles | Edition effects |
| 28 | `gothic` | Gothic | Cathedral windows and iron ornament | Cursed and Void Editions |
| 29 | `noir` | Noir | Monochrome shadows and rain | Clubs and Spades |
| 30 | `steampunk` | Steampunk | Copper pipes and pressure gauges | Steel cards and timing |
| 31 | `wasteland` | Wasteland | Scrap metal, dust, warning paint | Blank slots and low Grades |
| 32 | `haunted` | Haunted | Ghost trails and old portraits | Comebacks after a failed formation |
| 33 | `graveborn` | Graveborn | Cracked stone and pale flame | Discarded and redrawn cards |
| 34 | `dreamscape` | Dreamscape | Soft clouds and impossible geometry | Holographic and Prismatic Editions |
| 35 | `nightmare` | Nightmare | Distorted shadows and sharp red marks | High risk and high output |
| 36 | `carnival` | Carnival | Tickets, lights, striped tents | Formation variety |
| 37 | `toybox` | Toybox | Painted wood and building blocks | Number cards |
| 38 | `sugarcraft` | Sugarcraft | Candy glass and frosting | Boost duration and task rewards |
| 39 | `blossom` | Blossom | Flower petals and spring colors | Hearts, Diamonds, and growing chains |
| 40 | `harvest` | Harvest | Amber fields and woven baskets | Session accumulation |
| 41 | `festival` | Festival | Lanterns, confetti, ribbons | Cooperative play |
| 42 | `street` | Street | Stickers, spray paint, asphalt | Friend Clashes |
| 43 | `luxury` | Luxury | Black marble, gold trim, gemstones | Golden and Diamond Editions |
| 44 | `mosaic` | Mosaic | Colored tiles and geometric patterns | Mixed Deck Sets and suits |
| 45 | `origami` | Origami | Folded paper and clean shadows | Hand size manipulation |
| 46 | `fossil` | Fossil | Amber, bone impressions, museum labels | Early ranks and collection discovery |
| 47 | `primeval` | Primeval | Stone, claws, ancient vegetation | Raw Grade and Power Tier |
| 48 | `legendarium` | Legendarium | Illustrated myths and illuminated borders | Mythic and higher Power Tiers |
| 49 | `aether` | Aether | Floating islands and pale energy | Arcana and Souls |
| 50 | `monolith` | Monolith | Massive stone, minimal glowing symbols | Full Deck Sets and Guard |
| 51 | `coral` | Coral | Reef colors and living textures | Suit streaks and cooperative play |
| 52 | `obsidian` | Obsidian | Volcanic glass and razor highlights | Black suits, Steel, and Void Editions |

Expansion releases Deck Sets in small themed groups. Every group includes complete assets, a mastery path, pack identity, affinity, cosmetics, collection navigation, one event, performance evidence, and no copied service logic. All fifty-two sets becoming named does not authorize releasing unfinished art or unbalanced effects.

## FUT-002 — All Fourteen Editions and 37,856 Forms

Normal is available on first discovery. Each other Edition is unlocked for one card identity by consuming the matching Arcana. Unlocking a form never deletes or replaces an older form, and the player may select any unlocked form for that identity.

| No. | ID | Edition | Base effect |
|---:|---|---|---|
| 1 | `normal` | Normal | No modifier |
| 2 | `foil` | Foil | `1.10x` all scored output |
| 3 | `golden` | Golden | `2.00x` Cash |
| 4 | `steel` | Steel | `2.00x` Guard |
| 5 | `diamond` | Diamond | `1.20x` all output and `2.00x` Grade experience |
| 6 | `holographic` | Holographic | `1.50x` Power |
| 7 | `prismatic` | Prismatic | `1.60x` all output and counts as either color for formation detection |
| 8 | `blessed` | Blessed | `1.25x` all output and `1.50x` active task progress |
| 9 | `cursed` | Cursed | `2.20x` all output, but a failed formation removes the entire current streak |
| 10 | `glitched` | Glitched | Deterministically rotates a `2.50x` Cash, Power, or Guard specialty after each successful formation |
| 11 | `void` | Void | `3.00x` output when it is the only committed card, otherwise `0.75x` |
| 12 | `starfallen` | Starfallen | `1.20x` normally and `3.00x` while an active task or server event is running |
| 13 | `apex` | Apex | `4.00x` all output |
| 14 | `unknown` | Unknown | Reveals one permanent hidden specialty on first score: `3.00x` Cash, Power, Guard, or pack progress |

Edition multipliers apply to the card carrying the Edition. Global Joker and Soul rules may reference an Edition category through registered effect stages. Collection completion counts each unlocked permanent form once and never counts random Grade, Tier, Trait, or statistic combinations as additional forms.

## Complete Quality Axes

### All Eleven Grades

Grade is deterministic trained quality. Successful active use grants experience, earned Grade Ink accelerates one selected card, promotion never fails, and ordinary play never lowers a Grade.

| No. | ID | Grade | Multiplier | Cumulative Grade XP target |
|---:|---|---|---:|---:|
| 1 | `f` | F | `1.00x` | 0 |
| 2 | `e` | E | `1.10x` | 10 |
| 3 | `d` | D | `1.25x` | 30 |
| 4 | `c` | C | `1.50x` | 70 |
| 5 | `b` | B | `1.85x` | 150 |
| 6 | `a` | A | `2.25x` | 300 |
| 7 | `s` | S | `3.00x` | 600 |
| 8 | `ss` | SS | `4.00x` | 1,200 |
| 9 | `sr` | SR | `6.00x` | 2,400 |
| 10 | `ur` | UR | `9.00x` | 4,800 |
| 11 | `lr` | LR | `14.00x` | 9,600 |

Thresholds may rebalance globally, but a saved Grade never moves backward because of a balance patch.

### All Eleven Power Tiers

Power Tier is the instance rarity roll. It affects reveal presentation, base output, desirability, and high-end goals. Exact pack odds, pity, and deterministic Ascension paths prevent permanent bad luck.

| No. | ID | Power Tier | Multiplier |
|---:|---|---|---:|
| 1 | `common` | Common | `1.00x` |
| 2 | `uncommon` | Uncommon | `1.10x` |
| 3 | `rare` | Rare | `1.25x` |
| 4 | `epic` | Epic | `1.50x` |
| 5 | `legendary` | Legendary | `2.00x` |
| 6 | `mythic` | Mythic | `3.00x` |
| 7 | `secret` | Secret | `4.50x` |
| 8 | `infernal` | Infernal | `6.00x` |
| 9 | `celestial` | Celestial | `8.00x` |
| 10 | `chaos` | Chaos | `11.00x` |
| 11 | `zenith` | Zenith | `14.00x` |

### FUT-003 — All Twenty-Four Traits

A card has zero or one Trait. A Trait affects its card or the formation in which that card scores. Traits never change trade settlement, warning values, or another player's inventory.

| No. | ID | Trait | Effect when this card scores |
|---:|---|---|---|
| 1 | `fortune` | Fortune | `2.00x` this card's Cash |
| 2 | `fierce` | Fierce | `2.00x` this card's Power |
| 3 | `guardian` | Guardian | `2.00x` this card's Guard |
| 4 | `swift` | Swift | Reduces this card's draw and resolve delay contribution by `20%` |
| 5 | `lucky` | Lucky | Adds `15%` more pack progress from this card |
| 6 | `scholar` | Scholar | Gains `25%` more Grade experience |
| 7 | `critical` | Critical | Has a server rolled `10%` chance to double this card's output |
| 8 | `resilient` | Resilient | Once per round, this card can prevent a formation streak loss |
| 9 | `radiant` | Radiant | Contributes `20%` more toward its Deck Set affinity |
| 10 | `adaptive` | Adaptive | Once per round, may count as one adjacent rank for formation detection |
| 11 | `efficient` | Efficient | Adds `20%` active task progress while scored |
| 12 | `social` | Social | Adds `15%` reward contribution in cooperative play |
| 13 | `prosperous` | Prosperous | Adds `50%` Cash if the formation includes at least three cards |
| 14 | `brutal` | Brutal | Adds `75%` Power but contributes no Guard |
| 15 | `titan` | Titan | Adds `75%` Guard but resolves `10%` slower |
| 16 | `precise` | Precise | Adds `60%` output to exactly one card or exactly three card formations |
| 17 | `inspired` | Inspired | Gives the next card committed after this one `25%` more output |
| 18 | `resonant` | Resonant | Adds `20%` for every other card from the same Deck Set, capped at `80%` |
| 19 | `collector` | Collector | The first new catalog discovery each day grants extra Arcana Dust |
| 20 | `ascendant` | Ascendant | Treats this card's Grade multiplier as one step higher; LR gains `15%` |
| 21 | `eternal` | Eternal | Its personal combo bonus never decays during the current round |
| 22 | `paragon` | Paragon | Adds `35%` all output when Grade is S or higher |
| 23 | `transcendent` | Transcendent | Adds `50%` all output when Power Tier is Mythic or higher |
| 24 | `miraculous` | Miraculous | Once per session, a scoring failure involving this card becomes a success at minimum value |

Trait choice and replacement are explicit. Locked and favorited cards cannot change until deliberately unlocked. Every random effect is server rolled, recorded, bounded, and included in the calculation trace.

## FUT-004 — All One Hundred Twenty Jokers

Jokers apply deck-wide rules. A player may own every Joker but equip no more than five. Duplicate Jokers grant experience only after the player deliberately binds them. Joker Rarity is separate from card Power Tier.

| Rarity | Count |
|---|---:|
| Common | 30 |
| Uncommon | 24 |
| Rare | 22 |
| Epic | 18 |
| Legendary | 16 |
| Mythic | 10 |
| **Total** | **120** |

Definitions contain a stable ID, display name, rarity ID, effect handler ID, typed parameters, declared conflicts, and enabled state. Handlers subscribe to explicit stages such as formation detection, card contribution, formation multiplier, round start, success, failure, task completion, and duel result. The scorer applies one documented order and records every applied, skipped, capped, or suppressed rule.

### Common Jokers

| No. | ID | Name | Deck-wide effect |
|---:|---|---|---|
| 1 | `pocket_ledger` | Pocket Ledger | `+10%` Cash |
| 2 | `painted_pip` | Painted Pip | `+10%` Power |
| 3 | `paper_shield` | Paper Shield | `+10%` Guard |
| 4 | `quick_shuffle` | Quick Shuffle | `5%` faster drawing and resolving |
| 5 | `spare_sleeve` | Spare Sleeve | `+5%` pack progress |
| 6 | `red_ribbon` | Red Ribbon | Hearts and Diamonds gain `+15%` output |
| 7 | `black_thread` | Black Thread | Clubs and Spades gain `+15%` output |
| 8 | `club_coach` | Club Coach | Clubs gain `+20%` Power |
| 9 | `heartbeat` | Heartbeat | Hearts gain `+20%` Cash |
| 10 | `diamond_dust` | Diamond Dust | Diamonds gain `+15%` Grade experience |
| 11 | `spade_work` | Spade Work | Spades gain `+20%` Power |
| 12 | `number_cruncher` | Number Cruncher | Number cards gain `+15%` output |
| 13 | `court_clerk` | Court Clerk | Jacks, Queens, and Kings gain `+20%` output |
| 14 | `ace_up` | Ace Up | Aces gain `+25%` output |
| 15 | `pair_practice` | Pair Practice | Twin formations gain `+20%` output |
| 16 | `sequence_notes` | Sequence Notes | Sequence formations gain `+20%` output |
| 17 | `suit_sorter` | Suit Sorter | Monosuit formations gain `+20%` output |
| 18 | `four_corners` | Four Corners | Spectrum formations gain `+20%` output |
| 19 | `blank_canvas` | Blank Canvas | Each empty active deck slot adds `+1%` Cash, capped at `25%` |
| 20 | `full_binder` | Full Binder | A complete fifty-two-slot active deck gains `+15%` output |
| 21 | `set_sampler` | Set Sampler | Each distinct Deck Set in a formation adds `+3%` output |
| 22 | `matching_set` | Matching Set | A formation using one Deck Set gains `+20%` output |
| 23 | `fresh_ink` | Fresh Ink | Normal Edition cards gain `+15%` output |
| 24 | `foil_fan` | Foil Fan | Foil cards gain an additional `+20%` output |
| 25 | `golden_rule` | Golden Rule | Golden cards gain an additional `+25%` Cash |
| 26 | `steel_support` | Steel Support | Steel cards gain an additional `+25%` Guard |
| 27 | `task_ticket` | Task Ticket | Active tasks grant `+10%` rewards |
| 28 | `friendly_rival` | Friendly Rival | Friend Clash participation grants `+10%` Duel Tokens, subject to anti-farming limits |
| 29 | `repeat_reader` | Repeat Reader | The first repeated rank each round gains `+15%` output |
| 30 | `last_card` | Last Card | The last committed card gains `+20%` output |

### Uncommon Jokers

| No. | ID | Name | Deck-wide effect |
|---:|---|---|---|
| 31 | `balanced_scales` | Balanced Scales | Equal red and black cards in a formation gain `+30%` output |
| 32 | `odd_fellow` | Odd Fellow | Odd numbered cards gain `+35%` Power |
| 33 | `even_temper` | Even Temper | Even numbered cards gain `+35%` Cash |
| 34 | `royal_chorus` | Royal Chorus | A formation containing Jack, Queen, and King gains `+75%` output |
| 35 | `ace_circuit` | Ace Circuit | Each Ace scored this round adds `+10%` draw speed, capped at `30%` |
| 36 | `suit_bridge` | Suit Bridge | A formation containing both colors gains `+35%` Power |
| 37 | `theme_tourist` | Theme Tourist | Each distinct Deck Set in the active deck adds `+0.5%` Cash, capped at `20%` |
| 38 | `set_purist` | Set Purist | At least thirty-nine active cards from one Deck Set grants `+40%` output |
| 39 | `grade_school` | Grade School | Cards below Grade B gain `+60%` Grade experience |
| 40 | `honor_roll` | Honor Roll | Grade A or higher cards gain `+25%` output |
| 41 | `edition_collector` | Edition Collector | Each distinct Edition in a formation adds `+12%` output |
| 42 | `golden_dividend` | Golden Dividend | Golden Edition's Cash effect is `30%` stronger |
| 43 | `steel_nerve` | Steel Nerve | Steel cards convert `20%` of their Guard bonus into Power |
| 44 | `foil_cascade` | Foil Cascade | Each Foil card in a formation adds `+8%` output, capped at `40%` |
| 45 | `lucky_draw` | Lucky Draw | The first successful formation each round grants `+15%` pack progress |
| 46 | `task_runner` | Task Runner | Completing a task extends current timed boosts by thirty seconds |
| 47 | `perfect_timing` | Per&#102;ect Timing | A valid submission in the final half second gains `+60%` Power; never required by a task |
| 48 | `early_spark` | Early Spark | The first formation each round gains `1.50x` output |
| 49 | `second_wind` | Second Wind | The first failed formation each round does not reset the streak |
| 50 | `spare_hand` | Spare Hand | Adds one redraw per round |
| 51 | `deep_pockets` | Deep Pockets | Each unspent redraw adds `+10%` round-end Cash |
| 52 | `binder_bonus` | Binder Bonus | Each completed base Deck Set adds `+0.5%` output, capped at `25%` |
| 53 | `rivalry_badge` | Rivalry Badge | Friend Clash rewards gain `+25%` once per opponent per hour |
| 54 | `streak_keeper` | Streak Keeper | The first miss reduces the streak by one instead of resetting it |

### Rare Jokers

| No. | ID | Name | Deck-wide effect |
|---:|---|---|---|
| 55 | `full_spectrum` | Full Spectrum | A formation containing all four suits gains `1.80x` output |
| 56 | `royal_decree` | Royal Decree | Face cards gain `+50%` output inside a Court formation |
| 57 | `low_road` | Low Road | Ranks two through six gain `1.50x` output |
| 58 | `high_road` | High Road | Ranks ten through Ace gain `1.50x` output |
| 59 | `prime_pattern` | Prime Pattern | A formation using only prime valued cards gains `+60%` output |
| 60 | `echo_formation` | Echo Formation | Repeating a formation type adds `+25%`, stacking three times and resetting on change |
| 61 | `alternating_current` | Alternating Current | A perfectly alternating red and black formation gains `2.00x` Power |
| 62 | `set_architect` | Set Architect | Deck Set affinity thresholds require two fewer active cards |
| 63 | `edition_engineer` | Edition Engineer | Positive Edition effects are `20%` stronger |
| 64 | `trait_reader` | Trait Reader | Each distinct Trait in a formation adds `+15%` output |
| 65 | `grade_curve` | Grade Curve | Each distinct Grade in a formation adds `+12%` output |
| 66 | `fivefold` | Fivefold | Exactly five committed cards gain `1.75x` output |
| 67 | `threefold` | Threefold | Exactly three committed cards gain `1.50x` output and `+10%` pack progress |
| 68 | `soloist` | Soloist | A one-card formation gains `2.50x` Power |
| 69 | `empty_seat` | Empty Seat | Empty active deck slots each generate one passive Cash unit, capped at twenty slots |
| 70 | `collectors_eye` | Collector's Eye | The first new catalog discovery each session grants bonus Arcana Dust, capped daily |
| 71 | `arcana_adept` | Arcana Adept | Arcana task rewards gain `+50%` |
| 72 | `duelists_tempo` | Duelist's Tempo | Each Friend Clash round win adds `+10%` next-round output, stacking four times |
| 73 | `boss_breaker` | Boss Breaker | Boss Table Power gains `+60%` |
| 74 | `mixed_signal` | Mixed Signal | Four or more Deck Sets in a formation gains `1.60x` output |
| 75 | `pure_signal` | Pure Signal | One Deck Set across a formation gains `1.60x` output |
| 76 | `pack_hunter` | Pack Hunter | Every tenth successful formation grants one Deck Pack shard |

### Epic Jokers

| No. | ID | Name | Deck-wide effect |
|---:|---|---|---|
| 77 | `crown_engine` | Crown Engine | A ten through Ace Crown Run gains `2.00x` output |
| 78 | `endless_sequence` | Endless Sequence | A five-card Sequence repeats its lowest card at `50%` output |
| 79 | `suit_collapse` | Suit Collapse | At round start, off-suit cards count as the dominant suit for detection but lose `20%` output |
| 80 | `mirror_jester` | Mirror Jester | The first card in a formation copies the highest base rank value in that formation |
| 81 | `set_resonator` | Set Resonator | The dominant Deck Set's maximum affinity effect gains `+50%` |
| 82 | `edition_reactor` | Edition Reactor | The most common Edition in the active deck is `40%` stronger |
| 83 | `grade_amplifier` | Grade Amplifier | Grade S or higher gains `+60%` output; lower Grades lose `10%` |
| 84 | `trait_choir` | Trait Choir | A formation with all distinct Traits gains `2.00x` output |
| 85 | `high_voltage` | High Voltage | Consecutive successes add `+12%` Power, capped at `120%`, reset on failure |
| 86 | `cold_start` | Cold Start | The first ten seconds of a round grant `2.00x` Cash |
| 87 | `final_minute` | Final Minute | The last ten seconds of a round grant `2.00x` Power |
| 88 | `clean_sweep` | Clean Sweep | A full round without a failed submission grants a bonus Deck Pack |
| 89 | `comeback_act` | Comeback Act | After losing a duel round, the next round gains `2.00x` output; cannot chain |
| 90 | `overclock` | Overclock | Draw and resolve speed gain `35%`; Guard loses `25%` |
| 91 | `glass_cannon` | Glass Cannon | `2.00x` Power and `0.50x` Guard |
| 92 | `deep_vault` | Deep Vault | Excess pack progress carries forward and pack progress gains `25%` |
| 93 | `arcana_echo` | Arcana Echo | Every fifth Arcana use refunds Arcana Dust equal to half a basic Arcana Pack |
| 94 | `fifth_chair` | Fifth Chair | The Joker equipped in slot five has its numeric effect multiplied by `1.50x` |

### Legendary Jokers

| No. | ID | Name | Deck-wide effect |
|---:|---|---|---|
| 95 | `golden_sovereign` | Golden Sovereign | Twenty-six Golden active cards gain `1.75x` Cash; all fifty-two raises this to `2.00x` |
| 96 | `steel_colossus` | Steel Colossus | Steel Guard above the round target converts to Power at `50%` efficiency |
| 97 | `prismatic_regent` | Prismatic Regent | Prismatic cards count as every suit and raise a detected formation one reward band |
| 98 | `void_accountant` | Void Accountant | Void cards retain half their solo bonus when used in larger formations |
| 99 | `set_monarch` | Set Monarch | All fifty-two active cards from one Deck Set grants `3.00x` output |
| 100 | `mosaic_crown` | Mosaic Crown | Every ten distinct active Deck Sets adds `+25%` output, capped at `100%` |
| 101 | `grade_ascendant` | Grade Ascendant | Each active LR card adds `+2%` output, capped at `104%` |
| 102 | `perfect_copy` | Per&#102;ect Copy | The first card in a formation copies the strongest positive Edition multiplier present |
| 103 | `eternal_streak` | Eternal Streak | After reaching a streak of ten, the streak floor remains ten for that session |
| 104 | `joker_union` | Joker Union | Other equipped Jokers have numeric effects increased by `15%` |
| 105 | `arcana_master` | Arcana Master | Every Arcana use grants ten minutes of `+25%` active progress |
| 106 | `packstorm` | Packstorm | Every twenty-fifth successful formation starts a personal three-pack reward storm |
| 107 | `duel_crown` | Duel Crown | Friend Clash output gains `50%`; the first daily win grants one Joker Ticket |
| 108 | `boss_sigil` | Boss Sigil | Boss Table Power gains `2.00x` and cooperative rewards gain `25%` |
| 109 | `collection_emperor` | Collection Emperor | Each completed fifty-two-card Edition grid adds `+3%` output, capped at `60%` |
| 110 | `last_laugh` | Last Laugh | Below twenty-five percent duel shield, Power gains `2.00x` |

### Mythic Jokers

| No. | ID | Name | Deck-wide effect |
|---:|---|---|---|
| 111 | `fifth_law` | The Fifth Law | The other four equipped Joker effects are `35%` stronger; this Joker has no direct bonus |
| 112 | `house_of_fifty_two` | House of Fifty Two | A full active deck with no blank slots gains `2.00x` output |
| 113 | `wild_sovereign` | Wild Sovereign | The first card in each formation may count as any suit and one adjacent rank for detection |
| 114 | `archivist` | The Archivist | Every one hundred catalog forms adds `+0.5%` output, capped at `50%` |
| 115 | `infinite_ladder` | Infinite Ladder | Every card scores as one Grade higher; LR gains an additional `15%` |
| 116 | `world_card` | World Card | Dominant Deck Set affinity thresholds require three fewer cards and maximum affinity is `1.50x` stronger |
| 117 | `golden_sun` | Golden Sun | Golden Cash bonuses also add Power equal to half their Cash bonus |
| 118 | `null_crown` | Null Crown | Suppresses one negative Edition or Joker drawback each round |
| 119 | `echo_of_all` | Echo of All | Every fifth successful formation repeats at `60%` output |
| 120 | `fortunes_end` | Fortune's End | After twenty successful formations, the next earned pack has one slot guaranteed Legendary or higher, then resets |

At end-state scale, the complete Joker suite requires deterministic handler coverage, conflict and cap tests, pairwise interaction sampling, targeted adversarial combinations, five-slot build fixtures, calculation traces, migration compatibility, and performance proof. A new Joker cannot introduce client authority, hidden paid luck, unbounded multiplication, per-frame server work, or a rule that changes persistent ownership outside an idempotent transaction.

## FUT-005 — All Thirty-Six Arcana

An Arcana Pack reveals three server-committed offers and lets the player select one. The selected Arcana enters inventory. Consuming it is a separate confirmed transaction on one eligible playing card. An application never fails after commit, never selects multiple targets, and never erases the source identity. Edition Arcana permanently unlock selectable forms.

### Edition Arcana

| No. | ID | Arcana | Effect on one selected card |
|---:|---|---|---|
| 1 | `polisher` | The Polisher | Permanently unlocks Foil |
| 2 | `treasury` | The Treasury | Permanently unlocks Golden |
| 3 | `forge` | The Forge | Permanently unlocks Steel |
| 4 | `facet` | The Facet | Permanently unlocks Diamond |
| 5 | `mirage` | The Mirage | Permanently unlocks Holographic |
| 6 | `spectrum` | The Spectrum | Permanently unlocks Prismatic |
| 7 | `halo` | The Halo | Permanently unlocks Blessed |
| 8 | `thorn` | The Thorn | Permanently unlocks Cursed |
| 9 | `fracture` | The Fracture | Permanently unlocks Glitched |
| 10 | `hollow` | The Hollow | Permanently unlocks Void |
| 11 | `falling_star` | The Falling Star | Permanently unlocks Starfallen |
| 12 | `summit` | The Summit | Permanently unlocks Apex |
| 13 | `question` | The Question | Permanently unlocks Unknown and reveals its stable specialty on first score |

### Suit Arcana

Suit Arcana creates or unlocks the corresponding identity in the same Deck Set and Face Rank. It does not erase the source identity.

| No. | ID | Arcana | Effect |
|---:|---|---|---|
| 14 | `heart` | The Heart | Unlocks the Hearts identity |
| 15 | `gem` | The Gem | Unlocks the Diamonds identity |
| 16 | `clover` | The Clover | Unlocks the Clubs identity |
| 17 | `spear` | The Spear | Unlocks the Spades identity |

### Face Rank Arcana

Rank Arcana creates or unlocks the target rank identity in the same Deck Set and Suit. It never overwrites the source card.

| No. | ID | Arcana | Effect |
|---:|---|---|---|
| 18 | `stair` | The Stair | Unlocks the next rank, with Ace wrapping to two |
| 19 | `descent` | The Descent | Unlocks the previous rank, with two wrapping to Ace |
| 20 | `crown` | The Crown | Unlocks King |
| 21 | `heir` | The Heir | Unlocks Ace |
| 22 | `numerist` | The Numerist | Offers three numbered ranks and unlocks the chosen one |
| 23 | `court` | The Court | Offers Jack, Queen, and King and unlocks the chosen one |

### Grade Arcana

| No. | ID | Arcana | Effect |
|---:|---|---|---|
| 24 | `examiner` | The Examiner | Raises Grade by one step |
| 25 | `regrader` | The Regrader | Offers three Grade outcomes from the card's legal range; select one, never lowering the current Grade |
| 26 | `seal` | The Seal | Locks Grade during the next operation that could change the card instance |
| 27 | `scholar_arcana` | The Scholar | Adds a fixed amount of Grade experience |
| 28 | `laureate` | The Laureate | Raises the card to at least Grade A |

### Power Tier Arcana

| No. | ID | Arcana | Effect |
|---:|---|---|---|
| 29 | `ember` | The Ember | Raises Power Tier by one step |
| 30 | `crucible` | The Crucible | Offers three Power Tier outcomes and never lowers the current Tier |
| 31 | `anchor` | The Anchor | Locks Power Tier during the next applicable reroll |
| 32 | `awakening` | The Awakening | Raises the card to at least Legendary |

### Trait Arcana

| No. | ID | Arcana | Effect |
|---:|---|---|---|
| 33 | `voice` | The Voice | Offers three Traits for a card without one; select one |
| 34 | `mask` | The Mask | Offers three replacement Traits; select one |
| 35 | `oath` | The Oath | Locks the Trait during the next applicable reroll |
| 36 | `silence` | The Silence | Removes a Trait and refunds Trait Essence |

All Arcana operations validate the stable Arcana ID, inventory count, exact target instance, ownership, locks, current state, legal outcome set, and request identity. A before-and-after preview is presentation, while the server recomputes the authoritative result. Every application records one consumption, one target, one resulting state, permanent discovery changes, and an idempotent receipt.

## FUT-006 — All Twelve Souls

Souls are endgame global build rules. A player may own all twelve and equip only one. Souls are not required for early progression and arrive only after the active, collection, persistence, and social foundations are healthy.

| No. | ID | Soul | Global effect |
|---:|---|---|---|
| 1 | `origin` | The Origin | Classic cards gain `2.00x` output; every missing active slot weakens the bonus by `2%` |
| 2 | `archive` | The Archive | New catalog discoveries grant double one-time rewards and `+10%` permanent album reward progress |
| 3 | `mirror` | The Mirror | Copies the active Deck Set affinity of the largest represented set at `60%` strength |
| 4 | `forgeheart` | The Forgeheart | Positive Edition effects gain `25%`; Arcana Dust rewards lose `15%` |
| 5 | `crown_soul` | The Crown | Face cards and Aces gain `50%`, number cards lose `10%` |
| 6 | `compass` | The Compass | Daily tasks always include one goal suited to the active deck and grant `25%` more progress |
| 7 | `hourglass` | The Hourglass | Timed boosts last `50%` longer but are `15%` weaker |
| 8 | `gate` | The Gate | First completion of a task chain opens a personal bonus room with one earned pack |
| 9 | `bond` | The Bond | Cooperative contributions and friend rewards gain `50%`, subject to anti-farming limits |
| 10 | `challenger` | The Challenger | Fair Friend Clash rating rewards gain `40%`; passive Cash loses `20%` |
| 11 | `titan_soul` | The Titan | Boss Power and Guard gain `75%`; solo Formation Rush Cash loses `10%` |
| 12 | `pinnacle` | The Pinnacle | When every active card is Grade LR, all output gains `3.00x` |

Soul definitions use the same registered deterministic stage system as Jokers. They declare conflicts, penalties, caps, supported modes, trace entries, and migration behavior. Soul instances have unique server-generated IDs and provenance and may not change trade settlement or another player's state.

## Album, Mastery, Rarity, and Provenance

The complete album has four primary views:

1. A Deck Set grid with one familiar fifty-two-card page per set.
2. An Edition grid that filters every Deck Set by Normal through Unknown.
3. Quality records showing the best Grade, Power Tier, Trait, output, and other approved statistics ever owned for each base identity.
4. Special collections for Jokers, Arcana, Souls, event stamps, and mastery rewards.

Discovery and current ownership are separate. A traded-away permanent form remains discovered but no longer counts as currently owned. Both percentages are visible. Album completion uses only permanent catalog forms and named special collections.

Each Deck Set has Affinity and Mastery. Affinity derives from the number of active cards from that set, with initial thresholds at thirteen, twenty-six, thirty-nine, and fifty-two. Mastery is permanent experience earned by actively scoring the set. It unlocks pack cosmetics, binder pages, titles, a showcase pose, a small nonmultiplying utility perk, and a completion aura. Mastery can reward identity without forcing one build to dominate every mode.

Power Tier rarity, Edition form, Grade training, Trait specialty, Joker Rarity, and Soul identity remain independent axes. Reveal presentation communicates each axis through text, symbols, frame, material, aura, sound, and optional motion without conflating them.

Provenance records include origin type, source operation or event, creation time, content and schema versions, prior transformations, trade history references, and current ownership. Balance changes preserve identity. Impossible provenance or ownership is quarantined with evidence and never silently deleted.

## Packs, Odds, Pity, and Reveal Lifecycle

### Pack Families

- A Deck Set Pack contains five playing cards from one selected Deck Set. All five are granted. Rank and suit, Power Tier, initial Grade, and possible Trait are server rolled. Initial Edition is Normal.
- A Joker Pack reveals three committed Jokers and lets the player select one. Owned duplicates are visible before selection, and the unselected offers do not become owned.
- An Arcana Pack reveals three committed Arcana and lets the player select one. The Arcana is stored before a later separate application.
- A Soul Pack reveals two committed Souls and lets the player select one. Soul Packs are endgame rewards and are never an early progression requirement.

Every pack has a unique operation ID and follows `created → contents_committed → revealed → claimed`. Currency deduction and contents commit together. The client sees only committed results. A disconnect after commit reopens the same result. Replaying the operation returns that result and cannot create another pack. Pending offers retain their original stable IDs and catalog version until choice.

### Earned Deck Set Pack Odds

The starting per-card-slot Power Tier odds are:

| Power Tier | Chance |
|---|---:|
| Common | `66%` |
| Uncommon | `20%` |
| Rare | `8%` |
| Epic | `3.5%` |
| Legendary | `1.5%` |
| Mythic | `0.65%` |
| Secret | `0.25%` |
| Infernal | `0.08%` |
| Celestial | `0.015%` |
| Chaos | `0.004%` |
| Zenith | `0.001%` |

The production configuration uses exact integer weights totaling one hundred percent. Odds display the base chance, current pity, guarantees, and event modifiers.

Draft protection rules are:

- At least Rare within twenty card slots without Rare or higher.
- At least Legendary within one hundred card slots without Legendary or higher.
- At least Mythic within five hundred card slots without Mythic or higher.
- Secret and higher results produce Ascension Fragments for a slow deterministic chosen improvement path.
- Pity is tracked by pack family, persists before reveal acknowledgement, and never resets without committing its qualifying result.

Joker and Arcana offers have their own versioned weights, pity, duplicate protection, choice recovery, and content-family configuration. No public odds claim may differ from the exact server configuration.

### Reveal Contract

The reveal lets the player pick up and tear or swipe the pack, reveal cards one at a time or all at once, read Power Tier before the name, inspect special pulls, and see `NEW`, `UPGRADE`, `DUPLICATE`, or `WISHLIST`. Equip, Binder, Lock, Wishlist, and Continue actions remain available after the committed result appears. Animation skip is available after the first tutorial. Reduced motion, reduced flash, muted audio, static rarity cues, and fast reveal preserve the same information.

Earned gameplay packs remain separate from monetization. If paid random items are ever proposed, they require a new explicitly promoted product contract, PolicyService review, exact odds disclosure, purchase receipts, and transaction restrictions. The preserved product direction is guaranteed monetization, not paid randomized gameplay power.

## Active Modes and Calculation Contract

### Formation Rush

Formation Rush remains the fastest repeatable progress path. A sixty-second round uses the server-owned deck, eight-card hand, one-to-five-card submissions, discard and refill, streak, prompt, timer, and reward state. Blanks fill only an undersized hand and have no rank, suit, output, Tier, Trait, or Edition.

| Formation | Requirement | Starting multiplier |
|---|---|---:|
| Single | Any one card | `1.00x` |
| Twin | Two cards with the same Face Rank | `1.50x` |
| Twin Pair | Two different Twins | `2.20x` |
| Triple | Three cards with the same Face Rank | `2.50x` |
| Sequence | Three to five consecutive Face Ranks | `1.80x` to `4.00x` |
| Monosuit | Three to five cards of one Suit | `1.80x` to `4.00x` |
| Court | Jack, Queen, and King | `3.20x` |
| Spectrum | All four Suits | `3.00x` |
| Full Cluster | A Triple and a Twin | `5.00x` |
| Quad | Four cards with the same Face Rank | `6.00x` |
| Crown Run | Ten, Jack, Queen, King, and Ace | `8.00x` |
| Per&#102;ect Sum | Hits the round's displayed target value | `2.50x` plus accuracy bonus |

A submission can satisfy multiple patterns, but the server selects the highest configured base reward and applies only bonuses declared stackable. It never multiplies every detected pattern together.

```text
card contribution =
    face rank value
  × edition component
  × grade multiplier
  × power tier multiplier
  × trait effect
  × deck set affinity

formation output =
    sum of card contributions
  × formation multiplier
  × joker rules
  × soul rule
  × active boosts
  × mode modifier
```

Cash, Power, Guard, pack progress, and Grade experience use separate components. All stages, additive and multiplicative groups, conflicts, caps, and trace entries are versioned. Before endgame values threaten safe Luau integer precision, FUT-012 migrates them to deterministic normalized large numbers.

### Active Task Stations

| Station | Interaction | Primary reward | Boost or progression |
|---|---|---|---|
| Suit Sorter | Drag visible cards into four large suit lanes | Deck Pack progress | Faster pack earning |
| Sequence Bench | Arrange shuffled cards into ascending runs | Cash | Cash multiplier |
| Arcana Trace | Tap large connected symbols in the shown order | Arcana Dust | Arcana progress |
| Grade Press | Stop a moving marker inside broad quality zones | Grade Ink | Grade experience |
| Trait Lab | Match card conditions to useful Traits | Trait Essence | Trait discovery |

Tasks last roughly forty-five to ninety seconds, use server seeds and discrete actions, provide generous hit targets, and grant something on valid completion. Speed can improve rewards but a precision miss does not erase all progress. Keyboard, touch, controller, reduced-motion, and untimed alternatives remain available.

Boosts use absolute server time. Stronger same-type boosts replace weaker ones. Repeating a boost extends duration to a cap. Offline time pauses active-only boosts. Server event boosts apply in a declared group with a published cap.

## FUT-007 — Cooperative Boss Table

The Boss Table gives a server-wide shared target. Players enter short Formation Rush windows, contribute Power, and use Guard to protect the group. Boss patterns request suits, ranks, Deck Sets, or formation types so collection breadth matters.

Participation thresholds and diminishing repeated rewards prevent idle and alternate-account farming. Passive output cannot defeat a boss. The UI shows individual contribution, team milestones, remaining time, current mechanic, and next mechanic. Rewards include earned packs, cosmetics, mastery items, and Soul Fragments.

Bosses require authoritative contribution, versioned encounters, reconnect recovery, bounded server work, accessibility paths, anti-farming, failure-safe rewards, and seasonal analytics. The first healthy update adds the Boss Table and three Souls only after foundation health passes.

## Friend Clash and Competitive Play

Friend Clash is a best-of-five simultaneous card battle. Both players receive the same public formation prompt and time limit. Submitted formations create Power and Guard. Power above the opponent's Guard removes shield, and the first player to win three rounds wins.

- Power Clash uses owned Grade, Power Tier, Editions, Traits, affinities, and Jokers to measure collection strength.
- Fair Clash normalizes Grade, Power Tier, and Edition multipliers while preserving identities, formation choices, and deterministic rule interactions to measure play and deck construction.

There are no stakes, entry wagers, item transfers, or winner-take-all currency. Rewards use daily and same-opponent caps. Private friend rematches continue without rewards after caps. Competitive ratings and cross-server matchmaking remain FUT-008 and require sufficient population, abuse controls, seasonal resets, disconnect rules, queue observability, and normalization proof.

## Passive and Offline Progress

Equipped active cards contribute controlled passive table value. Passive output does not trigger Formation, Trait, Joker, Arcana, duel, boss, or other active effects unless an effect explicitly says so.

- Default offline cap is four hours.
- Expected offline Cash and basic pack progress are roughly fifteen to twenty percent of average active progress.
- No offline Power Tier rolls, Arcana applications, trades, Grade promotions, boss contribution, or duel rating occur.
- Trusted timestamps and versioned caps determine elapsed progress.
- The return screen shows duration, rate, cap, version, and exact reward.

Passive systems encourage return without making unattended clients optimal. Time rollback, clock skew, repeated claims, migration, and rate changes remain idempotent and capped.

## Social Spaces and Presentation

The hub is a compact card workshop rather than a tycoon line. The complete destination includes:

- A personal opening table with physical packs and cards.
- An inspectable Binder wall.
- A Card Grading hall with promotion ceremonies.
- An Arcana Lab for one-card transformations.
- A Joker Stage showing five active Jokers as animated props.
- Trade booths with visible participants and locked offer panels.
- Friend Clash tables with spectators who cannot see hidden hands.
- A cooperative Boss Table.
- Showcase podiums for a favorite card and completed Deck Set.
- Closely placed Task Stations for mobile navigation.

Rare-pull announcements are opt-out, use item names only, and expose no private account information. Inspection cards support bounded reactions and wishlist actions. Any later player-entered text uses Roblox filtering. Spectator polish, richer wishlists, clubs or crews, cooperative seasons, and expanded social systems remain FUT-010.

## Safe Direct Trading and FUT-009 Market Boundary

Direct trading is a core social system but remains behind `TradeEnabled` until duplication, disconnect, storage, exploit, and separately authorized production checks pass. The initial release may ship with the booth visibly disabled under DEC-005 and FUT-015.

Tradable categories are playing card instances, eligible Joker instances or unbound copies, Arcana inventory items, and Souls after Souls release. Cash, Grade Ink, Arcana Dust, Trait Essence, Duel Tokens, mastery, boosts, starter grants, quest grants, bound Jokers, and protected promotional items are not transferable. Robux value is never displayed, and real-money trading is unsupported.

Eligibility and protection include:

- Suggested minimum seven-day account age, two active hours, completed tutorial, and a fully loaded writable profile.
- A configurable acquisition lock before a new item can trade.
- Favorite, equipped, grading, Arcana-targeted, locked, prepared, settling, and otherwise ineligible items cannot enter an offer.
- Both players see exact item art and properties, ownership count, collection status, and an approximate game-value band.
- Only-copy and large-value-disparity warnings appear without claiming a real-money value.
- Every edit clears readiness, and final acceptance has a visible five-second countdown.
- Both players receive an immutable in-game receipt and bounded recent history.
- Reports reference a receipt rather than a screenshot.

Because Roblox DataStore does not provide one atomic transaction across two profile keys, settlement uses a persistent idempotent journal:

```text
requested
  → accepted
  → editing
  → both ready
  → countdown complete
  → journal prepared
  → items moved idempotently
  → journal committed
  → profiles saved
  → items unlocked and receipts issued
```

Before `prepared`, disconnect cancels and unlocks. After `prepared`, clients cannot cancel. Recovery completes the exact transfer once or restores the exact original ownership according to the journal contract. A committed journal never rolls back into a duplicate. Repeating a step with the same trade ID never moves an item twice. Profiles reconcile prepared journals before becoming writable.

FUT-009 is a separate cross-server listing market. It cannot begin until direct trades have stable ledgers, moderation tools, price history, expiration, taxes, recovery, scam controls, and acceptable support metrics. Listings escrow exact item instances outside a player's live session. MemoryStore may coordinate presence or queues but cannot own escrowed items. The market never supports currency transfer, real-money value, or paid-random-item circumvention.

## Economy and Deterministic Progression Paths

| Currency | Main sources | Main uses | Tradable |
|---|---|---|---|
| Cash | Formations, tasks, offline table | Deck Set Packs and basic upgrades | No |
| Joker Tickets | Formation streaks, bosses, daily goals | Joker Packs | No |
| Arcana Dust | Arcana tasks, discoveries, salvage | Arcana Packs | No |
| Grade Ink | Active card use, Grade tasks, salvage | Deterministic Grade progress | No |
| Trait Essence | Trait tasks and trait salvage | Trait choices and removal | No |
| Duel Tokens | Rewarded Friend Clashes | Duel cosmetics and earned packs | No |
| Soul Fragments | Bosses and endgame mastery | Soul Packs | No |
| Ascension Fragments | High-Tier pulls, events, high-Tier salvage | Deterministic high-Tier improvement | No |

Every source and sink uses integer versioned configuration and emits previous balance, delta, reason ID, resulting balance, operation ID, and sanitized context. Client requests never choose a trusted amount or price.

Economy protections include social reward caps, rapid same-opponent diminishing returns, controlled pack price curves, published price paths for new Deck Sets, identity-preserving seasonal content, versioned balance patches, unusual-delta monitoring, and seasonal boards where inflation would otherwise make permanent placement impossible. Deterministic Grade, Arcana, Trait, and Ascension paths ensure long-term goals do not depend only on luck.

## FUT-014 — Live Operations and Retention

The complete live-operations system creates reasons to return without punishing absence.

Daily systems include three short tasks with one free reroll, one featured formation, one featured Deck Set, first Friend Clash and Boss bonuses, capped offline return, and a wishlist target with active progress rather than hidden odds manipulation.

Weekly systems include a cooperative boss rotation, collection-page challenge, normalized formation board, scheduled Packstorm event, and cosmetic mastery reward path.

Long-term goals include base Deck Set completion, Edition grids such as all fifty-two Golden Radioactive cards, LR training, Joker collection and mastery, Souls and endgame builds, permanent collection records, and seasonal active records.

Missing a day does not reset valuable progress. A limited number of daily tasks may bank, and returning players receive catch-up goals rather than permanent disadvantage. Event and season configuration is versioned, disclosed, recoverable, and incapable of invalidating permanent cards.

## FUT-013 — Loadouts, Album Rewards, and Leaderboards

The player may eventually save multiple convenience loadouts without gaining extra simultaneous power. Each loadout still obeys one instance per slot, five active Jokers, one active Soul, ownership, locks, and server validation.

Separate leaderboards prevent one number from defining the game:

- Permanent Forms Discovered.
- Permanent Forms Currently Owned.
- Deck Set Mastery.
- Best Card Output.
- Formation Rush seasonal score.
- Boss contribution seasonal score.
- Fair Clash rating.
- Power Clash rating.
- Total Cash earned as a prestige statistic rather than the main skill board.

Boards use server-generated normalized values, exclude flagged or quarantined profiles, display shared rank for ties where supported, and reward cosmetics, titles, table decorations, or inspect effects rather than exclusive power. Seasonal resets never erase permanent collection state.

Edition-grid rewards, all-set mastery, endgame album views, showcase auras, titles, and final collection records remain visible, deterministic, and accessible. Completion rewards never require destroying the only owned copy.

## Ethical Monetization

The complete monetization direction sells guaranteed presentation and declared convenience:

- Card backs and sleeves.
- Binder covers, page materials, and sorting themes.
- Personal table skins.
- Pack opening animations and reveal effects.
- Emotes, inspect poses, nameplates, and chat-free reactions.
- Extra saved deck loadout slots.
- Private servers.
- A cosmetic season track after retention is proven.

Products show exact guaranteed contents before purchase, grant exactly once through durable receipts, restore correctly, and have an emergency disable control. They do not sell Power Tier odds, hidden luck, leaderboard power, trade currency, recovery, destructive effects, or a way to erase another player's progress. A mixed cosmetic and gameplay product must show every exact guaranteed item and cannot hide random gameplay content.

Monetization performance is observed as one health dimension, not an excuse to weaken originality, accessibility, progression, policy, or safety.

## Rendering, Presentation, and Accessibility at Full Scale

One reusable renderer composes these layers:

1. Deck Set base illustration and frame.
2. Suit icon and color treatment.
3. Face Rank text and corner pips.
4. Edition material and static shader fallback.
5. Grade badge.
6. Power Tier aura.
7. Trait symbol.
8. Lock, favorite, new, wishlist, and trade overlays.

The same normalized card data drives binder cards, table cards, pack reveals, inspect views, trade panels, showcases, and thumbnails. Full-scale collection pages are virtualized and paged. Live 3D viewports are not instantiated for every binder item. Cards, pack pieces, particles, sounds, and reusable interface cells are pooled.

Every primary action works with touch, mouse, keyboard, and controller. Important rarity and confirmation information uses text and symbols in addition to color. Reduced motion, reduced flash, mute reveal sound, skip animation, color assistance, UI scaling, and low graphics remain first-class. Timing tasks provide broad zones and an untimed alternative. Card tilt is decorative. Trade confirmation never relies on color alone.

Content waves cannot ship until their cards, materials, sounds, icons, fallbacks, localization-safe text bounds, virtualized collection pages, device performance, and originality provenance are complete.

## FUT-012 — Storage Sharding, Large Numbers, and Scaling

Launch can begin with a compact profile behind `ProfileStore` and `InventoryStore` interfaces. Before live profiles approach the DataStore key ceiling, inventory migrates to a core profile plus versioned shards. The core manifest records shard identities and revisions. Card instances partition by a stable Deck Set hash, and every multi-key mutation uses a persistent journal.

The capacity gate accounts for core state, all shards, recovery journals, pending operations, receipts, migration workspace, and safety reserve. Migration rehearsals use representative maximum profiles, interruption at every stage, repeated execution, old-client rejection, rollback, and exact ownership conservation.

Launch values remain below `10^15`. Before endgame multiplication approaches unsafe precision in Luau doubles, the economy and leaderboard boundary adopts a deterministic mantissa-and-exponent representation. Normalization, comparison, serialization, formatting, caps, migration, and cross-version round trips are pure and fixture tested. Leaderboards compare normalized numbers, never formatted strings.

At full scale, the architecture must support:

- 2,704 base identities and 37,856 permanent forms without copying catalog text into every profile.
- Sparse permanent discovery and current ownership views.
- Large instance inventories without broad per-frame or per-action scans.
- Paged network snapshots with strict payload limits.
- Bounded catalog startup validation and cached lookups.
- Deterministic effect evaluation across 120 Jokers, 24 Traits, 14 Editions, 12 Souls, and future mode modifiers.
- Eight-player public servers before any evidence-based server-size increase.

MemoryStore can coordinate temporary cross-server presence, queues, matchmaking, or market activity but remains disposable and nonauthoritative.

## Originality, Policy, Security, and Privacy

Standard playing card ranks and suits are generic building blocks. Every expressive layer is original: Deck Set identities, card frames, illustrations, names, interfaces, effects, sounds, writing, mascots, pack designs, world design, logo, icon, thumbnails, and branding. The product does not import or imitate Pokémon, anime characters, Balatro Jokers or card art, protected logos, proprietary pack designs, character names, screenshots, or another game's interface composition.

The active game uses original Card Formations. It does not use poker chips, dealers, roulette devices, wagers, betting, stakes, jackpots, winner-take-all inventory, or cash-out language. A loss costs match time and reward opportunity, never permanent inventory.

Server authority, typed schemas, ownership checks, rate limits, idempotent receipts, journaled transfers, policy checks, feature flags, and sanitized evidence remain mandatory at every expansion. New content cannot add a client-trusted reward, price, Tier, Trait, score, timestamp, owner, purchase result, or settlement outcome.

Credentials, raw private profiles, private logs, unfiltered player text, authentication data, and unrelated inventory never enter analytics, moderation evidence, issue reports, or public diagnostics. Custom text uses Roblox filtering before display. Security quarantine preserves evidence and ownership while preventing unsafe play. Admin actions use a separate permission-checked path and durable audit receipts.

Every expansion receives originality, provenance, Community Standards, metadata, policy, security, privacy, device, and accessibility review before publication. A conflict blocks the affected release instead of weakening these boundaries.

## Analytics, Health Gates, and Evidence-Driven Expansion

Server-emitted analytics cover onboarding, sessions, economy, progression, packs, collection, formations, tasks, duels, bosses, trades, market activity, purchases, errors, security, performance, and release state. Properties are stable IDs or bounded bands, not raw private data.

Core event families include:

| Event family | Required evidence |
|---|---|
| Onboarding | Step, completion or skip, elapsed time, next action, interruption and recovery |
| Packs | Pack family, source reason, pity before and after, committed result band, choice and recovery |
| Collection | Stable content family, new form, ownership count band, mastery, wishlist, and showcase use |
| Progression | Grade, Trait, Edition, Arcana, salvage, deterministic-path use, and operation result |
| Formation | Formation ID, card count, valid state, output bands, streak, timing, and round summary |
| Tasks and boosts | Task ID, duration, accuracy band, reward band, boost state, and accessibility mode |
| Social | Invite, match mode, rounds, disconnect, reward eligibility, boss contribution, spectator use |
| Trading and market | State, item count, duration, error, recovery, receipt, listing lifecycle, and abuse signals |
| Economy and commerce | Currency reason and balances, product ID, receipt result, restore state, and policy result |
| Reliability | Profile stage, save and migration result, crash, shutdown, payload, frame, memory, and recovery |
| Security | Stable signal ID, action ID, severity band, quarantine state, and resolution without exploit instructions |

Initial healthy targets retained from the launch foundation are:

| Metric | Initial healthy target |
|---|---:|
| First pack completion | More than `85%` of joins |
| First pack median time | Less than `30 seconds` |
| First Formation Rush completion | More than `70%` of joins |
| First Formation Rush median time | Less than `2 minutes` |
| Ten-minute first-session retention | More than `55%` |
| Tutorial completion | More than `70%` |
| Pack opening interruption or failure | Less than `0.1%` |
| Successful save sessions | More than `99.9%` |
| Crash-free sessions | More than `99.5%` |
| Confirmed item duplication | Exactly `0` |
| Trade settlement requiring recovery | Measured and less than `0.1%` after release |

Day one, day seven, playtime, play days, intentional co-play, retention, and monetization are compared with current Roblox Similar Experiences benchmarks rather than invented as permanent promises. A content wave starts only after the current version has sufficient sample quality, stable data, acceptable safety and performance, no unresolved ownership defect, and an owner-approved release boundary.

Before each expansion, the health review answers:

- Do players complete and understand the first pack and Formation Rush?
- Which activities create healthy voluntary sessions?
- Do players understand Edition versus Deck Set?
- Are players using multiple Joker and later Soul builds?
- Is deck and Edition-grid completion satisfying rather than exhausting?
- Do Friend Clash, Boss Table, and other social systems receive voluntary repeat use?
- Do trades settle without duplication, loss, recovery spikes, scams, or support cases?
- Which missing identities or sets create return sessions?
- Does mobile and low-graphics performance remain stable during reveals, bosses, trading, and busy hubs?
- Are storage, payload, number, moderation, policy, and operator controls within their budgets?

If the core is unhealthy, the next work is foundation repair, not catalog volume.

## FUT-011 — Story and World Ideas Remain Unpromoted

Story chapters, dialogue trees, large quests, or a larger open world are not part of the defined final completion endpoint. They may be considered only through a later explicit owner promotion that defines narrative authority, localization, content moderation, accessibility, save compatibility, world performance, rewards, and how the work supports rather than obscures the card loop.

## FUT-015 — Conditional Later Trading Enablement

If the initial public release uses the visibly disabled direct-trading state, later enablement remains a separate future release. It must close every deferred defect, rerun the complete journal and ownership failure matrix, prove support and scam controls, obtain a newly scoped production authorization, execute bounded smoke, observe recovery and support thresholds, and retain an immediate feature-disable path. The disabled initial state is not permission to bypass any later gate.

## Future Scope Registry

| ID | Preserved future scope | Initial-release disposition |
|---|---|---|
| FUT-001 | Remaining forty-nine Deck Sets and all 2,704 base identities | excluded |
| FUT-002 | Remaining ten Editions and all 37,856 permanent forms | excluded |
| FUT-003 | Remaining twelve Traits and all twenty-four Trait interactions | excluded |
| FUT-004 | Remaining ninety-six Jokers and full 120-Joker suite | excluded |
| FUT-005 | Remaining twenty-four Arcana and all thirty-six one-card effects | excluded |
| FUT-006 | All twelve Souls and Soul Packs | excluded |
| FUT-007 | Cooperative Boss Table, encounters, and boss seasons | excluded |
| FUT-008 | Cross-server matchmaking and population-supported competitive ratings | excluded |
| FUT-009 | Escrowed cross-server listing market | excluded |
| FUT-010 | Spectators, richer wishlists, clubs or crews, social seasons, and expanded co-play | excluded |
| FUT-011 | Story chapters, dialogue quests, or larger world after explicit promotion | excluded |
| FUT-012 | Inventory sharding and deterministic large-number migration | excluded |
| FUT-013 | Multiple loadouts, endgame album rewards, and final leaderboards | excluded |
| FUT-014 | Expanded daily, weekly, event, and cosmetic season systems | excluded |
| FUT-015 | Later direct-trading enablement if launch trading remains disabled | excluded |

## Preserved Non-Goals

| ID | Boundary that remains in force |
|---|---|
| NG-001 | No protected franchise assets, identities, interfaces, or imitation branding |
| NG-002 | No poker, blackjack, casino, betting, wagering, stakes, chips, dealers, jackpots, or cash-out presentation |
| NG-003 | No paid random gameplay packs, hidden luck, purchasable odds, leaderboard power, or random power requirements |
| NG-004 | No real-money trading, Robux value display, player currency transfer, or wagered inventory |
| NG-005 | No client authority over inventory, RNG, scoring, rewards, progression, purchases, trades, or persistence |
| NG-006 | No passive, offline, unattended, or held-input path stronger than active play |
| NG-007 | No catalog volume used to hide an unhealthy core loop |
| NG-008 | No guarantee of popularity, discovery rank, retention, spending, or audience size |
| NG-009 | No full 52 by 52 implementation as an initial-release gate |
| NG-010 | No change to the GitHub repository's current public visibility as part of Roblox publication |

## Future Work Package Topology

These labels describe the dependency order inside this nonblocking aspect. They are not global phases and do not authorize execution.

| Work package | Objective | Dependencies | Included FUT scope | Entry gate | Exit gate | Next transition |
|---|---|---|---|---|---|---|
| FULL-WP-000 | Review foundation health and deliver the first healthy update with two complete Deck Sets, Boss Table, three Souls, targeted content, and measured quality-of-life fixes | Initial public release complete, DEC-012 | FUT-001, FUT-004, FUT-005, FUT-006, FUT-007, FUT-014 | Initial release observation has sufficient clean evidence and no unresolved mandatory safety defect | Update assets, systems, migrations, devices, operations, and live evidence pass without weakening the foundation | FULL-WP-001 |
| FULL-WP-001 | Release remaining Deck Sets in small complete themed waves with mastery, affinity, packs, events, album pages, and performance proof | FULL-WP-000 | FUT-001, FUT-013, FUT-014 | Prior wave is merged, released, observed, and healthy | Every released set is complete and healthy; all fifty-two sets are not required until the final wave | FULL-WP-002 |
| FULL-WP-002 | Complete Editions, Traits, Jokers, and Arcana through versioned compatible waves | FULL-WP-001 | FUT-002, FUT-003, FUT-004, FUT-005 | Catalog, effect engine, storage, number, UI, and test budgets support the next wave | Fourteen Editions, twenty-four Traits, 120 Jokers, and 36 Arcana work exactly as cataloged with deterministic traces | FULL-WP-003 |
| FULL-WP-003 | Expand cooperative, spectator, wishlist, club or crew, live-operations, and competitive social systems | FULL-WP-002 | FUT-007, FUT-008, FUT-010, FUT-014 | Direct social systems, moderation, performance, and population evidence support expansion | Boss, spectator, co-play, seasonal, and competitive systems are safe, accessible, observed, and voluntary | FULL-WP-004 |
| FULL-WP-004 | Add safe cross-server matchmaking and consider the escrow market only after direct-trade maturity | FULL-WP-003 | FUT-008, FUT-009, FUT-015 | Queue population, trade ledgers, support, moderation, price history, recovery, and abuse evidence pass | Cross-server systems preserve identity, ownership, fairness, privacy, recovery, and feature-disable controls | FULL-WP-005 |
| FULL-WP-005 | Complete Souls, endgame builds, storage sharding, large numbers, final album rewards, leaderboards, and scale hardening | FULL-WP-004 | FUT-006, FUT-012, FUT-013 | Representative endgame profiles approach approved migration triggers and all rehearsals pass | Twelve Souls, sharded ownership, normalized numbers, endgame views, and scale budgets pass migration and live evidence | FULL-WP-006 |
| FULL-WP-006 | Complete the 52 by 52 destination and verify the final vision | FULL-WP-005 | FUT-001 through FUT-014, plus FUT-015 when the initial public release leaves trading visibly disabled | Every prior package and content wave is merged, released, observed, and healthy | All final-vision conditions below pass with no known aspect-owned defect | final future-aspect closure |

Work packages remain sequential at their integration boundaries. Content production may proceed in bounded independent groups only after shared contracts freeze, but no later package release may stack on an unmerged or unobserved predecessor.

## Final 52 by 52 Closure

The full vision is complete only when:

- All fifty-two original Deck Sets contain every rank and suit identity, complete original assets, pack identity, affinity, mastery, collection page, and observed healthy release evidence.
- All fourteen Editions can be permanently unlocked one card at a time without deleting prior forms.
- The album tracks exactly 37,856 permanent forms and separately reports discovery and current ownership.
- All eleven Grades and eleven Power Tiers are meaningful, readable, deterministic, and compatible across balance changes.
- All twenty-four Traits, 120 Jokers, 36 Arcana, and 12 Souls work exactly as cataloged through registered deterministic effects and complete traces.
- Formation Rush remains the fastest core progress path, with tasks, bosses, Friend Clash, and other modes supporting rather than replacing it.
- Boss Table, social inspection, showcases, spectators, and approved co-play systems are reliable and accessible.
- Direct trading cannot duplicate or lose an item under tested disconnect, replay, concurrency, shutdown, storage failure, and recovery scenarios.
- Any cross-server market uses durable escrow, moderation, recovery, expiration, price evidence, and abuse controls without real-money or paid-random circumvention.
- Passive and offline systems complement active play and remain bounded.
- The economy provides visible odds, deterministic paths, useful sinks, stable identities, and no paid-random-power requirement.
- Sharded storage, normalized large numbers, paged networking, bounded calculations, and device performance support representative endgame profiles.
- Mobile, tablet, controller, keyboard, mouse, reduced-motion, reduced-flash, color-assistance, and low-graphics players can complete every required activity.
- Analytics, feature controls, moderation, rollback, migrations, documentation, operations, and support evidence remain current for the final release.
- The game has a recognizable original identity and contains no protected franchise assets or prohibited gambling presentation.
- Every future work package, release gate, migration, real workflow, observation window, documentation obligation, and highest-fidelity verification passes with no known aspect-owned defect.

This closure is the preserved destination. It is not part of the initial-release Definition of Done and cannot be promoted by inference, implementation convenience, a content asset becoming available, or another automated planning pass.
