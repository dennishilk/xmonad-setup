# Codebasis-Review: Vorschläge für konkrete Folgeaufgaben

## 1) Aufgabe: Tippfehler/Sprachfehler in README korrigieren

**Problem:**
In der deutschen Sektion steht „Installation des Base Systems“, was sprachlich inkonsistent ist (Denglisch) und in der deutschen Passage besser als „Basissystems“ formuliert werden sollte.

**Fundstelle:**
`README.md` Zeile 137.

**Vorschlag für Ticket:**
- Formulierung in der deutschen Liste vereinheitlichen (z. B. „Installation des Basissystems“).
- Danach kurzen Readability-Check der restlichen deutschsprachigen Liste durchführen.

**Akzeptanzkriterien:**
- Keine Denglisch-Formulierungen mehr in der deutschen Aufzählung.
- README bleibt inhaltlich unverändert, nur sprachlich verbessert.

---

## 2) Aufgabe: Programmierfehler bei CPU-Microcode-Erkennung beheben

**Problem:**
`install_microcode()` installiert aktuell bei allen CPUs, die **nicht** als AMD erkannt werden, pauschal `intel-microcode`. Auf nicht-Intel-Architekturen (z. B. ARM) ist das falsch.

**Fundstelle:**
`install.sh` Zeilen 122–127.

**Vorschlag für Ticket:**
- CPU-Hersteller explizit unterscheiden (AMD, Intel, sonst „überspringen mit Hinweis“).
- Optional zusätzlich Architektur prüfen (`dpkg --print-architecture`), damit nur auf `amd64`/`i386` versucht wird, x86-Microcode zu installieren.

**Akzeptanzkriterien:**
- Auf AMD wird nur `amd64-microcode` installiert.
- Auf Intel wird nur `intel-microcode` installiert.
- Auf anderen Plattformen erfolgt kein falscher Paketinstallationsversuch.
- Ausgabe enthält klaren Hinweis, warum ggf. übersprungen wurde.

---

## 3) Aufgabe: Dokumentations-Unstimmigkeit im Quick-Start beheben

**Problem:**
Der Quick-Start-Codeblock ist nicht geschlossen (fehlende schließende ```), dadurch wird der Rest der Datei in vielen Renderern fehlerhaft formatiert.

**Fundstelle:**
`README.md` ab Zeile 190 bis Dateiende.

**Vorschlag für Ticket:**
- Fehlende schließende Codeblock-Markierung ergänzen.
- Kurz prüfen, ob nach dem Quick-Start weitere Inhalte korrekt gerendert werden.

**Akzeptanzkriterien:**
- Markdown rendert ab „Quick Start“ korrekt.
- Kein unabsichtlich als Code dargestellter Folgeinhalt.

---

## 4) Aufgabe: Testabdeckung für Interaktionspfade verbessern

**Problem:**
Die Bats-Tests decken nur DRY-RUN + INSTALL_ALL ab. Der Pfad ohne INSTALL_ALL (einzelne Fragen), sowie Negativpfade (Antworten „n“) werden nicht überprüft.

**Fundstelle:**
`tests/install.bats` Zeilen 29–45.

**Vorschlag für Ticket:**
- Zusätzliche Tests für:
  - DRY-RUN aktiv, aber INSTALL_ALL = nein.
  - DRY-RUN = nein (mit gemocktem `sudo`), um Ausführungsfluss zu verifizieren.
  - Selektive Bestätigung einzelner Schritte (gemischte y/n-Antworten).
- Assertions auf konkrete erwartete/unerwartete `sudo`-Aufrufe erweitern.

**Akzeptanzkriterien:**
- Mindestens 2 neue Tests für bisher ungetestete Entscheidungszweige.
- Testfälle sind deterministisch und laufen ohne Root-Rechte.
