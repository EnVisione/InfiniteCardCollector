# Card Game Content Catalog

This catalog fixes the names, counts, identity rules, and first balance targets for the complete game. Every numeric effect is configuration data. Names and collection identities are stable; balance values may change without changing an item's identity.

## Canonical Card Name

Every collectible playing card uses this order:

`[Edition] [Grade] [Power Tier] [Face Rank] of [Deck Set] [Suit], [Trait] trait`

Example:

`Golden LR Infernal Ace of Radioactive Spades, Fortune trait`

The fields are independent:

| Field | Example | Meaning |
|---|---|---|
| Edition | Golden | A permanent, selectable card form unlocked with Arcana |
| Grade | LR | The card instance's trained quality |
| Power Tier | Infernal | The card instance's rolled base rarity and multiplier |
| Face Rank | Ace | One of the thirteen standard ranks |
| Deck Set | Radioactive | One of the fifty two collectible visual families |
| Suit | Spades | One of the four standard suits |
| Trait | Fortune | An optional per card specialty |

A card's permanent identity is `Deck Set + Face Rank + Suit`. Edition forms are permanent collection unlocks attached to that identity. Grade, Power Tier, and Trait describe an owned card instance.

## Collection Scale

| Layer | End goal count |
|---|---:|
| Face ranks per suit | 13 |
| Suits per Deck Set | 4 |
| Cards per Deck Set | 52 |
| Deck Sets | 52 |
| Base card identities | 2,704 |
| Editions, including Normal | 14 |
| Permanent catalog forms | 37,856 |
| Grades | 11 |
| Power Tiers | 11 |
| Traits | 24 |
| Jokers | 120 |
| Arcana | 36 |
| Souls | 12 |

The completion album tracks the 37,856 permanent card forms, 120 Jokers, 36 Arcana discoveries, and 12 Souls. Grade, Power Tier, Trait, and statistics are recorded as best observed values. Requiring every theoretical combination would create millions of mostly meaningless checklist entries and would make completion impossible.

## Face Ranks and Suits

Each Deck Set contains exactly these fifty two identities.

- Face ranks: `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9`, `10`, `Jack`, `Queen`, `King`, `Ace`
- Suits: `Hearts`, `Diamonds`, `Clubs`, `Spades`

The active deck has one slot for every Face Rank and Suit pair. A player may place only one owned Deck Set version into each slot. For example, the `10 of Spades` slot may hold the Classic, Radioactive, or Astral version, but never two at once.

## The Fifty Two Deck Sets

Every Deck Set must have its own card frame, suit treatment, pack wrapper, reveal sound, collection page, mastery track, and one gameplay affinity. Affinities are mild build directions, not mandatory bonuses.

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

## Editions

Normal is available when a card is first discovered. Each other Edition is unlocked for one card identity by consuming its matching Arcana. Unlocking an Edition never deletes or replaces an older form. The player can switch among every Edition unlocked for that identity.

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

Edition multipliers are applied only to the card carrying the Edition. Joker effects may improve an Edition category globally.

## Grades

Grade represents long term training. Every card can reach LR without failure, destruction, or a paid shortcut. Cards gain Grade experience when used in successful formations. Players may also apply earned Grade Ink. Duplicate cards may be kept, traded, or salvaged for Grade Ink; they are never consumed automatically.

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

These thresholds are launch tuning targets. Experience requirements may be rebalanced globally, but a saved Grade can never move backward because of a balance patch.

## Power Tiers

Power Tier is the card instance's rarity roll. It affects visual presentation, reveal excitement, base output, trading desirability, and leaderboard potential. Tier odds must be visible in the pack details screen. The rarest tiers use pity protection and remain earnable through active play.

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

## Traits

A card has zero or one Trait. A Trait affects only the card carrying it or the formation in which that card scores. Trait effects never alter trade completion, trade value warnings, or another player's inventory.

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

## Jokers

Jokers apply deck wide rules. A player may own every Joker but equip no more than five. Duplicate Jokers grant Joker experience after the player chooses to bind them; they are not destroyed automatically. Joker Rarity is separate from card Power Tier.

### Joker Count by Rarity

| Rarity | Count |
|---|---:|
| Common | 30 |
| Uncommon | 24 |
| Rare | 22 |
| Epic | 18 |
| Legendary | 16 |
| Mythic | 10 |
| **Total** | **120** |

### Common Jokers

| No. | ID | Name | Deck wide effect |
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
| 20 | `full_binder` | Full Binder | A complete fifty two slot active deck gains `+15%` output |
| 21 | `set_sampler` | Set Sampler | Each distinct Deck Set in a formation adds `+3%` output |
| 22 | `matching_set` | Matching Set | A formation using one Deck Set gains `+20%` output |
| 23 | `fresh_ink` | Fresh Ink | Normal Edition cards gain `+15%` output |
| 24 | `foil_fan` | Foil Fan | Foil cards gain an additional `+20%` output |
| 25 | `golden_rule` | Golden Rule | Golden cards gain an additional `+25%` Cash |
| 26 | `steel_support` | Steel Support | Steel cards gain an additional `+25%` Guard |
| 27 | `task_ticket` | Task Ticket | Active tasks grant `+10%` rewards |
| 28 | `friendly_rival` | Friendly Rival | Friend Clash participation grants `+10%` Duel Tokens, subject to anti farming limits |
| 29 | `repeat_reader` | Repeat Reader | The first repeated rank each round gains `+15%` output |
| 30 | `last_card` | Last Card | The last committed card gains `+20%` output |

