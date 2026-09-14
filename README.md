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
scripts/
  analysis.R                         Sourced by the qmd: loads data and builds the
                                       tables/figures/objects used in the manuscript
  export-cited-refs.R                Pre-render step: trims the master .bib to cited keys
data/                                Survey data (NOT in git -- see below)
  energyActorsDataWeighted.csv       Survey data with weights
literature/                          Background literature (NOT in git -- local only)
notebooks/                           Ad-hoc/one-off analyses (NOT in git -- local only)
```

## Reproducing the analysis

Requires R with: `dplyr`, `tidyr`, `ggplot2` (add packages here as the
analysis grows; use `renv` to lock versions).

- **Manuscript:** `quarto render` → outputs to `_output/`
  (HTML, PDF, and DOCX; the DOCX uses `custom-reference-doc.docx`)
- **Analysis only:** `Rscript scripts/analysis.R` builds the analysis
  objects without rendering the manuscript.

## Data

The `data/` folder is **not tracked in git**. Restore it before rendering:

- `data/energyActorsDataWeighted.csv` — survey responses, weighted to match
  US Census demographics. Includes trust in energy actors (EPA, national
  labs, NAS, DOE, state officials, utilities, environmental groups, local
  officials, university/federal/state scientists, president, Congress,
  local/national news), energy concerns (cost, reliability, pollution, AI
  demand, loss), political identity (`democrat`, `republican`, `libDem`,
  `conRep`, `trump.approval`), and controls (`age`, `male`, `white`, `edu`,
  `college`, `inc`).

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
