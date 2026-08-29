# InfiniteCardCollector: Launch Foundation and Implementation Specification

This document defines the first public version that proves the complete vision without attempting to build all fifty two Deck Sets. It is written as an implementation contract for a Roblox Studio project.

The permanent destination is defined in [Final Product Vision](../general/product-vision.md). All fixed names and effects are defined in [Content Catalog](../general/content-catalog.md).

## Start Goal

Ship a polished, mobile friendly public foundation where a new player can:

1. Open a free pack within thirty seconds.
2. Begin filling a permanent fifty two slot deck from three original Deck Sets.
3. Play Formation Rush within two minutes.
4. Earn packs and boosts through four active tasks.
5. Improve cards with Grades, Power Tiers, Traits, and four Editions.
6. Collect and equip up to five of twenty four launch Jokers.
7. Earn and apply one of twelve launch Arcana to one card.
8. Inspect, lock, wishlist, and showcase cards.
9. Challenge a friend in the same server.
10. Trade safely after meeting eligibility requirements, provided the trade release gate passes.
11. Leave and return without losing progress, pending rewards, pity, or trade recovery state.

The release is successful if opening, improving, using, and showing cards is fun with only three Deck Sets. More Deck Sets do not fix a weak core loop.

## Launch Scope

### Included Content

| Content | Launch count | Included items |
|---|---:|---|
| Deck Sets | 3 | Classic, Radioactive, Astral |
| Base card identities | 156 | Three sets times fifty two ranks and suits |
| Editions | 4 | Normal, Foil, Golden, Steel |
| Permanent card forms | 624 | 156 identities times four Editions |
| Grades | 11 | F through LR |
| Power Tiers | 11 | Common through Zenith |
| Traits | 12 | Fortune through Social in the catalog |
| Jokers | 24 | Listed below |
| Arcana | 12 | Listed below |
| Souls | 0 public | Data contract reserved; first Souls are post launch |
| Formations | 12 | Entire foundation formation catalog |
| Active tasks | 4 | Suit Sorter, Sequence Bench, Arcana Trace, Grade Press |
| Multiplayer | 2 | Same server Friend Clash and direct trade |

### Launch Jokers

| Rarity | Count | Jokers |
|---|---:|---|
| Common | 8 | Pocket Ledger, Painted Pip, Paper Shield, Quick Shuffle, Red Ribbon, Black Thread, Number Cruncher, Full Binder |
| Uncommon | 5 | Balanced Scales, Royal Chorus, Set Purist, Golden Dividend, Streak Keeper |
| Rare | 4 | Full Spectrum, Set Architect, Fivefold, Arcana Adept |
| Epic | 3 | Crown Engine, Set Resonator, Overclock |
| Legendary | 2 | Joker Union, Packstorm |
| Mythic | 2 | House of Fifty Two, The Archivist |
| **Total** | **24** | Maximum five equipped |

### Launch Arcana

| Category | Arcana |
|---|---|
| Edition | The Polisher, The Treasury, The Forge |
| Suit | The Heart, The Gem, The Clover, The Spear |
| Face Rank | The Stair |
| Grade | The Examiner, The Regrader |
| Trait | The Voice, The Mask |

### Not in the First Public Version

- The remaining forty nine Deck Sets.
- Diamond through Unknown Editions.
- The remaining ninety six Jokers.
- The remaining twenty four Arcana.
- Souls and Soul Packs.
- Cooperative Boss Table.
- Cross server matchmaking.
- Cross server listings or an auction market.
- Crews, guilds, clans, or player built shops.
- Player to player currency transfer.
- Paid random gameplay packs.
- Story chapters, quests with dialogue trees, or a large open world.

These are data and architecture destinations, not launch blockers.

## Foundation Gameplay Loop

### First Session Timeline

| Target time | Player experience |
|---:|---|
| 0 to 30 seconds | Walk to the highlighted opening table and tear a free five card Starter Pack |
| 30 to 90 seconds | Inspect pulls, auto fill five valid deck slots, and learn that the deck has fifty two permanent slots |
| 1 to 2 minutes | Submit a guided Single and Twin in a short Formation Rush tutorial |
| 2 to 5 minutes | Complete Suit Sorter, earn a pack boost, and open a second pack |
| 5 to 10 minutes | Unlock the binder, receive the first Joker Pack, equip one Joker, and replay Formation Rush |
| 10 to 20 minutes | Unlock Arcana Trace, receive the first Arcana Pack, and transform one chosen card |
| 20 to 30 minutes | Choose a Radioactive or Astral target, see collection and wishlist goals, and challenge a nearby player |
| 45 to 90 minutes active | Expected range for filling all fifty two active slots, using early missing slot protection |
| 2 hours active and eligible | Trade tutorial and direct trading unlock |

The tutorial is embedded in normal actions. It should never trap the player in a long modal explanation. Every tutorial prompt can be dismissed, and the action remains discoverable later.

### Early Pack Protection

- The Starter Pack contains five unique Face Rank and Suit slots.
- Until twenty six active slots are filled, at least three of five Deck Set Pack cards target currently empty slots when enough empty slots exist.
- From twenty six through forty four filled slots, at least one of five targets an empty slot.
- At forty five or more filled slots, normal distribution and pity apply.
- Protection chooses an empty rank and suit slot first, then rolls the selected Deck Set version, Power Tier, starting Grade, and possible Trait.
- Protection does not guarantee a new catalog form if the player already owns another copy but has deliberately left the slot empty.
- A player may disable auto equip at any time. Auto equip never replaces a locked or manually chosen card.

### Reward Cadence Targets

- One visible micro reward every fifteen to thirty seconds.
- One pack, Joker, Arcana, Grade, or major deck decision every sixty to ninety seconds during onboarding.
- One basic Deck Set Pack approximately every two to four active minutes after onboarding.
- One Joker Pack approximately every ten to fifteen active minutes.
- One Arcana Pack approximately every eight to twelve active minutes when deliberately pursuing Arcana tasks.
- Passive play is approximately fifteen to twenty percent as efficient as ordinary active play.

