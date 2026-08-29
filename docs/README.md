# Documentation

Tracked documentation is the source of truth for InfiniteCardCollector. The GitHub wiki is a navigation surface and must link back to these files rather than becoming a separate product specification.

## General

- [Technical overview](general/documentation.md)
- [Initial release master plan](general/plan.md)
- [Complete future plan](general/full_plan.md)
- [Plan manifest](general/plan.index.json)
- [Goal Creator handoff](general/plan.handoff.json)
- [Final product vision](general/product-vision.md)
- [Complete content catalog](general/content-catalog.md)

## Initial Release Phases

- [Phase 000, reproducible toolchain and repository foundation](general/phases/plan-phase-000.md)
- [Phase 001, catalogs and deterministic calculation layer](general/phases/plan-phase-001.md)
- [Phase 002, profiles, inventory, progression, and economy](general/phases/plan-phase-002.md)
- [Phase 003, original content assets and responsive interface](general/phases/plan-phase-003.md)
- [Phase 004, active Formation Rush and task loop](general/phases/plan-phase-004.md)
- [Phase 005, Friend Clash and social competition](general/phases/plan-phase-005.md)
- [Phase 006, recoverable direct trading](general/phases/plan-phase-006.md)
- [Phase 007, analytics, retention, and live operations](general/phases/plan-phase-007.md)
- [Phase 008, full release candidate verification](general/phases/plan-phase-008.md)
- [Phase 009, controlled public release](general/phases/plan-phase-009.md)

## Implementation

- [Launch foundation and implementation specification](implementation/launch-foundation.md)
- [Phase 002 runtime architecture](implementation/phase-002-runtime.md)

## Operations

- [Development setup and command contract](operations/development-setup.md)

## Testing

- [Phase 000 toolchain test procedure](test/phase-000-toolchain.md)
- [Phase 001 catalog and calculation test procedure](test/phase-001-calculation-contracts.md)
- [Phase 002 network and security tests](test/phase-002-network-and-security.md)
- [Phase 002 profile and transaction tests](test/phase-002-profile-and-transactions.md)
- [Phase 002 inventory and renderer tests](test/phase-002-inventory-and-rendering.md)
- [Phase 002 blank account recovery workflow](test/phase-002-recovery-workflow.md)
- [Phase 003 asset contract tests](test/phase-003-assets.md)
- [Phase 003 Deck Set asset tests](test/phase-003-decksets.md)
- [Phase 003 compositional card asset tests](test/phase-003-composition.md)

## Verification

- [Phase 000 foundation evidence](verification/phase-000-foundation.md)
- [Phase 000 tool provenance](verification/phase-000-tool-provenance.md)
- [Phase 001 catalog and calculation evidence](verification/phase-001-calculation-contracts.md)
- [Phase 002 recoverable vertical slice evidence](verification/phase-002-recoverable-vertical-slice.md)
- [Phase 003 entry and baseline evidence](verification/phase-003-entry.md)
- [Phase 003 asset contract evidence](verification/phase-003-asset-contract.md)
- [Phase 003 asset manifest snapshot](verification/phase-003-asset-manifest.json)
- [Phase 003 Deck Set identity evidence](verification/phase-003-deckset-identities.md)
- [Phase 003 compositional card asset evidence](verification/phase-003-composition.md)

## Troubleshooting

- [Toolchain and synchronization troubleshooting](troubleshooting/toolchain.md)
- [Profile and recovery troubleshooting](troubleshooting/profile-and-recovery.md)

## External Navigation

- [Repository README](../README.md)
- [Issues](https://github.com/EnVisione/InfiniteCardCollector/issues)
- [InfiniteCardCollector roadmap](https://github.com/users/EnVisione/projects/8)
- [Wiki](https://github.com/EnVisione/InfiniteCardCollector/wiki)

## Documentation Rules

- Describe shipped behavior as implemented only after code and verification exist.
- Mark planned architecture and features as planned until their implementation and required evidence pass.
- Keep stable content IDs and collection counts synchronized with the content catalog.
- Update this index whenever documentation is added, renamed, or removed.
- Store implementation details under `docs/implementation/`, testing procedures under `docs/test/`, and verified build or release evidence under `docs/verification/` when those areas exist.
