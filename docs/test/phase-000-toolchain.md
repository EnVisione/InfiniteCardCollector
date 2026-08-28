# Phase 000 Toolchain Test Procedure

## Purpose

This procedure verifies only the reproducible repository foundation. It does not test gameplay because Phase 000 implements no gameplay behavior.

## Positive Gates

1. Bootstrap reviewed tools on a clean Linux x86_64 environment.
2. Bootstrap the same manifest on a clean Windows x86_64 environment.
3. Run `lune run verify-tools` with only the expected Rokit `bin` directory on tool PATH.
4. Run `stylua --check .` and `selene .` over `src/` and `lune/`.
5. Run `lune run test` twice and compare the complete normalized output.
6. Generate the source map and verify every file path is repository relative and exists.
7. Run `lune run artifact` twice from clean output and compare the project, source map, canonical manifest, SHA 256, SHA 512, source input digest, and instance inventory digest.
8. Run `lune run docs` and `lune run secrets`.
9. Run `lune run ci` from a cold tool cache and from a warm tool cache.
10. Complete native Roblox Studio synchronization, controlled resynchronization, bootstrap play test, and topology parity.
11. Record Vinegar as present or absent. If present, run it as a separately labeled compatibility check.

## Automated Test IDs

| Test ID | Contract |
| --- | --- |
| `P000-TEST-001-project-map` | Required source, asset, GUI, and DataModel mappings exist, while duplicate physical source mapping fails. |
| `P000-TEST-002-strict-boundaries` | Every applicable Luau file is strict and shared, server, client, test, tool, and runtime directions remain isolated. |
| `P000-TEST-003-environment` | Safe defaults pass, while an unsafe bind, path escape, or secret shaped key fails. |
| `P000-TEST-004-source-map` | The real source map is complete and relative, while an absolute path and missing source fail. |
| `P000-TEST-005-tool-clean-path` | A minimal expected PATH resolves every pinned tool. |
| `P000-TEST-006-tool-shadow` | An earlier executable with the same name fails before use. |
| `P000-TEST-007-format-lint-negatives` | Intentionally malformed formatting and lint fixtures fail, recovery succeeds, and unrelated content is unchanged. |
| `P000-TEST-008-artifact-normalization` | Object insertion order normalizes identically and a timestamp field fails. |
| `P000-TEST-009-harness-failures` | Failed assertions, crashes, path escapes, network attempts, and timeouts remain nonzero with stable IDs. |
| `P000-TEST-010-mandatory-gate-negatives` | Missing documentation commands, secret shaped content, and corrupted artifact bytes fail their mandatory gates. |
| `P000-TEST-011-ci-policy` | Hosted runner images, least privilege, timeouts, cancellation, pinned actions, cache digests, artifact retention, and secret boundaries remain fixed. |

## Fixture Boundaries

Negative Luau snippets use `.txt` files so `stylua .` and `selene .` never treat an intentionally invalid fixture as production source. The harness copies only the required fixture into `build/test-work/`, invokes the exact pinned tool, validates the expected nonzero result, and removes the isolated work root after success.

Fixtures contain no real credential, user path, network endpoint, profile, or private log. Secret shaped input is assembled only in memory. The network attempt fixture is rejected by capability policy before any network module is loaded or request is sent.

## Expected Output

`lune run test` prints one `test passed` line per stable test ID in sorted order, followed by `test summary, 11 passed, 0 failed`. It prints no timestamp, duration, username, home directory, random value, or absolute repository path.

Any assertion failure or harness exception reports the owning stable test ID and exits nonzero. A timeout is terminated by the platform process supervisor. A failed run keeps its isolated diagnostics under `build/test-work/` until the next deliberate test rerun.

## Manual Studio Procedure

The native Studio procedure remains pending. Its acceptance packet must record the exact Studio build and channel, reviewed Rojo plugin identity, loopback server address, clean synchronization, controlled source edit and resynchronization, server and client bootstrap attributes, built versus synchronized topology, and sanitized logs.

The separate Vinegar compatibility procedure passed for Vinegar 1.9.4, Wine 11.16, Studio `0.736.0.7361346` on the LIVE channel, and the reviewed Rojo 7.7.0 plugin. It proved an empty DataModel before synchronization, the complete synchronized topology, a controlled contract version update and revert, both ready bootstrap attributes in play mode, and an empty project console. This conditional result never substitutes for the native Studio gate.

## Rerun Order

After a change, rerun from the lowest affected layer:

1. `lune run verify-tools`.
2. `stylua --check .` and `selene .`.
3. `lune run test`.
4. Source map and build commands.
5. `lune run artifact`.
6. `lune run docs` and `lune run secrets`.
7. Native Studio parity when mapping, source, Rojo, plugin, or Studio inputs changed.
8. Clean Linux and Windows acceptance.
9. Hosted CI.
10. Final diff and evidence audit.
