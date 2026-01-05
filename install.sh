#!/usr/bin/env bash
set -e

# ==========================================================
# Debian 13 XMonad Setup (generic Intel/NVIDIA/)
# ==========================================================

DRY_RUN=false
INSTALL_ALL=false

# --------------------------
# Helpers
# --------------------------
ask() {
  read -rp "$1 [y/N]: " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

run() {
  if $DRY_RUN; then
    echo "[DRY-RUN] $*"
  else
    eval "$@"
  fi
}

step() {
  local prompt="$1"
  local func="$2"
  if $INSTALL_ALL || ask "$prompt"; then
    $func
  fi
}

# --------------------------
# Dry-Run handling
# --------------------------
if ask "Enable DRY-RUN mode (no changes will be made)?"; then
  DRY_RUN=true
  echo ">>> DRY-RUN ENABLED"
fi

if $DRY_RUN && ask "After DRY-RUN, install EVERYTHING automatically (INSTALL ALL)?"; then
  INSTALL_ALL=true
fi

if ! sudo -v; then
  echo "This script requires sudo privileges."
  exit 1
fi

echo "== Debian 13 XMonad Setup =="

# ==========================================================
# Functions
# ==========================================================

enable_repos() {
  if $DRY_RUN; then
    echo "[DRY-RUN] enable contrib / non-free repositories"
    return
  fi

  if ! grep -Eq '^[[:space:]]*deb([[:space:]]|$)' /etc/apt/sources.list; then
    local codename version_id
    . /etc/os-release
    codename="$VERSION_CODENAME"
    version_id="$VERSION_ID"
    if [[ -z "$codename" && "$version_id" == "13" ]]; then
      codename="trixie"
    elif [[ -z "$codename" ]]; then
      codename="stable"
    fi
    cat <<EOF | sudo tee /etc/apt/sources.list >/dev/null
deb http://deb.debian.org/debian ${codename} main contrib non-free non-free-firmware
deb http://deb.debian.org/debian ${codename}-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security ${codename}-security main contrib non-free non-free-firmware
EOF
  fi

  local awk_script
  awk_script="$(mktemp)"
  cat > "$awk_script" <<'AWK'
function has(field, n, target, i) {
  for (i = 1; i <= n; i++) {
    if (field[i] == target) return 1
  }
  return 0
}
/^[[:space:]]*deb(-src)?[[:space:]]/ && $0 !~ /^[[:space:]]*#/ {
  n = split($0, fields, /[[:space:]]+/)
  if (has(fields, n, "main") && !has(fields, n, "contrib") \
      && !has(fields, n, "non-free") && !has(fields, n, "non-free-firmware")) {
    $0 = $0 " contrib non-free non-free-firmware"
  }
}
{ print }
AWK

  sudo awk -f "$awk_script" /etc/apt/sources.list \
    | sudo tee /etc/apt/sources.list >/dev/null
  rm -f "$awk_script"
  run "sudo apt update"
}

install_nvidia() {
  run "sudo apt install -y linux-headers-\$(uname -r)"
  run "sudo apt install -y nvidia-driver nvidia-settings"
}

install_base() {
  run "sudo apt install --no-install-recommends -y \
    xorg xinit dbus-x11 \
    network-manager \
    lightdm lightdm-gtk-greeter \
    pipewire pipewire-audio wireplumber alsa-utils \
    firmware-misc-nonfree \
    mesa-vulkan-drivers intel-media-va-driver \
    xserver-xorg-video-intel \
    fonts-dejavu fonts-jetbrains-mono \
    git curl unzip wget gnupg"
  run "sudo systemctl enable NetworkManager"
  run "sudo systemctl enable lightdm"
}

install_xmonad() {
  run "sudo apt install --no-install-recommends -y \
    xmonad xmobar suckless-tools \
    ghc libghc-xmonad-dev libghc-xmonad-contrib-dev \
    kitty dmenu feh scrot \
    pamixer brightnessctl"
}

deploy_configs() {
  if $DRY_RUN; then
    echo "[DRY-RUN] deploy xmonad.hs, kitty.conf, wallpaper"
    return
  fi

  mkdir -p "$HOME/.xmonad" "$HOME/.config/kitty" "$HOME/Pictures/wallpapers" "$HOME/Pictures/screenshots"
  cp ./xmonad/xmonad.hs "$HOME/.xmonad/xmonad.hs"
  cp ./kitty/kitty.conf "$HOME/.config/kitty/kitty.conf"
  cp ./assets/wallpapers/default.png "$HOME/Pictures/wallpapers/default.png"
}

install_chrome() {
  run "sudo apt install -y gnupg curl wget"
  run "wget -qO - https://dl.google.com/linux/linux_signing_key.pub \
    | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg"
  run "echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] \
    http://dl.google.com/linux/chrome/deb/ stable main' \
    | sudo tee /etc/apt/sources.list.d/google-chrome.list"
  run "sudo apt update"
  run "sudo apt install -y google-chrome-stable"
}

install_steam() {
  run "sudo dpkg --add-architecture i386"
  run "sudo apt update"
  run "sudo apt install -y steam"
}

install_fish_fastfetch() {
  run "sudo apt install -y fish fastfetch"
  if $DRY_RUN; then
    echo "[DRY-RUN] configure fish + fastfetch"
    return
  fi
  mkdir -p "$HOME/.config/fish"
  cat > "$HOME/.config/fish/config.fish" <<'EOF'
if status is-interactive
    fastfetch
end
EOF
  chsh -s /usr/bin/fish
}

enable_zram() {
  run "sudo apt install -y zram-tools"
  run "sudo sed -i 's/#ALGO=.*/ALGO=zstd/' /etc/default/zramswap"
  run "sudo sed -i 's/#PERCENT=.*/PERCENT=25/' /etc/default/zramswap"
  run "sudo systemctl enable zramswap"
}

cleanup_system() {
  run "sudo apt autoremove -y"
  run "sudo apt clean"
}

# ==========================================================
# Execution order
# ==========================================================

step "Enable contrib / non-free repositories?" enable_repos
step "Install NVIDIA driver (if needed)?" install_nvidia
step "Install base system (X11, LightDM, Audio, Network)?" install_base
step "Install XMonad, Kitty, dmenu and build dependencies?" install_xmonad
step "Deploy configs (xmonad, kitty, wallpaper)?" deploy_configs
step "Install Google Chrome?" install_chrome
step "Install Steam (enable i386)?" install_steam
step "Install Fish shell + Fastfetch?" install_fish_fastfetch
step "Enable ZRAM swap?" enable_zram
step "Run cleanup?" cleanup_system

echo
echo "============================================"
$DRY_RUN && echo "DRY-RUN completed — no changes were made."
echo "DONE. Reboot recommended."
echo "LightDM → Session → XMonad"
echo "============================================"
