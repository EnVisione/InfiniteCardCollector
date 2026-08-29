# Phase 003 Special Content Asset Test Procedure

## Purpose

This procedure validates the registered special content asset families owned by `P003-TASK-005`. It covers the enabled Joker and Arcana identities, pack families, required collection surfaces, sounds, effects, icons, thumbnails, metadata, and neutral fallback references. It does not claim that reviewed source media has been imported.

## Commands

From the repository root, run:

```console
lune run test
stylua --check .
selene .
lune run artifact
lune run docs
lune run secrets
```

The deterministic suite must report 58 passing tests. The full command contract must remain green.

## Registry checks

`SpecialContentAssets.build` consumes the enabled catalog selections and creates immutable records without special cases for individual Joker or Arcana IDs. The registry contains 24 Jokers, 12 Arcana, five pack families, seven required surfaces, eight sound cues, nine effect cues, and matching 41 item records for icons, thumbnails, and metadata.

Every record exposes a stable primary asset ID, a neutral fallback ID, source and built identities, and sorted consumer references. Disabled future content such as `fifth_law` is excluded from the public lookup.

## Runtime check

The connected Vinegar Studio client must build the registry during client startup. The app records the registry version and enabled Joker and Arcana counts as diagnostic attributes. Server and client console output must remain empty during the bounded boot.

## Evidence limits

These records are the identity and reachability contract for special content and surfaces. Reviewed art, audio, effects, interface files, source hashes, budget measurements, device goldens, and the complete launch manifest remain required by later Phase 003 tasks.
