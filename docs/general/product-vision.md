# InfiniteCardCollector: Final Product Vision

`InfiniteCardCollector` is the owner-selected public title. Before publication, the name, logo, icon, and related public assets must pass trademark, Roblox experience search, originality, and provenance review.

## Product Statement

InfiniteCardCollector is an active Roblox card collection game built around a permanent fifty two slot deck. Players begin with an empty deck, tear open earned packs, choose which version occupies each rank and suit slot, transform individual cards with Arcana, equip five global Jokers, and use the deck in rapid formation challenges, cooperative bosses, and friend battles.

The collection can eventually contain more than thirty seven thousand permanent card forms without requiring thirty seven thousand unrelated illustrations. The depth comes from fifty two original Deck Sets, fourteen Editions, eleven Grades, eleven Power Tiers, twenty four Traits, one hundred twenty Jokers, thirty six Arcana, and twelve Souls.

The experience must feel good before the number becomes large. Pack tearing, card inspection, deck decisions, quick tasks, formations, trades, and social reveals are the game. Passive income is only a background benefit.

The complete named content catalog is in [Card Game Content Catalog](content-catalog.md).

## Design Pillars

### Collectible at a Glance

A player should understand why a pull is special without opening a statistics panel. Deck Set changes the illustration and frame. Edition changes the material and effect. Grade changes the border badge. Power Tier changes the aura and reveal. Trait adds one recognizable symbol. Rare combinations receive a staged reveal and a shareable inspection card.

### Active First, Passive Second

The strongest progress comes from playing one to three minute activities. A passive table and capped offline earnings let players return to something useful, but active play should be approximately five to eight times more efficient than waiting.

### Permanent Progress

Arcana unlocks forms instead of replacing them. Grade never decreases through ordinary progression. Pity meters never reset without giving their reward. Collection rewards never require destroying the only owned copy of an item. Balance changes preserve identities and ownership.

### Short Decisions, Long Ambition

Each moment asks for a small decision: which cards to submit, which Joker to equip, which card receives Golden, whether to keep or trade a duplicate. Long term goals include finishing a Deck Set, completing an Edition grid, reaching LR, collecting every Joker, building a specialized deck, and climbing fair or power leaderboards.

### Social Without Wagering

Players inspect, compare, trade, cooperate, and battle. They never stake cards or currency on a result. A loss costs time in the match, not inventory.

### Original Identity

The game uses standard card ranks and suits but no Pokémon, anime characters, Balatro artwork, Balatro Joker names, proprietary cards, logos, interfaces, sounds, or characters. Original Deck Sets are the recognizable cast. The goal is for a player to say they pulled a Radioactive Ace or finished a Golden Astral grid, not that they found a disguised character from another franchise.

## The Player's Permanent Deck

Every account owns one active deck with exactly fifty two identity slots:

`13 Face Ranks × 4 Suits = 52 slots`

A slot can be empty. It can hold only one selected card instance at a time. A player may own many versions of the same slot, such as Classic Ace of Spades, Radioactive Ace of Spades, and Astral Ace of Spades, but chooses one for the active deck.

The player also equips:

- Up to five Jokers, each applying a deck wide rule.
- Up to one Soul after Souls are introduced.
- One saved visual loadout and, later, multiple convenience loadouts.

Empty slots become Blank cards when a mode needs a minimum hand size. Blanks have no rank, suit, output, Tier, Trait, or Edition. They make the first minutes playable without pretending the player's collection is complete.

## Card Identity and the Ultimate Pull

The canonical display order is:

`[Edition] [Grade] [Power Tier] [Face Rank] of [Deck Set] [Suit], [Trait] trait`

The target showcase example is:

`Golden LR Infernal Ace of Radioactive Spades, Fortune trait`

That name describes seven independent axes. Golden can be applied to a Radioactive card or a Classic card. Infernal does not mean Radioactive. LR is trained quality. Fortune is a personal specialty. This separation is what makes a familiar fifty two card deck support a very large collection.

