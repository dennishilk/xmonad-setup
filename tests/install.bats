#!/usr/bin/env bats

setup() {
  export ROOT_DIR
  ROOT_DIR="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
  export SUDO_LOG
  SUDO_LOG="${BATS_TEST_TMPDIR}/sudo.log"

  mkdir -p "${BATS_TEST_TMPDIR}/bin"
  cat > "${BATS_TEST_TMPDIR}/bin/sudo" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail

echo "$*" >> "${SUDO_LOG}"

if [[ "${1:-}" == "-v" ]]; then
  exit 0
fi

exit 0
MOCK
  chmod +x "${BATS_TEST_TMPDIR}/bin/sudo"

  export PATH="${BATS_TEST_TMPDIR}/bin:${PATH}"
}

@test "install.sh runs in dry-run mode" {
  run bash "${ROOT_DIR}/install.sh" <<< $'y\ny\n'

  [ "$status" -eq 0 ]
  [[ "$output" == *"DRY-RUN ENABLED"* ]]
  [[ "$output" == *"[DRY-RUN] sudo apt install"* ]]
}

@test "dry-run mode does not execute commands" {
  run bash "${ROOT_DIR}/install.sh" <<< $'y\ny\n'

  [ "$status" -eq 0 ]

  run wc -l "${SUDO_LOG}"
  [ "$status" -eq 0 ]
  [ "${output%% *}" -eq 1 ]

  run cat "${SUDO_LOG}"
  [ "$status" -eq 0 ]
  [ "$output" = "-v" ]
}
