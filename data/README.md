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
| `m3_simple_span.csv` | Simple span (M3) | Chenyu | done |
| `m3_complex_span.csv` | Complex span (M3 extension) | Chenyu | done |
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

Simple-span data from Oberauer (2019), Experiments 1 and 2, as used in
the [M3 tutorial](https://osf.io/yb7wm/) (Frischkorn & Li, 2026). Reproducible
preparation: `data/prepare_m3.R`; its output matches the tutorial's aggregated
CSV.

Participants studied words in boxes and then selected the word associated
with a probed position. The two experiments had 20 participants each and
differed in whether words were new on every trial (`openset`) or reused
(`closedset`). Experiment (`exp`) was a between-subjects factor; set size
and the composition of the test options varied within participants.

One row contains response counts for one participant at one set size and
one combination of test options: 40 participants × 24 conditions = 960 rows,
with 23 trials per row. The response-count columns sum to 23; `n_*` columns
give the number of available options in each category on each trial.

| Column | Type | Values | Description |
| --- | --- | --- | --- |
| `id` | chr | 40 unique IDs ending `_openset` or `_closedset` | Participant ID, unique across experiments |
| `exp` | chr | `openset`, `closedset` | Between-subjects experiment / stimulus set |
| `setsize` | int | 2, 4, 6, 8 | Number of studied word–box pairs |
| `ss_fac` | int | 2, 4, 6, 8 | Set size, converted to a factor for the M3 fit |
| `ss_lin` | num | −3.8333…, −1.8333…, 0.1667…, 2.1667… | Centered set size (`setsize - mean(setsize)`), retained to match the tutorial's public dataset |
| `corr` | int | 6–23 | Correct responses |
| `other` | int | 0–17 | Responses selecting another studied item |
| `npl` | int | 0–9 | Responses selecting a non-presented lure |
| `n_corr` | int | 1 | Available correct options |
| `n_other` | int | 0, 1, 3, 5, 7 | Available other-list options |
| `n_npl` | int | 0, 1, 2, 4 | Available non-presented lure options |

### m3_complex_span.csv

Complex-span filtering data from Li, Frischkorn, & Oberauer (2026),
Experiment 1, <https://doi.org/10.1037/xlm0001585>, obtained through the
[M3 tutorial supplement](https://osf.io/yb7wm/). Reproducible preparation:
`data/prepare_m3.R`; the output matches the tutorial's aggregated CSV.

Participants studied three target images while judging image sizes. The
within-subjects conditions were `control` (no distractors), `pre` (targets
cued before the judgment), and `retro` (targets cued after the judgment).
Each target was tested against 12 image options. Distractors were either
paired with the tested target (`distc`) or with another target (`disto`).

The public data contain 50 participants. Following the companion script,
five were excluded for a judgment response rate below 50% or accuracy below
70% among answered judgments. Trials with missing images and unanswered
retrieval tests were removed. The original study also used survey exclusions;
that survey is not public, so this preparation applies only the tutorial's
performance criteria. One row is one participant × condition: 45 participants
× 3 conditions = 135 rows. Each row contains 48–60 completed retrieval responses.

| Column | Type | Values | Description |
| --- | --- | --- | --- |
| `participant` | int | 45 IDs from 1–50 | Participant ID after exclusions |
| `condition` | chr | `control`, `pre`, `retro` | Within-subjects cue condition |
| `corr` | int | 7–60 | Correct target responses |
| `other` | int | 0–28 | Responses selecting another target |
| `distc` | int | 0–16 | Responses selecting the distractor paired with the tested target |
| `disto` | int | 0–17 | Responses selecting another distractor |
| `npl` | int | 0–19 | Responses selecting a not-presented lure |
| `n_corr` | int | 1 | Available correct options |
| `n_other` | int | 2 | Available other-target options |
| `n_distc` | int | 0, 1 | Paired-distractor options; 0 in control |
| `n_disto` | int | 0, 2 | Other-distractor options; 0 in control |
| `n_npl` | int | 6, 9 | Lure options; 9 in control, 6 in pre/retro |

### ezddm_perceptual.csv

**TODO — Adriana, by 2026-09-30.**

Open first: the PB&R paper contributes no data of its own — its empirical
sections re-analyse Ratcliff & Rouder (1998; numerosity/brightness, speed vs.
accuracy instructions, Appendix D) and Vandekerckhove, Panis, & Wagemans
(2007; shape perception, nine participants, Appendix E). Say which one this
file is, so the Source/Terms row above can name the study that has to be
cited.
