# Phase 000 Foundation Evidence

## Scope

This rolling evidence record covers the reproducible repository foundation for `CORE-REQ-001`. It records ordinary implementation evidence only. It does not modify the protected plan or saved goal, and it does not claim Phase 000 completion while mandatory gates remain.

## Current Result

The reviewed Linux x86_64 foundation passes locally and from a fresh clone. The complete hosted contract passes on Linux x86_64 and clean Windows x86_64. The repository has exact tool resolution, a strict typed Luau boundary skeleton, deterministic formatting and linting, a deterministic Lune harness, safe environment defaults, source map validation, byte identical Rojo builds, canonical artifact metadata, SHA 256, SHA 512, documentation checks, secret checks, and bounded CI evidence.

Phase 000 remains open. The selected qualified Vinegar Studio route passes. Final candidate reconciliation, final diff audit, pull request checks, independent review capability disposition, GitHub merge commit, signed `phase-000` tag, and post merge wiki synchronization are not yet complete.

## Verified Inputs

| Contract | Result |
| --- | --- |
| Saved goal SHA 256 | `fbe125681fc52b42131aa7aa1f4f61902d33c7912adc982ebcb7dbd87cff2f69` matched before implementation. |
| Master plan SHA 256 | Current authorized plan `55e38a51c424446cb10f2b52482eb44b3bbec1c70570b0cb4d2d3395b640c3a8` was reread through EOF. |
| Plan set SHA 256 | Current authorized plan set `4b7b03e8d70b5f5650e265f115d15878329742409825b07cd515079882556b3c` validated after the owner authorized `DEC-015` revision. |
| Approved base | `311f6d1a3342b53aa280dda53d13e33cb269284f` on `origin/main`. |
| Phase branch | `envy/core-phase-000`. |
| Tool artifacts | Five tools, ten platform executables, and the reviewed Rojo plugin are recorded in `config/tool-artifacts.json`. |
| Roblox standard library | Generated once by Selene 0.31.0, timestamp normalized, then pinned as `roblox.yml`. |

The complete release, license, dependency, security, archive, executable, and plugin evidence is in [Phase 000 tool provenance](phase-000-tool-provenance.md).

## Implemented Boundaries

`default.project.json` maps only shared, server, and client source roots. Server controlled asset folders and a responsive GUI root are declarative. The runtime artifact excludes tests, Lune scripts, build tools, registries, local configuration, CI files, and evidence documents.

Every applicable Luau file begins with `--!strict`. Static negative fixtures reject shared access to server or client services, server access to client GUI paths, client access to server services, runtime access to tools or tests, remote loaders, numeric asset requires, URLs, nonstrict source, duplicate mappings, missing source, and absolute source map paths.

## Linux Verification

The checksum first Linux bootstrap completed from an initially empty isolated Rokit root. It downloaded and independently verified every selected Linux archive and extracted executable, seeded the Rokit cache, ran `rokit install`, and reproduced exact version output for all five tools. A separate clean PATH check passed, and an earlier shadow executable failed with `P000-TOOLS-025`.

The following direct checks pass locally:

```console
lune run verify-tools
stylua --check .
selene .
lune run test
lune run artifact
lune run secrets
```

The initial project source map contains four mapped inputs. The built project inventory contains the intended `ReplicatedStorage`, `ServerScriptService`, `ServerStorage`, `StarterGui`, and `StarterPlayer` foundation topology with no development or test instance.

Two isolated source maps and two isolated `.rbxlx` builds are byte identical. `build/artifact-manifest.json` is canonical JSON and records the source commit, project map, build input digest, mapped paths, exact tool versions, source map hashes, artifact hashes, and instance inventory hashes. It contains no generation timestamp or machine path.

## Clean Environment and Hosted CI

An independent Linux x86_64 reproduction cloned commit `a4adfaf14de3e074c6c062c1985dd5140bd0d191` with none of the five project tools initially available on `PATH`. Cold and warm checksum first bootstrap both passed. Direct tool verification, formatting, formatting check, lint, two deterministic test runs, source map generation, project build, artifact generation, documentation validation, secret scanning, and `lune run ci` all exited zero. The two test transcripts were byte identical with SHA 256 `d50a9d852baa9b7d9759f05a0b104ef02eaa8708c9c032519429047ce082e596`.

The clean Linux artifact had SHA 256 `6e77c39b4a2640be76b8320e37a46df0b0edf499ecf0567415d162ed17608529` and SHA 512 `d17b283178cf75f3a5f1bd9a964a76e1dde9f407ef70b44374f012c9fba0da0a56a801dbe4b613973e8e32fe04347cd4e3471a49c8b24f83b6bcdc30e4b2cd04`. Its source map SHA 256 was `195644838d30163aa5bcc0636e321d1d0d6a4819d62c0191835293145e09c84d`, source input SHA 256 was `c9fbb69097d7b17e6ecc63fd588268c4afe23e5213ab1699362989500d7034f3`, and instance inventory SHA 256 was `884ecb3912559abfad45dec05982e4c1c7eabd69207b578abc3189dc791b1d8d`.

GitHub Actions run `33201999116` passed the same nine gate `lune run ci` contract on `ubuntu-24.04` and `windows-2025`. Linux job `98953478817` passed with the pinned cache restored. Windows job `98953478936` began without a matching tool cache, downloaded and verified the selected native Windows artifacts, and passed all nine gates. The run used least privilege, twenty minute job timeouts, superseded run cancellation, three day evidence retention, and SHA pinned Node 24 action releases.

