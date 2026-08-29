# Phase 003 Surface State Evidence

The authoritative client surface contract is implemented on the current Phase 003 branch. `SurfaceState` exposes Hub, Binder, Deck, Inspect, Arcana Lab, Joker Stage, Showcase, Settings, Tutorial, Recovery, Formation Rush, Tasks, Friend Clash, and Trade as stable IDs. It accepts only server snapshots, preserves selected instances only while they remain owned, identifies pending committed pack recovery, and fails closed for read only, maintenance, disabled, and later service states.

`ClientApp` binds those IDs to a scrollable navigation surface and records the active surface, state, revision, and recovery flag on the App root. The existing pack, deck, formation, preview, and binder controls remain server authoritative. Later task, duel, and trade actions remain registered but show unavailable state instead of inventing success.

The deterministic suite passes 68 tests, including `P003-TEST-015-surface-state-contract` and `P003-TEST-016-input-and-responsive-state`. The constrained foundation panel is vertically scrollable, action labels wrap inside responsive buttons, and the card viewport remains at least 180 logical pixels before UI scale. Formatting, Selene, documentation, artifact, secret, and hosted CI checks pass. The rebuilt artifact is `build/infinite-card-collector.rbxlx` with SHA 256 `61592e59255550bd02f768d5ee3f1bdfde61e5c36e871685ca196a51ac2f4ab3` and SHA 512 `7645ff0cc10b140e9dab53444b082727ebdd49fbaa2ce392526a976a4ac286f54b1480fdd9991195bbaaafb3c047b1f70eaafccf5b821a99e98c8a388c7cc9bb`.

The phone, tablet, and desktop layout foundation and controller, touch, mouse, and keyboard state contracts are covered here. Complete collection workflows, accessibility goldens, and isolated recovery remain later Phase 003 gates.
