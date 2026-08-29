# Phase 003 Full Verification Procedure

This procedure covers `P003-TASK-016`. It runs the complete deterministic suite, static gates, artifact inspection, Studio presentation checks, and the local recovery workflow. Isolated DataStore recovery must use the owner authorized private universe and place and is recorded separately from local memory evidence.

## Deterministic checks

Run from the repository root in this order:

```console
ROKIT_ROOT="$PWD/build/rokit" PATH="$PWD/build/rokit/bin:$PATH" build/rokit/bin/stylua --check .
ROKIT_ROOT="$PWD/build/rokit" PATH="$PWD/build/rokit/bin:$PATH" build/rokit/bin/selene src lune tests
ROKIT_ROOT="$PWD/build/rokit" PATH="$PWD/build/rokit/bin:$PATH" build/rokit/bin/lune run test
ROKIT_ROOT="$PWD/build/rokit" PATH="$PWD/build/rokit/bin:$PATH" build/rokit/bin/lune run ci
```

The expected deterministic result is 68 tests with zero failures. The complete CI result is nine passed gates, including tools, formatting, static analysis, tests, source map, artifact, documentation, secret scan, and artifact inspection.

## Requirement to test matrix

| Area | Evidence in the deterministic suite |
| --- | --- |
| Catalog, assets, reachability, provenance, fallbacks, and budgets | `P003-TEST-001` through `P003-TEST-007`, plus Phase 001 catalog and Phase 002 renderer tests |
| Deck Set, Joker, and Arcana packs | `P003-TEST-008` and `P003-TEST-009`, with odds, pity, duplicate, choice, replay, and no mutation assertions |
| Reveal, reduced presentation, and recovery state | `P003-TEST-010` |
| Grade, Tier, Trait, and migrations | `P003-TEST-011` |
| Arcana one target and one consumption | `P003-TEST-012` |
| Collection flags, salvage protection, conservation, and best records | `P003-TEST-013` |
| Twenty four Jokers, five slots, replacement, binding, XP, and traces | `P003-TEST-014`, plus Phase 001 handler, conflict, cap, pairwise, and order tests |
| Required surfaces and unavailable later services | `P003-TEST-015` |
| Touch, mouse, keyboard, controller, breakpoints, focus, reduced settings, UI scale, and constrained layout | `P003-TEST-016` and the responsive client shell check |
| Hostile payloads, stale state, replay, foreign ownership, failure stages, retry, shutdown, and conservation | Phase 002 `P002-TEST-003`, `P002-TEST-006`, `P002-TEST-011` through `P002-TEST-015`, `P002-TEST-021` through `P002-TEST-025` |
| Deterministic calculation traces and table order | Phase 001 `P001-TEST-009`, `P001-TEST-010`, `P001-TEST-014`, and `P001-TEST-015` |
| Pooling, virtualization, preload, and visible-cell bounds | Phase 002 `P002-TEST-017` and `P002-TEST-018` |

## Studio workflow

Use the local built artifact through the qualified Vinegar route. Start from Edit mode, verify the Rojo connection, run Play, and check the client and server data models. The shell must expose the fourteen surface buttons, `ActiveSurfaceId = hud`, `SurfaceState = ready`, `InputDevice`, `Breakpoint`, `UIScale`, and `FocusedSurfaceId` attributes. Click `Open Starter Pack`, verify five visible binder rows and `pack.starter_committed`, then click `Reveal Next` and verify an eight layer 3D card preview. The console must remain empty and Play must stop cleanly.

The responsive captures use the local artifact and these device simulator presets in landscape mode:

| Preset | Result |
| --- | --- |
| iPhone 17 Pro, 874 by 402 | Action buttons fit and wrap, the panel scrolls vertically, and the constrained card viewport remains reachable. Capture `phase003_phone_landscape_action_fit`. |
| iPad Pro M5, 1376 by 1032 | Surface navigation and content remain readable with horizontal navigation overflow contained. Capture `phase003_tablet_landscape`. |
| Average Laptop, 1366 by 768 | Full foundation layout, preview, pack controls, and virtualized card area remain readable. Capture `phase003_desktop_landscape`. |

The game declares `LandscapeSensor`, so portrait evidence is outside the supported orientation contract. Reset the device simulator to its default state after the run.

## Isolated recovery gate

The exact private DataStore workflow remains mandatory. Run the pack, progression, Joker, disconnect, shutdown, rejoin, and recovery matrix in the owner authorized isolated place, compare stable profile, receipt, pending state, ownership, discovery, pity, trace, and revision hashes, and record the result under `docs/verification/`. Local memory evidence cannot substitute for this gate.
