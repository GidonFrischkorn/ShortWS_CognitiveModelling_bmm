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
| `sdt_binary.rds` | Hierarchical binary SDT | Gidon | — | TODO |
| `sdt_rating.rds` | Rating-scale SDT | Gidon | — | TODO |
| `m3_simple.rds` | M3, simple span | Chenyu | — | TODO |
| `m3_complex.rds` | M3, complex span | Chenyu | — | TODO |
| `ezddm_summary.rds` | EZ-DDM from summary statistics | Adriana | — | TODO |
| `ddm_trial.rds` | Trial-level DDM | Adriana | — | TODO |

## Size guidance

Keep each `.rds` well under ~50 MB (fewer chains / thinned draws if needed);
GitHub hard-rejects files over 100 MB. Check with `ls -lh models/` before
committing.
