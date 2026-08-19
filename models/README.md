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
| `sdt_yn.rds` | Hierarchical yes/no SDT (`sdt_yn()`, EVSDT, condition on `d` + `criterion`) | Gidon | 1.4.1.9000 (dev) / 2.23.0 | done (re-fit at release) |
| `sdt_rating.rds` | Rating-scale SDT (`sdt_rating()`, UVSDT, condition on `d` + `criterion`) | Gidon | 1.4.1.9000 (dev) / 2.23.0 | done (re-fit at release) |
| `m3_simple.rds` | M3, simple span | Chenyu | — | TODO |
| `m3_complex.rds` | M3, complex span | Chenyu | — | TODO |
| `ezddm_summary.rds` | EZ-DDM from summary statistics | Adriana | — | TODO |
| `ddm_trial.rds` | Trial-level DDM | Adriana | — | TODO |

**SDT exception to the CRAN contract:** the SDT models (`sdt_yn()`,
`sdt_rating()`) are new in bmm and **not in the CRAN version** — CRAN is
still at 1.3.1, which has no SDT models at all. The current fits were made
with the development version (1.4.1.9000). **Re-fit both SDT models with
the CRAN release as soon as it is out** and update the table above.
Fitting script: `models/fit_sdt.R` (installs the dev version if needed).

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
committing.
