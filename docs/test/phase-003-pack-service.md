# Phase 003 Deck Set Pack Test Procedure

## Scope

This procedure covers the first earned Deck Set Pack service boundary in `P003-TASK-007`. It verifies the Classic, Radioactive, and Astral pack definitions, server selected identities, five card grants, configured Power Tier rolls, persistent pity, early missing slot protection, provenance, pending result records, insufficient currency rejection, and direct replay protection.

It does not claim the Joker Pack, Arcana Pack, saved three offer choices, opening table state machine, progression, salvage, or client pack selection. Those remain later Phase 003 tasks.

## Deterministic Test

Run the repository suite from the project root:

```console
lune run test
```

`P003-TEST-008-deckset-pack-service` constructs a blank profile and the production service dependencies. It opens a Classic pack with 5,000 Cash, checks the exact five card result and 500 Cash deduction, verifies unique slot keys, records the committed pending result, confirms the configured Power Tier roll count, checks pity before and after the commit, validates pack provenance on each owned card, and runs profile validation.

The same operation ID is then rejected without changing the canonical profile. An Astral open with no balance is rejected with `pack.insufficient_currency` and leaves the rejected profile byte stable. A Radioactive open confirms the second earned Deck Set family uses its own identity set.

The service derives prices from `LaunchConfig.economy.packPrices`, requires all three Deck Sets to be enabled, and delegates weighted rolls and early protection to the versioned `RollContract`.

## Required Follow Up

The complete Phase 003 gate must add boundary rolls for every Tier, pity threshold transitions, profiles with partially filled active decks, failure injection at card creation and pending save, transaction replay after receipt compaction, disconnect and shutdown reopen, catalog version retention, and local and isolated Studio recovery for all three pack families.
