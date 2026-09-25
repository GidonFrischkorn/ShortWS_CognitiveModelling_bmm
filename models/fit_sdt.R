# Fit the two Part-1 SDT models with bmm and cache them in models/
# (naming contract in models/README.md).
#
# The SDT models (sdt_yn, sdt_rating + post-processing toolkit) are new in
# bmm and not in the CRAN version yet (1.3.1 has no SDT models), so this
# script needs the development version. Once the release is out, install
# bmm from CRAN instead and re-fit (version contract in models/README.md).
#
# Run from the repo root: Rscript models/fit_sdt.R
#
# Fits are cached through bmm's `file` argument with file_refit = "on_change"
# (see the comment at the first bmm() call). To force a refit when nothing
# in the model changed, e.g. a bmm release that leaves the Stan code as it
# is, delete models/sdt_*.rds or set file_refit = "always".

if (!"sdt_yn" %in% getNamespaceExports("bmm")) {
  remotes::install_github("venpopov/bmm", upgrade = "never")
}

library(bmm)
library(tidyverse)

dat <- read.csv(file.path("data", "sdt_recognition.csv"))

options(mc.cores = 4, brms.backend = "cmdstanr")

# --- Yes/No (binary) SDT -------------------------------------------------
# sdt_yn() expects one row per (participant x stimulus class) with the
# count of "old" responses and the number of trials.
binary_counts <- dat |>
  summarise(
    n_old    = sum(say_old),
    n_trials = n(),
    .by = c(pid, condition, is_old)
  )

fit_binary <- bmm(
  formula = bmf(
    d         ~ 1 + condition + (1 | pid),
    criterion ~ 1 + condition + (1 | pid)
  ),
  data  = binary_counts,
  model = sdt_yn(response = "n_old", stimulus = "is_old",
                 n_trials = "n_trials"),
  chains = 4, iter = 2000, warmup = 1000,
  # Keep draws from the prior: hypothesis() needs them for the Bayes factor
  # (Savage-Dickey) of point hypotheses such as "d_conditionimmediate = 0".
  sample_prior = "yes",
  seed = 2026,
  # Cache: with "on_change", a rerun reuses models/sdt_yn.rds unless the model
  # changed. bmm regenerates the Stan code and Stan data for this call and
  # refits only if they, or the data, differ from the cached fit (new priors,
  # formula, or sample_prior). Sampler settings (chains, iter, seed) are not
  # compared and do not trigger a refit.
  file = file.path("models", "sdt_yn"),
  file_refit = "on_change"
)

# --- Rating-scale SDT ----------------------------------------------------
# sdt_rating() expects one row per (participant x stimulus class) with one
# count column per rating category, r1 = "sure new" ... r6 = "sure old".
# Recognition ROCs are classically asymmetric (the point of Koen et al.,
# 2013), so the rating model also estimates the signal-SD ratio (UVSDT).
rating_counts <- dat |>
  count(pid, condition, is_old, rating) |>
  complete(nesting(pid, condition, is_old), rating, fill = list(n = 0)) |>
  pivot_wider(names_from = rating, values_from = n,
              names_prefix = "r", values_fill = 0)

fit_rating <- bmm(
  formula = bmf(
    d         ~ 1 + condition + (1 | pid),
    criterion ~ 1 + condition + (1 | pid),
    spacing   ~ 1,
    sdratio   ~ 1
  ),
  data  = rating_counts,
  model = sdt_rating(response = paste0("r", 1:6), stimulus = "is_old"),
  chains = 4, iter = 2000, warmup = 1000,
  # Keep draws from the prior: hypothesis() needs them for the Bayes factor
  # (Savage-Dickey) of point hypotheses such as "d_conditionimmediate = 0".
  sample_prior = "yes",
  seed = 2026,
  file = file.path("models", "sdt_rating"),
  file_refit = "on_change"  # see the cache comment at the first fit
)

cat("\n==== sdt_yn ====\n"); print(summary(fit_binary))
cat("\n==== sdt_rating ====\n"); print(summary(fit_rating))
