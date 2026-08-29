# Phase 003 Surface State Tests

`P003-TEST-015-surface-state-contract` validates the authoritative client surface map owned by `P003-TASK-014`. It covers all fourteen required surfaces, navigation, selected owned cards and Jokers, pending recovery detection, read only and maintenance transitions, writable action revision binding, and fail closed later service adapters. `P003-TEST-016-input-and-responsive-state` validates semantic input actions across touch, mouse, keyboard, and controller, phone, tablet, and desktop breakpoints, UI scale, deterministic focus recovery, reduced settings, and maintenance state.

The shell keeps constrained layouts usable by making the foundation panel vertically scrollable, wrapping scaled action labels, and maintaining a minimum card viewport for short screens. The navigation, pack, and reveal rows remain horizontally scrollable where their complete button sets exceed the viewport.

The client shell exposes the same surface IDs through a horizontally scrollable navigation bar. The active surface, status, revision, and pending recovery state are mirrored as attributes on `PlayerGui.App` for visual and runtime inspection. Surface navigation never creates ownership or invents service results.

Run the focused and complete checks from the repository root:

```console
ROKIT_ROOT="$PWD/build/rokit" PATH="$PWD/build/rokit/bin:$PATH" build/rokit/bin/lune run test
```

Expected result is 68 passing tests with no failures.