## Qualified Vinegar Studio Acceptance

The selected qualified Vinegar route passed on this exact environment and independently satisfies the Phase 000 Studio gate. It runs the actual Windows Roblox Studio binary under Vinegar and Wine and requires every identity and behavior field below.

| Component | Verified identity |
| --- | --- |
| Vinegar | 1.9.4, Flathub stable commit `addf1c36ba534d500952e7dcd310b1afc8253670c85d4f078f0623c43d508f5f` |
| Wine | Vinegar Kombucha `kombucha-stable+20260824153321`, reporting Wine 11.16 |
| Roblox Studio | LIVE channel deployment `version-268c7d941ba34c1a`, client `0.736.0.7361346` |
| Rojo plugin | Release 7.7.0 `Rojo.rbxm`, SHA 256 `214e5ad84ccdc88f873e0467b6724e4ea9ada8ea340fcb9d4397cb899a67c83f`, SHA 512 `54190faed08c336888bfff26086336717b25a007f4710b60442f1b138f1b1c54541dc1d2e9cac2d1534a75d126fed6e7719984140983f22b4c4e1c6ebcdf1463` |
| Rojo server | CLI 7.7.0 bound only to `127.0.0.1:34872` |

The run began from a generated empty DataModel. Before synchronization, the five mapped services contained none of the project descendants. The reviewed plugin presented the complete create set from `default.project.json`; after acceptance, Studio contained the same 18 service, folder, script, and GUI inventory entries as the built artifact. No extra mapped descendant or development tool appeared.

A controlled source change moved `BootstrapContract.contractVersion` from 1 to 2. Studio received the update without a manual copy. Reverting the tracked source to 1 removed version 2 from the synchronized ModuleScript. In play mode, the server and client bootstrap scripts were enabled and each reported `BootstrapState` as `ready` and `BootstrapContractVersion` as 1. The Studio console returned no project message or error during the bootstrap run.

The same artifact also opened successfully as a local `.rbxlx`. Vinegar and Wine emitted compatibility warnings outside the project console, including graphics and built in asset warnings. These did not change the synchronized project tree or bootstrap result. This packet supports only the exact tested qualified snapshot and makes no official native Linux Studio support claim.

## Candidate Continuity

The complete Studio workflow was exercised at revision `ef6b0ed648f66ab3035cce5245cd0ab3b9679059`. Candidate reconciliation found no byte change from that revision in `default.project.json`, `rokit.toml`, or any file under `src/`. Their SHA 256 identities are:

| Studio affecting input | SHA 256 |
| --- | --- |
| `default.project.json` | `245b28857ab6abf2e77139a89224b2437f5ebd251a7f205dfe433abfe75b1e8f` |
| `rokit.toml` | `9d6b91cf94aa7aea2ef7ab957047441cc07229e517223c43a0161455d5b2e504` |
| `src/shared/BootstrapContract.luau` | `b7347b6c4a9e1f382ba1517c87d399fd3afda64690c971daaba6a372cc6cae24` |
| `src/server/Bootstrap.server.luau` | `ddf3f4170791f4919ce1816c6be73d709d9005a3d971fffdddb897ef399a5d29` |
| `src/client/ClientBootstrap.client.luau` | `a05fce4b1e6bfe50ea7ecfaa50c0e10da34911b1a625a54b484d00ebdff56a4c` |

The canonical Rojo address and Studio connection subset has SHA 256 `652c6d021d6046ccaf9a2787c817362c6035c131bba4b1fe782e9b06726f31e5` at both revisions. The selected Rojo CLI and plugin identity subset has SHA 256 `1cd5daa71bf33466175825adb2cd457e91ecca7bc5a550c8b56e3f7ab8cdab16` at both revisions. The environment schema change only reclassifies the accepted Studio routes and selects the already exercised qualified route. It does not change the loopback connection, project mapping, runtime source, Rojo executable, or reviewed plugin bytes.

Live MCP reconciliation listed one connected Studio instance named `infinite-card-collector.rbxlx` in Edit mode. The synchronized project roots and descendants remained present, the reviewed Rojo 7.7.0 plugin was loaded, and the project console remained empty. The final pull request packet must name the final branch head and transfer this content addressed Studio packet to it before merge.

## Negative Verification

The deterministic harness proves nonzero outcomes for an assertion failure, an uncaught exception, a path escape, a network capability attempt, an unsafe environment, a secret shaped environment key, an occupied trust boundary through PATH shadowing, invalid formatting, a Selene violation, an absolute source map, a missing source, duplicate source mapping, and a supervised timeout.

Negative snippets are inert `.txt` or JSON fixtures. The network fixture is rejected before module loading. The secret shaped key is assembled in memory. No negative fixture contains a real credential or external request.

## Evidence Invalidation

A change to any tool version, artifact URL, archive hash, executable hash, source commit, license, security disposition, `rokit.toml`, `roblox.yml`, formatter or linter configuration, `default.project.json`, runtime source, Lune harness, environment schema, command, normalization rule, workflow, plugin, or Studio identity invalidates its dependent evidence. Rerun from the lowest changed layer through the final audit.

Generated evidence under `build/` is intentionally untracked. Final completion evidence must be regenerated from the final phase candidate and linked to successful hosted CI, the selected Studio route, merge, signed tag, and wiki state.