## Complete Collection Goal

The end state contains:

- 2,704 base identities from fifty two Deck Sets.
- 37,856 permanent forms after fourteen Editions are counted.
- 120 Jokers across six Joker Rarities.
- 36 Arcana discoveries.
- 12 Souls.
- Best observed Grade, Power Tier, and Trait records for every base identity.

The album has four views:

1. **Deck Set grid:** Each page is a familiar fifty two card grid.
2. **Edition grid:** Each Deck Set can be filtered by Normal, Golden, Steel, and every other Edition.
3. **Quality records:** Shows the best Grade, Power Tier, Trait, and output ever owned for each identity.
4. **Special collections:** Jokers, Arcana, Souls, event stamps, and mastery rewards.

Collection percentage is based on permanent catalog forms, not every random combination. A traded away form remains discovered in the album but no longer counts as currently owned. Both values are displayed.

## Core Session Loop

```text
choose an activity
        ↓
play a 45 to 90 second active challenge
        ↓
earn cash, pack progress, tickets, dust, ink, or a timed boost
        ↓
open a pack and make a choice
        ↓
improve the active deck, binder, joker build, or trade inventory
        ↓
test the change in formation rush, a boss, or a friend clash
        ↓
claim mastery and collection goals, then repeat
```

A player should encounter a meaningful reward or decision every sixty to ninety seconds. The game should not require holding a button while a number rises.

## Main Active Mode: Formation Rush

Formation Rush is the repeatable center of the game. A round lasts sixty seconds.

1. The server shuffles the active deck and draws eight cards. Blanks fill missing positions only when required.
2. The player selects one to five cards.
3. The server detects every valid Card Formation and previews the best result.
4. The player submits. The server validates ownership, hand state, timing, Joker rules, and score.
5. Used cards enter a discard pile. The hand refills.
6. Successful submissions build a streak and activity meter. Invalid or failed submissions consume time and may affect the streak.
7. The round converts Cash, Power, Guard, pack progress, task progress, and Grade experience into rewards.

There are no chips, bets, dealers, wagers, roulette devices, or cash out language. Roblox's current Community Standards prohibit simulated gambling, so the game uses original formation challenges rather than poker or blackjack presentation. See [Roblox Community Standards](https://en.help.roblox.com/hc/en-us/articles/203313410-Roblox-Community-Standards).

### Formation Catalog

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
| Perfect Sum | Hits the round's displayed target value | `2.50x` plus accuracy bonus |

These names, visuals, and reward rules must be presented as InfiniteCardCollector mechanics. A formation can satisfy multiple patterns, but the server selects the highest base reward and then applies explicitly stackable bonuses. It never multiplies every detected pattern together.

### Scoring Model

Each scoring card begins with a Face Rank value. Jack is 11, Queen is 12, King is 13, and Ace is 14.

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

Cash, Power, Guard, pack progress, and Grade experience use separate components so Golden can specialize in Cash and Steel can specialize in Guard. The client may preview a result, but only the server calculates the authoritative reward.

Numerical order and caps are part of the configuration contract. During the first release, total saved currency and score values should remain below `10^15`. Before endgame multipliers approach unsafe integer precision in Luau doubles, the economy moves to a deterministic mantissa and exponent number representation. Leaderboards compare normalized numbers rather than formatted strings.

## Active Task Stations

Task Stations provide a reason to leave the passive table and change what the player is doing. A station lasts forty five to ninety seconds and rewards a ten to fifteen minute boost plus a focused currency.

| Station | Interaction | Primary reward | Boost |
|---|---|---|---|
| Suit Sorter | Drag visible cards into four large suit lanes | Deck Pack progress | Faster pack earning |
| Sequence Bench | Arrange shuffled cards into ascending runs | Cash | Cash multiplier |
| Arcana Trace | Tap large connected symbols in the shown order | Arcana Dust | Arcana progress |
| Grade Press | Stop a moving marker inside broad quality zones | Grade Ink | Grade experience |
| Trait Lab | Match card conditions to useful Traits | Trait Essence | Trait discovery |

