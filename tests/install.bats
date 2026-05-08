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

@test "dry-run without install-all only runs confirmed steps" {
  run bash "${ROOT_DIR}/install.sh" <<< $'y\nn\ny\nn\nn\nn\nn\nn\nn\nn\nn\n'

  [ "$status" -eq 0 ]
  [[ "$output" == *"[DRY-RUN] sudo apt install -y amd64-microcode"* || "$output" == *"[DRY-RUN] sudo apt install -y intel-microcode"* ]]
  [[ "$output" != *"[DRY-RUN] sudo apt install -y nvidia-driver nvidia-settings nvidia-vulkan-icd"* ]]
  [[ "$output" != *"[DRY-RUN] sudo apt install --no-install-recommends -y     xorg xinit dbus-x11"* ]]
}

@test "non-dry-run executes sudo commands for selected steps" {
  run bash "${ROOT_DIR}/install.sh" <<< $'n\nn\ny\nn\nn\nn\nn\nn\nn\nn\nn\n'

  [ "$status" -eq 0 ]

  run cat "${SUDO_LOG}"
  [ "$status" -eq 0 ]
  [[ "$output" == *"-v"* ]]
  [[ "$output" == *"apt install -y amd64-microcode"* || "$output" == *"apt install -y intel-microcode"* ]]
}
