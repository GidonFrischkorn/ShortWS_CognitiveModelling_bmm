# Pre-fitted models

All models shown in the workshop ship here as fitted objects, so slides and
notebooks never fit live and participants never need the Stan toolchain.

Workflow: fit locally (in your `examples/` notebook or a scratch script),
`saveRDS(fit, here::here("models", "<name>.rds"))`, commit the `.rds`
together with your deck and the updated `_freeze/` entries.

**Version contract:** fit every shipped model with the **CRAN** versions of
bmm and brms — participants install from CRAN, and an `.rds` produced with a
development version can error or misbehave for them. Record the versions you
used in the table below (`packageVersion("bmm")`, `packageVersion("brms")`).
Development versions (`Install_Packages.R`, Part 3) are for prototyping only;
re-fit with CRAN versions before committing.

## Naming contract

| File | Model | Added by | Fitted with (bmm / brms) | Status |
| --- | --- | --- | --- | --- |
| `sdt_binary.rds` | Hierarchical binary SDT (`sdt_binary()`, EVSDT, condition on `dprime` + `criterion`) | Gidon | 1.3.1-dev (PR #370) / 2.23.0 | done (re-fit at release) |
| `sdt_rating.rds` | Rating-scale SDT (`sdt_rating()`, UVSDT, condition on `dprime` + `criterion`) | Gidon | 1.3.1-dev (PR #370) / 2.23.0 | done (re-fit at release) |
| `m3_simple.rds` | M3, simple span | Chenyu | — | TODO |
| `m3_complex.rds` | M3, complex span | Chenyu | — | TODO |
| `ezddm_summary.rds` | EZ-DDM from summary statistics | Adriana | — | TODO |
| `ddm_trial.rds` | Trial-level DDM | Adriana | — | TODO |

**SDT exception to the CRAN contract:** the SDT models (`sdt_binary()`,
`sdt_rating()`) are new in bmm and currently live on the
[venpopov/bmm#370](https://github.com/venpopov/bmm/pull/370) PR stack
(branch `sdt-post-processing`), planned for CRAN release before the
workshop. The current SDT fits were made with that development version
(commit recorded in `models/fit_sdt.R` history); **re-fit both SDT models
with the CRAN release as soon as it is out** and update the table above.
Fitting script: `models/fit_sdt.R` (installs the dev version if needed).

## Size guidance

Keep each `.rds` well under ~50 MB (fewer chains / thinned draws if needed);
GitHub hard-rejects files over 100 MB. Check with `ls -lh models/` before
committing.
