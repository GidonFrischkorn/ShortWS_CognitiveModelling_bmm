# Prepare data/ezddm_perceptual.csv from participant N.H. in Ratcliff and
# Rouder (1998), Experiment 1 (brightness).
#
# Source file: data/nh.tsv, as used in Chávez De la Peña and Vandekerckhove
# (2025) and stored in https://github.com/Adrifelcha/EZ-project
# (demos/applications/brightness_perception/data/nh.tsv).
# The source has no header and one row per trial.
#
# The cuts match the 2025 brightness demo: drop the even-mix cells, where
# accuracy is undefined, and drop trials slower than 3000 ms.
#
# Run from the repo root: Rscript data/prepare_ezddm_perceptual.R
library(here)

# The raw data file can be downloaded from:
# https://github.com/Adrifelcha/EZ-project/tree/main/demos/applications/brightness_perception/data

# Read the whitespace-separated source. Four columns, no header.
raw_data <- read.table(here("data", "nh.tsv"),header = FALSE)

# Name the columns the way the brightness demo report does.
colnames(raw_data) <- c("index", "cond", "response", "rt_ms")

# Confirm the file is still the single-participant brightness file.
stopifnot(nrow(raw_data) == 7890,
          all(raw_data$index == 1),
          all(raw_data$cond %in% 1:66),
          length(unique(raw_data$cond)) == 66,
          all(raw_data$response %in% c(1, 2)),
          min(raw_data$rt_ms) == 173,
          max(raw_data$rt_ms) == 14072)

# Drop the 50/50 cells (cond 17 and 50; no correct answer).
clean_data <- raw_data[!(raw_data$cond %in% c(17, 50)), ]

# Drop trials slower than 3000 ms.
clean_data <- clean_data[clean_data$rt_ms <= 3000, ]

# Confirm the cleaned file: 64 cells, no even-mix rows, no slow trials.
stopifnot(nrow(clean_data) == 7373,
          all(clean_data$index == 1),
          length(unique(clean_data$cond)) == 64,
          !any(clean_data$cond %in% c(17, 50)),
          all(clean_data$response %in% c(1, 2)),
          min(clean_data$rt_ms) == 173,
          max(clean_data$rt_ms) == 2981)

# Write the contracted workshop file.
write.csv(clean_data, here("data", "ezddm_perceptual.csv"), row.names = FALSE)

cat("Wrote", nrow(clean_data), "trials to data/ezddm_perceptual.csv\n")
