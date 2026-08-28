# repository instructions

## review priorities

- focus on correctness, security, compatibility, regressions, lifecycle behavior, concurrency, persistence, protocol changes, and missing verification.
- inspect the complete change and affected call paths. avoid style only comments unless they identify a real maintainability or correctness risk.
- cite exact files and behavior. explain a reproducible failure mode for every blocking finding.
- never include credentials, private data, generated content notices, or assistant attribution.
- treat repository documentation and the active plan under `docs/general/` as sources of truth.

## environment and verification

- run the repository documented formatting, tests, and build.

## architecture

- follow existing architecture, naming, formatting, and error handling conventions.

## pull requests

- verify that behavior, configuration, commands, apis, architecture, and troubleshooting documentation changed together when required.
- do not approve when required compilation, tests, packaging, or smoke checks failed.
- check for build output, caches, logs, local configuration, credentials, and unrelated changes in the final diff.