These are balancing hypotheses. Analytics must measure actual time to reward rather than assuming the targets are correct.

## Launch Economy Configuration

All values live in one versioned server configuration module. Clients receive display copies and never decide prices or rewards.

### Starting Values

| Setting | Draft value |
|---|---:|
| Starting Cash | 0 |
| Free Starter Pack | 1 |
| Classic Deck Set Pack | 500 Cash |
| Radioactive Deck Set Pack | 800 Cash |
| Astral Deck Set Pack | 1,200 Cash |
| Joker Pack | 10 Joker Tickets |
| Arcana Pack | 100 Arcana Dust |
| Default offline cap | 4 hours |
| Default passive rate | 18% of normalized active baseline |
| Active deck size | 52 slots |
| Active Joker limit | 5 |
| Active Soul limit | 0 at launch, schema maximum 1 |
| Server size | 8 players initially |

### Phase 001 Calculation Tuning

The first executable configuration uses `catalogVersion = 1` and `configVersion = 1`. These are balance values rather than stable inventory identity.

- All three launch affinities use active deck thresholds of 13, 26, 39, and 52 cards with 5, 10, 15, and 25 percent strength.
- Sequence and Monosuit use `1.80x`, `2.80x`, and `4.00x` for three, four, and five submitted cards.
- Perfect Sum keeps its `2.50x` base and declares `perfect_sum_accuracy` as an explicit `1.10x` stackable bonus. If another matching formation has the stronger base, that base wins and the accuracy bonus still applies once.
- Trusted arithmetic uses checked integers and rational multipliers with half up rounding. A result above `999999999999999` fails closed before a trusted score is returned.
- Personal active boosts apply before server event boosts. Mode modifiers apply afterward, followed by named component caps.
- The same opponent can grant one full eligible social reward and two reduced rewards at 25 percent. The third repeat and later repeats grant no reward under the launch configuration.

The complete executable stage, cap, odds, pity, and reason contract is documented in [Technical Overview](../general/documentation.md) and verified by [Phase 001 Catalog and Calculation Tests](../test/phase-001-calculation-contracts.md).

### Currency Sources and Sinks

| Currency | Launch sources | Launch sinks |
|---|---|---|
| Cash | Formation Rush, Sequence Bench, passive table, offline return, goals | Three Deck Set Packs |
| Joker Tickets | Formation streak milestones, first daily Friend Clash, goals | Joker Packs |
| Arcana Dust | Arcana Trace, catalog discoveries, duplicate Arcana salvage | Arcana Packs |
| Grade Ink | Grade Press, successful card use, card salvage | Deterministic Grade progress |
| Trait Essence | Trait card salvage, goals | Trait reroll choices and removal |
| Duel Tokens | Reward eligible Friend Clashes | Duel cosmetics and a weekly earned pack |
| Ascension Fragments | Secret or higher pulls and eligible high Tier salvage | Future deterministic high Tier promotion |

Do not tune the economy by making every price exponential. New Deck Sets may cost more, but the active loop must still deliver frequent decisions. Currency caps, reward caps, and formatted display thresholds are configuration values.

## Pack Rules

### Deck Set Pack

- Cost: selected Deck Set's Cash price or one earned pack token.
- Contents: five playing card instances from that Deck Set.
- Choice: all five are granted; the player chooses what to equip or salvage afterward.
- Power Tier odds: use the eleven Tier table in the final vision.
- Starting Grade: primarily F through C at launch; higher initial Grades are a separate visible roll.
- Trait: a configured chance after Tier is selected; launch target is ten percent, with one Trait maximum.
- Edition: Normal on initial pack creation. Editions are unlocked with Arcana.
- Pity: saved before the opening animation can complete.

### Joker Pack

- Contents: three server rolled Joker offers.
- Player chooses exactly one.
- Draft slot rarity: Common `55%`, Uncommon `25%`, Rare `12%`, Epic `5%`, Legendary `2.5%`, Mythic `0.5%`.
- At least Epic in twenty packs without Epic or higher.
- At least Legendary in one hundred packs without Legendary or higher.
- Pending choice persists across disconnects and updates.

### Arcana Pack

- Contents: three server rolled Arcana offers.
- Player chooses exactly one.
- Early duplicate protection prefers an undiscovered basic Arcana until six different launch Arcana are discovered.
- Pending choice persists across disconnects and updates.
- Consuming the selected Arcana is a separate confirmed action.

### Pack Transaction State

Every pack has a unique operation ID and one of these states:

```text
created → contents_committed → revealed → claimed
```

- Currency is deducted and results are committed together in the server profile mutation.
- The client receives only committed contents.
- Disconnecting after `contents_committed` reopens the same result.
- Replaying a request ID returns the existing result and never creates another pack.
- Joker and Arcana offers remain `revealed` until a valid choice is committed.
- A catalog update preserves the original offered stable IDs until the player chooses.

## Formation Rush Launch Rules

### Round State

```text
idle → countdown → active → resolving → rewards → idle
```

The server stores the round ID, seed, ordered draw pile, hand, discard pile, redraw count, submitted cards, streak, timers, prompt, and accumulated reward. A request must include the current round ID and client request ID. A stale round ID is rejected without consuming cards.

### Hand and Draw

- Hand size: eight.
- Submission size: one to five.
- Used cards go to the discard pile.
- Empty active slots generate non scoring Blanks only if the deck cannot provide eight cards.
- When draw pile cannot refill the hand, discard pile reshuffles under the same server round state.
- One base redraw per round; Jokers may add redraws.
- A redraw discards selected cards and draws replacements. It does not create or destroy owned instances.

### Validation

The server rejects a submission when:

- The mode or round is not active.
- The request ID was already consumed with different data.
- A supplied card is not in the current server hand.
- A card appears twice.
- Submission count is outside one through five.
- The request arrives after the authoritative deadline plus configured latency tolerance.
- The player profile is not writable.
- The payload has invalid types, excessive depth, non finite numbers, or oversized strings.
- The per action rate limit is exceeded.

Rejected submissions return a stable error code and refreshed hand state. They do not trust or echo arbitrary client text.

