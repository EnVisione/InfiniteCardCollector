# Toolchain Troubleshooting

## Bootstrap Integrity Failure

A size, SHA 256, SHA 512, archive layout, extracted size, or extracted hash mismatch is a hard failure. Do not execute the downloaded file. Confirm the selected platform, release URL, filename, and both hashes in `config/tool-artifacts.json`. Compare them with [tool provenance](../verification/phase-000-tool-provenance.md), remove only the incomplete temporary directory, and rerun the checksum first bootstrap.

## PATH Shadowing

`lune run verify-tools` requires the first `rokit`, `rojo`, `stylua`, `selene`, and `lune` executable on PATH to be the expected Rokit link. If `P000-TOOLS-025` appears, inspect the current PATH without running the conflicting program. Prepend the expected Rokit `bin` directory, clear any shell command cache, and rerun verification.

Do not copy arbitrary executables into Rokit storage or bypass the verifier. The underlying executable bytes must match the selected platform record.

## Partial Rokit Installation

Use the same `ROKIT_ROOT` used during bootstrap. Rerun the platform bootstrap, then `rokit install`, then `lune run verify-tools`. The bootstrap preserves unrelated valid cache entries but refuses a conflicting executable at any pinned target path.

If the trust or install cache is malformed, preserve it as private local diagnostic evidence, create a fresh Rokit root, and rerun bootstrap. Do not commit the cache or its authentication file.

## Formatter Coverage

Run `stylua --check .`. Every applicable file under `src/` and `lune/` must be checked. Generated paths under `build/`, `coverage/`, and `dist/` are the only focused exclusions. Intentional negative fixtures use `.txt` and are copied to generated work paths during tests.

Use `stylua .` to correct ordinary source formatting. Review the diff before continuing because formatting must not rewrite documentation, JSON, YAML, PowerShell, shell scripts, or generated evidence.

## Selene Coverage

Run `selene .`. `selene.toml` sets `roblox-std-source = "pinned"`, and the committed `roblox.yml` is the only accepted Roblox standard library for ordinary linting. Do not run `selene update-roblox-std` during normal setup or CI.

A deliberate standard library refresh requires a reviewed toolchain change. Generate once with the pinned Selene executable, remove its generation timestamp, record the resulting SHA 256 and SHA 512, then rerun formatting, linting, tests, build, Studio, clean environment, and CI evidence.

## Harness Failure

The first stable `P000` identifier names the failed contract. Test output is deterministic and hides machine paths. A crash is never converted into a pass. A timed out child is terminated and fails the run. Inspect only `build/test-work/` for retained generated diagnostics, correct the cause, and rerun `lune run test` twice.

## Rojo Mapping Failure

Confirm every `$path` in `default.project.json` is repository relative, unique, and present. Runtime paths may point only to `src/shared`, `src/server`, and `src/client`. Tests, Lune scripts, tool registries, local environment files, caches, and build output must never be mapped.

After a mapping change, rerun source map validation, two build reproducibility, artifact inventory, native Studio synchronization, and topology parity.

## Occupied Synchronization Port

The accepted server address is `127.0.0.1` and the default port is `34872`. Identify the local process holding the port. Stop only the process you own, or select a reviewed local override after confirming the Studio plugin uses the same loopback port. A nonloopback bind is not accepted for Phase 000.

## Plugin Mismatch

Do not install an unreviewed plugin or use Rojo protocol compatibility as an assumption. Compare the plugin artifact with the reviewed `Rojo.rbxm` record, confirm the Studio plugin identity, restart Studio from a clean plugin state, start the loopback Rojo server, and repeat full synchronization and controlled resynchronization.

## Nonreproducible Artifact

`P000-ARTIFACT-008` means source maps differ. `P000-ARTIFACT-009` means project bytes differ. Remove only generated output under `build/`, keep the tracked `.gitkeep`, verify tools, and rerun from clean inputs. Reject timestamps, absolute paths, cache dependent input, random identifiers, locale dependent serialization, and unstable table order. Never normalize away a real artifact byte difference.

## CI Cache Drift

Rerun the job without restored tool cache. The cache key must include the operating system and pinned manifest digest. A cold run and a warm run must resolve the same executable hashes and produce the same normalized artifact identity. Never make an integrity check optional to repair a cache failure.

## Windows Path Behavior

Use 64 bit Windows PowerShell and keep repository commands at the repository root. Generated manifests use forward slash repository paths even when Windows APIs use backslashes. The process supervisor quotes controlled arguments and returns child output through the same stable command interface. The command contract passes on the recorded clean `windows-2025` runner. Wine execution cannot replace that Windows evidence or the separate native Roblox Studio gate.

## Vinegar Limitations

Vinegar is conditional Linux compatibility. Record its version, Wine version, Studio identity, plugin identity, synchronization, resynchronization, bootstrap, and topology evidence when it is present. A missing or failing Vinegar path is nonblocking, but it cannot weaken the independent native Roblox Studio gate or create an official Linux Studio support claim.