Tasks use generous hit targets, keyboard, touch, controller, and reduced motion alternatives. Speed improves reward, but every completed task grants something. Missing a precision window does not erase progress.

Boost rules are simple:

- A stronger boost replaces a weaker boost of the same type.
- Repeating the same boost extends duration up to a configured cap.
- Offline time pauses active only boosts.
- Server event boosts multiply after personal boosts and have a published cap.
- Boost state is saved with an absolute expiration time and validated by the server.

## Packs and Reveal Experience

### Deck Set Pack

Contains five playing cards from the selected Deck Set. The Face Rank and Suit, Power Tier, initial Grade, and possible Trait are server rolled. The first packs use missing slot protection so a new player can build a functional deck quickly.

### Joker Pack

Reveals three Jokers and lets the player choose one. Owned duplicates are shown before selection. A player can keep a duplicate for trading or bind it for Joker experience.

### Arcana Pack

Reveals three Arcana and lets the player choose one. Arcana are stored in inventory stacks. Using one is a second, deliberate action on one selected playing card.

### Soul Pack

Reveals two Souls and lets the player choose one. Soul Packs are endgame rewards and do not appear in the foundation release.

### Reveal Sequence

The opening should be tactile and fast:

1. Pick up the pack.
2. Tear or swipe the wrapper.
3. Pull cards one at a time or reveal all.
4. Use color, sound, shake, and aura to indicate Power Tier before the name appears.
5. Let the player tilt and inspect a special card.
6. Show `NEW`, `UPGRADE`, `DUPLICATE`, or `WISHLIST` clearly.
7. Offer Equip, Binder, Lock, Wishlist, or Continue.

Animation skip is always available after the first tutorial. Reduced flash and reduced motion settings replace intense effects without hiding rarity.

## Draft Earned Pack Odds

These are transparent starting targets for each playing card slot in an earned Deck Set Pack. They sum to one hundred percent and remain server configuration.

| Power Tier | Chance per card slot |
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

Draft protection rules:

- At least Rare within twenty card slots without Rare or higher.
- At least Legendary within one hundred card slots without Legendary or higher.
- At least Mythic within five hundred card slots without Mythic or higher.
- Secret and higher rolls produce Ascension Fragments. Fragments provide a slow deterministic path toward a chosen high Tier upgrade.
- Pity is tracked by pack family, saved before the reveal is acknowledged, and cannot be reset by leaving.
- Published odds show the base chance, current pity state, guarantees, and whether a temporary event changes anything.

