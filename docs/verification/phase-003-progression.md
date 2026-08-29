# Phase 003 progression evidence

The Phase 003 progression task is implemented on the current phase branch. `ProgressionService` applies server-authoritative Grade Ink, promotes cumulative Grade XP through the configured F through LR thresholds, clamps at the Grade experience cap, preserves saved Power Tier and card provenance, and emits a versioned trace. It also exposes deterministic eligible Trait choices and explicit Trait replacement with Trait Essence costs and stale or locked fail closed behavior.

`P003-TEST-011-progression-service` covers all eleven Grade thresholds, LR promotion, Grade experience cap, preserved Zenith Tier, Trait choice, replacement confirmation, stale expected Trait rejection, locked card rejection, and no mutation on rejected work. The full deterministic suite passes 63 tests with 0 failures. Formatting and Selene checks pass.

The `grade.apply_ink` action is available through the existing 24 action registry and routes through `TransactionService` with expected revision, exact once receipts, and authoritative profile snapshots. Trait choice and replacement methods are ready for the Arcana handlers owned by the next progression task. The current artifact is rebuilt after this change and its hashes are recorded in the phase evidence files that reference it.

Vinegar verification on the rebuilt local artifact confirmed the server route is registered as `grade_apply_ink`, a malformed ownership request returns `ownership.instance_not_found` with the original action and request ID, the client foundation surface exposes the staged reveal controls, and the clean restarted Studio console remains empty.

This evidence does not claim Arcana application, salvage, Joker mutation, full responsive progression panels, isolated DataStore rejoin, or complete Phase 003 exit completion.
