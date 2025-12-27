#!/usr/bin/env bash
set -e

# ==========================================================
# xmonad-setup – Debian 13 (X11 only, generic hardware)
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
# DRY-RUN handling
# --------------------------
if ask "Enable DRY-RUN mode (no changes will be made)?"; then
  DRY_RUN=true
  echo ">>> DRY-RUN ENABLED"
fi

if $DRY_RUN && ask "After DRY-RUN, install EVERYTHING automatically?"; then
  INSTALL_ALL=true
fi

if ! sudo -v; then
  echo "This script requires sudo privileges."
  exit 1
fi

echo "== xmonad-setup – Debian 13 =="

# ==========================================================
# Functions
# ==========================================================

enable_repos() {
  run "sudo sed -i 's/main/main contrib non-free non-free-firmware/' /etc/apt/sources.list"
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
    mesa-vulkan-drivers \
    fonts-dejavu fonts-jetbrains-mono \
    git curl wget unzip"

  run "sudo systemctl enable NetworkManager"
  run "sudo systemctl enable lightdm"
}

install_xmonad() {
  run "sudo apt install --no-install-recommends -y \
    xmonad xmobar suckless-tools \
    ghc libghc-xmonad-dev libghc-xmonad-contrib-dev \
    kitty dmenu feh scrot \
    pamixer brightnessctl \
    picom"
}

deploy_configs() {
  if $DRY_RUN; then
    echo "[DRY-RUN] deploy xmonad.hs, kitty.conf, picom.conf, wallpaper"
    return
  fi

  mkdir -p ~/.xmonad
  mkdir -p ~/.config/kitty
  mkdir -p ~/.config/picom
  mkdir -p ~/Pictures/wallpapers
  mkdir -p ~/Pictures/screenshots

  cp ./xmonad/xmonad.hs ~/.xmonad/xmonad.hs
  cp ./kitty/kitty.conf ~/.config/kitty/kitty.conf
  cp ./assets/wallpapers/default.png ~/Pictures/wallpapers/default.png

  # picom config (minimal, opacity-ready)
  cat > ~/.config/picom/picom.conf <<'EOF'
#################################
# Backend
#################################
backend = "glx";
vsync = true;

#################################
# Opacity
#################################
active-opacity = 1.0;
inactive-opacity = 0.90;
frame-opacity = 0.90;

opacity-rule = [
  "90:class_g = 'kitty'",
  "95:class_g = 'Google-chrome'",
  "95:class_g = 'firefox'",
  "100:fullscreen"
];

#################################
# Shadows (disabled by default)
#################################
shadow = false;
EOF
}

install_chrome() {
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

  mkdir -p ~/.config/fish
  cat > ~/.config/fish/config.fish <<'EOF'
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
step "Install NVIDIA driver (proprietary)?" install_nvidia
step "Install base system (X11, LightDM, Audio, Network)?" install_base
step "Install XMonad, picom and core tools?" install_xmonad
step "Deploy default configs (xmonad, kitty, picom, wallpaper)?" deploy_configs
step "Install Google Chrome?" install_chrome
step "Install Steam (enable i386 multiarch)?" install_steam
step "Install fish shell and fastfetch?" install_fish_fastfetch
step "Enable zram swap?" enable_zram
step "Run cleanup?" cleanup_system

echo
echo "============================================"
$DRY_RUN && echo "DRY-RUN completed — no changes were made."
echo "DONE. Reboot recommended."
echo "LightDM → Session → XMonad"
echo "============================================"
