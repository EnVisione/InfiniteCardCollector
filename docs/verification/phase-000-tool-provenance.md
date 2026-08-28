# Phase 000 Tool Provenance and Security Review

This record covers `P000-TASK-002` and the external tool contracts `EXT-001` through `EXT-005`. The machine readable registry is [`config/tool-artifacts.json`](../../config/tool-artifacts.json).

Review date: 2026-08-28
Reviewer role: repository maintainer
Result: accepted with enforced constraints for the Phase 000 command contract

The review authorizes `P000-TASK-003` to bootstrap and resolve the selected artifacts. Clean Linux, clean Windows, hosted CI, and reproducible build acceptance are recorded separately in [Phase 000 foundation evidence](phase-000-foundation.md). Native Roblox Studio remains a separate mandatory gate.

## Selection

| Tool | Version | Source commit | License | Approved Phase 000 use |
|---|---:|---|---|---|
| Rojo | 7.7.0 | `bcadc97de27ab3800e915abcb72c6c7a3c30f363` | MPL 2.0 | Version verification, build, source map, and loopback only serve |
| Rokit | 1.2.0 | `3b803035635c29c752f6ea1d2befc1473b96c51a` | MIT | Version verification and installation from the tracked manifest |
| StyLua | 2.5.2 | `5ae6e7a55748414b4be30a832afd895014c65352` | MPL 2.0 | Format and check tracked Luau files |
| Selene | 0.31.0 | `9d531b8d3755e139b26c534914e252239014bb3d` | MPL 2.0 | Validate configuration, lint tracked Luau, and generate one pinned Roblox standard library snapshot |
| Lune | 0.10.5 | `e173211a3b529eb53624137931fc11f0a02ff867` | MPL 2.0 | Run reviewed tracked repository scripts |

All selected archives came from the named upstream GitHub release. The downloaded SHA 256 values matched GitHub's release asset digest, both hashes were independently recomputed, archive integrity tests passed, and each archive contained exactly one expected executable basename without path components. Extracted Linux files are 64 bit x86 ELF position independent executables. Extracted Windows files are 64 bit x86 PE executables with ordinary Windows system and runtime imports. No executable showed an ELF runtime search path.

The Selene Linux ZIP stores `selene` with mode `0644`. Bootstrap must verify the archive and executable hashes before adding only the owner executable bit.

## Artifact Integrity

| Artifact | Bytes | SHA 256 | SHA 512 |
|---|---:|---|---|
| `rojo-7.7.0-linux-x86_64.zip` | 5,902,658 | `22503e5839864f9d7c2171c48b536fc229f2cc4d8774c9cc149f60941d864073` | `1afdc696864b86acd5db65f37a6a8533fec04ebd8b44f35ce91d285db5fbdfcb5268dbb8cce0a65e99e528221996ca9239ae5b8ac4fbff838f09eac6a4d596c7` |
| `rojo-7.7.0-windows-x86_64.zip` | 4,556,842 | `2179c44862a10ecbd725bdfeb4abc64e16dc4aad9b6c8f3e1a7c46a87280b949` | `b04625bf6f28157606cfb9f3ea7d438626f9acfa9723a5197b2effdf084eb4e0c1864332562aa204f5bde30c78360c98a5513af9c42cb3b36a1651ec2145710b` |
| `Rojo.rbxm` | 567,993 | `214e5ad84ccdc88f873e0467b6724e4ea9ada8ea340fcb9d4397cb899a67c83f` | `54190faed08c336888bfff26086336717b25a007f4710b60442f1b138f1b1c54541dc1d2e9cac2d1534a75d126fed6e7719984140983f22b4c4e1c6ebcdf1463` |
| `rokit-1.2.0-linux-x86_64.zip` | 3,837,151 | `951a7f3ec3d2a5e021fd1867d32f69f010ee4c2927f644b759578afc59c65fc0` | `bf88c03c13c4b63b8d9a641182c885cb5ca0aae60e62eade02d994e48ca52d6c6c81a17b4c334b32a958facf555a7ef6fcf83a7b421aaa6bde576fcde8c54915` |
| `rokit-1.2.0-windows-x86_64.zip` | 3,638,436 | `f9ba1704014ff67d51e8005f605955c7c26d2429a5312a9419dc477fc310e96d` | `0db3c12eb1c7160d51fbf6c240788de179a6087366a09a04301eafe0ca16f7a85b3657258ab16fd9638cddd271160cae6c3c5371a565a3d7b945d9cb5888b208` |
| `stylua-linux-x86_64.zip` | 3,303,824 | `bcb0d855e91f102f28a370e850f8566b3b44b79e6274d806ea5246837c0fd5ab` | `36f21827e596d69b38665174530cb004035a8942b0a6e740b59da2b8f62e882c19009da604c33c2160d879dbfdd30c725204e9a3cfb55de642fbb201ff2d525f` |
| `stylua-windows-x86_64.zip` | 2,859,281 | `e77d0ea1226b8b389b43f702240091249a96eea25857281f90ea24d0eb9eb969` | `051c3ff6b9ce16a74f8895aebbe5e5b54b9bccdaaf3b2197e884385049a13a20d0968fd00ea733fb8ed40ed533952e54d6417243e302a94505f05deeb070867d` |
| `selene-0.31.0-linux.zip` | 3,651,372 | `dac452422747999ec4919bbb8bb52992b66aae533b60022bf005669de8616671` | `00d68b4cee61385bb044f1c0b84ba2d4d4c234328b14740bf92afef01b2cc4e65d57f9cf165b41877ca03204bcb01f5a41d4f90ca36183f83661e1926f059213` |
| `selene-0.31.0-windows.zip` | 3,041,479 | `c5d5d087daa8e38bd71680b2202a407e5d4bc00fd584a648dec17ef9b29a2b73` | `4cc82b0a1945efb43b5ca415324159e7d9075c4f168d30480a4015b1e0e41364456c973b929f887a9795bce3e5b732834a304d2589da602a15647853bfcb36df` |
| `lune-0.10.5-linux-x86_64.zip` | 5,373,877 | `1fb5dee6a1afa1d300092805c6e660fe06144d29dd68c45cf6956f040667f791` | `781b5e16e33e95f9a578e80ad226b4e014cd9cbc306c9fc8a0777d69738d03f4fd6ccd837ecdfdbbe3e2fb6d71af3900215302d1b9e8cdd7dc48475565e5b93b` |
| `lune-0.10.5-windows-x86_64.zip` | 5,178,086 | `ad0305f5cc6d7ff20996644b40bf7de0de613812f431ca241456e16f9fc89cda` | `098b5a29b567350f52f1de610b84d2554130e8c62ca4f1759d941b6cb53c16d78bd0c6badd6dc585ff969dfe315392756333c9effd5f39028f6cceeef4b8e2cc` |

