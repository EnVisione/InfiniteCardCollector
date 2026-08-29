# Phase 003 Deck Set Pack Service Evidence

## Current Result

The current Phase 003 branch implements server-authoritative earned pack services for Classic, Radioactive, and Astral Deck Sets, plus Joker and Arcana offer packs. Deck Set opening selects five unique base identity slots, rolls each card's Power Tier through the versioned weighted and pity contract, deducts the configured Cash price inside the enclosing transaction, creates cards with immutable pack provenance, and stores a committed pending result reference. Joker opening records three rarity-rolled offers with disclosed odds and persistent pity. Arcana opening records three unique item offers with disclosed item weights and prefers undiscovered Arcana until six different Arcana are discovered. Both offer families save original offer IDs and grant exactly one selected Joker or Arcana stack through the durable choice route.

The service rejects unknown packs, invalid operation IDs, duplicate pending operation IDs, and insufficient currency. Transaction replay remains owned by `TransactionService`; the direct service boundary also rejects a pending operation ID without a second mutation. The runtime route accepts the three earned pack IDs while preserving the free `classic_starter` path.

## Deterministic Evidence

The repository suite passes 61 tests with 0 failures. The `P003-TEST-008-deckset-pack-service` fixture covers the five card result, price deduction, unique slots, configured Tier roll count, pity state, pack provenance, profile validation, duplicate operation rejection, insufficient currency no mutation, and Radioactive identity selection. The `P003-TEST-009-offer-pack-service` fixture covers disclosed Joker rarity and Arcana item odds, three unique saved offers, persistent Joker pity, invalid choice no mutation, exact one-choice Joker and Arcana grants, claimed pending projection, profile validation, and replay rejection.

Formatting and Selene pass. Artifact, documentation, secret, CI, Studio, and isolated Roblox recovery evidence must be refreshed after the current source is committed.

## Remaining Boundary

This record does not claim the complete Phase 003 pack contract. Opening reveal states, all failure injection boundaries, catalog update compatibility, responsive client presentation, and isolated recovery remain unfinished work under the active phase plan.
