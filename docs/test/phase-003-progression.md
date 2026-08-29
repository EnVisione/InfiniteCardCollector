# Phase 003 progression test procedure

This procedure covers `P003-TASK-010`. It verifies deterministic Grade XP and Grade Ink progress, saved Power Tier preservation, explicit Trait choice and replacement, and fail closed eligibility.

## Deterministic coverage

`P003-TEST-011-progression-service` creates a high Tier card and advances it through every configured Grade threshold from F through LR. It verifies the Grade XP cap, no spend at the cap, preserved Tier, Trait Essence costs, all twelve eligible Trait choices, explicit replacement confirmation, stale replacement protection, and locked card no mutation. Every successful result includes the catalog and configuration versions and a compact progression trace.

Run the complete suite with:

```text
ROKIT_ROOT="$PWD/build/rokit" PATH="$PWD/build/rokit/bin:$PATH" lune run test
```

Expected result is 63 passed and 0 failed.

## Runtime contract

`ProgressionService` runs inside the existing `TransactionService` boundary. `grade.apply_ink` accepts only an integer amount and an owned card instance. Grade Ink converts one for one to cumulative Grade XP, clamps at the configured Grade experience cap, promotes to the highest reached Grade, and never lowers a saved Grade. Insufficient balance, foreign instances, missing instances, favorites, locks, disabled content, and cap no op paths do not spend currency or alter the card.

Trait choice and replacement use Trait Essence. A card without a Trait can choose any enabled launch Trait. A card with a Trait requires an explicit replacement confirmation and an optional expected current Trait ID, so stale replacement requests fail without mutation. The saved Edition, Grade, XP, Power Tier, Trait provenance, ownership, and discovery fields remain separate and stable.

## Studio acceptance

The connected Vinegar Studio artifact must show `grade.apply_ink` as an available writable route after a clean server and client restart. The route must return an authoritative snapshot and retain Grade XP, Grade, Power Tier, and Trait fields after rejoin. The full Arcana Lab choice and replacement presentation remains the next progression task.
