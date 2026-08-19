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
| `m3_simple_span.csv` | Oberauer (2019), <https://doi.org/10.5334/joc.86>, via the M3 tutorial supplement (Frischkorn & Li, 2026), <https://osf.io/yb7wm/> | OSF project is **CC BY-NC 4.0** (checked 2026-08-19); cite Oberauer (2019) and the tutorial |
| `m3_complex_span.csv` | Li, Frischkorn, & Oberauer (2026), Exp. 1, <https://doi.org/10.1037/xlm0001585>, via the same supplement | as above |
| `ezddm_perceptual.csv` | Chávez De la Peña & Vandekerckhove (2025), <https://doi.org/10.3758/s13423-025-02729-y>, supplement <https://osf.io/bzkpn/> | OSF project is **CC BY 4.0** (checked 2026-08-19); cite the PB&R paper **and the original study the data come from** — TODO Adriana, see below |

## Naming contract

| File | Segment | Added by | Status |
| --- | --- | --- | --- |
| `sdt_recognition.csv` | Recognition memory (binary + rating SDT) | Gidon | done |
| `m3_simple_span.csv` | Simple span (M3) | Chenyu | TODO — by 2026-09-30 |
| `m3_complex_span.csv` | Complex span (M3 extension) | Chenyu | TODO — by 2026-09-30 |
| `ezddm_perceptual.csv` | Perceptual decision making (EZ-DDM / DDM) | Adriana | TODO — by 2026-09-30 |

The file names above were contracted before the kickoff and were **not
re-discussed** on 2026-08-18. They stand by default; keep them unless you have
a reason to change one, and flag a rename in your PR — the notebook and deck
that reference the file have to change with it.

## Codebooks

**This file is the single source for all codebooks.** Document every column
of your dataset here when you add it; slides and notebooks reference this
file instead of duplicating column descriptions (duplicates drift apart).

**Each presenter writes their own codebook** (decided 2026-08-18), in the same
PR that adds the CSV. Use the `sdt_recognition.csv` entry below as the model
for length and level of detail: what participants did, what one row is (trial
or aggregate), sample size, which factors are within- vs. between-subjects,
then the column table with types and value ranges.

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

**TODO — Chenyu, by 2026-09-30.**

Source (from the tutorial, not yet confirmed against the committed CSV):
cued recall with words in boxes from Oberauer (2019), two experiments of 20
participants each differing in stimulus set (open vs. closed), aggregated to
response frequencies per participant × recognition condition.

### m3_complex_span.csv

**TODO — Chenyu, by 2026-09-30.**

Source (same caveat): the complex-span filtering task of Li, Frischkorn, &
Oberauer (2026), Experiment 1, 45 participants after exclusions,
within-subjects, pre-aggregated into frequencies across five response
categories.

### ezddm_perceptual.csv

**TODO — Adriana, by 2026-09-30.**

Open first: the PB&R paper contributes no data of its own — its empirical
sections re-analyse Ratcliff & Rouder (1998; numerosity/brightness, speed vs.
accuracy instructions, Appendix D) and Vandekerckhove, Panis, & Wagemans
(2007; shape perception, nine participants, Appendix E). Say which one this
file is, so the Source/Terms row above can name the study that has to be
cited.
