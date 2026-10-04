# Fit the simple-span and complex-span M3 examples from Frischkorn & Li (2026).
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
dat_simple$exp <- factor(dat_simple$exp, levels = c("openset", "closedset"))
dat_simple$ss_fac <- factor(dat_simple$ss_fac, levels = c(2, 4, 6, 8))

## 2.2 Model
model_simple <- m3(
  resp_cats = c("corr", "other", "npl"),
  num_options = c("n_corr", "n_other", "n_npl"),
  version = "ss", choice_rule = "softmax"
)

## 2.3 Formula
formula_simple <- bmf(
  c ~ 0 + exp:ss_fac + (1 + ss_fac | gr(id, by = exp)),
  a ~ 0 + exp:ss_fac + (1 + ss_fac | gr(id, by = exp))
)

## 2.4 Priors
# Apply the tutorial's normal(3, 1) activation prior to every cell mean.
# The original linear set-size slope priors do not apply to categorical cells.
priors_simple <- c(
  prior(normal(3, 1), class = "b", nlpar = "a"),
  prior(normal(3, 1), class = "b", nlpar = "c")
)

## 2.5 Fit
fit_simple <- bmm(
  formula = formula_simple, model = model_simple, data = dat_simple, prior = priors_simple,
  chains = 4, cores = 4, iter = 4000, warmup = 2000,
  control = list(adapt_delta = 0.99),
  sample_prior = "yes", backend = "cmdstanr", seed = 2026,
  file = file.path("models", "m3_simple"), file_refit = "never"
)

# 3. Complex span
# Complex span: Tutorial 2, including the fixed control-condition filtering.

## 3.1 Data
dat_complex <- read.csv(file.path("data", "m3_complex_span.csv"))
dat_complex$condition <- factor(dat_complex$condition,
                                levels = c("control", "pre", "retro"))

## 3.2 Model
model_complex <- m3(
  resp_cats = c("corr", "distc", "other", "disto", "npl"),
  num_options = c("n_corr", "n_distc", "n_other", "n_disto", "n_npl"),
  version = "cs", choice_rule = "softmax"
)

## 3.3 Formula
formula_complex <- bmf(
  c ~ 0 + condition + (0 + condition || participant),
  a ~ 0 + condition + (0 + condition || participant),
  f ~ 0 + condition + (0 + condition || participant)
)

## 3.4 Priors
# Without distractors, control responses contain no information about f.
# The companion script fixes its logit-scale coefficient at -10 and SD at 0.
priors_complex <- c(
  prior(constant(-10), nlpar = "f", coef = "conditioncontrol"),
  prior(constant(0), class = "sd", nlpar = "f",
        coef = "conditioncontrol", group = "participant"),
  prior(normal(3, 1), class = "b", nlpar = "a", coef = "conditioncontrol"),
  prior(normal(3, 1), class = "b", nlpar = "a", coef = "conditionpre"),
  prior(normal(3, 1), class = "b", nlpar = "a", coef = "conditionretro"),
  prior(normal(3, 1), class = "b", nlpar = "c", coef = "conditioncontrol"),
  prior(normal(3, 1), class = "b", nlpar = "c", coef = "conditionpre"),
  prior(normal(3, 1), class = "b", nlpar = "c", coef = "conditionretro")
)

## 3.5 Fit
fit_complex <- bmm(
  formula = formula_complex, model = model_complex,
  data = dat_complex, prior = priors_complex,
  chains = 4, cores = 4, iter = 4000, warmup = 2000,
  control = list(adapt_delta = 0.95),
  sample_prior = "yes", backend = "cmdstanr", seed = 2026,
  file = file.path("models", "m3_complex"), file_refit = "never"
)
