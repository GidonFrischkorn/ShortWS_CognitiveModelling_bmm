# Prepare data/sdt_recognition.csv from the Koen et al. (2013) recognition
# data shipped with the MPTinR package (dataset `roc6`; Klauer & Kellen, 2015).
#
# Source study: Koen, Aly, Wang, & Yonelinas (2013), JEP:LMC, 39(6), 1726-1741.
# https://doi.org/10.1037/a0033671
#
# MPTinR's roc6 contains the CONTROL conditions of two experiments:
#   * "Koen-2013_full"      -> Experiment 2, full-attention recognition test
#                              (the subset used in Vuorre, 2025)
#   * "Koen-2013_immediate" -> Experiment 4, immediate recognition test
# The treatment cells (divided attention, 24-hr delay) are NOT distributed
# with MPTinR, so `condition` is a between-subjects factor comparing the two
# test procedures (48 participants each).
#
# roc6 stores per-participant response counts (stimulus x 6-point rating).
# We expand the counts to one row per trial for regression modeling; trial
# ORDER is arbitrary (the source data are aggregated).
#
# Run from the repo root: Rscript data/prepare_sdt_recognition.R

library(tidyverse)

# --- load roc6 without requiring MPTinR to be installed -----------------
if (requireNamespace("MPTinR", quietly = TRUE)) {
  data(roc6, package = "MPTinR")
} else {
  tmp <- tempfile(fileext = ".tar.gz")
  download.file("https://cran.r-project.org/src/contrib/MPTinR_1.14.1.tar.gz",
                tmp, quiet = TRUE)
  untar(tmp, files = "MPTinR/data/roc6.rda", exdir = tempdir())
  load(file.path(tempdir(), "MPTinR", "data", "roc6.rda"))
}

# --- reshape: counts -> one row per (pseudo-)trial -----------------------
rating_levels <- c("3new" = 1, "2new" = 2, "1new" = 3,
                   "1old" = 4, "2old" = 5, "3old" = 6)

sdt_recognition <- roc6 |>
  filter(str_detect(exp, "Koen-2013")) |>
  mutate(
    condition = if_else(exp == "Koen-2013_full", "full_attention", "immediate"),
    pid = str_c(if_else(condition == "full_attention", "full_", "imm_"),
                sprintf("%02d", as.integer(str_extract(as.character(id), "^[0-9]+"))))
  ) |>
  pivot_longer(OLD_3new:NEW_3old, names_to = "cell", values_to = "n") |>
  separate_wider_delim(cell, "_", names = c("stimulus", "resp")) |>
  mutate(
    stimulus = str_to_lower(stimulus),
    rating   = rating_levels[resp]
  ) |>
  uncount(n) |>
  mutate(
    is_old  = as.integer(stimulus == "old"),
    say_old = as.integer(rating >= 4)
  ) |>
  select(pid, condition, stimulus, is_old, rating, say_old) |>
  arrange(condition, pid, desc(stimulus), rating)

stopifnot(
  n_distinct(sdt_recognition$pid) == 96,
  all(sdt_recognition$say_old == (sdt_recognition$rating >= 4))
)

write_csv(sdt_recognition, file.path("data", "sdt_recognition.csv"))
cat("Wrote", nrow(sdt_recognition), "trials from",
    n_distinct(sdt_recognition$pid), "participants to data/sdt_recognition.csv\n")
