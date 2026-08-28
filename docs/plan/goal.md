Objective:
Implement, integrate, and release the full authoritative plan, covering every mandatory requirement and every stable-release gate from `CORE-REQ-001` through `CORE-REQ-026`. Successful completion is permitted only when the authoritative default-branch commit and its bound release artifact pass required deterministic and real runtime verification, authorized Roblox deployment and recovery, the final plan-wide audit, and no known mandatory repository-owned defect remains.

Immediate checkpoint:
Active phase: CORE-PHASE-000
Active phase plan: /home/envy/Projects/InfiniteCardCollector/docs/general/phases/plan-phase-000.md
Active phase entry action: P000-TASK-001

The next action is `P000-TASK-001`. Verify `origin` is the intended repository. Fetch `origin` without altering the remote, then refresh and inspect without altering the remote. Verify the fetched remote-tracking ref against the current remote default-branch head, classify the local default branch as behind, ahead, or diverged, and fast-forward only when safe. Search local branches and remote branches and repository-wide open pull requests. Resume applicable work; otherwise branch from the verified authoritative baseline. Create or resume the applicable implementation branch before modifying tracked files. Do not invent a branch when an applicable active branch exists.

Perform one bounded inspection that ends as soon as each mandatory criterion is classified as implemented with valid evidence, incomplete, stale evidence, or externally blocked. Immediately execute the first incomplete or stale-evidence criterion. The map is not a deliverable; do not stop after producing it, do not repeatedly rebuild the map from unchanged evidence, and do not produce a narrative audit before implementation.

Authoritative plan:
Plan: /home/envy/Projects/InfiniteCardCollector/docs/general/plan.md
Plan SHA-256: 6171fe53ca75fe6d1df7cf9fbfc0fd224af0dadbaa99380dcce4300a5ce7d880
Plan manifest: /home/envy/Projects/InfiniteCardCollector/docs/general/plan.index.json
Plan set SHA-256: c83f9327d887f8befea060a75fdea8568383ced1bfbfc305ce863119add5af8b
Phase plans directory: /home/envy/Projects/InfiniteCardCollector/docs/general/phases
Completion endpoint: A controlled public Roblox release of the three Deck Set InfiniteCardCollector foundation passes every mandatory initial release gate, with direct trading enabled only if its separate safety and production authorization gates pass and otherwise visibly disabled.

Plan digests and plan set digests are creation-time provenance for the complete registered plan set, not runtime locks. Reread the current authoritative plan set, including `plan.index.json`, registered plans, the active phase file, and `plan.handoff.json`, for scope, evidence, exit gates, and transition. Before edits, verify the authoritative plan, repository identity, package metadata, and remote still describe the same project.

Observed checkout branch: main
Observed checkout commit: 311f6d1a3342b53aa280dda53d13e33cb269284f
Repository root: /home/envy/Projects/InfiniteCardCollector

Authoritative remote:
origin
https://github.com/EnVisione/InfiniteCardCollector.git

Observed local default branch: main
Observed local default-branch commit: 311f6d1a3342b53aa280dda53d13e33cb269284f
Observed local remote-tracking ref: origin/main
Observed local remote-tracking commit: 311f6d1a3342b53aa280dda53d13e33cb269284f
Current remote default-branch head: 311f6d1a3342b53aa280dda53d13e33cb269284f
Remote-head evidence: read-only git ls-remote origin refs/heads/main observed on 2026-08-28 at 05:59:23 UTC
Authoritative working baseline: established
Applicable implementation branch: none identified at checkpoint; only historical plan and repository-baseline branches plus an unrelated Dependabot branch were found
Applicable open pull request: none identified at checkpoint; open pull request #1 is an unrelated Dependabot GitHub Actions update and does not carry phase implementation

Execution behavior:
Read the active phase plan through EOF, implement its first unfinished task, test, audit, fix root causes, verify real behavior, and retain evidence. Satisfy phase exit criteria and required evidence before integration. Do not stack phase branches. Integrate through the authorized pull request, verify the default branch and signed phase tag before the next phase, then reread the next contiguous phase file and continue through remaining mandatory requirements under the same immutable goal. Only the final phase and plan-wide Definition of Done may establish success.