No Robux purchased random content is planned for launch. If paid random items or trading of paid items are ever introduced, implementation must query the player's policy information, disclose odds, retain purchase records, and block prohibited transactions according to Roblox's [paid random item guidance](https://create.roblox.com/docs/production/monetization/paid-random-items) and [`PolicyService`](https://create.roblox.com/docs/reference/engine/classes/PolicyService/GetPolicyInfoForPlayerAsync). The safer product direction is to keep gameplay packs earned and sell guaranteed cosmetics.

## Arcana Transformation

Arcana is the long term form collection system.

Example:

1. The player owns a Radioactive Ten of Spades.
2. The player earns `The Treasury` from an Arcana Pack.
3. The Arcana Lab shows exactly one target, the cost, the resulting Golden form, and a confirmation.
4. The server consumes one `The Treasury` and permanently unlocks Golden for that identity.
5. Normal Radioactive Ten of Spades remains selectable.
6. The player can now use Golden Radioactive Ten of Spades in the active deck.

A complete Golden Radioactive Deck Set requires fifty two separate Golden unlocks. There is no single item that instantly converts the entire set. This creates a visible, understandable collection chase without deleting progress.

Suit and Face Rank Arcana also unlock identities rather than mutating the source out of existence. This prevents accidental destruction, keeps collection math stable, and makes every Arcana use recoverable from a transaction log.

## Grade, Tier, Trait, and Duplicate Progression

### Grade

Grade is trained. Successful use grants experience. Grade Ink can accelerate a chosen card. Grade promotion is deterministic and cannot fail. LR is the final Grade and multiplies the card by fourteen.

### Power Tier

Power Tier is rolled when an instance is created. Tier Arcana can reroll or improve it without lowering the current result. High Tier cards are exciting trade objects, but a long deterministic Ascension path prevents permanent bad luck.

### Trait

Traits give a card a specialty. Trait Arcana offers choices instead of secretly replacing a useful Trait. Locked and favorited cards cannot be changed until deliberately unlocked.

### Duplicates

After receiving a duplicate, the player chooses one action:

- Keep it as a separate instance.
- Lock it for collection or trading.
- Equip it if it is stronger than the current slot.
- Bind it to the same Joker for Joker experience.
- Salvage it for Grade Ink, Trait Essence, Arcana Dust, or Ascension Fragments according to item type and rarity.

The game never auto salvages a new best result, a favorite, a wishlist match, an item in a trade, or the last currently owned copy.

## Deck Set Affinity and Mastery

Each Deck Set has two progression systems.

**Affinity** is based on how many active cards use that Deck Set. Suggested thresholds are thirteen, twenty six, thirty nine, and fifty two cards. The bonuses reinforce the affinity listed in the content catalog.

**Mastery** is permanent experience earned by actively scoring that Deck Set. Mastery unlocks pack cosmetics, binder pages, titles, a showcase pose, a small non multiplying utility perk, and finally a Deck Set completion aura. Mastery rewards should be prestigious without forcing one build to dominate every mode.

## Friend Clash

Friend Clash is a best of five simultaneous card battle. Each round gives both players the same public formation prompt and time limit. Submitted formations create Power and Guard. Power above the opponent's Guard removes shield. The first player to win three rounds wins the match.

Two queues serve different motivations:

- **Power Clash:** Uses owned Grade, Power Tier, Editions, Traits, affinities, and Jokers. It measures collection strength.
- **Fair Clash:** Normalizes Grade, Power Tier, and Edition multipliers while preserving the player's card identities, formation choices, and Joker rule interactions. It measures play and deck construction.

Friend Clash has no stake, entry wager, item transfer, or winner take all currency. Rewards use daily and same opponent caps to stop alternate account farming. Private friend challenges can be replayed without rewards.

## Cooperative Boss Table

A server wide Boss Table gives players a shared target. Players enter short Formation Rush windows and contribute Power while Guard protects the group from boss attacks. Boss patterns ask for suits, ranks, Deck Sets, or formation types, making collection breadth useful.

Contribution rewards have participation thresholds and diminishing repeated rewards. The boss cannot be defeated solely by passive output. The server shows individual contribution, team milestones, remaining time, and the next mechanic. Bosses reward earned packs, cosmetics, mastery items, and Soul Fragments.

## Passive and Offline Progress

Every equipped active card contributes a small passive table value. Passive output uses only a controlled fraction of active potential and does not trigger Formation, Trait, Joker, Arcana, duel, or boss effects unless explicitly marked.

Offline rules:

- Default cap: four hours.
- Expected rate: approximately fifteen to twenty percent of an average active player's Cash rate.
- Offline reward includes Cash and a small amount of basic pack progress only.
- No offline Power Tier rolls, Arcana applications, trades, Grade promotions, or leaderboard duel rating.
- The server calculates elapsed time from trusted timestamps and applies versioned caps.
- The return screen shows duration, rate, cap, and exact reward.

Offline progress gives players a reason to return. It must not make staying in game with an unattended client the optimal strategy.

## Social Spaces and Interactive Presentation

The hub is a compact card workshop, not a line of tycoon droppers. It contains:

- A personal opening table with physical packs and cards.
- A Binder wall that other players can inspect.
- A Card Grading hall with promotion ceremonies.
- An Arcana Lab for one card transformations.
- A Joker Stage showing the five active Jokers as animated props.
- Trade booths with visible participants and locked offer panels.
- Friend Clash tables that spectators can watch without seeing hidden hands.
- A cooperative Boss Table.
- Showcase podiums for a favorite card and completed Deck Set.
- Task Stations spaced closely enough that mobile players do not spend minutes walking.

Rare pull announcements are opt out, use item names only, and never reveal private account information. Inspection cards support reactions and wishlist buttons. Any player entered text must use Roblox filtering; launch trading should avoid custom notes entirely. See [Roblox chat filtering guidance](https://create.roblox.com/docs/chat/guidelines).

## Trading System

Trading is a core social feature, but it stays disabled behind a server feature flag until it survives duplication, disconnect, storage failure, and exploit testing.

### Tradable Items

- Playing card instances.
- Joker instances or unbound Joker copies.
- Arcana inventory items.
- Soul instances after Souls release.

Cash, Grade Ink, Arcana Dust, Trait Essence, Duel Tokens, mastery, boosts, starter grants, quest grants, bound Jokers, and protected promotional items are not transferable. Robux value is never displayed. The game does not support real money trading.

### Eligibility and Protection

- Suggested unlock: seven day account age, two hours of active play, completed trade tutorial, and verified saved profile.
- Newly obtained items have a short trade lock so rollback and purchase states settle.
- Favorite, equipped, grading, Arcana target, and already locked items cannot enter an offer.
- Both sides see item art, exact properties, ownership count, collection status, and an approximate game value band.
- A warning appears when a player offers a much rarer item or their only owned copy.
- Every edit clears both Ready states.
- Final acceptance has a visible five second countdown.
- Both players receive a permanent in game receipt and recent trade history.
- Reporting a trade references the immutable receipt, not a screenshot.

### Server Settlement

Roblox data stores do not provide one atomic transaction spanning two player profile keys. The trade therefore uses a persistent journal and idempotent settlement:

```text
requested
  → validated
  → items locked
  → both ready
  → countdown complete
  → journal prepared
  → items moved idempotently
  → journal committed
  → profiles saved
  → items unlocked and receipts issued
```

If a player disconnects before `prepared`, the trade cancels and unlocks. If a server stops after `prepared`, reconciliation reads the journal and either completes the exact transfer once or restores the exact original ownership. Repeating a settlement step with the same trade ID must never duplicate an item. Permanent state uses DataStore, while MemoryStore may coordinate temporary cross server presence but is never the ownership source of truth. Roblox documents these stores separately in [Data stores](https://create.roblox.com/docs/cloud-services/data-stores), [Memory stores](https://create.roblox.com/docs/cloud-services/memory-stores), and [Data stores versus memory stores](https://create.roblox.com/docs/cloud-services/data-stores-vs-memory-stores).

### Future Market

A cross server listing market is not part of the first public release. It becomes a separate update only after direct trades have stable ledgers, moderation tools, price history, listing expiration, taxes, recovery, and abuse controls. A listing service must use escrowed item instances and cannot depend on a player's live server.

## Economy

### Currencies

| Currency | Main sources | Main uses | Tradable |
|---|---|---|---|
| Cash | Formations, tasks, offline table | Deck Set Packs and basic upgrades | No |
| Joker Tickets | Formation streaks, bosses, daily goals | Joker Packs | No |
| Arcana Dust | Arcana tasks, discoveries, salvage | Arcana Packs | No |
| Grade Ink | Active card use, Grade tasks, salvage | Deterministic Grade progress | No |
| Trait Essence | Trait tasks and trait salvage | Trait choices and removal | No |
| Duel Tokens | Rewarded Friend Clashes | Duel cosmetics and earned packs | No |
| Soul Fragments | Bosses and endgame mastery | Soul Packs | No |
| Ascension Fragments | High Tier pulls, events, high Tier salvage | Deterministic high Tier improvement | No |

Currency rewards and costs are integer configuration values. Every source and sink emits an analytics event with previous balance, delta, reason ID, and resulting balance. Client requests never supply a trusted reward amount or price.

### Economy Protections

- Daily reward caps apply only to repeatable social farming, not normal solo play.
- Same opponent rewards diminish quickly.
- Pack prices use a controlled curve and never grow from the player's displayed wealth alone.
- Newly released Deck Sets have a published price path, not secretly worse odds.
- Seasonal content cannot invalidate owned permanent cards.
- Balance patches are versioned, and unusual currency deltas are logged.
- Leaderboards use seasonal categories where inflation would otherwise make permanent placement impossible.

## Retention and Live Operations

The game should create reasons to return without punishing absence.

### Daily

- Three short tasks with one free reroll.
- One featured formation and one featured Deck Set.
- First Friend Clash and first Boss Table bonuses.
- A return reward based on capped offline output.
- A daily wishlist target with a small active progress bonus, never improved random odds without disclosure.

### Weekly

- A cooperative boss rotation.
- A collection page challenge.
- A formation score board with a normalized Fair category.
- A server Packstorm event schedule.
- One cosmetic mastery reward path.

### Long Term

- Base Deck Set completion.
- Edition grids such as all fifty two Golden Radioactive cards.
- Grade LR goals.
- Joker collection and Joker mastery.
- Souls and endgame builds.
- All time collection records and seasonal active records.

Missing a day does not reset a valuable streak. Daily tasks bank for a limited time, and returning players receive catch up goals instead of a permanent disadvantage.

## Leaderboards

Separate boards prevent one number from deciding the entire game:

- Permanent Forms Discovered.
- Permanent Forms Currently Owned.
- Deck Set Mastery.
- Best Card Output.
- Formation Rush seasonal score.
- Boss contribution seasonal score.
- Fair Clash rating.
- Power Clash rating.
- Total Cash earned, shown as a prestige statistic rather than the main skill board.

Boards exclude flagged or quarantined profiles and use server generated values. Ties display shared rank where supported. Top rewards are cosmetic, titles, table decorations, and inspect effects rather than exclusive power.

## Ethical Monetization

The launch monetization plan sells guaranteed presentation and convenience, not random power:

- Card backs and sleeves.
- Binder covers, page materials, and sorting themes.
- Personal table skins.
- Pack opening animations and reveal effects.
- Emotes, inspect poses, nameplates, and chat free reactions.
- Extra saved deck loadout slots.
- Private servers.
- Cosmetic season track after retention is proven.

Do not sell Power Tier odds, hidden luck, leaderboard power, trade currency, inventory recovery, or a way to erase another player's progress. Avoid paid random packs. If a product includes both cosmetic and gameplay content, its exact guaranteed contents must be shown before purchase.

## Discovery and Popularity Strategy

No design can guarantee a large audience. The foundation should be optimized for the behaviors Roblox says discovery evaluates, including qualified play through rate, playtime, play days, spending, and intentional co play. The current overview is in [Roblox discovery documentation](https://create.roblox.com/docs/production/promotion/discovery).

The practical strategy is:

1. Show a pack tear and a visually rare card in the first thirty seconds.
2. Start the first Formation Rush within two minutes.
3. Deliver a deck improvement in the first five minutes.
4. Make the next clear goal visible on the table and in the binder.
5. Give friends a useful activity within the first session.
6. Make every rare pull easy to inspect and share inside Roblox.
7. Update only after analytics show where players stop, not merely because a calendar says to add content.

Thumbnail and icon tests should emphasize one original high value card, a visible pack, and a readable action. They should not use protected characters or imitate another game's thumbnail composition.

## Technical Product Boundaries

The server owns inventory, RNG, pack contents, scoring, rewards, Grade progress, Arcana use, Joker effects, tasks, boosts, trades, leaderboards, purchases, and policy decisions. Clients send intent and render results. Roblox recommends validating remote context, type, structure, value, permission, and rate on the server; see [client server boundary guidance](https://create.roblox.com/docs/scripting/security/client-server-boundary) and [security tactics](https://create.roblox.com/docs/scripting/security/security-tactics).

Static content is data driven. Stable IDs reference Deck Sets, Editions, Grades, Power Tiers, Traits, Jokers, Arcana, Souls, and formations. Adding a Deck Set should add configuration and assets, not duplicate service logic.

Permanent profiles use DataStore `UpdateAsync`, session ownership, schema versions, retries, and migrations. The profile must remain comfortably under Roblox's current `4,194,304` byte per key limit by storing IDs, instances, compact flags, and sparse collection data instead of copied catalog text. See [Data store limits](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits).

Analytics records onboarding, session, economy, progression, pack, formation, task, duel, trade, and error funnels. Roblox provides custom and economy event patterns in its [analytics event documentation](https://create.roblox.com/docs/production/analytics/event-types).

## Accessibility and Device Support

- Every primary action works with touch, mouse, keyboard, and controller.
- Important rarity information uses text and symbols in addition to color.
- Reduced motion, reduced flash, mute reveal sounds, and skip animation settings are available.
- Timing tasks use broad zones and an untimed alternative.
- Text scales for small mobile screens without hiding confirmation details.
- Trade confirmations never rely on color alone.
- Card tilt is decorative and never required to read statistics.
- Low graphics mode disables expensive particles and animated materials while preserving rarity labels.

## Expansion Sequence Toward the End Goal

### Foundation Release

Three Deck Sets, four Editions, all Grades and Power Tiers, twelve Traits, twenty four Jokers, twelve Arcana, Formation Rush, task stations, the binder, passive return progress, Friend Clash, and tested same server trading.

### First Healthy Update

Only after onboarding, retention, storage, and exploit metrics are healthy: add two Deck Sets, the Boss Table, three Souls, more formations, and targeted quality of life based on observed friction.

### Collection Expansion

Release Deck Sets in small themed groups. Each group adds a mastery path, pack identity, affinity, cosmetics, and one event. Do not dump forty nine unfinished Deck Sets into the game.

### Social Expansion

Add spectator polish, cooperative seasons, clubs or crews, better wishlists, and only then consider an escrowed cross server market.

### Endgame Expansion

Complete all fifty two Deck Sets, fourteen Editions, one hundred twenty Jokers, thirty six Arcana, twelve Souls, endgame bosses, Edition grid rewards, and normalized seasonal leaderboards.

## Definition of the Final Vision

The end vision is achieved when:

- All fifty two original Deck Sets contain all fifty two Face Rank and Suit identities.
- All fourteen Editions can be permanently unlocked one card at a time.
- The album correctly tracks 37,856 forms without requiring impossible random combinations.
- All eleven Grades and eleven Power Tiers are meaningful and readable.
- All twenty four Traits, one hundred twenty Jokers, thirty six Arcana, and twelve Souls work as cataloged.
- Formation Rush remains the fastest core progress path.
- Friend Clash, Boss Table, tasks, trading, inspection, and showcases are reliable social activities.
- Trading cannot duplicate or lose an item under tested disconnect and storage failure scenarios.
- Passive and offline systems complement play instead of replacing it.
- The economy has deterministic paths, visible odds, useful sinks, and no paid random power requirement.
- Mobile, controller, keyboard, reduced motion, and low graphics players can complete every required activity.
- The game has its own recognizable art direction and does not depend on protected franchises.

This is the destination. The first release should prove the fun of opening, choosing, transforming, forming, and showing cards with only three Deck Sets.