## Four Launch Tasks

### Suit Sorter

Cards move across a short belt. The player sends each to Hearts, Diamonds, Clubs, or Spades. Correct sorting fills pack progress. Incorrect sorting reduces only the current combo. Touch targets occupy at least a comfortable thumb sized area and keyboard controls use four remappable keys.

### Sequence Bench

The player arranges three to five visible cards in ascending order. Ace is explicitly shown as high for launch. Correct sequences grant Cash and a timed Cash boost. The untimed accessibility mode uses fewer rewards but the same completion credit.

### Arcana Trace

The player taps large rune nodes in a shown order. Correct chains grant Arcana Dust. Reduced motion mode uses static connected shapes. The task does not require drawing a perfect line.

### Grade Press

A marker crosses broad F through LR zones. The player presses once to earn Grade Ink. Higher zones are smaller but a miss still grants minimum progress. There is no failure that destroys or downgrades a card.

### Task State and Anti Exploit Rules

- Server creates the task seed, target sequence, start time, and maximum possible result.
- Client reports discrete actions, not a final reward amount.
- Server checks action order, minimum plausible timing, maximum rate, and target membership.
- Suspiciously impossible input receives no reward and increments a server security signal.
- Lag tolerance is generous enough that ordinary mobile latency is not punished.
- Task boosts use absolute server timestamps and configured stacking caps.

## Launch Friend Clash

The public foundation includes same server invitations. Cross server matchmaking is deferred.

### Flow

```text
invite → accepted → loadout snapshot → five round match → result → capped reward
```

- Invitations expire after thirty seconds.
- Either player may decline without penalty.
- Loadouts lock for the current match only; inventory ownership does not lock.
- Each round presents the same public formation prompt.
- Hands are independently server shuffled. A later competitive update can add mirrored challenge hands.
- Best of five rounds; first to three wins.
- No stakes, wagers, or transferred inventory.
- Disconnect before round two cancels rewards. Disconnect afterward counts as a match loss after a reconnect grace period.
- Repeated rewards against the same opponent diminish and stop for the configured hour.
- Private rematches continue with no economy reward after the cap.

### Modes

- Power mode uses the player's full collection strength.
- Fair mode normalizes Grade, Power Tier, and Edition numeric multipliers but preserves card choices, formation logic, Traits, and Jokers that can be fairly evaluated.
- Launch leaderboards should track Fair rating only after matchmaking volume is sufficient. Same server friend games alone do not create a meaningful global rating.

## Launch Trading

Trading is implemented during the foundation but controlled by `TradeEnabled`. Public launch requires every trade release test to pass. If it does not, publish the rest of the game with the booth marked as coming soon rather than risking inventory loss or duplication.

### Eligibility Defaults

| Rule | Draft value |
|---|---:|
| Roblox account age | At least 7 days |
| Active play time | At least 2 hours |
| Trade tutorial | Completed |
| Profile mode | Writable and fully loaded |
| Newly obtained item lock | 10 minutes |
| Trade request cooldown | 5 seconds |
| Offer item limit per side | 12 |
| Final countdown | 5 seconds |
| Recent receipt history | 100 trades |

All values are server configuration. No client supplied age, play time, ownership, or value is trusted.

### Trade State Machine

```text
requested
  → accepted
  → editing
  → a_ready or b_ready
  → both_ready
  → countdown
  → prepared
  → settling
  → committed
  → completed

terminal alternatives: declined, cancelled, expired, rejected, rolled_back
```

### Trade Invariants

- One instance ID has one effective owner.
- An item in `prepared` or `settling` cannot be equipped, changed, salvaged, packed, or traded elsewhere.
- Any offer edit clears both Ready flags and invalidates the countdown.
- The exact offer hash shown during countdown must match the prepared journal.
- Settlement is idempotent by trade ID and step number.
- A committed journal is never rolled back to create a duplicate.
- A prepared but uncommitted journal is reconciled before either profile becomes writable.
- A client disconnect cannot cancel a prepared trade.
- Trade completion never depends on both clients acknowledging animation.

### Persistent Trade Journal

```luau
type TradeJournal = {
    tradeId: string,
    schemaVersion: number,
    state: string,
    playerA: number,
    playerB: number,
    offerA: {string},
    offerB: {string},
    offerHash: string,
    preparedAt: number?,
    committedAt: number?,
    settlementA: string,
    settlementB: string,
    errorCode: string?,
    version: number,
}
```

The journal contains IDs and state, not arbitrary player text. Profile mutations store the processed trade ID so retrying the same journal cannot repeat a transfer.

### Trade Recovery Cases

| Failure | Required recovery |
|---|---|
| One player leaves while editing | Cancel and unlock both offers |
| One player leaves during countdown | Cancel unless journal is already prepared |
| Server stops after prepared | Next join or recovery worker resumes settlement |
| Player A settled, Player B not settled | Keep transferred items unusable and complete Player B idempotently |
| DataStore request throttled | Retry with backoff; preserve prepared journal |
| Item no longer matches prepared ownership | Reject before prepared; quarantine and log if detected afterward |
| Duplicate request or stale client UI | Return current server state without mutation |

## Project Structure

The game is implemented in typed Luau with strict mode for shared types, services, controllers, configuration, and pure gameplay modules.

