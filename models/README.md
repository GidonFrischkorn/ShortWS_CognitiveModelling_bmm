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

Confirmed on 2026-08-18: **M3 and EZ-DDM need no development-version
features** — both segments fit with CRAN bmm, so the only dev-version
dependency in this repo is the SDT exception below.

## Naming contract

| File | Model | Added by | Fitted with (bmm / brms) | Status |
| --- | --- | --- | --- | --- |
| `sdt_yn.rds` | Hierarchical yes/no SDT (`sdt_yn()`, EVSDT, condition on `d` + `criterion`) | Gidon | 1.3.2.9000 (develop `1625e860`, 2026-10-05) / 2.23.0 | done (re-fit at release) |
| `sdt_rating.rds` | Rating-scale SDT (`sdt_rating()`, UVSDT, condition on `d` + `criterion`) | Gidon | 1.3.2.9000 (develop `1625e860`, 2026-10-05) / 2.23.0 | done (re-fit at release) |
| `m3_simple.rds` | M3, simple span — TODO: bmm model function + parameterization | Chenyu | — | TODO — by 2026-09-30 |
| `m3_complex.rds` | M3, complex span — TODO: bmm model function + parameterization | Chenyu | — | TODO — by 2026-09-30 |
| `ezddm_summary.rds` | EZ-DDM from summary statistics — TODO: model function + parameterization | Adriana | — | TODO — by 2026-09-30 |
| `ddm_trial.rds` | Trial-level DDM — TODO: model function + parameterization | Adriana | — | TODO — by 2026-09-30 |

As with the datasets, these file names were contracted before the kickoff and
**not re-discussed** on 2026-08-18. They stand by default and are checked for
consistency at PR review; which fits a segment actually ships depends on what
that segment ends up covering, so flag a change in your PR rather than
silently renaming.

**SDT exception to the CRAN contract:** the SDT models (`sdt_yn()`,
`sdt_rating()`) are new in bmm and **not in the CRAN version** — CRAN is
still at 1.3.1, which has no SDT models at all. The current fits were made
on 2026-10-05 with the develop branch of popov-lab/bmm (1.3.2.9000 at
`1625e860`, which carries the SDT models after review; the earlier fits used a
feature-branch build numbered 1.4.1.9000). Fitting script: `models/fit_sdt.R`
(installs the dev version if needed).

**The release now has a date: 30 September 2026** (agreed with Ven Popov on
2026-08-18), including the SDT models. Consequences:

- **All results get re-generated at the beginning of October** with the
  release version — not only the SDT fits — and the table above updated.
  Anyone rendering before that is rendering against dev-version fits.
- Until then, running the Part-1 code (deck or `examples/01_sdt.qmd`) requires
  the development version installed. Nothing else in the repo does.
- `fit_sdt.R` now fits with `sample_prior = "yes"` (added 2026-09-25), so
  `hypothesis()` can report Bayes factors for point hypotheses. The
  2026-10-05 refit includes the prior draws and bmm's new default
  random-effect SD priors (`exponential(1)` on `d`, `exponential(2)` on
  `criterion`, replacing brms's `student_t(3, 0, 43)` fallback). Estimates
  match the earlier fits to two decimals. The fits now use 4000 iterations
  after warmup thinned by 4: with 1000 unthinned, the criterion
  coefficients had Rhat up to 1.03.
- While re-generating, check whether anything new in the release is worth
  showing, since the workshop is about getting people started. Candidates:
  `prior_info()` (prior table, or prose with `format = "text"`) and
  `native_parameters()` (posterior draws on the native scale). Both exist on
  develop as of 2026-10-05; `prior_info()` is now in `examples/01_sdt.qmd`.
  **Verify against the actual release** before a slide depends on them.

⚠️ **Standing release risk.** Until that release lands, every take-home path
for Part 1 depends on attendees installing bmm from GitHub — which
contradicts what `Install_Packages.R` tells them and what the
version contract above requires. The API is also still moving: what shipped
as `sdt_binary()` with a `dprime` parameter in August 2026 is now `sdt_yn()`
with `d`. Treat "bmm on CRAN with SDT" as a hard prerequisite for the
workshop, not a nice-to-have.

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