The registry also pins the byte length and both hashes of every extracted executable. The verifier must validate both the archive and executable records.

## Version Probes

Native Linux probes returned:

```text
lune 0.10.5
Rojo 7.7.0
rokit 1.2.0
selene 0.31.0
stylua 2.5.2
```

The five selected Windows executables returned the same versions under Wine 11.16. That remains a compatibility probe only. The required command line acceptance was completed independently on a clean GitHub hosted `windows-2025` runner using the selected native Windows artifacts. Neither result replaces native Roblox Studio acceptance.

## Upstream Build Provenance

| Tool | Upstream result | Disposition |
|---|---|---|
| Rojo | The exact tag CI passed. Selected Linux and Windows release build jobs passed. The release workflow later failed while uploading the already built plugin through Open Cloud because the upstream credential lacked a scope. | Accepted. The CLI and plugin release assets were already attached, and their GitHub digests match the independently computed hashes. |
| Rokit | The release workflow and selected platform build jobs passed. | Accepted. |
| StyLua | Selected Linux and Windows release build jobs passed. The workflow later failed while publishing the binary npm package. | Accepted. The npm failure does not affect the GitHub release assets. |
| Selene | The full artifact build workflow passed. Unit and exhaustive tests passed. A separate lint job failed, and its retained logs are unavailable. | Accepted for the selected artifact with local format, lint, configuration, and negative fixture verification still required. |
| Lune | The release workflow and every platform build passed at commit `35d7ebe19c8bc5ff62cbb7d36843fab35be2af33`. The release tag points to `e173211a3b529eb53624137931fc11f0a02ff867`, which changes only two changelog heading lines. Later tag CI built and linted successfully but failed network socket tests across platforms. | Accepted for the offline, repository controlled harness. Network capability remains prohibited. |

Rojo, Rokit, and Lune source commits are GitHub verified. The StyLua annotated tag and source commit are unsigned. The Selene lightweight tag source commit is unsigned. Unsigned provenance is compensated by the authoritative release location, successful selected build jobs, two independently recorded hashes, extracted executable hashes, constrained command surfaces, and local negative verification. This is not a general approval of unsigned replacement artifacts.

## Security Review

Each exact release `Cargo.lock` was scanned with `cargo audit 0.22.2` and RustSec database revision `6420e39260b3d771b049954cf5d52b57e2118da4`, dated 2026-08-27. The selected versions contain current advisories. They are accepted only because the Phase 000 command contract removes the reported exploit preconditions or bounds the affected path.

### Common Constraints

1. Downloads use fixed authoritative GitHub release URLs, TLS 1.2 or newer, bounded timeouts, byte limits, and post download SHA 256 and SHA 512 verification.
2. Rojo `serve` binds only to `127.0.0.1`. Host and Origin validation remains enabled. Upload and syncback are prohibited.
3. Rokit may extract only the selected ZIP artifacts. Tar extraction and self update are prohibited.
4. StyLua and Selene process tracked repository paths only. A repository validator rejects path control characters before lint output reaches a terminal.
5. Selene generates one Roblox standard library snapshot from its hard coded GitHub API dump URL under a timeout and before its lint thread pool exists. The result is committed and `roblox-std-source` is set to `pinned`, so ordinary lint is offline.
6. Lune runs reviewed tracked scripts only. Phase scripts may not use network APIs, load remote code, read secrets, escape validated roots, or start an unbounded child process.