```text
ReplicatedStorage/
  Shared/
    Catalogs/
      DeckSets.luau
      Editions.luau
      Grades.luau
      PowerTiers.luau
      Traits.luau
      Jokers.luau
      Arcana.luau
      Souls.luau
      Formations.luau
    Config/
      Economy.luau
      Features.luau
      Limits.luau
    Math/
      CardMath.luau
      FormationDetector.luau
      NumberFormat.luau
    Net/
      Actions.luau
      Errors.luau
      Schemas.luau
    Types/
      CatalogTypes.luau
      ProfileTypes.luau
      RuntimeTypes.luau
  Remotes/
    ClientAction
    ServerMessage

ServerScriptService/
  Server/
    Services/
      AnalyticsService.luau
      PolicyService.luau
      ProfileService.luau
      TransactionService.luau
      InventoryService.luau
      CollectionService.luau
      RandomService.luau
      PackService.luau
      DeckService.luau
      ProgressionService.luau
      ArcanaService.luau
      JokerService.luau
      FormationService.luau
      TaskService.luau
      BoostService.luau
      DuelService.luau
      TradeService.luau
      LeaderboardService.luau
      SecurityService.luau
    Bootstrap.server.luau

ServerStorage/
  Assets/
    CardFrames/
    PackModels/
    JokerProps/

StarterPlayer/
  StarterPlayerScripts/
    Client/
      Controllers/
        BootstrapController.luau
        TableController.luau
        BinderController.luau
        PackController.luau
        DeckController.luau
        FormationController.luau
        TaskController.luau
        ArcanaController.luau
        JokerController.luau
        DuelController.luau
        TradeController.luau
        InspectController.luau
        SettingsController.luau
      ClientBootstrap.client.luau

StarterGui/
  App/
    Hud/
    OpeningTable/
    Binder/
    DeckBuilder/
    CardInspect/
    PackReveal/
    ArcanaLab/
    JokerStage/
    FormationRush/
    Tasks/
    FriendClash/
    Trade/
    Settings/
```

Catalog modules contain data only. Pure math modules cannot access DataStore, remotes, UI, or mutable player state. Services own server mutations. Controllers render server state and send validated intent.

## Server Initialization Order

1. Load and validate every catalog and configuration table.
2. Fail closed in Studio if counts, IDs, references, or effect handlers are invalid.
3. Create remotes and register action schemas.
4. Start Analytics, Policy, Security, Profile, and Transaction services.
5. Start Inventory, Collection, Random, Pack, Deck, Progression, Arcana, and Joker services.
6. Start Formation, Task, Boost, Duel, Trade, and Leaderboard services.
7. Connect `PlayerAdded`, `PlayerRemoving`, remote routing, autosave, and shutdown handling.
8. Accept player actions only after that player's profile, recovery journal, policy state, and bootstrap snapshot are ready.

If a required service fails to initialize, the server must not accept economy actions. Players receive a short maintenance message and can safely leave.

## Stable IDs and Slot Keys

- Deck Set IDs: `classic`, `radioactive`, `astral`.
- Face Rank IDs: `2` through `10`, `jack`, `queen`, `king`, `ace`.
- Suit IDs: `hearts`, `diamonds`, `clubs`, `spades`.
- Slot key: `<faceRankId>:<suitId>`, for example `10:spades`.
- Base identity key: `<deckSetId>:<slotKey>`.
- Form key: `<baseIdentityKey>:<editionId>`.
- Instance IDs: server generated opaque IDs with enough entropy and no player supplied component used for trust.

Display names may change. Stable IDs, saved schema fields, analytics reason IDs, and transaction IDs do not change without a migration.

## Profile Schema Version 1

```luau
type CurrencyState = {
    cash: number,
    jokerTickets: number,
    arcanaDust: number,
    gradeInk: number,
    traitEssence: number,
    duelTokens: number,
    ascensionFragments: number,
    soulFragments: number,
}

type CardInstance = {
    uid: string,
    deckSetId: string,
    faceRankId: string,
    suitId: string,
    selectedEditionId: string,
    unlockedEditionBits: number,
    gradeId: string,
    gradeXp: number,
    powerTierId: string,
    traitId: string?,
    traitLocked: boolean,
    createdAt: number,
    originType: string,
    originId: string,
    favorite: boolean,
    tradeLockId: string?,
    tradeLockedUntil: number?,
    version: number,
}

type JokerInstance = {
    uid: string,
    jokerId: string,
    xp: number,
    level: number,
    bound: boolean,
    favorite: boolean,
    tradeLockId: string?,
    createdAt: number,
    originId: string,
    version: number,
}

type PendingPack = {
    operationId: string,
    packTypeId: string,
    catalogVersion: number,
    state: string,
    offers: {any},
    createdAt: number,
}

type PlayerProfileV1 = {
    schemaVersion: number,
    revision: number,
    createdAt: number,
    lastSeenAt: number,
    activeSeconds: number,
    currencies: CurrencyState,
    cards: {[string]: CardInstance},
    jokers: {[string]: JokerInstance},
    arcanaStacks: {[string]: number},
    souls: {[string]: any},
    activeDeck: {[string]: string},
    activeJokers: {string},
    activeSoulUid: string?,
    discoveredForms: {[string]: {number}},
    discoveredJokers: {[string]: boolean},
    discoveredArcana: {[string]: boolean},
    discoveredSouls: {[string]: boolean},
    bestRecords: {[string]: any},
    pity: {[string]: number},
    pendingPacks: {[string]: PendingPack},
    boosts: {[string]: any},
    dailyState: any,
    tutorial: {[string]: boolean},
    tradeHistory: {string},
    processedOperations: {[string]: number},
    settings: any,
    moderation: any,
}
```

The actual saved field names may be compact, but the typed domain model should remain readable. Serialization and domain types are separate modules so storage optimization does not leak into gameplay services.

### Collection Representation

Each Deck Set and Edition grid needs fifty two bits. Store the bits as two safe twenty six bit integers or an equivalent compact byte encoding. Do not store 624 launch booleans as verbose keyed tables if the profile serializer can encode them compactly. Current ownership is derived from card instances; discovery remains permanent.

### Size Strategy

