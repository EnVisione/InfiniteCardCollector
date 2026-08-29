# Phase 003 Joker Service Evidence

The Joker service implementation is bound to the Phase 003 candidate source and artifact. `JokerService` validates ownership, enabled content, locks, dense five slot state, replacement safety, duplicate instance use, and deliberate duplicate binding. Joker instances persist `xp`, `level`, and `bound` fields. Active Formation scoring receives Joker IDs from the authoritative profile and awards one experience point to each active Joker after a committed success.

The deterministic suite passed 67 tests, including `P003-TEST-014-joker-service-and-loadout` and `P003-TEST-015-surface-state-contract`. The Joker fixture proves five active slots, sixth slot rejection, locked replacement atomicity, replacement after unlock, duplicate binding with ten experience, level two at one hundred experience, Joker Stage projection, and canonical calculation trace parity. Existing Phase 001 tests cover the twenty four handler goldens, pairwise combinations, conflict and cap checks, and table order.

The two enabled Joker routes are `joker.equip` and `joker.unequip`. Both use the existing expected revision and durable transaction boundary and return an authoritative profile snapshot. Older version 1 Joker records that omit the new progression fields receive safe defaults during validation.

The rebuilt phase artifact is `build/infinite-card-collector.rbxlx` with SHA 256 `b3d060e94887e5225266379de0ae628ea5ef741f935463a2cea7c8a15daf19fe` and SHA 512 `46a82d6af3eb72e2a7f650574e5a676716b97c1668fa4721a046977b6424b8809fa3e557a49c108f0ed995ae913af7475872aaa2338b688071744b931a1ba91c`.
