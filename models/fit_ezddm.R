# Fit the Part-3 diffusion models with bmm and cache them in models/
# (naming contract in models/README.md).
#
# EZ-DDM and the trial-level DDM are in the CRAN release of bmm. This script
# was run with the development build already installed for Part 1
# (1.3.2.9000). Re-fit from CRAN when that release is what participants have.
#
# Run from the repo root:
#   Rscript models/fit_ezddm.R          # EZ summary model only
#   Rscript models/fit_ezddm.R trial    # trial-level DDM only
#   Rscript models/fit_ezddm.R all
#
# Fits are cached through bmm's file argument with file_refit = "on_change".
# Sampler settings do not trigger a refit: delete the .rds after changing them.
library(bmm)
library(tidyverse)

which_fit <- commandArgs(trailingOnly = TRUE)

if(length(which_fit) == 0){  which_fit <- "ez"   }

dat <- read.csv(file.path("data", "ezddm_perceptual.csv"))

options(mc.cores = 4, brms.backend = "rstan")

# Shared cell covariates. Accuracy is the reference instruction condition.
# Xs places the black-to-white mix; abs_xs is the distance from a 50/50 mix.
cell_covariates <- function(trial_data) {
    trial_data |> mutate(instruction = factor(if_else(cond <= 33, "accuracy", "speed"),
                         levels = c("accuracy", "speed")), xs = ((cond - 1) %% 33 - 16) / 5,
                         abs_xs = abs(xs),
                         majority = if_else(xs < 0, "more black", "more white"),
                         correct = as.integer((response == 1 & majority == "more black") |
                                              (response == 2 & majority == "more white")),
                        rt_s = rt_ms / 1000)
}

coded <- cell_covariates(dat)

if (any(c("ez", "all") %in% which_fit)){
  # One row per design cell. Mean and variance use every trial.
  ez_summary <- coded |> summarise(mean_rt = mean(rt_s),
                                   var_rt = var(rt_s),
                                   n_upper = sum(correct),
                                   n_trials = n(),
                                   .by = c(cond, instruction, abs_xs))

  fit_ez <- bmm(formula = bmf(drift ~ 1 + instruction + abs_xs,
                              bound ~ 1 + instruction,
                              ndt   ~ 1 + instruction),
            data = ez_summary,
            model = ezdm(mean_rt = "mean_rt",
                          var_rt = "var_rt",
                          n_upper = "n_upper",
                          n_trials = "n_trials",
                          version = "3par"),
            chains = 4, iter = 2000, warmup = 1000,
            sample_prior = "yes",
            seed = 2026,
            file = file.path("models", "ezddm_summary"),
            file_refit = "on_change",
            cores = 4)

  cat("\n==== ezddm_summary ====\n")
  print(summary(fit_ez))
}

if(any(c("trial", "all") %in% which_fit)){
  # One row per trial. response 1 = correct (upper boundary).
  trial_data <- coded |> transmute(rt = rt_s, response = correct,
                                   instruction, abs_xs)
  fit_trial <- bmm(formula = bmf(drift ~ 1 + instruction + abs_xs,
                                 bound ~ 1 + instruction,
                                 ndt   ~ 1 + instruction),
                    data = trial_data,
                    model = ddm(rt = "rt", response = "response"),
                    chains = 4, iter = 2000, warmup = 1000,
                    sample_prior = "yes",
                    seed = 2026,
                    file = file.path("models", "ddm_trial"),
                    file_refit = "on_change",
                    cores = 4
                  )

  cat("\n==== ddm_trial ====\n")
  print(summary(fit_trial))
}
