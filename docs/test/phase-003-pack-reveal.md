# Phase 003 pack reveal procedure

This procedure covers `P003-TASK-009`. It verifies that pack results are committed before presentation, that the client only displays server supplied contents, and that every supported input path produces the same final reveal state.

## Deterministic coverage

`P003-TEST-010-pack-reveal-controller` exercises the pure client controller with a five card result and a three offer result. It checks pack request validation, read only rejection, committed and revealed pending states, one at a time reveal, reveal all, skip, reduced motion, reduced flash and muted audio behavior, exact odds and pity metadata, one choice validation and claim projection, malformed success responses, and card snapshot recovery.

Run the complete suite with:

```text
ROKIT_ROOT="$PWD/build/rokit" PATH="$PWD/build/rokit/bin:$PATH" lune run test
```

Expected result is 62 passed and 0 failed.

## Studio acceptance

In the local Vinegar Studio artifact, confirm that the client can select Classic, Radioactive, Astral, Joker, and Arcana pack surfaces. Opening remains server authoritative. The reveal controls expose Reveal Next, Reveal All, and Skip. Offer packs expose exactly three choices after reveal completion. A reconnect or bootstrap response with a pending pack reconstructs the pending surface from the snapshot and never fabricates card fields or offer metadata.

