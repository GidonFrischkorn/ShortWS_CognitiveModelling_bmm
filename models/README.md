# Pre-fitted models

All models shown in the workshop ship here as fitted objects, so slides and
notebooks never fit live and participants never need the Stan toolchain.

Workflow: fit locally from your fitting script (`models/fit_*.R`, mirroring
`models/fit_sdt.R`) and let **brms cache the fit for you** — pass
`file = here::here("models", "<name>")` to the fitting call instead of a
manual `saveRDS()` (decided 2026-08-18). Re-running the script then reloads
the cached fit rather than refitting. Commit the `.rds` together with your
deck and the updated `_freeze/` entries.

**Version contract:** fit every shipped model with the **CRAN** versions of
bmm and brms — participants install from CRAN, and an `.rds` produced with a
development version can error or misbehave for them. Record the versions you
used in the table below (`packageVersion("bmm")`, `packageVersion("brms")`).
Development versions (`Install_Packages.R`, Part 3) are for prototyping only;
re-fit with CRAN versions before committing.

All six fits come from CRAN releases of bmm (1.4.1 or 1.4.2, see the
table); nothing in this repo needs a development version. Checked on
2026-11-17 under bmm 1.4.2: rerunning the three fitting scripts reloads all
six cached fits without refitting (`file_refit = "on_change"`), so 1.4.2
builds the same Stan code and data the fits were made with, the 1.4.1 SDT
fits included.

## Naming contract

| File | Model | Added by | Fitted with (bmm / brms) | Status |
| --- | --- | --- | --- | --- |
| `sdt_yn.rds` | Hierarchical yes/no SDT (`sdt_yn()`, EVSDT, condition on `d` + `criterion`) | Gidon | 1.4.1 (CRAN, 2026-11-02) / 2.23.0 | done, final |
| `sdt_rating.rds` | Rating-scale SDT (`sdt_rating()`, UVSDT, condition on `d` + `criterion`) | Gidon | 1.4.1 (CRAN, 2026-11-02) / 2.23.0 | done, final |
| `m3_simple.rds` | M3 for simple span (`m3()`, softmax, open set; set size on `a` + `c`) | Chenyu | 1.4.2 (CRAN) / 2.23.0 | done |
| `m3_complex.rds` | M3 for complex span (`m3()`, softmax, pre-cue; intercepts on `a` + `c` + `f`) | Chenyu | 1.4.2 (CRAN) / 2.23.0 | done |
| `ezddm_summary.rds` | EZ-DDM, 3 parameters (`ezdm(version = "3par")`; drift ~ instruction + abs(Xs), bound and ndt ~ instruction; one participant, 64 cells) | Adriana | 1.4.2 (CRAN) / 2.23.0 | done (refit 2026-11-14, cmdstanr) |
| `ddm_trial.rds` | Trial-level DDM (`ddm()`, Wiener likelihood; same formulas as `ezddm_summary.rds`; `zr` fixed at the midpoint; 7,369 trials) | Adriana | 1.4.2 (CRAN) / 2.23.0 | done (refit 2026-11-14, cmdstanr) |

M3 sampling uses four chains, 5,000 iterations per chain, 2,000 warmup,
`adapt_delta = 0.95`, and seed 2026. Rhat is reported to two decimals: 1.01 for open set and 1.00 for pre-cue.
The unrounded open-set maximum remains slightly above 1.01. Both have zero
divergences. Review figures and numerical diagnostics are in `data/figures/`;
regenerate figures with `Rscript data/plot_m3.R`.

As with the datasets, these file names were contracted before the kickoff and
**not re-discussed** on 2026-08-18. They stand by default and are checked for
consistency at PR review; which fits a segment actually ships depends on what
that segment ends up covering, so flag a change in your PR rather than
silently renaming.

**Resolved 2026-11-02: bmm 1.4.1 is on CRAN (released 2026-10-16) and
carries the SDT models.** The Part 1 fits were re-made with it on 2026-11-02
(`models/fit_sdt.R`; `sample_prior = "yes"` for the Bayes factors in
`hypothesis()`, 4000 post-warmup draws thinned by 4 because the criterion
coefficients mix slowly). Until the 2026-10-05 refit the SDT fits had come from
the develop branch (1.3.2.9000); the standing release risk recorded here from
August to October is closed, and nothing in the repo needs a development
version any more.

**Two names for the decision criterion since bmm 1.4.1.** `criterion` is
measured from the mean of the noise (new-item) distribution, so the
false-alarm rate depends on it alone; `bias` is the same boundary measured
from the midpoint between the two means (0 = neutral; `bias = criterion -
d/2` under equal variance). A formula names one of the two, never both. The
workshop uses `criterion`; its default priors are `normal(0.5, 1.5)` on the
intercept and `exponential(1)` on the random-effect SD (`bias`: `normal(0,
1.5)` and `exponential(2)`). The develop-era fits had estimated the
midpoint-relative quantity under the name `criterion`, so the criterion
estimates of the 2026-11-02 refit are shifted by about `d/2` against the
2026-10-05 ones; `d` is unchanged in meaning.

**Note on `d`:** bmm's sensitivity parameter is $d_a$ — the distance between
the distributions in units of their root-mean-square SD. It equals the
familiar $d'$ exactly when `sdratio` is 1 (i.e. `sdratio_Intercept` = 0,
which the yes/no model fixes by default). In the rating model, where
`sdratio` is estimated, `d` is $d_a$ and not $d'$.

## Size guidance

Keep each `.rds` well under ~50 MB (fewer chains / thinned draws if needed);
GitHub hard-rejects files over 100 MB. Check with `ls -lh models/` before
committing. With the amount of data these models see, no fit is expected to
come close — the SDT fits are 12 MB each. If one ever does, the fallback
agreed on 2026-08-18 is to host the fit objects in a companion OSF project or
Zenodo deposit and download them, rather than committing them here.