Roblox currently limits a data store key to `4,194,304` bytes. Launch profiles should warn at `1,000,000` encoded bytes and block publication if realistic stress fixtures exceed `1,500,000` bytes. The limit is documented in [Roblox data store limits](https://create.roblox.com/docs/cloud-services/data-stores/error-codes-and-limits).

Before the inventory could approach the launch ceiling, migrate behind `ProfileStore` and `InventoryStore` interfaces to a core profile plus versioned inventory shards. The end design should partition card instances by a stable hash of Deck Set ID, use a manifest in the core profile, and journal every multi key mutation. Do not wait until a live profile is near the platform limit to design that migration.

## Persistence Contract

- Use DataStore `UpdateAsync` for profile acquisition and writes rather than blind overwrite.
- Acquire a session token containing place version, job ID, and heartbeat time.
- Refuse a second writable session while a healthy lock exists.
- Expired locks require a recovery read and journal reconciliation before reassignment.
- Mark profiles dirty in memory and batch ordinary saves approximately every sixty seconds.
- Save immediately after purchases, pack result commitment, Arcana application, Grade promotion, and prepared or committed trades through the transaction layer.
- Retry throttling and transient failures with bounded exponential backoff and jitter.
- Never retry a non idempotent mutation without the same operation ID.
- Use `BindToClose` to stop new mutations, finish or journal active transactions, save dirty profiles, and release locks within the shutdown window.
- On repeated save failure, put the profile into read only safe mode. Do not let the player continue earning progress that cannot be persisted.
- Keep rolling schema migrations pure, versioned, repeatable, and fixture tested.

Roblox distinguishes permanent DataStore from fast, temporary MemoryStore. MemoryStore can coordinate ephemeral server presence, queues, or short locks but cannot be the source of permanent ownership. See [Data stores](https://create.roblox.com/docs/cloud-services/data-stores) and [Memory stores](https://create.roblox.com/docs/cloud-services/memory-stores).

## Transaction Service

Every meaningful economy mutation goes through one operation envelope:

```luau
type Operation = {
    operationId: string,
    userId: number,
    kind: string,
    requestedAt: number,
    expectedProfileRevision: number?,
    payload: any,
}
```

The service checks whether `operationId` was processed, validates preconditions, applies the mutation once, records a compact receipt, increments profile revision, and returns the saved result. Pack opens, choices, Arcana use, Grade upgrades, salvage, deck edits, and reward claims all use this boundary. Trade has a two profile journal in addition to per profile operation receipts.

## Network Contract

Use one client to server `RemoteEvent` named `ClientAction` and one server to client `RemoteEvent` named `ServerMessage`, with a typed action registry. This reduces accidental unvalidated remotes while preserving action specific rate limits.

```luau
type ClientEnvelope = {
    action: string,
    requestId: string,
    payload: any,
}

type ServerEnvelope = {
    kind: string,
    requestId: string?,
    payload: any,
}
```

### Launch Client Actions

| Action ID | Intent |
|---|---|
| `bootstrap.request` | Request paged initial state after server marks the profile ready |
| `pack.open` | Purchase or consume one pack token |
| `pack.choose` | Select one saved Joker or Arcana offer |
| `deck.equip_card` | Place an owned card in its rank and suit slot |
| `deck.unequip_card` | Empty a slot |
| `joker.equip` | Equip an owned Joker in one of five slots |
| `joker.unequip` | Remove an active Joker |
| `arcana.apply` | Confirm one Arcana action on one eligible card |
| `grade.apply_ink` | Spend Grade Ink on one card |
| `inventory.set_flags` | Change favorite, lock, or wishlist state within allowed fields |
| `formation.start` | Start a round when eligible |
| `formation.redraw` | Redraw selected server hand cards |
| `formation.submit` | Submit one to five current hand instance IDs |
| `task.start` | Start a server generated task |
| `task.action` | Submit one discrete task interaction |
| `duel.invite` | Invite an eligible same server player |
| `duel.respond` | Accept or decline a current invite |
| `duel.submit` | Submit a current duel formation |
| `trade.request` | Invite an eligible same server player to trade |
| `trade.respond` | Accept or decline a current request |
| `trade.set_offer` | Add or remove one eligible instance |
| `trade.set_ready` | Set readiness for the exact current offer revision |
| `trade.cancel` | Cancel before prepared state |
| `binder.page` | Request one validated collection or inventory page |

Every action has a maximum payload size, exact type schema, state precondition, permission check, and token bucket rate limit. Unknown fields can be rejected during development and ignored only when a deliberate forward compatibility rule exists.

The server sends complete authoritative state transitions or narrow patches. It does not send private inventory or hidden hand data to unrelated players. Roblox's [remote event documentation](https://create.roblox.com/docs/scripting/events/remote) and [client server security guidance](https://create.roblox.com/docs/scripting/security/client-server-boundary) should be treated as implementation references.

## Service Ownership

| Service | Owns | Must not own |
|---|---|---|
| ProfileService | Session locks, load, save, migration, profile lifecycle | Gameplay calculations |
| TransactionService | Idempotent mutations and receipts | UI animation |
| InventoryService | Instance lookup, creation, locks, salvage eligibility | Random roll decisions |
| CollectionService | Discovery bits, best records, completion rewards | Current inventory authority |
| RandomService | Server RNG, odds, pity evaluation, reproducible result records | Client animation timing |
| PackService | Pack purchase, committed results, pending choices | Card score calculation |
| DeckService | Fifty two slot validation and active loadout | Inventory creation |
| ProgressionService | Grade XP, Grade Ink, Trait Essence, Tier promotion | Pack purchases |
| ArcanaService | Eligibility, previews, confirmed one card applications | UI target selection |
| JokerService | Five slot rules, effect registration, Joker XP | Formation ownership |
| FormationService | Draw state, formation detection, authoritative scoring | Permanent profile saves directly |
| TaskService | Task seeds, action validation, reward outcomes | Client input rendering |
| BoostService | Timed boost stacking and expiration | Currency storage |
| DuelService | Invitations, loadout snapshots, rounds, reward caps | Trades or wagers |
| TradeService | Offer state, persistent journals, reconciliation | Real money value |
| LeaderboardService | Sanitized ordered values and seasonal boards | Source inventory state |
| SecurityService | Rate limits, anomaly signals, quarantine decisions | Silent permanent bans from one signal |
| AnalyticsService | Sanitized event emission and funnels | Raw private chat or arbitrary payloads |

Services communicate through typed methods and domain events, not by reaching into one another's tables.

## Joker Effect Architecture

Do not implement one hundred twenty Jokers as scattered `if jokerId == ...` statements.

Each Joker definition references an effect handler and configuration:

```luau
type JokerDefinition = {
    id: string,
    displayName: string,
    rarityId: string,
    effectHandlerId: string,
    params: {[string]: number | string | boolean},
    conflicts: {string}?,
    launchEnabled: boolean,
}
```

Effect handlers subscribe to explicit calculation stages such as:

- `beforeFormationDetection`
- `afterFormationDetected`
- `beforeCardContribution`
- `afterCardContribution`
- `beforeFormationMultiplier`
- `afterFormationReward`
- `onRoundStart`
- `onFormationSuccess`
- `onFormationFailure`
- `onTaskComplete`
- `onDuelRoundResult`

The scorer applies stages in one documented order and writes a calculation trace used by the inspect panel and tests. Conflicting rules declare precedence. Multipliers use explicit additive or multiplicative groups so order is deterministic.

## Card Rendering Architecture

One reusable renderer builds a card from layered assets:

1. Deck Set base illustration and frame.
2. Suit icon and color treatment.
3. Face Rank text and corner pips.
4. Edition material and shader substitute.
5. Grade badge.
6. Power Tier aura.
7. Trait symbol.
8. Lock, favorite, new, wishlist, and trade status overlays.

The same data drives 2D binder cards, 3D table cards, pack reveals, inspect views, trade panels, and thumbnails. Lower graphics settings replace particles and animated gradients with static frames. Never render every binder card as a live 3D viewport at once; virtualize pages and recycle card components.

## Required User Interfaces

### HUD

Shows Cash, focused secondary currency, pack progress, active boost, current task, and one next goal. It must not show every currency at once on a phone.

### Opening Table

Shows available packs, price or token, exact contents, published odds, pity progress, and opening controls. The paid currency icon must never appear on an earned random pack unless policy compliant paid randomness is deliberately added later.

### Binder

Supports Deck Set, Edition, owned, missing, duplicate, Grade, Tier, Trait, wishlist, favorite, and tradable filters. Pages are virtualized and loaded in chunks. Each identity shows discovered and currently owned state separately.

### Deck Builder

Displays the fifty two slot grid, empty slots, active versions, suggested upgrades, affinity totals, five Joker slots, and a server generated output preview. Equipping requires an owned instance matching the slot key.

### Card Inspect

Shows canonical name, large art, all multipliers, form unlocks, Grade XP, provenance, trade lock, owned count, best record, set progress, and actions. The calculation panel explains why a card produced its last result.

### Arcana Lab

Shows Arcana inventory, eligible targets, before and after preview, permanent unlock wording, one target limit, and final confirmation. Locked or traded items are ineligible.

### Trade

Shows two mirrored offer grids, exact item details, only copy warnings, offer revision, Ready state, countdown, cancel state, connection state, and receipt. Offer changes must be obvious and reset readiness.

### Settings

Includes master volume, music, effects, reveal sound, reduced motion, reduced flash, lower graphics, pack animation speed, auto reveal, auto equip, trade requests, duel requests, rare pull announcements, color assistance, UI scale, and tutorial replay.

## Analytics Plan

Use server emitted events and Roblox's [analytics event types](https://create.roblox.com/docs/production/analytics/event-types). Never include raw player entered text, authentication data, full inventory dumps, or another player's private state.

### Funnel Events

| Event | Key properties |
|---|---|
| `onboarding_step` | Step ID, elapsed seconds, completed or skipped |
| `pack_opened` | Pack ID, source reason, pity before, elapsed session time |
| `pack_choice` | Pack ID, chosen stable ID, owned before |
| `card_obtained` | Deck Set, Tier, Grade, has Trait, new form, source reason |
| `deck_slot_changed` | Filled slots, Deck Set, upgrade or empty |
| `formation_submitted` | Formation ID, card count, valid, output bands, streak |
| `formation_round_end` | Submissions, successes, reward bands, duration |
| `task_completed` | Task ID, accuracy band, duration, reward band |
| `arcana_applied` | Arcana ID, target category, new discovery, success code |
| `joker_equipped` | Joker ID, slot, active Joker count |
| `duel_result` | Mode, rounds, disconnect, reward eligible |
| `trade_state` | State, item counts, duration, error code, never item names from user text |
| `currency_flow` | Currency ID, integer delta, reason ID, balance band |
| `profile_error` | Stage, stable error code, retry count, read only entered |
| `security_signal` | Signal ID, action ID, severity band, no exploit instructions |

### Launch Metrics

These are decision thresholds, not promises of popularity:

| Metric | Initial healthy target |
|---|---:|
| First pack completion | More than `85%` of joins |
| First pack median time | Less than `30 seconds` |
| First Formation Rush completion | More than `70%` of joins |
| First Formation Rush median time | Less than `2 minutes` |
| Ten minute first session retention | More than `55%` |
| Tutorial completion | More than `70%` |
| Pack opening interruption or failure | Less than `0.1%` |
| Successful save sessions | More than `99.9%` |
| Crash free sessions | More than `99.5%` |
| Confirmed item duplication | Exactly `0` |
| Trade settlement requiring recovery | Measured and less than `0.1%` after release |

Day one, day seven, playtime, play days, co play, and monetization should be compared with Roblox's Similar Experiences benchmarks in the live analytics dashboard rather than guessed in advance.

## Security Requirements

- Never trust card IDs, rewards, prices, Grade XP, Tier, Trait, task results, timestamps, hand contents, trade ownership, or opponent state from a client.
- Reject `NaN`, infinity, negative counts, fractional integers, oversized arrays, unknown enum IDs, and strings over configured limits.
- Rate limit each action independently and add a global burst limit.
- Validate player state and spatial context when an action requires being at a station.
- Treat client animation completion as cosmetic only.
- Use opaque request IDs and processed operation receipts for retry safety, not as security secrets.
- Keep unreleased catalog entries server disabled even if a modified client knows their IDs.
- Quarantine impossible inventory or currency states for review; do not silently erase them.
- Log stable reason codes and sanitized values, not secrets or raw DataStore payloads.
- Keep admin actions on a separate permission checked server path with complete audit receipts.
- Test every remote with wrong types, missing fields, stale state, duplicate calls, high frequency, and another player's instance IDs.

Roblox's guidance emphasizes server validation and rate limiting at the client server boundary. Use [client server boundary](https://create.roblox.com/docs/scripting/security/client-server-boundary) and [security tactics](https://create.roblox.com/docs/scripting/security/security-tactics) during implementation and review.

## Performance Budgets

- Target smooth play on common mobile devices before increasing server size above eight.
- Keep authoritative formation detection pure and bounded to an eight card hand and at most five submitted cards.
- Pool 3D cards, pack pieces, particles, and sound emitters.
- Render only visible binder entries and reuse UI cells.
- Load the active deck and nearby social summaries first; page full inventory on demand.
- Preload only the opening table, current Deck Set frame, basic sounds, and tutorial UI at join.
- Cap rare reveal particles and provide static low graphics replacements.
- Avoid per frame server loops for passive income. Calculate from timestamps on a controlled interval.
- Batch analytics and saves within platform guidance. Do not write DataStore on every click.
- Profile serialized size, remote payload sizes, task script time, UI frame rate, and peak memory on real mobile presets before public release.

## Implementation Order

### Milestone 1: Contracts and Pure Systems

1. Create stable IDs and typed catalogs for the launch content.
2. Add a catalog validator for counts, unique IDs, valid references, and effect handlers.
3. Implement Face Rank values, slot keys, Edition, Grade, Tier, Trait, and affinity math.
4. Implement and unit test all twelve formation detectors.
5. Implement deterministic score stages and calculation traces.
6. Add feature, economy, odds, limits, and balance configuration modules.

Exit gate: all pure tests pass, catalogs contain exactly the launch counts, and the ultimate example can be represented without special cases.

### Milestone 2: Profile, Inventory, and Vertical Slice

1. Implement ProfileService, session locks, schema version one, retry policy, and read only safe mode.
2. Implement TransactionService with operation IDs and receipts.
3. Implement InventoryService, CollectionService, DeckService, and compact discovery grids.
4. Create one Classic card frame, one pack, and the layered renderer.
5. Build Starter Pack opening, five committed cards, deck auto fill, binder page, and save or rejoin.
6. Build a single guided Formation Rush round.

Exit gate: a new test account can open, equip, score, leave during each step, rejoin, and recover the exact committed state.

### Milestone 3: Three Deck Content and Progression

1. Complete Classic, Radioactive, and Astral card assets.
2. Add Normal, Foil, Golden, and Steel visual layers.
3. Add all eleven Grades, eleven Power Tiers, and twelve launch Traits.
4. Add Power Tier odds, pity, pending packs, and reveal presentation.
5. Add Grade XP, Grade Ink, salvage rules, locks, favorites, wishlists, and best records.
6. Add the twelve launch Arcana and Arcana Lab.
7. Add twenty four launch Jokers and the five slot Joker Stage.

Exit gate: all 624 launch forms are reachable, Grade never regresses, Arcana affects one target and preserves prior forms, pity survives rejoin, and every Joker produces an explainable calculation trace.

### Milestone 4: Active Loop and Retention

1. Complete sixty second Formation Rush and all twelve formations.
2. Add Suit Sorter, Sequence Bench, Arcana Trace, and Grade Press.
3. Add BoostService, offline calculation, daily goals, and collection rewards.
4. Build the complete first session tutorial and next goal presentation.
5. Add card inspection, showcase podium, rare reveal announcements, and settings.
6. Emit onboarding, economy, formation, task, pack, Arcana, and Joker analytics.

Exit gate: first session acceptance timing is achievable on touch, mouse, keyboard, and controller, and active progress is at least five times the passive baseline in test fixtures.

### Milestone 5: Friend Clash and Trading

1. Add same server invitations and loadout snapshots.
2. Implement best of five Power and Fair Friend Clash.
3. Add reward caps and disconnect recovery.
4. Implement trade eligibility, item locks, two sided offer UI, readiness reset, and countdown.
5. Implement persistent trade journals, idempotent settlement, receipts, and reconciliation.
6. Run disconnect, shutdown, throttle, stale state, duplicate request, and malicious client tests at every trade state.

Exit gate: Friend Clash cannot transfer inventory, and no tested trade path duplicates or loses an item. `TradeEnabled` remains false until this gate passes.

### Milestone 6: Hardening and Soft Launch

1. Complete mobile layout, controller navigation, reduced motion, reduced flash, low graphics, and UI scaling.
2. Add policy checks, guaranteed cosmetic products, purchase receipts, and restore behavior.
3. Load test eight player servers with pack openings, tasks, clashes, and trades.
4. Test DataStore throttling, server shutdown, session collision, schema migration, and read only recovery.
5. Test every remote with invalid and hostile payload fixtures.
6. Configure dashboards, feature flags, rollback configuration, and moderation tools.
7. Publish to a small audience, inspect funnels and failures, fix decisive drop offs, then widen access.

Exit gate: every public launch gate below is satisfied.

## Verification Matrix

### Automated Pure Tests

- Exactly three launch Deck Sets and fifty two identities per set.
- Exactly four enabled Editions and 624 possible launch forms.
- Exactly eleven Grades, eleven Power Tiers, twelve Traits, twenty four Jokers, and twelve Arcana.
- All stable IDs unique and every referenced effect handler exists.
- Every formation accepts valid hands and rejects near misses, duplicates, and invalid ranks.
- Score order is stable regardless of table iteration order.
- Every Joker interaction has a fixed expected calculation trace.
- Odds total exactly one hundred percent using integer weight units.
- Pity awards at the exact threshold and resets only after the qualifying result is committed.
- Grade XP reaches each threshold once and never decreases.
- Arcana consumes once, affects one target, and preserves prior Edition unlocks.
- Duplicate operation IDs return the first result without a second mutation.
- Every profile migration is repeatable and preserves fixture ownership.

### Studio Integration Tests

Roblox Studio supports client and server testing modes; use multi client sessions for all social systems. See [Studio testing modes](https://create.roblox.com/docs/studio/testing-modes).

- New account tutorial from blank profile.
- Existing profile rejoin at every tutorial step.
- Two clients invite, accept, play, disconnect, and rematch.
- Two clients edit offers, ready, change offers, cancel, disconnect, and complete trades.
- Server closes at every pack, Arcana, Grade, reward, and trade transaction state.
- Simulated DataStore throttle and transient failures.
- Old schema fixtures migrate to current schema.
- Duplicate and out of order remote requests.
- Another player's card instance supplied to each inventory action.
- Mobile, tablet, controller, keyboard, and low graphics UI paths.
- Reduced motion and reduced flash reveal paths.

### Trade Failure Injection

For every transition from `requested` through `completed`:

1. Stop client A.
2. Stop client B.
3. Stop the server.
4. Fail the next profile write.
5. Repeat the last remote request.
6. Reorder two valid client requests.
7. Attempt to equip, salvage, Grade, Arcana modify, or retrade a locked item.
8. Rejoin both players and reconcile.
9. Assert exactly one effective owner for every instance ID.
10. Assert both receipts agree with the committed journal.

Any duplication, disappearance, unlocked prepared item, or irreconcilable journal blocks trading release.

### Manual Experience Review

- A player understands the fifty two slots without reading documentation.
- The first pack is interactive and skippable.
- Normal, Foil, Golden, Steel, Grade, Tier, and Trait are visually distinguishable.
- A rare reveal is exciting with sound off and reduced motion on.
- The next useful action is visible after every reward screen.
- Formation selection works with one thumb.
- No required text is clipped on small mobile screens.
- The binder remains responsive with large generated fixture inventories.
- Trade details remain readable and unchanged during final countdown.
- No screen uses poker chips, betting, casino, dealer, jackpot, wager, or cash out presentation.

## Public Launch Gates

The game is ready for public release only when:

- The first pack and first Formation Rush funnels work from a blank production profile.
- No known profile loss, item duplication, infinite reward, or currency underflow exists.
- Pack results, pity, Arcana, Grades, salvage, and purchase receipts are idempotent.
- Server validation and rate limits cover every client action.
- Eight player mobile and server performance is acceptable.
- Reduced motion, reduced flash, controller, touch, and keyboard paths work.
- All random gameplay packs are earned and their odds are visible.
- Guaranteed cosmetic purchases grant exactly once and restore correctly.
- Analytics, error dashboards, feature flags, and rollback values are active.
- Trading passes the complete release test or remains visibly disabled.
- Original art and sound review finds no copied franchise assets or protected characters.
- Community Standards and experience metadata review is complete.
- A private soft launch shows no decisive onboarding failure that can be fixed before wider release.

## Feature Flags and Emergency Controls

The server configuration must be able to disable without republishing:

- Individual Deck Sets, packs, Jokers, Arcana, Traits, and formations.
- Pack purchase while preserving pending reveals.
- Salvage.
- Arcana application.
- Grade upgrades.
- Passive and offline rewards.
- Friend Clash rewards while preserving private play.
- Trading and new trade requests while allowing prepared journal recovery.
- Rare pull announcements.
- Individual monetization products.

Disabling content hides new acquisition but never deletes existing ownership. A disabled effect receives a documented neutral fallback. Emergency settings are server fetched, versioned, cached with a safe default, and included in diagnostics.

## Common Failure Handling

| Failure | Player behavior | Operator evidence |
|---|---|---|
| Profile cannot load | Show retry and safe leave; do not create a blank overwrite | Stable load error, DataStore status, retry count |
| Profile loses writable session | Enter read only safe mode and stop rewards | Lock owner, heartbeat age, profile revision |
| Pack purchase save fails | Keep Cash and do not reveal a new result | Operation ID and failure stage |
| Pack committed, client disconnects | Reopen exact pending result on rejoin | Pending pack state and result hash |
| Arcana mutation fails | Do not consume Arcana or change target | Operation receipt and before revision |
| Leaderboard write fails | Preserve profile result and retry asynchronously | Board ID and normalized score |
| Trade journal stalls | Lock involved items and reconcile before writable play | Trade ID, state, per player settlement step |
| Catalog reference missing | Disable affected content and fail validation before public server accepts actions | Catalog version and missing ID |
| Client sends impossible input | Reject, refresh narrow state, rate limit, and record a security signal | Action ID, stable reason, severity |

## Post Launch Decision Rules

Do not immediately build all forty nine remaining Deck Sets.

Add the first update only after answering:

- Do players complete the first pack and Formation Rush?
- Which activity creates the longest healthy play sessions?
- Do players understand Edition versus Deck Set?
- Are players using multiple Joker builds?
- Is deck completion satisfying or exhausting?
- Are Friend Clashes played voluntarily after their first reward?
- Do trades settle without recovery spikes, scams, or inventory support cases?
- Which missing card or Deck Set goals create return sessions?
- Does mobile performance remain stable during rare reveals and busy tables?

If the core is healthy, the first expansion adds two Deck Sets, the cooperative Boss Table, three Souls, a small Joker and Arcana group, and fixes based on measured friction. If the core is unhealthy, improve the first ten minutes before adding catalog volume.

## Immediate Coding Checklist

Start with this exact order:

1. Create the typed stable ID catalogs for Classic, Radioactive, Astral, Normal, Foil, Golden, Steel, all Grades, all Tiers, twelve Traits, twenty four Jokers, twelve Arcana, and twelve formations.
2. Write the catalog validator and pure formation tests before building card art.
3. Implement the canonical `CardInstance`, slot key, active deck, score stages, and calculation trace.
4. Implement version one profile loading, session locking, transaction receipts, a five card Starter Pack, and save or rejoin recovery.
5. Build one reusable layered card renderer and one Classic card visual across the opening table, binder, deck slot, and Formation Rush.
6. Complete the vertical slice with one pack, one guided formation round, one reward, and a verified rejoin.
7. Add Radioactive and Astral as data and assets through the same renderer.
8. Continue through the implementation milestones without adding endgame content early.

That vertical slice is the first concrete goal. It proves the data model, persistence, card presentation, and active loop that every future Deck Set depends on.
