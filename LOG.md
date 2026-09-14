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

### Session 3 — 2026-09-14 (LCA of trust in energy actors; multinomial logit; concern validity check)

- Initialized `renv` for the project (wasn't set up yet) and snapshotted
  `renv.lock` after installing `poLCA`, `nnet`, `estimatr`, `modelsummary`,
  `broom`, `gt`, `dplyr`, `tidyr`, `ggplot2`. `survey` could not be installed
  (its `RcppArmadillo` dependency fails to compile on this machine — missing
  gfortran runtime libs, a local toolchain issue, not fixed); used
  `estimatr::lm_robust` for weighted/robust regression instead, which needs
  no Fortran compiler and is adequate here since there's no strata/PSU
  design info, just a plain survey weight.
- Built the full three-part analysis outlined in the Introduction:
  1. **Latent Class Analysis** (`scripts/analysis.R`) of trust in the 15
     energy actors, collapsed to Low/Moderate/High ordinal indicators.
     Compared k = 2–9 (`scripts/lca-model-selection.R`; cached results in
     `data/lca_model_comparison.csv`); chose **k = 4** based on the elbow in
     BIC improvement (sharp drop after k = 4), high entropy (~0.85), and
     because k = 4 is the smallest solution where every class is
     qualitatively distinct rather than a further split of the same
     pattern. Classes are labeled programmatically from their item-response
     profiles (not hardcoded): *Trust in Scientists & Environmental Groups*
     (33.2%), *Broad Institutional Trust* (26.5%), *Generalized Low Trust*
     (24.7%), *Deep Distrust of All Actors* (15.5%).
  2. **Multinomial logit** (`nnet::multinom`, survey-weighted) predicting
     trust-class membership from demographics (age, male, white, college,
     income) and political beliefs (democrat, republican, Trump approval).
     Trump approval and race are the most consistent predictors across
     classes.
  3. **Concern validity check** — after discussing scope for a PSJ research
     note (3,000–5,000 words, narrow contribution), trimmed what was
     initially a 5-outcome concern-regression battery down to a single
     flagship outcome, concern about pollution, framed explicitly as an
     external-validity check on the LCA typology rather than a second full
     study.
- Wired all of the above into `energy-actors-trust.qmd` (Methods: model-
  comparison table; Results: class-size table, a trust-profile heatmap,
  the multinomial logit table, the pollution-concern validity-check table).
  Verified the manuscript actually renders (HTML, PDF, and DOCX all
  succeed), not just that the R code runs standalone.
- Restructured `tbl-mnl` to match Table 2's layout in Wehde & Nowlin (2023,
  *Weather, Climate, and Society*) — one column per trust class (with class
  size in the header, e.g. "Broad Institutional Trust (26.5%)"), covariates
  as rows, SEs in parentheses, GOF stats in the footer. Kept the heatmap
  figure over that paper's bar-chart style, per preference.
- Added significance stars to both `modelsummary` tables, with a dagger
  (†) for p < 0.10 rather than folding it into the asterisk scale.
- Added `scripts/lca-model-selection.R` (not sourced by the manuscript —
  it's slow, k = 2–9 with 10 random starts each — run manually to
  regenerate `data/lca_model_comparison.csv`).
- Fixed a `.gitignore` mistake from earlier in this session: `_output/` had
  been added to `.gitignore`, contradicting this README's stated convention
  that rendered output is tracked in git. Reverted; only `/_freeze/` (the
  Quarto freeze cache) is ignored now.

### Session 2 — 2026-09-14 (Ad-hoc concern.ai.demand notebook)

- Added `notebooks/concern-ai-demand-summary.qmd`: a standalone quick
  analysis (question wording, one-row descriptive table, weighted OLS of
  `concern.ai.demand` on `age`, `male`, `white`, `edu`, `inc`,
  `trump.approval`, `libDem`, `conRep`) rendered to DOCX and exported to
  the `00-narrative-learning` project (`02-ideas/00-narrative-learning/`).
- Added `/notebooks` to `.gitignore` — this and future one-off notebooks
  stay local-only, not tracked in this repo.

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
