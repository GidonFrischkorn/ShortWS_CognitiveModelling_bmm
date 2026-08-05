# Check_Setup.R -- Psychonomics 2026 lunchtime workshop
# "Fitting cognitive measurement models with bmm"
#
# Run this AFTER Install_Packages.R to verify you are ready:
#   1. Open ShortWS_CognitiveModelling_bmm.Rproj in RStudio/Positron.
#   2. source("Check_Setup.R")
#
# It checks that (a) the required packages load and (b) the pre-fitted
# models in models/ can be read. No Stan toolchain needed.

ok   <- "✓"  # check mark
fail <- "✗"  # cross
problems <- 0L

cat("== Checking packages ==\n")
pkgs <- c("bmm", "brms", "tidyverse", "here", "tidybayes", "bayesplot")
for (p in pkgs) {
  if (requireNamespace(p, quietly = TRUE)) {
    cat(sprintf("  %s %s (%s)\n", ok, p, as.character(utils::packageVersion(p))))
  } else {
    cat(sprintf("  %s %s is missing -- run source(\"Install_Packages.R\")\n", fail, p))
    problems <- problems + 1L
  }
}

cat("\n== Checking pre-fitted models ==\n")
if (!dir.exists("models")) {
  cat(sprintf("  %s models/ folder not found -- are you in the workshop folder?\n", fail),
      "    Open ShortWS_CognitiveModelling_bmm.Rproj first, then re-run this script.\n")
  problems <- problems + 1L
} else {
  rds_files <- list.files("models", pattern = "\\.rds$")
  if (length(rds_files) == 0L) {
    cat(sprintf("  %s no fitted models found in models/ --\n", fail),
        "    did you download/clone the *complete* repository?\n")
    problems <- problems + 1L
  } else {
    for (f in rds_files) {
      fit <- tryCatch(readRDS(file.path("models", f)), error = function(e) NULL)
      if (is.null(fit)) {
        cat(sprintf("  %s %s could not be read -- re-download the repository\n", fail, f))
        problems <- problems + 1L
      } else {
        cat(sprintf("  %s %s\n", ok, f))
      }
      rm(fit)
    }
  }
}

cat("\n")
if (problems == 0L) {
  cat("All good -- you're ready for the workshop! \U0001F389\n",
      "Start with the notebooks in examples/.\n")
} else {
  cat(sprintf("%d problem(s) found -- see the lines marked %s above.\n", problems, fail),
      "Fix them (or just come anyway -- the workshop is demonstration-based,\n",
      "and all materials are also published online).\n")
}
