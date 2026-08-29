# Phase 003 Joker Service Tests

`P003-TEST-014-joker-service-and-loadout` verifies the server owned Joker boundary. The fixture creates five distinct launch Jokers and an unbound duplicate, equips the five dense slots, rejects a sixth slot, inspects the registered handler and explanation, rejects replacement of a locked active item without changing the loadout, replaces an unlocked slot, binds one eligible duplicate, and advances active and bound Joker experience.

The same fixture projects the five slot Joker Stage state and runs the shared score calculation twice against the projected active IDs. Canonical results and traces must remain identical. The full Phase 001 Joker corpus continues to cover all twenty four registered handlers, rarity counts, pairwise combinations, conflicts, caps, and stage ordering.

Run the focused and complete checks from the repository root:

```console
ROKIT_ROOT="$PWD/build/rokit" PATH="$PWD/build/rokit/bin:$PATH" build/rokit/bin/lune run test
```

Expected result is 67 passing tests with no failures.
