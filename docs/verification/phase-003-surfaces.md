# Phase 003 Surface State Evidence

The authoritative client surface contract is implemented on the current Phase 003 branch. `SurfaceState` exposes Hub, Binder, Deck, Inspect, Arcana Lab, Joker Stage, Showcase, Settings, Tutorial, Recovery, Formation Rush, Tasks, Friend Clash, and Trade as stable IDs. It accepts only server snapshots, preserves selected instances only while they remain owned, identifies pending committed pack recovery, and fails closed for read only, maintenance, disabled, and later service states.

`ClientApp` binds those IDs to a scrollable navigation surface and records the active surface, state, revision, and recovery flag on the App root. The existing pack, deck, formation, preview, and binder controls remain server authoritative. Later task, duel, and trade actions remain registered but show unavailable state instead of inventing success.

The deterministic suite passes 67 tests, including `P003-TEST-015-surface-state-contract`. Formatting, Selene, documentation, artifact, secret, and hosted CI checks are required after this source change. The rebuilt artifact is `build/infinite-card-collector.rbxlx` with SHA 256 `b3d060e94887e5225266379de0ae628ea5ef741f935463a2cea7c8a15daf19fe` and SHA 512 `46a82d6af3eb72e2a7f650574e5a676716b97c1668fa4721a046977b6424b8809fa3e557a49c108f0ed995ae913af7475872aaa2338b688071744b931a1ba91c`.

The full small layout, controller focus, touch and mouse parity, accessibility goldens, and complete runtime workflows remain later Phase 003 tasks.
