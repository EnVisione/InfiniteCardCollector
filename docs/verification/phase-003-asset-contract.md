# Phase 003 Asset Contract Evidence

## Scope

This record covers `P003-TASK-002` and freezes the asset manifest contract before new launch content is produced. It defines the fields, validation rules, invalidation behavior, and bounded loading groups that later Phase 003 tasks must use. The complete Classic, Radioactive, Astral, Edition, Joker, Arcana, pack, interface, world, audio, effect, and metadata bundle remains pending.

## Contract result

`AssetManifest` uses schema version 1 and manifest version 1. Every entry has a stable ID, source and built identities, SHA 256 and SHA 512 content hashes, a stable asset version, original provenance and license, review state, sorted consumer references, a fallback identity, preload and pool groups, dimensions or duration, measured byte and memory values, instance count, and declared budgets. Unknown fields and duplicate IDs or built hashes fail closed.

Enabled entries must have reviewed provenance and a resolvable fallback. The fallback may be a dedicated fallback entry or a self reference only for an entry of kind `fallback`. Source and built identities remain separate so deterministic imports can optimize output without changing source provenance. The runtime bundle is not allowed to use an unresolved, quarantined, or over budget entry.

## Budget contract

The current schema limits one entry to 4 MiB of bytes, 16 MiB of memory, and 128 instances. Preload groups declare their own maximum bytes and instances, capped at 8 MiB and 256 instances. Pool groups declare live instance limits. Measured entry values must remain at or below their own budgets, and group totals must remain within group limits. These are contract limits, not evidence that the full launch bundle has been built.

## Deterministic fixtures

The five Phase 003 asset tests cover a reviewed original model with a static fallback, malformed hashes, an over budget entry, an unresolved fallback, an unreviewed enabled entry, changed built content, changed budget, an unchanged manifest, and all three visual systems with 156 base identity records. The empty launch contract records catalog version 1 and artifact version `phase-003-contract` with no asset entries, accurately reflecting the source inventory at phase entry.

The contract snapshot is recorded in [`phase-003-asset-manifest.json`](phase-003-asset-manifest.json). The task 002 contract artifact check produced SHA 256 `f20a845c6571f343ede897c353cec117051dccfbaf7da7d52a805cfc7807bea5` and SHA 512 `2145014966e17af753ffa4e551c76fc8794e5eb3f383381ac046aec459c62b4da2dd4bc46a6262132fb176f1495d8006170ddffb21b2208f41a45b79aa8eb99b`. The later Deck Set fixture commit intentionally invalidates that artifact and records its replacement in [the Deck Set identity evidence](phase-003-deckset-identities.md).

The next task is `P003-TASK-003`, which must create the original three Deck Set presentation families and 156 base identity records against this frozen contract. It must not bypass the manifest or import an asset without provenance and fallback fields.
