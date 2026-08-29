# Phase 003 Compositional Card Asset Test Procedure

## Purpose

This procedure validates the data driven compositional layer registry owned by `P003-TASK-004`. It covers the four enabled Editions, eleven Grades, eleven Power Tiers, twelve Traits, six readable status overlays, twelve formation presentations, and exactly 624 launch form keys. It does not claim that the final source media bundle or every surface golden exists.

## Commands

From a bootstrapped repository root, run:

```console
lune run test
stylua --check .
selene .
lune run artifact
lune run docs
lune run secrets
```

The suite must report `P003-TEST-005-deckset-identity-assets` and a total of 59 passing tests. The full command contract must remain green.

## Registry checks

`ComposedCardAssets.build` consumes the projected launch axes and generates stable asset and fallback IDs without requiring private profile data or exposing disabled catalog records. Form keys are generated from the ordinary `deckSet:rank:suit:edition` contract. The registry is frozen and can compose a card into the same layer order used by both render adapters.

The test verifies counts of 4 Editions, 11 Grades, 11 Power Tiers, 12 Traits, 6 status overlays, 12 formation presentations, and 624 forms. It also verifies Edition, Tier, form, and status asset references for a valid card, and a neutral unavailable status when a required layer is missing.

## Runtime check

The connected Vinegar Studio client must be restarted after source synchronization. A client Luau check builds the projected registry, composes an Astral Golden card, and confirms the 624 form count, form asset ID, Edition asset ID, and status asset ID. Server and client console output must remain empty for the bounded boot.

## Evidence limits

The registry and semantic references are implementation evidence for compositional reachability. They do not substitute for reviewed Edition, Grade, Tier, Trait, effect, audio, image, or surface source files, visual goldens, device screenshots, or the complete manifest owned by later Phase 003 tasks.
