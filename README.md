## 🪟 xmonad-setup
![Debian](https://img.shields.io/badge/Debian-Stable-d70a53?logo=debian&logoColor=white)
![X11](https://img.shields.io/badge/X11-only-yellow)
![xmonad](https://img.shields.io/badge/xmonad-TILING-magenta)
![ThinkPad](https://img.shields.io/badge/Tested-ThinkPad%20T480-2563eb)
![Tea](https://img.shields.io/badge/Tea-sudo%20holdmyteacup-2563eb)

A minimal, reproducible XMonad setup for Debian (X11 only).
---

## 🇩🇪 Was ist xmonad-setup?

**xmonad-setup** ist ein bewusst minimalistisches Setup-Projekt für Debian,
das eine saubere **X11 + XMonad** Umgebung bereitstellt.

Ursprünglich für ein **ThinkPad T480** erstellt, funktioniert das Setup
auf jedem Debian-System mit X11.

Der Fokus liegt auf:
- Stabilität
- Reproduzierbarkeit
- minimalem Overhead
- klaren, nachvollziehbaren Entscheidungen

---

## 🇬🇧 What is xmonad-setup?

**xmonad-setup** is a deliberately minimal setup project for Debian,
providing a clean **X11 + XMonad** environment.

Originally created for a **ThinkPad T480**, it works on any Debian system
running X11.

The focus is on:
- stability
- reproducibility
- minimal overhead
- clear and understandable decisions

---

## 🎯 Projektziel / Project goal

🇩🇪  
Ein reproduzierbares Debian-System, das:
- XMonad sauber und nachvollziehbar installiert
- keine versteckten Automatismen nutzt
- als stabile Basis für eigene Anpassungen dient

🇬🇧  
A reproducible Debian system that:
- installs XMonad in a clean and transparent way
- avoids hidden automation
- serves as a stable base for your own customizations

---

## 🧠 Philosophie / Philosophy

🇩🇪  
- **X11 only** (bewusst)
- **boring is good**
- **no magic**
- **no hidden services**
- **user decides what comes next**

Dieses Projekt versucht **nicht**, dir einen perfekten Desktop vorzuschreiben.  
Es liefert lediglich eine **saubere, minimale Ausgangsbasis**.

🇬🇧  
- **X11 only** (by design)
- **boring is good**
- **no magic**
- **no hidden services**
- **user decides what comes next**

This project does **not** try to define a perfect desktop for you.  
It simply provides a **clean and minimal starting point**.

---

## 🪟 Window Manager

🇩🇪  
- **XMonad**
- native X11-Session
- kein Wayland
- keine DE-Abhängigkeiten

🇬🇧  
- **XMonad**
- native X11 session
- no Wayland
- no desktop environment dependencies

---

## 🧰 Enthaltene Basis / Included Base

🇩🇪  
Das Setup installiert nur das Nötigste:

- Xorg (X11)
- XMonad
- LightDM (optional)
- NetworkManager
- PipeWire (Audio)
- dmenu
- feh (Wallpaper)
- picom (optional Compositor)
- grundlegende Fonts

optional: google-chrome, nvidia-driver, steam, zram, fish, fastfetch

🇬🇧  
The setup installs only what is necessary:

- Xorg (X11)
- XMonad
- LightDM (optional)
- NetworkManager
- PipeWire (Audio)
- dmenu
- feh (wallpaper)
- picom (optional compositor)
- basic fonts

optional: google-chrome, nvidia-driver, steam, zram, fish, fastfetch

## 🎬 Video Tutorial / Step-by-Step Guide

🇩🇪  
Schau dir das **komplette Tutorial-Video** zur Installation und Nutzung unseres Debian 13 XMonad Setup Tools an!  
Das Video zeigt dir Schritt für Schritt:

- Installation des Base Systems (X11, LightDM, Audio, Network)  
- Optional NVIDIA-Treiber Setup  
- XMonad + Kitty + Hotkeys (Win+K, Win+B)  
- Google Chrome Installation  
- Konfiguration der `xmonad.hs`  
- Tipps: `xmonad --recompile && xmonad --restart` nach Änderungen  

[Jetzt Video ansehen](https://www.youtube.com/watch?v=R3u0lGSSybc)

---

🇬🇧  
Watch the **full tutorial video** for installing and using our Debian 13 XMonad Setup Tool!  
The video walks you through step by step:

- Installing the base system (X11, LightDM, Audio, Network)  
- Optional NVIDIA driver setup  
- XMonad + Kitty + Hotkeys (Win+K, Win+B)  
- Installing Google Chrome  
- Editing and configuring `xmonad.hs`  
- Pro tip: run `xmonad --recompile && xmonad --restart` after changes  

[Watch Video Now](https://www.youtube.com/watch?v=R3u0lGSSybc)


---

## 🚫 Was dieses Projekt NICHT ist / What this project is NOT

🇩🇪  
- ❌ kein Desktop Environment
- ❌ kein Wayland-Setup
- ❌ kein „Install everything“-Script
- ❌ kein Opinionated Workflow
- ❌ kein Tuning-Monster

Wenn du „alles fertig“ willst, ist dieses Projekt **nicht** für dich.  
Wenn du verstehen willst, **was dein System tut**, dann schon.

🇬🇧  
- ❌ not a desktop environment
- ❌ not a Wayland setup
- ❌ not an “install everything” script
- ❌ not an opinionated workflow
- ❌ not a performance-tuning playground

If you want a fully preconfigured desktop, this project is **not** for you.  
If you want to understand **what your system is doing**, it is.

---

## 🚀 Quick Start

```bash
git clone https://github.com/dennishilk/xmonad-setup.git
cd xmonad-setup
chmod +x install.sh
./install.sh
