# Fit the two Part-1 SDT models with bmm and cache them in models/
# (naming contract in models/README.md).
#
# The SDT models (sdt_binary, sdt_rating + post-processing toolkit) are new
# in bmm — currently on the PR #370 stack (venpopov/bmm#370), planned for
# CRAN release before the workshop. Until then this script installs the
# development version from the PR branch; once the release is out, swap the
# install step for the CRAN version and re-fit (version contract in
# models/README.md).
#
# Run from the repo root: Rscript models/fit_sdt.R

if (!"sdt_binary" %in% getNamespaceExports("bmm")) {
  remotes::install_github("venpopov/bmm@sdt-post-processing", upgrade = "never")
}

library(bmm)
library(tidyverse)

dat <- read.csv(file.path("data", "sdt_recognition.csv"))

options(mc.cores = 4, brms.backend = "cmdstanr")

# --- Binary (Yes/No) SDT -------------------------------------------------
# sdt_binary() expects one row per (participant x stimulus class) with the
# count of "old" responses and the number of trials.
binary_counts <- dat |>
  summarise(
    n_old    = sum(say_old),
    n_trials = n(),
    .by = c(pid, condition, is_old)
  )

fit_binary <- bmm(
  formula = bmf(
    dprime    ~ 1 + condition + (1 | pid),
    criterion ~ 1 + condition + (1 | pid)
  ),
  data  = binary_counts,
  model = sdt_binary(response = "n_old", stimulus = "is_old",
                     n_trials = "n_trials"),
  chains = 4, iter = 2000, warmup = 1000,
  seed = 2026
)
saveRDS(fit_binary, file.path("models", "sdt_binary.rds"))

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
    dprime    ~ 1 + condition + (1 | pid),
    criterion ~ 1 + condition + (1 | pid),
    spacing   ~ 1,
    sdratio   ~ 1
  ),
  data  = rating_counts,
  model = sdt_rating(response = paste0("r", 1:6), stimulus = "is_old"),
  chains = 4, iter = 2000, warmup = 1000,
  seed = 2026
)
saveRDS(fit_rating, file.path("models", "sdt_rating.rds"))

cat("\n==== sdt_binary ====\n"); print(summary(fit_binary))
cat("\n==== sdt_rating ====\n"); print(summary(fit_rating))