### Uncommon Jokers

| No. | ID | Name | Deck wide effect |
|---:|---|---|---|
| 31 | `balanced_scales` | Balanced Scales | Equal red and black cards in a formation gain `+30%` output |
| 32 | `odd_fellow` | Odd Fellow | Odd numbered cards gain `+35%` Power |
| 33 | `even_temper` | Even Temper | Even numbered cards gain `+35%` Cash |
| 34 | `royal_chorus` | Royal Chorus | A formation containing Jack, Queen, and King gains `+75%` output |
| 35 | `ace_circuit` | Ace Circuit | Each Ace scored this round adds `+10%` draw speed, capped at `30%` |
| 36 | `suit_bridge` | Suit Bridge | A formation containing both colors gains `+35%` Power |
| 37 | `theme_tourist` | Theme Tourist | Each distinct Deck Set in the active deck adds `+0.5%` Cash, capped at `20%` |
| 38 | `set_purist` | Set Purist | At least thirty nine active cards from one Deck Set grants `+40%` output |
| 39 | `grade_school` | Grade School | Cards below Grade B gain `+60%` Grade experience |
| 40 | `honor_roll` | Honor Roll | Grade A or higher cards gain `+25%` output |
| 41 | `edition_collector` | Edition Collector | Each distinct Edition in a formation adds `+12%` output |
| 42 | `golden_dividend` | Golden Dividend | Golden Edition's Cash effect is `30%` stronger |
| 43 | `steel_nerve` | Steel Nerve | Steel cards convert `20%` of their Guard bonus into Power |
| 44 | `foil_cascade` | Foil Cascade | Each Foil card in a formation adds `+8%` output, capped at `40%` |
| 45 | `lucky_draw` | Lucky Draw | The first successful formation each round grants `+15%` pack progress |
| 46 | `task_runner` | Task Runner | Completing a task extends current timed boosts by thirty seconds |
| 47 | `perfect_timing` | Perfect Timing | A valid submission in the final half second gains `+60%` Power; never required by a task |
| 48 | `early_spark` | Early Spark | The first formation each round gains `1.50x` output |
| 49 | `second_wind` | Second Wind | The first failed formation each round does not reset the streak |
| 50 | `spare_hand` | Spare Hand | Adds one redraw per round |
| 51 | `deep_pockets` | Deep Pockets | Each unspent redraw adds `+10%` round end Cash |
| 52 | `binder_bonus` | Binder Bonus | Each completed base Deck Set adds `+0.5%` output, capped at `25%` |
| 53 | `rivalry_badge` | Rivalry Badge | Friend Clash rewards gain `+25%` once per opponent per hour |
| 54 | `streak_keeper` | Streak Keeper | The first miss reduces the streak by one instead of resetting it |

### Rare Jokers

| No. | ID | Name | Deck wide effect |
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
| 68 | `soloist` | Soloist | A one card formation gains `2.50x` Power |
| 69 | `empty_seat` | Empty Seat | Empty active deck slots each generate one passive Cash unit, capped at twenty slots |
| 70 | `collectors_eye` | Collector's Eye | The first new catalog discovery each session grants bonus Arcana Dust, capped daily |
| 71 | `arcana_adept` | Arcana Adept | Arcana task rewards gain `+50%` |
| 72 | `duelists_tempo` | Duelist's Tempo | Each Friend Clash round win adds `+10%` next round output, stacking four times |
| 73 | `boss_breaker` | Boss Breaker | Boss Table Power gains `+60%` |
| 74 | `mixed_signal` | Mixed Signal | Four or more Deck Sets in a formation gains `1.60x` output |
| 75 | `pure_signal` | Pure Signal | One Deck Set across a formation gains `1.60x` output |
| 76 | `pack_hunter` | Pack Hunter | Every tenth successful formation grants one Deck Pack shard |

### Epic Jokers

| No. | ID | Name | Deck wide effect |
|---:|---|---|---|
| 77 | `crown_engine` | Crown Engine | A ten through Ace Crown Run gains `2.00x` output |
| 78 | `endless_sequence` | Endless Sequence | A five card Sequence repeats its lowest card at `50%` output |
| 79 | `suit_collapse` | Suit Collapse | At round start, off suit cards count as the dominant suit for detection but lose `20%` output |
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

