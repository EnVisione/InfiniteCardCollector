# Phase 003 Joker Service Evidence

The Joker service implementation is bound to the Phase 003 candidate source and artifact. `JokerService` validates ownership, enabled content, locks, dense five slot state, replacement safety, duplicate instance use, and deliberate duplicate binding. Joker instances persist `xp`, `level`, and `bound` fields. Active Formation scoring receives Joker IDs from the authoritative profile and awards one experience point to each active Joker after a committed success.

The deterministic suite passed 68 tests, including `P003-TEST-014-joker-service-and-loadout`, `P003-TEST-015-surface-state-contract`, and `P003-TEST-016-input-and-responsive-state`. The Joker fixture proves five active slots, sixth slot rejection, locked replacement atomicity, replacement after unlock, duplicate binding with ten experience, level two at one hundred experience, Joker Stage projection, and canonical calculation trace parity. Existing Phase 001 tests cover the twenty four handler goldens, pairwise combinations, conflict and cap checks, and table order.

The two enabled Joker routes are `joker.equip` and `joker.unequip`. Both use the existing expected revision and durable transaction boundary and return an authoritative profile snapshot. Older version 1 Joker records that omit the new progression fields receive safe defaults during validation.

The rebuilt phase artifact is `build/infinite-card-collector.rbxlx` with SHA 256 `61592e59255550bd02f768d5ee3f1bdfde61e5c36e871685ca196a51ac2f4ab3` and SHA 512 `7645ff0cc10b140e9dab53444b082727ebdd49fbaa2ce392526a976a4ac286f54b1480fdd9991195bbaaafb3c047b1f70eaafccf5b821a99e98c8a388c7cc9bb`.
