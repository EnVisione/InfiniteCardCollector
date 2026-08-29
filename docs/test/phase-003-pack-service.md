# Phase 003 Deck Set Pack Test Procedure

## Scope

This procedure covers the earned Deck Set Pack and three offer pack service boundaries in `P003-TASK-007` and `P003-TASK-008`. It verifies the Classic, Radioactive, and Astral pack definitions, server selected identities, five card grants, configured Power Tier rolls, persistent pity, early missing slot protection, provenance, card classifications, pending result records, insufficient currency rejection, Joker rarity odds, Arcana item odds, three unique saved offers, one choice grant, and direct replay protection.

The client opening and reveal state machine is covered by [the Phase 003 pack reveal procedure](phase-003-pack-reveal.md). Progression, salvage, and responsive presentation remain later Phase 003 tasks.

## Deterministic Test

Run the repository suite from the project root:

```console
lune run test
```

`P003-TEST-008-deckset-pack-service` constructs a blank profile and the production service dependencies. It opens a Classic pack with 5,000 Cash, checks the exact five card result and 500 Cash deduction, verifies unique slot keys, records the committed pending result, confirms the configured Power Tier roll count, checks pity before and after the commit, validates pack provenance on each owned card, and runs profile validation. `P003-TEST-009-offer-pack-service` opens a Joker pack and an Arcana pack with deterministic random sources, checks the disclosed odds and three unique offers, validates the saved committed offer state, rejects an invalid choice without mutation, grants exactly the selected Joker or Arcana stack, validates the claimed state, and rejects a second choice as a replay conflict.

The same operation ID is then rejected without changing the canonical profile. An Astral open with no balance is rejected with `pack.insufficient_currency` and leaves the rejected profile byte stable. A Radioactive open confirms the second earned Deck Set family uses its own identity set. A classification array is persisted with the pending card result and accepts repeated `new` entries.

The service derives prices from `LaunchConfig.economy.packPrices`, requires all three Deck Sets to be enabled, and delegates weighted rolls and early protection to the versioned `RollContract`.

## Required Follow Up

The complete Phase 003 gate must add boundary rolls for every Tier, pity threshold transitions, profiles with partially filled active decks, failure injection at card creation and pending save, transaction replay after receipt compaction, disconnect and shutdown reopen, catalog version retention, and local and isolated Studio recovery for all three pack families.
