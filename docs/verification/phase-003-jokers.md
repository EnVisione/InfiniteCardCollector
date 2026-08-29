# Phase 003 Joker Service Evidence

The Joker service implementation is bound to the Phase 003 candidate source and artifact. `JokerService` validates ownership, enabled content, locks, dense five slot state, replacement safety, duplicate instance use, and deliberate duplicate binding. Joker instances persist `xp`, `level`, and `bound` fields. Active Formation scoring receives Joker IDs from the authoritative profile and awards one experience point to each active Joker after a committed success.

The deterministic suite passed 68 tests, including `P003-TEST-014-joker-service-and-loadout`, `P003-TEST-015-surface-state-contract`, and `P003-TEST-016-input-and-responsive-state`. The Joker fixture proves five active slots, sixth slot rejection, locked replacement atomicity, replacement after unlock, duplicate binding with ten experience, level two at one hundred experience, Joker Stage projection, and canonical calculation trace parity. Existing Phase 001 tests cover the twenty four handler goldens, pairwise combinations, conflict and cap checks, and table order.

The two enabled Joker routes are `joker.equip` and `joker.unequip`. Both use the existing expected revision and durable transaction boundary and return an authoritative profile snapshot. Older version 1 Joker records that omit the new progression fields receive safe defaults during validation.

The rebuilt phase artifact is `build/infinite-card-collector.rbxlx` with SHA 256 `7a8626f22fdad320625a0a48ae1d25ae0b7ff25f1777807bd310df053dd40876` and SHA 512 `95b13af153491b31562cd044b359f08f7c39eb4ace96b03eac567303d1f52f534e99c0d4f544cb9fe64bfdd5bebbb54d91c1ce4ea8f712aa3acc1271c99caf53`.
