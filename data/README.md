# Datasets

Each presenter adds their segment's dataset here and documents it below.
Keep files small (plain-text CSV preferred) — this repo is public and cloned
by participants.

## Licensing

**The datasets in this folder are not covered by the repository license.**
They are redistributed from their original sources and carry those sources'
terms; the workshop presenters claim no rights over them. Cite the original
study, not this repository, when you use one of these datasets.

Presenters: when you add a dataset, record its source and terms in the
codebook below. If a dataset is not yours to redistribute publicly, do not
put it here — link to its repository instead.

| File | Source | Terms |
| --- | --- | --- |
| `sdt_recognition.csv` | Koen et al. (2013), via the `roc6` dataset in [MPTinR](https://cran.r-project.org/package=MPTinR) | MPTinR is GPL-2 \| GPL-3; cite Koen et al. (2013) and Klauer & Kellen (2015) |
| `m3_simple_span.csv` | TODO — Chenyu | TODO |
| `m3_complex_span.csv` | TODO — Chenyu | TODO |
| `ezddm_perceptual.csv` | TODO — Adriana | TODO |

## Naming contract

| File | Segment | Added by | Status |
| --- | --- | --- | --- |
| `sdt_recognition.csv` | Recognition memory (binary + rating SDT) | Gidon | done |
| `m3_simple_span.csv` | Simple span (M3) | Chenyu | TODO |
| `m3_complex_span.csv` | Complex span (M3 extension) | Chenyu | TODO |
| `ezddm_perceptual.csv` | Perceptual decision making (EZ-DDM / DDM) | Adriana | TODO |

## Codebooks

**This file is the single source for all codebooks.** Document every column
of your dataset here when you add it; slides and notebooks reference this
file instead of duplicating column descriptions (duplicates drift apart).

### sdt_recognition.csv

Recognition memory data from Koen, Aly, Wang, & Yonelinas (2013),
<https://doi.org/10.1037/a0033671>, as distributed in the `roc6` dataset of
the [MPTinR](https://cran.r-project.org/package=MPTinR) R package (Klauer &
Kellen, 2015). Reproducible prep: `data/prepare_sdt_recognition.R`.

Participants studied word lists and then judged old/new test words on a
6-point confidence scale. MPTinR ships the **control conditions of two
experiments**, so `condition` is a **between-subjects** factor comparing two
test procedures (48 participants each):

- `full_attention` — Experiment 2, recognition test under full attention
  (~100 old + ~100 new trials per participant). This is the subset used in
  the Vuorre (2025) tutorial in `resources/01_sdt/`.
- `immediate` — Experiment 4, recognition test given immediately after study
  (150 old + 150 new trials per participant).

The treatment cells of those experiments (divided attention at test, 24-hr
delay) are *not* distributed with MPTinR. Rows are individual trials expanded
from per-participant counts; **trial order is arbitrary** (the source data
are aggregated).

| Column | Type | Values | Description |
| --- | --- | --- | --- |
| `pid` | chr | `full_01`–`full_48`, `imm_01`–`imm_48` | Participant ID (unique across conditions; between-subjects design) |
| `condition` | chr | `full_attention`, `immediate` | Test procedure (see above) |
| `stimulus` | chr | `old`, `new` | Item status: studied (old) vs. unstudied (new) |
| `is_old` | int | 0, 1 | Numeric copy of `stimulus` (1 = old); predictor in the SDT regressions |
| `rating` | int | 1–6 | Confidence rating: 1 = sure new … 6 = sure old |
| `say_old` | int | 0, 1 | Binary "old" response, binned as `rating >= 4` (response variable for binary SDT) |

### m3_simple_span.csv

TODO

### m3_complex_span.csv

TODO

### ezddm_perceptual.csv

TODO
