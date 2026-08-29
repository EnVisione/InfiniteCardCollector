# Phase 003 Asset Contract Test Procedure

## Purpose

This procedure covers `P003-TASK-002`. It validates the stable asset manifest schema, provenance fields, reference graph, fallback contract, deterministic invalidation reasons, and byte, memory, instance, preload, and pool budgets. It does not claim that the complete launch asset set exists.

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

The suite must report `P003-TEST-001-asset-schema-and-budget`, `P003-TEST-002-asset-negative-fixtures`, `P003-TEST-003-invalidation-reasons`, `P003-TEST-004-empty-launch-contract`, and `P003-TEST-005-deckset-identity-assets` as passed. The full command contract must remain green.

## Contract checks

Every entry uses a lowercase stable ID, a declared kind, source and built identities, SHA 256 and SHA 512 hashes, an asset version, provenance and license, review state, consumer references, a fallback ID, preload and pool groups, dimensions or duration, and measured byte, memory, and instance values with independent budgets. Enabled entries require reviewed provenance. Entries and groups are sorted and unique. References are sorted and unique. The validator rejects unknown fields, malformed hashes, duplicate built hashes, unresolved fallbacks, unreviewed enabled entries, missing dimensions or duration, and every budget breach.

Preload groups bound total bytes and instances. Pool groups bound the number of live instances. The manifest keeps these limits separate from the asset's own byte, memory, and instance budgets. An empty launch manifest is valid for the entry checkpoint and records the contract version without implying that launch assets are present.

## Invalidation checks

`AssetManifest.invalidationReasons` validates both manifests before comparing them. It emits deterministic reasons for manifest, catalog, artifact, entry, source, built, enabled state, fallback, asset version, provenance, reference, and budget changes. An unchanged manifest returns an empty reason list. Any source, built identity, catalog, or contract change invalidates dependent asset and surface evidence before a rebuild.

Presentation kind, dimensions, duration, preload limits, and pool limits are also invalidation inputs. The validator reports these changes before downstream asset and surface evidence can be reused.

## Evidence handling

Keep generated artifacts under `build/`. Record manifest snapshots, source and built hashes, provenance review, reference graph, fallback matrix, budget measurements, and deterministic rebuild comparisons under `docs/verification/`. Do not store credentials, raw profiles, private logs, temporary exports, or unreviewed external asset URLs.
