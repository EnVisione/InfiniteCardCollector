# Phase 003 Joker Service Evidence

The Joker service implementation is bound to the Phase 003 candidate source and artifact. `JokerService` validates ownership, enabled content, locks, dense five slot state, replacement safety, duplicate instance use, and deliberate duplicate binding. Joker instances persist `xp`, `level`, and `bound` fields. Active Formation scoring receives Joker IDs from the authoritative profile and awards one experience point to each active Joker after a committed success.

The deterministic suite passed 66 tests, including `P003-TEST-014-joker-service-and-loadout`. The fixture proves five active slots, sixth slot rejection, locked replacement atomicity, replacement after unlock, duplicate binding with ten experience, level two at one hundred experience, Joker Stage projection, and canonical calculation trace parity. Existing Phase 001 tests cover the twenty four handler goldens, pairwise combinations, conflict and cap checks, and table order.

The two enabled Joker routes are `joker.equip` and `joker.unequip`. Both use the existing expected revision and durable transaction boundary and return an authoritative profile snapshot. Older version 1 Joker records that omit the new progression fields receive safe defaults during validation.

The rebuilt phase artifact is `build/infinite-card-collector.rbxlx` with SHA 256 `29ecfd67c29e0ddaceccb0cca86a0098aa592310c9105d137618481913a56ea9` and SHA 512 `ad87c4bf7b8eb413fa79719c97eb22c7b9608209dbc2f6b9c5c513b8580e39d5572f5fca752b57f371edc7bd6b803f7aeeb94450ff24d2220fa584db5783c803`.
