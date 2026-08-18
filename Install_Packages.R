# Install_Packages.R -- Psychonomics 2026 lunchtime workshop
# "Analyzing Behavioral Data at the Cognitive Process Level with bmm in R"
#
# Run this script once before the workshop.

## Part 1: Required for all participants ------------------------------------
# These packages are enough to run all take-home notebooks in examples/,
# because every model used in the workshop ships pre-fitted in models/*.rds.

pkgs <- c(
  "bmm",        # Bayesian measurement models
  "brms",       # Bayesian regression models (bmm builds on this)
  "tidyverse",  # data wrangling and plotting
  "here",       # project-relative file paths
  "tidybayes",  # tidy access to posterior draws
  "bayesplot",  # posterior visualization
  "quarto"      # render the .qmd notebooks from R (optional convenience)
)

new_pkgs <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(new_pkgs) > 0) install.packages(new_pkgs)

## Part 2: OPTIONAL -- only needed to re-fit models yourself ----------------
# All workshop models are provided as fitted objects in models/*.rds, so you
# do NOT need this to follow the workshop or run the notebooks.
#
# Fitting new models requires the Stan toolchain and a C++17 compiler:
#   - Windows: Rtools (https://cran.r-project.org/bin/windows/Rtools/)
#   - macOS: Xcode command line tools (xcode-select --install)
#
# install.packages("cmdstanr", repos = c("https://stan-dev.r-universe.dev", getOption("repos")))
# cmdstanr::check_cmdstan_toolchain(fix = TRUE)
# cmdstanr::install_cmdstan()   # this can take a while

## Part 3: Development versions (presenters only) ----------------------------
# If a workshop model requires bmm features that are not yet on CRAN:
# if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
# remotes::install_github("venpopov/bmm")
