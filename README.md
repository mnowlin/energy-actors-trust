# Who Does the Public Trust on Energy Issues?

Manuscript and reproducible analysis examining who the US public trusts with
regard to energy policy (e.g., federal and state agencies, elected
officials, utilities, scientists, environmental groups, news media) and how
that trust relates to public concern about energy issues (cost,
reliability, pollution, AI-driven demand growth).

The data come from a weighted public-opinion survey (weighted, e.g., to
match US Census demographics) that measures trust in a range of energy
actors alongside energy-related concerns, political identity, and
demographic controls.

## Layout

```
energy-actors-trust.qmd              Manuscript source (renders to HTML, PDF, DOCX)
_quarto.yaml                         Quarto project config
_output/                             Rendered HTML/PDF/DOCX (tracked in git)
custom-reference-doc.docx            Word reference template used for the DOCX output
LOG.md                               Running session log (newest entry first)
renv.lock, renv/, .Rprofile          renv: locked package versions for reproducibility
scripts/
  analysis.R                         Sourced by the qmd: LCA of trust in energy actors,
                                       multinomial logit (class ~ demographics/politics),
                                       and a concern-about-pollution validity check
  lca-model-selection.R              Standalone (not sourced by the qmd -- slow): compares
                                       LCA solutions k = 2-9, regenerates the csv below
  export-cited-refs.R                Pre-render step: trims the master .bib to cited keys
data/                                Survey data (NOT in git -- see below)
  energyActorsDataWeighted.csv       Survey data with weights
  lca_model_comparison.csv           Cached fit statistics from lca-model-selection.R
literature/                          Background literature (NOT in git -- local only)
notebooks/                           Ad-hoc/one-off analyses (NOT in git -- local only)
```

## Reproducing the analysis

Uses `renv` to lock package versions (`poLCA`, `nnet`, `estimatr`,
`modelsummary`, `broom`, `gt`, `dplyr`, `tidyr`, `ggplot2`). Run
`renv::restore()` to install the locked versions.

- **Manuscript:** `quarto render` → outputs to `_output/`
  (HTML, PDF, and DOCX; the DOCX uses `custom-reference-doc.docx`)
- **Analysis only:** `Rscript scripts/analysis.R` builds the analysis
  objects (LCA fit, multinomial logit, concern validity-check regression)
  without rendering the manuscript.
- **LCA class-count model comparison** (slow, not run automatically):
  `Rscript scripts/lca-model-selection.R` regenerates
  `data/lca_model_comparison.csv`.

Note: `survey` cannot currently be installed on this machine (its
`RcppArmadillo` dependency fails to compile — a local gfortran toolchain
issue, not a code problem), so weighted regressions use
`estimatr::lm_robust` instead.

## Data

The `data/` folder is **not tracked in git**. Restore it before rendering:

- `data/energyActorsDataWeighted.csv` — survey responses, weighted to match
  US Census demographics. Includes trust in energy actors (EPA, national
  labs, NAS, DOE, state officials, utilities, environmental groups, local
  officials, university/federal/state scientists, president, Congress,
  local/national news), energy concerns (cost, reliability, pollution, AI
  demand, loss), political identity (`democrat`, `republican`, `libDem`,
  `conRep`, `trump.approval`), and controls (`age`, `male`, `white`, `edu`,
  `college`, `inc`). `scripts/analysis.R` derives a 4-class `trust_class`
  latent variable from the 15 trust items via LCA (see LOG.md, Session 3).

## Notes

- `references.bib` and the local `.csl` are generated at render time by the
  pre-render step (`export-cited-refs.R`) from the master bibliography, so
  they are git-ignored.
- `_output/` **is tracked in git** (unlike most build artifacts) so the
  rendered manuscript is available without re-running R/Quarto. Re-render
  (`quarto render`) after any change to `energy-actors-trust.qmd` or
  `scripts/analysis.R` and commit the updated files in `_output/` alongside
  the source change.
- Quarto's freeze cache (`_freeze/`) is enabled (`execute: freeze: auto` in
  `_quarto.yaml`), so code chunks are only re-executed when the qmd or its
  upstream R sources change.
- `literature/` is git-ignored (kept local only).
- `notebooks/` is git-ignored (kept local only) — ad-hoc analyses that
  produce a standalone output (e.g., exported to another project) rather
  than feeding the manuscript.
- `LOG.md` records what changed and why for each work session; add a new
  entry at the top rather than editing manuscript prose notes into commit
  messages.
