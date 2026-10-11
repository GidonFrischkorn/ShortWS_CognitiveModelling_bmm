# Fit the open-set and pre-cue M3 subsets from Frischkorn & Li (2026).
# Run from the repository root: Rscript models/fit_m3.R
# Fits are cached at models/m3_simple.rds and models/m3_complex.rds.
# CRAN bmm 1.3.1 does not support
# brms's on_change mode; remove the file or use file_refit = "always" to refit.

# 1. Setup

library(bmm)
library(brms)

# 2. Simple span

## 2.1 Data
dat_simple <- read.csv(file.path("data", "m3_simple_span.csv"))
dat_simple$ss_fac <- factor(dat_simple$ss_fac, levels = c(2, 4, 6, 8))

## 2.2 Model
model_simple <- m3(
  resp_cats = c("corr", "other", "npl"),
  num_options = c("n_corr", "n_other", "n_npl"),
  version = "ss", choice_rule = "softmax"
)

## 2.3 Formula
formula_simple <- bmf(
  c ~ 0 + ss_fac + (0 + ss_fac | id),
  a ~ 0 + ss_fac + (0 + ss_fac | id)
)

## 2.4 Priors
# Apply the tutorial's normal(3, 1) activation prior to every cell mean.
# Explicit coefficients override bmm's coefficient-specific default priors.
priors_simple <- c(
  prior(normal(3, 1), class = "b", nlpar = "a", coef = "ss_fac2"),
  prior(normal(3, 1), class = "b", nlpar = "a", coef = "ss_fac4"),
  prior(normal(3, 1), class = "b", nlpar = "a", coef = "ss_fac6"),
  prior(normal(3, 1), class = "b", nlpar = "a", coef = "ss_fac8"),
  prior(normal(3, 1), class = "b", nlpar = "c", coef = "ss_fac2"),
  prior(normal(3, 1), class = "b", nlpar = "c", coef = "ss_fac4"),
  prior(normal(3, 1), class = "b", nlpar = "c", coef = "ss_fac6"),
  prior(normal(3, 1), class = "b", nlpar = "c", coef = "ss_fac8")
)

## 2.5 Fit
fit_simple <- bmm(
  formula = formula_simple, model = model_simple, data = dat_simple, prior = priors_simple,
  chains = 4, cores = 4, iter = 5000, warmup = 2000,
  control = list(adapt_delta = 0.95),
  sample_prior = "yes", backend = "cmdstanr", seed = 2026,
  file = file.path("models", "m3_simple"), file_refit = "never"
)

# 3. Complex span
# Complex span: the pre-cue teaching subset of Tutorial 2.

## 3.1 Data
dat_complex <- read.csv(file.path("data", "m3_complex_span.csv"))

## 3.2 Model
model_complex <- m3(
  resp_cats = c("corr", "distc", "other", "disto", "npl"),
  num_options = c("n_corr", "n_distc", "n_other", "n_disto", "n_npl"),
  version = "cs", choice_rule = "softmax"
)

## 3.3 Formula
formula_complex <- bmf(
  c ~ 1 + (1 | participant),
  a ~ 1 + (1 | participant),
  f ~ 1 + (1 | participant)
)

## 3.4 Priors
# Intercept is class b for these nonlinear parameter formulas.
priors_complex <- c(
  prior(normal(3, 1), class = "b", nlpar = "a", coef = "Intercept"),
  prior(normal(3, 1), class = "b", nlpar = "c", coef = "Intercept")
)

## 3.5 Fit
fit_complex <- bmm(
  formula = formula_complex, model = model_complex,
  data = dat_complex, prior = priors_complex,
  chains = 4, cores = 4, iter = 5000, warmup = 2000,
  control = list(adapt_delta = 0.95),
  sample_prior = "yes", backend = "cmdstanr", seed = 2026,
  file = file.path("models", "m3_complex"), file_refit = "never"
)
