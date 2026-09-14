# Session Log — energy-actors-trust Project

Paper title: **"Who Does the Public Trust on Energy Issues?"**

This log records what has been done in each working session. Update it at the end of each session.

---

## Project Overview

An academic article examining who the US public trusts with regard to
energy policy and how that trust influences concern about energy issues.
Data from a weighted public-opinion survey measuring trust in a range of
energy actors (agencies, elected officials, utilities, scientists,
environmental groups, news media) alongside energy-related concerns,
political identity, and demographic controls.

**Key files:**
- `energy-actors-trust.qmd` — main manuscript (renders to HTML, PDF, DOCX)
- `scripts/analysis.R` — data loading and any tables/figures/objects sourced by the manuscript
- `scripts/export-cited-refs.R` — pre-render step that trims the master `.bib` to cited keys
- `data/energyActorsDataWeighted.csv` — weighted survey data
- `README.md` — project structure and reproduction instructions

---

## Session History

### Session 1 — 2026-09-14 (Restructure to project-files template)

- Restructured the project folder from its earlier ad-hoc layout
  (`manuscript/`, `lit-review/`, `output/`, `presentation/` subfolders,
  scripts/setup.R bootstrap script) to the current standard `project-files`
  template layout.
- Copied `LOG.md`, `README.md`, `_quarto.yaml`, `custom-reference-doc.docx`,
  and `nowlin-style-profile.md` from the template into the project root.
- Moved the manuscript to the project root as `energy-actors-trust.qmd`
  (built from `template.qmd`), set the title to "Who Does the Public Trust
  on Energy Issues?", and pointed its setup chunk at `scripts/analysis.R`.
- Updated `_quarto.yaml`'s render target and `scripts/export-cited-refs.R`'s
  source-file list to `energy-actors-trust.qmd`.
- Created `scripts/analysis.R` (loads `data/energyActorsDataWeighted.csv`;
  to be built out with the models/tables/figures used in the manuscript).
- Added `/data`, `/literature`, and `nowlin-style-profile.md` to
  `.gitignore`.
- Existing survey data (`data/energyActorsDataWeighted.csv`) was already in
  place and left untouched.
- `renv` has not yet been initialized for this project.
