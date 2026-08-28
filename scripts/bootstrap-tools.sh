#!/usr/bin/env bash
set -euo pipefail

task_script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
task_repo_root="$(cd -- "${task_script_dir}/.." && pwd -P)"
task_registry="${task_repo_root}/config/tool-artifacts.json"

task_fail() {
    printf 'bootstrap error, %s\n' "$1" >&2
    return 1
}

for task_command in curl jq unzip sha256sum sha512sum install mktemp stat; do
    command -v "${task_command}" >/dev/null 2>&1 || task_fail "missing required command ${task_command}"
done

if [[ "$(uname -s)" != "Linux" || "$(uname -m)" != "x86_64" ]]; then
    task_fail "supported target is linux x86_64"
fi

jq -e '
    .schema_version == 1
    and ([.tools[].id] | sort == ["lune", "rojo", "rokit", "selene", "stylua"])
    and ([.tools[] | select(.id != "rokit") | .rokit_spec | type] | all(. == "string"))
' "${task_registry}" >/dev/null || task_fail "artifact registry contract is invalid"

task_bootstrap_dir="$(mktemp -d /tmp/infinite-card-collector-bootstrap.XXXXXXXX)"
task_cleanup() {
    if [[ "${task_bootstrap_dir}" == /tmp/infinite-card-collector-bootstrap.* ]]; then
        find "${task_bootstrap_dir}" -depth -delete
    fi
}
trap task_cleanup EXIT

task_rokit_root="${ROKIT_ROOT:-${HOME}/.rokit}"
export ROKIT_ROOT="${task_rokit_root}"
mkdir -p "${ROKIT_ROOT}/bin" "${ROKIT_ROOT}/tool-storage"

task_trusted_ids=()
task_installed_specs=()
task_alias_names=()
task_alias_sources=()
task_alias_hashes=()

while IFS=$'\t' read -r task_id task_version task_alias task_spec task_filename task_url task_size task_sha256 task_sha512 task_executable task_executable_size task_executable_sha256 task_executable_sha512; do
    [[ "${task_filename}" != */* && "${task_executable}" != */* ]] || task_fail "artifact names must be basenames"
    [[ "${task_url}" == https://github.com/* ]] || task_fail "artifact source must be github over https"

    task_archive="${task_bootstrap_dir}/${task_filename}"
    task_extracted="${task_bootstrap_dir}/${task_id}"

    curl --silent --show-error --proto '=https' --tlsv1.2 --fail --location --retry 3 --connect-timeout 15 --max-time 300 --output "${task_archive}" "${task_url}"

    [[ "$(stat -c '%s' "${task_archive}")" == "${task_size}" ]] || task_fail "${task_filename} size mismatch"
    [[ "$(sha256sum "${task_archive}" | cut -d ' ' -f 1)" == "${task_sha256}" ]] || task_fail "${task_filename} sha256 mismatch"
    [[ "$(sha512sum "${task_archive}" | cut -d ' ' -f 1)" == "${task_sha512}" ]] || task_fail "${task_filename} sha512 mismatch"

    mapfile -t task_entries < <(unzip -Z1 "${task_archive}")
    [[ "${#task_entries[@]}" == 1 && "${task_entries[0]}" == "${task_executable}" ]] || task_fail "${task_filename} archive layout mismatch"
    unzip -p "${task_archive}" "${task_executable}" > "${task_extracted}"

    [[ "$(stat -c '%s' "${task_extracted}")" == "${task_executable_size}" ]] || task_fail "${task_executable} size mismatch"
    [[ "$(sha256sum "${task_extracted}" | cut -d ' ' -f 1)" == "${task_executable_sha256}" ]] || task_fail "${task_executable} sha256 mismatch"
    [[ "$(sha512sum "${task_extracted}" | cut -d ' ' -f 1)" == "${task_executable_sha512}" ]] || task_fail "${task_executable} sha512 mismatch"

    if [[ "${task_id}" == "rokit" ]]; then
        task_target="${ROKIT_ROOT}/bin/rokit"
    else
        [[ "${task_alias}" =~ ^[a-z0-9]+$ ]] || task_fail "${task_id} alias is invalid"
        task_spec_id="${task_spec%@*}"
        task_spec_version="${task_spec##*@}"
        task_author="${task_spec_id%%/*}"
        task_name="${task_spec_id##*/}"
        task_target="${ROKIT_ROOT}/tool-storage/${task_author,,}/${task_name,,}/${task_spec_version}/${task_name,,}"
        task_trusted_ids+=("${task_spec_id}")
        task_installed_specs+=("${task_spec}")
        task_alias_names+=("${task_alias}")
        task_alias_sources+=("${task_target}")
        task_alias_hashes+=("${task_executable_sha256}")
    fi

    mkdir -p "$(dirname -- "${task_target}")"
    if [[ -e "${task_target}" ]]; then
        [[ "$(sha256sum "${task_target}" | cut -d ' ' -f 1)" == "${task_executable_sha256}" ]] || task_fail "existing ${task_target} is not the pinned executable"
    else
        install -m 0755 "${task_extracted}" "${task_target}"
    fi
done < <(jq -r '
    .tools[] as $tool
    | $tool.artifacts[]
    | select(.platform == "linux-x86_64")
    | [
        $tool.id,
        $tool.version,
        ($tool.rokit_alias // "not-managed"),
        ($tool.rokit_spec // "not-managed"),
        .filename,
        .url,
        (.size | tostring),
        .sha256,
        .sha512,
        .executable,
        (.executable_size | tostring),
        .executable_sha256,
        .executable_sha512
    ]
    | @tsv
' "${task_registry}")

task_trusted_json="$(printf '%s\n' "${task_trusted_ids[@]}" | jq -Rsc 'split("\n")[:-1]')"
task_installed_json="$(printf '%s\n' "${task_installed_specs[@]}" | jq -Rsc 'split("\n")[:-1]')"
task_cache="${ROKIT_ROOT}/tool-storage/cache.json"
task_cache_next="$(mktemp "${ROKIT_ROOT}/tool-storage/cache.json.XXXXXXXX")"
jq -n --argjson trusted "${task_trusted_json}" --argjson installed "${task_installed_json}" '
    {
        trusted: ($trusted | unique),
        installed: ($installed | unique)
    }
' > "${task_cache_next}"
mv "${task_cache_next}" "${task_cache}"

export PATH="${ROKIT_ROOT}/bin:${PATH}"
hash -r
[[ "$(command -v rokit)" == "${ROKIT_ROOT}/bin/rokit" ]] || task_fail "rokit is shadowed on path"
[[ "$(rokit --version)" == "rokit 1.2.0" ]] || task_fail "rokit version mismatch"

cd -- "${task_repo_root}"
rokit install

for task_alias_index in "${!task_alias_names[@]}"; do
    task_alias_target="${ROKIT_ROOT}/bin/${task_alias_names[${task_alias_index}]}"
    install -m 0755 "${task_alias_sources[${task_alias_index}]}" "${task_alias_target}"
    [[ "$(sha256sum "${task_alias_target}" | cut -d ' ' -f 1)" == "${task_alias_hashes[${task_alias_index}]}" ]] || task_fail "${task_alias_target} sha256 mismatch"
done

printf 'bootstrap complete, rokit root %s\n' "${ROKIT_ROOT}"