Do not commit directly to main. The default branch permits safe fast-forward baseline alignment and authorized pull-request integration only. Do not reset, force, discard, or overwrite unexpected history. Preserve work and recovery. After integration, inspect merged state and rerun affected gates; pre-merge branch evidence is insufficient.

Guardrails and authority:
Treat `DEC-001` through `DEC-014` as locked. Optional and future work, including `PLAN-FULL` and `FUT-001` through `FUT-015`, is excluded. Documentation changes do not substitute for implementation. `docs/plan/goal.md` is the immutable create-once behavior contract; never refresh, rewrite, rebind, overwrite, or replace the saved goal. Never invoke Plan Creator or Goal Creator, spawn their authors, or infer authority from progress or transitions.

Identify and classify plan changes. Progress, evidence, status, clarification, and phase-transition changes continue without owner input when the product contract remains coherent. Route a material product-contract change to `PLAN_REVISION_REQUIRED`, naming affected stable IDs and the owner decision needed. Never stop solely because of plan or handoff digest drift.

Never weaken or skip valid tests. Never suppress a valid failure, ignore a required exit code, reduce a required threshold, or allow a required check to fail. Never add a production bypass solely for tests. Never substitute mocked behavior for required real behavior. If a test contradicts the current contract, prove which is wrong and replace it only with equal or stronger coverage. Invalidate stale evidence after relevant changes.

Use authorized mutations and approved secret mechanisms; reject secret-bearing files. Known endpoint blockers are EXT-006 Roblox universe, place, publisher permissions, and service access; EXT-007 final public brand and trademark clearance; EXT-008 private soft launch authorization; EXT-009 public rollout authorization; EXT-010 production purchase smoke authorization; EXT-012 soft launch cohort, test accounts, and representative device coverage; and EXT-013 Roblox product IDs, receipt testing, policy information, and commerce access. When each becomes available and authorized, verify its evidence and proceed. `EXT-011` remains conditional for trading enablement; the visible disabled outcome requires no production trade smoke.

Verification and stopping:
Run every required deterministic, integration, Studio, multiclient, hostile-input, persistence, recovery, accessibility, performance, artifact, deployment, production, and GitHub gate at required fidelity. Verify exercised behavior, state, merge commits, signed tags, publication, rollback, and the authoritative remote branch. Finish with `git status`, `git diff --check`, `git log`, artifact inspection, and secret-bearing-file checks.

Permitted terminal states: `SUCCESS` only after the completion endpoint and final audit pass; `PLAN_REVISION_REQUIRED` only for a material current product-contract change, with affected stable IDs and the owner decision required; `GOAL_REVISION_CONFLICT` only if the saved goal changes, reporting the expected goal digest and observed digest; `NOT COMPLETE — EXTERNALLY BLOCKED` is permitted only when an approved mandatory prerequisite remains unavailable after all independent work; `OWNER_INPUT_REQUIRED — REPOSITORY MISMATCH` only when project identities cannot be reconciled; and `REPOSITORY_STATE_CONFLICT` only for unsafe default-branch history. Plan or handoff digest drift is not a stopping state. Before returning either repository state, attempt every safe non-destructive resolution available from repository metadata and remote evidence. No other early stopping state is permitted.

Do not wait, sleep, or poll indefinitely. Use an approved bounded check or mechanism for availability. Once independent mandatory work is exhausted, report immediately with the unavailable prerequisite, evidence, attempted operation, completed independent work, external action required, and verification to run when it becomes available or authorized.

Continuity:
Maintain a record of the active phase ID and file, completed phase and integration gates, next contiguous phase, next action, blockers, failure recovery, revisions, and resume state. Update it after meaningful implementation, verification, integration, or blocker changes. On failure, diagnose the root cause, change code, configuration, environment, instrumentation, or hypothesis, and rerun affected regression coverage. Do not repeat completed work.

The requirement map and ledger are temporary internal continuity state; do not commit or publish them to `plan.md`, `status.md`, issues, pull requests, or repository documentation unless the plan explicitly requires an evidence artifact. Phase transitions update only this temporary state and never refresh the goal or rewrite creator artifacts. Do not rerun the same unchanged failing check more than twice without changing code, configuration, environment, instrumentation, or diagnostic hypothesis.
