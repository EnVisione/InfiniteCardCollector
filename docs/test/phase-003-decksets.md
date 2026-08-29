# Phase 003 Deck Set Asset Test Procedure

## Purpose

This procedure covers the Phase 003 Deck Set identity slice. It validates the three launch visual systems, their procedural Studio fixtures, and the 156 stable base identity records produced from the pinned catalog. It does not claim that the complete launch art, audio, or responsive renderer bundle exists.

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

The suite must report `P003-TEST-005-deckset-identity-assets`, `P003-TEST-006-deckset-fixture-project`, and a total of 58 passing tests. The full command contract must remain green.

## Identity checks

`LaunchDeckSetAssets.buildIdentityRecords` consumes the existing launch catalog and produces exactly 52 records for each of Classic, Radioactive, and Astral. The shared presentation tables contain all 13 rank marks and all four suit treatments, with stable asset and fallback IDs. Each identity record keeps the catalog base identity and slot key, binds a visual system, frame, rank, suit, pack, reveal sound, binder, mastery, affinity cue, fallback, source identity, built identity, provenance, review state, and sorted consumer references. Every rank and suit slot appears once per Deck Set, and all records are immutable after construction.

## Presentation fixtures

The Rojo project maps one original procedural frame model, one neutral fallback model, and one pack model for each launch Deck Set. Classic uses ivory stock and red or black ink. Radioactive uses hazard stripes, warning accents, and neon green. Astral uses a violet nebula palette, silver marks, and constellation accents. `Phase002Runtime` publishes all nine fixtures to the bounded client folder. `PresentationResolver` selects the registered themed fixture for enabled card data and selects the matching neutral fallback for unknown or disabled data. The client records the selected visual system and fallback state on the preview model.

## Evidence limits

The records and procedural fixtures are the first Deck Set presentation slice. They do not substitute for reviewed source art files, content hashes, audio, complete binder or mastery surfaces, golden screenshots, or the remaining Edition and progression layers owned by later Phase 003 tasks.
