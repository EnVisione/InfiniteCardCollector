# Phase 003 Surface State Evidence

The authoritative client surface contract is implemented on the current Phase 003 branch. `SurfaceState` exposes Hub, Binder, Deck, Inspect, Arcana Lab, Joker Stage, Showcase, Settings, Tutorial, Recovery, Formation Rush, Tasks, Friend Clash, and Trade as stable IDs. It accepts only server snapshots, preserves selected instances only while they remain owned, identifies pending committed pack recovery, and fails closed for read only, maintenance, disabled, and later service states.

`ClientApp` binds those IDs to a scrollable navigation surface and records the active surface, state, revision, and recovery flag on the App root. The existing pack, deck, formation, preview, and binder controls remain server authoritative. Later task, duel, and trade actions remain registered but show unavailable state instead of inventing success.

The deterministic suite passes 68 tests, including `P003-TEST-015-surface-state-contract` and `P003-TEST-016-input-and-responsive-state`. Formatting, Selene, documentation, artifact, secret, and hosted CI checks are required after this source change. The rebuilt artifact is `build/infinite-card-collector.rbxlx` with SHA 256 `7a8626f22fdad320625a0a48ae1d25ae0b7ff25f1777807bd310df053dd40876` and SHA 512 `95b13af153491b31562cd044b359f08f7c39eb4ace96b03eac567303d1f52f534e99c0d4f544cb9fe64bfdd5bebbb54d91c1ce4ea8f712aa3acc1271c99caf53`.

The full small layout, controller focus, touch and mouse parity, accessibility goldens, and complete runtime workflows remain later Phase 003 tasks.