### Finding Dispositions

| Tool | Findings | Disposition |
|---|---|---|
| Rojo | `RUSTSEC-2026-0007`, `RUSTSEC-2026-0258` | Inputs are bounded and the server is loopback only. No approved path requests an allocation near the machine word limit. |
| Rojo | `RUSTSEC-2026-0098`, `RUSTSEC-2026-0099`, `RUSTSEC-2026-0104` | The approved Rojo commands do not use the outbound TLS client path. CRL parsing is not configured. |
| Rojo and StyLua | `RUSTSEC-2026-0204` | No selected source formats invalid crossbeam pointers. The vulnerable formatting precondition is absent. |
| Rojo, Rokit, and StyLua | `RUSTSEC-2026-0190` | No selected source calls `anyhow::Error::downcast_mut`. The vulnerable precondition is absent. |
| Rojo and Rokit | `RUSTSEC-2026-0097` | No selected executable installs a custom logger that obtains random data. The vulnerable preconditions are absent. |
| Rokit | `RUSTSEC-2026-0067`, `RUSTSEC-2026-0068` | Only ZIP release assets are allowed. The tar parser is not reached. |
| Rokit | `RUSTSEC-2026-0194`, `RUSTSEC-2026-0195` | The XML path is under self update Markdown rendering. Self update is prohibited. |
| Rokit | `RUSTSEC-2026-0009` | The approved path does not parse RFC 2822 input. |
| Rokit | `RUSTSEC-2026-0037`, `RUSTSEC-2026-0185` | Quinn is absent from the selected Linux and Windows target graphs. |
| Rokit and Lune | `RUSTSEC-2026-0221` | Observed consumers use the default `Event<()>` or another `Send` tag. No selected source calls `Event::with_tag`, so a non Send tag cannot cross threads. |
| Selene | `RUSTSEC-2024-0421`, `RUSTSEC-2024-0336`, `RUSTSEC-2025-0009`, `RUSTSEC-2026-0098`, `RUSTSEC-2026-0099`, `RUSTSEC-2026-0104` | The network path is limited to one bounded request to a hard coded ASCII GitHub hostname. TLS does not encrypt a 64 GB record, CRLs are not configured, and the output is parsed and pinned before ordinary lint. |
| Selene | `RUSTSEC-2020-0071` | The affected local time call occurs only in the single threaded standard library generation command. Pinned lint does not call it. |
| Selene | `RUSTSEC-2025-0055` | Tracked paths with terminal control characters are rejected before lint, and no untrusted text is accepted into the command contract. |
| Selene | `RUSTSEC-2023-0075` | The unsafe YAML advisory affects 16 and 32 bit targets. Both selected targets are 64 bit. |
| Selene | `RUSTSEC-2026-0202` | CXX is absent from the selected Linux and Windows target graphs. |
| Lune | `RUSTSEC-2026-0194`, `RUSTSEC-2026-0195` | Quick XML is absent from the selected Linux and Windows target graphs. |

Unmaintained crates and yanked lockfile entries are recorded in the machine registry. They do not independently establish an exploitable Phase 000 path. The exact tool pins cannot be upgraded silently, so any artifact or plan revision must repeat the complete dependency and capability review.

## Executable Capability Boundaries

Rojo can read tracked project sources, write generated build and source map files, open a local synchronization server, and mutate the connected Studio tree through the reviewed plugin. It is not authorized to publish a place, upload an asset, use syncback, or listen on a network reachable address.

Rokit can download and install executable release assets. Its manifest must contain only the four managed tool pins, and the verifier must reject an unknown source, version, filename, target, archive format, digest, executable basename, or extracted executable digest.

StyLua can rewrite source files. Formatting is limited to tracked Luau source roots and deterministic configuration. Negative fixtures must stay outside the runtime mapping.

Selene can read Luau and configuration files, and the full build can contact GitHub to generate a Roblox standard library. The repository pins that generated file. Normal lint must not contact the network.

Lune exposes filesystem, process, network, and Roblox document capabilities. The Phase 000 harness must enforce repository relative paths, bounded child execution, stable output, no network access, no remote module loading, and no secret access. A script outside the tracked allowlist is not trusted merely because Lune can execute it.

## Invalidation

Any of the following invalidates the affected artifact review and every dependent result:

1. A selected filename, byte length, archive hash, executable hash, release URL, source commit, license, or version changes.
2. RustSec publishes a new applicable advisory or an existing reachability assumption changes.
3. A prohibited command becomes necessary.
4. The Selene standard library becomes floating or ordinary lint contacts the network.
5. Rojo serves beyond loopback or the plugin identity differs from the reviewed `Rojo.rbxm`.
6. Lune scripts gain network, secret, remote code, unrestricted process, or unrestricted filesystem access.

The affected artifact must be quarantined and reviewed again before execution. A version or source change requires an authorized plan revision because the exact pins are part of `CORE-REQ-001`.
