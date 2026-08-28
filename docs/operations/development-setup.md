# Development Setup

## Current Support

The command line foundation targets Linux x86_64 and Windows x86_64. Linux x86_64 local and clean environment verification passes. A clean GitHub hosted `windows-2025` runner also passes bootstrap, tool verification, formatting, linting, tests, source map generation, reproducible build generation, documentation checks, secret checks, and artifact inspection.

Authoritative runtime acceptance requires native Roblox Studio on a platform Roblox currently supports. Linux Studio through Vinegar is conditional compatibility. The exact Vinegar 1.9.4, Wine 11.16, Studio `0.736.0.7361346`, and Rojo 7.7.0 snapshot passed clean synchronization, resynchronization, topology, and bootstrap checks. It remains additional evidence and never replaces native Roblox Studio acceptance.

The protected product contract is `docs/general/plan.md`. The immutable saved execution goal is `docs/plan/goal.md`. Ordinary implementation evidence belongs in the repository, tests, this documentation, and `docs/verification/`, never in those protected contracts.

## Pinned Tools

| Tool | Version | Role |
| --- | --- | --- |
| Rokit | 1.2.0 | Tool resolution and executable links |
| Rojo | 7.7.0 | Source map, project build, and Studio synchronization |
| StyLua | 2.5.2 | Deterministic Luau formatting |
| Selene | 0.31.0 | Luau and Roblox linting |
| Lune | 0.10.5 | Portable tests, validation, artifact generation, and CI orchestration |

The selected release archives, executable hashes, license records, provenance, and security dispositions are in `config/tool-artifacts.json` and [Phase 000 tool provenance](../verification/phase-000-tool-provenance.md). Executables and downloaded archives are never committed.

## Linux Bootstrap

The Linux bootstrap requires Bash, curl, jq, unzip, `sha256sum`, `sha512sum`, and the standard core utilities. Source the script so `ROKIT_ROOT` and `PATH` remain available in the current shell.

```bash
source scripts/bootstrap-tools.sh
```

The script downloads each exact Linux x86_64 ZIP from its reviewed GitHub release, checks its size, SHA 256, SHA 512, single executable archive layout, extracted size, and extracted hashes. It refuses an existing conflicting executable. It then seeds Rokit trust and install state from the pinned registry and runs the exact manifest resolution command.

## Windows Bootstrap

Use 64 bit Windows PowerShell. The script relies only on PowerShell and the .NET ZIP and hashing libraries.

```powershell
.\scripts\bootstrap-tools.ps1
```

The Windows script applies the same registry driven size, SHA 256, SHA 512, archive layout, extracted executable, trust, alias, and path checks to the selected Windows x86_64 artifacts. The clean `windows-2025` acceptance run is recorded in [Phase 000 foundation evidence](../verification/phase-000-foundation.md). This command line acceptance does not replace the separate native Roblox Studio gate.

## Managed Tool Resolution

Run these commands from the repository root after bootstrap.

```console
rokit install
lune run verify-tools
```

`rokit install` resolves only the four managed tools in `rokit.toml`. The bootstrap preloads only independently verified executable bytes, so install creates Rokit links without accepting an unverified download. `lune run verify-tools` checks Rokit itself plus every managed executable. It prints machine neutral paths rooted at `$ROKIT_ROOT`, exact versions, platform artifact names, and executable integrity identities.

If a new shell cannot resolve the tools, set `ROKIT_ROOT` to the same Rokit directory and prepend its `bin` directory to `PATH`. Do not point `ROKIT_ROOT` at the repository, a cache shared with untrusted work, or an unrelated installation.

## Exact Command Contract

Format the tracked Luau source and scripts:

```console
stylua .
```

Check formatting without changes:

```console
stylua --check .
```

Lint every tracked Luau source set against the pinned Roblox standard library:

```console
selene .
```

Run deterministic repository and harness tests:

```console
lune run test
```

Generate the complete repository relative source map:

```console
rojo sourcemap default.project.json --output build/infinite-card-collector.sourcemap.json
```

Build the project artifact:

```console
rojo build default.project.json --output build/infinite-card-collector.rbxlx
```

Serve the exact mapping to the matching Rojo Studio plugin over loopback only:

```console
rojo serve default.project.json --address 127.0.0.1 --port 34872
```

Create the release candidate artifact packet and prove two isolated builds are byte identical:

```console
lune run artifact
```

Validate required documents, links, support claims, and this command inventory:

```console
lune run docs
```

Scan candidate repository inputs and generated artifacts for secret and machine path leakage:

```console
lune run secrets
```

Run the complete gate in the required order:

```console
lune run ci
```

All commands exit zero only on acceptance. Failures use stable `P000` identifiers and return a nonzero status. Child processes are supervised with bounded timeouts. Output is sanitized before a child failure reaches the command transcript.

## Generated Files

`build/.gitkeep` preserves the output directory required by the direct Rojo commands. Everything else under `build/` is ignored. A successful artifact run creates:

| Path | Purpose |
| --- | --- |
| `build/infinite-card-collector.rbxlx` | Reproducible project candidate |
| `build/infinite-card-collector.sourcemap.json` | Repository relative Rojo source map |
| `build/artifact-manifest.json` | Canonical tool, input, source map, artifact, and instance inventory record |
| `build/infinite-card-collector.rbxlx.sha256` | SHA 256 verification file |
| `build/infinite-card-collector.rbxlx.sha512` | SHA 512 verification file |

The manifest contains no generation timestamp, random identifier, locale dependent value, username, or machine path. Rerunning `lune run artifact` replaces generated output from tracked inputs and removes isolated work directories after success.

## Environment and Secrets

`config/environment.json` contains only safe defaults. Rojo binds to `127.0.0.1:34872`, output stays under `build/`, and Studio synchronization is loopback only. `config/environment.local.json` is the ignored local override path. It must never contain a credential or enter a candidate artifact.

Phase 000 requires no Roblox publishing credential and no repository secret. Do not add Roblox cookies, GitHub tokens, passwords, private logs, raw player profiles, or machine specific Studio paths. Diagnostics must use repository relative paths or the stable `$REPOSITORY`, `$ROKIT_ROOT`, and `$USER_HOME` labels.

## Recovery

On a bootstrap hash, size, or archive layout failure, stop. Remove only the incomplete temporary download, verify the registry against the authoritative release, and rerun bootstrap. Never waive the mismatch.

On PATH shadowing, inspect the first resolved executable, remove the unrelated path entry from the current shell, prepend the expected Rokit `bin` directory, and rerun `lune run verify-tools`.

On a partial Rokit installation, use the same `ROKIT_ROOT`, rerun the checksum first bootstrap, then rerun `rokit install` and `lune run verify-tools`. The bootstrap refuses to overwrite conflicting executable bytes.

On a formatter, linter, test, source map, build, documentation, secret, or artifact failure, correct the reported stable identifier and rerun from that lowest failed layer through `lune run ci`. See [toolchain troubleshooting](../troubleshooting/toolchain.md) for targeted checks.