| No. | ID | Name | Deck wide effect |
|---:|---|---|---|
| 95 | `golden_sovereign` | Golden Sovereign | Twenty six Golden active cards gain `1.75x` Cash; all fifty two raises this to `2.00x` |
| 96 | `steel_colossus` | Steel Colossus | Steel Guard above the round target converts to Power at `50%` efficiency |
| 97 | `prismatic_regent` | Prismatic Regent | Prismatic cards count as every suit and raise a detected formation one reward band |
| 98 | `void_accountant` | Void Accountant | Void cards retain half their solo bonus when used in larger formations |
| 99 | `set_monarch` | Set Monarch | All fifty two active cards from one Deck Set grants `3.00x` output |
| 100 | `mosaic_crown` | Mosaic Crown | Every ten distinct active Deck Sets adds `+25%` output, capped at `100%` |
| 101 | `grade_ascendant` | Grade Ascendant | Each active LR card adds `+2%` output, capped at `104%` |
| 102 | `perfect_copy` | Perfect Copy | The first card in a formation copies the strongest positive Edition multiplier present |
| 103 | `eternal_streak` | Eternal Streak | After reaching a streak of ten, the streak floor remains ten for that session |
| 104 | `joker_union` | Joker Union | Other equipped Jokers have numeric effects increased by `15%` |
| 105 | `arcana_master` | Arcana Master | Every Arcana use grants ten minutes of `+25%` active progress |
| 106 | `packstorm` | Packstorm | Every twenty fifth successful formation starts a personal three pack reward storm |
| 107 | `duel_crown` | Duel Crown | Friend Clash output gains `50%`; the first daily win grants one Joker Ticket |
| 108 | `boss_sigil` | Boss Sigil | Boss Table Power gains `2.00x` and cooperative rewards gain `25%` |
| 109 | `collection_emperor` | Collection Emperor | Each completed fifty two card Edition grid adds `+3%` output, capped at `60%` |
| 110 | `last_laugh` | Last Laugh | Below twenty five percent duel shield, Power gains `2.00x` |

### Mythic Jokers

| No. | ID | Name | Deck wide effect |
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

## Arcana

An Arcana Pack reveals three cards and lets the player choose one. Consuming an Arcana applies one deterministic action to one selected playing card. Selection happens after the Arcana is obtained, and an application never fails. Arcana affecting Edition unlock a selectable permanent form.

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
| 25 | `regrader` | The Regrader | Offers three Grade outcomes from the card's legal range; choose one, never lowering the current Grade |
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
| 33 | `voice` | The Voice | Offers three Traits for a card without one; choose one |
| 34 | `mask` | The Mask | Offers three replacement Traits; choose one |
| 35 | `oath` | The Oath | Locks the Trait during the next applicable reroll |
| 36 | `silence` | The Silence | Removes a Trait and refunds Trait Essence |

## Souls

Souls are endgame global build rules. A player may own all twelve but equip only one. Souls arrive after the core game is stable; they must not be required for early progression.

| No. | ID | Soul | Global effect |
|---:|---|---|---|
| 1 | `origin` | The Origin | Classic cards gain `2.00x` output; every missing active slot weakens the bonus by `2%` |
| 2 | `archive` | The Archive | New catalog discoveries grant double one time rewards and `+10%` permanent album reward progress |
| 3 | `mirror` | The Mirror | Copies the active Deck Set affinity of the largest represented set at `60%` strength |
| 4 | `forgeheart` | The Forgeheart | Positive Edition effects gain `25%`; Arcana Dust rewards lose `15%` |
| 5 | `crown_soul` | The Crown | Face cards and Aces gain `50%`, number cards lose `10%` |
| 6 | `compass` | The Compass | Daily tasks always include one goal suited to the active deck and grant `25%` more progress |
| 7 | `hourglass` | The Hourglass | Timed boosts last `50%` longer but are `15%` weaker |
| 8 | `gate` | The Gate | First completion of a task chain opens a personal bonus room with one earned pack |
| 9 | `bond` | The Bond | Cooperative contributions and friend rewards gain `50%`, subject to anti farming limits |
| 10 | `challenger` | The Challenger | Fair Friend Clash rating rewards gain `40%`; passive Cash loses `20%` |
| 11 | `titan_soul` | The Titan | Boss Power and Guard gain `75%`; solo Formation Rush Cash loses `10%` |
| 12 | `pinnacle` | The Pinnacle | When every active card is Grade LR, all output gains `3.00x` |

## Stable Identity Rules

- Store IDs such as `radioactive`, `golden`, and `pocket_ledger`, never display names.
- Never reuse a retired ID for different content.
- A balance patch changes configuration values, not inventory identity.
- A renamed display label leaves the stable ID unchanged.
- Every owned card, Joker, and Soul has a unique server generated instance ID and provenance record.
- Catalog definitions are versioned and validated for duplicate IDs, missing art, invalid references, and incorrect counts before publishing.
- Content can be disabled with configuration without deleting ownership data.

## Originality Boundary

The game may use standard playing card ranks and suits, which are generic building blocks, but all card frames, Deck Sets, names, art, sounds, interface, effects, writing, mascots, and branding must be original. Do not import Pokémon, anime characters, Balatro Jokers, Balatro card art, another game's pack design, logos, character names, or screenshots. The product should be recognizable because of its own Deck Sets and collection identity, not because it copies a protected franchise.
