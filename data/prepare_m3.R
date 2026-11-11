# Prepare the simple-span and complex-span datasets for the M3 examples.
# Source files and aggregation follow tutorial1_simple_span.R at
# https://github.com/GidonFrischkorn/tutorial-m3-bmm
# Run from the repository root: Rscript data/prepare_m3.R

# 1. Setup

library(tidyverse)

source_base <- "https://raw.githubusercontent.com/GidonFrischkorn/tutorial-m3-bmm/main/data/"
# 2. Simple span

## 2.1 Data
files <- paste0("Oberauer_2019_SimpleSpan_Exp", 1:2, ".dat")
raw_files <- file.path(tempdir(), files)
for (i in seq_along(files)) {
  download.file(paste0(source_base, files[i]), raw_files[i], quiet = TRUE)
}

columns <- c("id", "session", "block", "trial", "setsize",
             "rsizeList", "rsizeNPL", "tested", "response", "rcat", "rt")

read_experiment <- function(file, experiment) {
  read.table(file, header = FALSE, col.names = columns, fill = TRUE) |>
    drop_na() |>
    mutate(exp = experiment, id = paste(id, experiment, sep = "_"))
}

## 2.2 Aggregate responses
simple_span <- bind_rows(
  read_experiment(raw_files[1], "openset"),
  read_experiment(raw_files[2], "closedset")
) |>
  filter(rsizeList + rsizeNPL > 0) |>
  group_by(id, exp, setsize, rsizeList, rsizeNPL) |>
  summarise(corr = sum(rcat == 1),
            other = sum(rcat == 2),
            npl = sum(rcat == 3), .groups = "drop") |>
  mutate(n_corr = 1, n_other = rsizeList - 1, n_npl = rsizeNPL,
         ss_fac = factor(setsize), ss_lin = setsize - mean(setsize),
         exp = factor(exp)) |>
  select(id, exp, setsize, ss_fac, ss_lin, corr, other, npl,
         n_corr, n_other, n_npl)

## 2.3 Save the open-set teaching subset
simple_span <- simple_span |> filter(exp == "openset")
write_csv(simple_span, file.path("data", "m3_simple_span.csv"))

# 3. Complex span

# Complex span: follow prepare_Li2026_data.R in the same tutorial repository.
# Exclusions use the public judgment-performance data; the original study's
# post-experiment survey is not in the public data and cannot be applied here.
## 3.1 Data
complex_file <- file.path(tempdir(), "Li_2026_ComplexSpan_Exp1.csv")
download.file(paste0(source_base, "Li_2026_ComplexSpan_Exp1.csv"),
              complex_file, quiet = TRUE)
complex_raw <- read_csv(complex_file, show_col_types = FALSE)

## 3.2 Exclusions
# Exclude complete trials with missing images before assessing performance.
missing_images <- complex_raw |>
  filter(screenID == "memory") |>
  group_by(participant, blockID, trialID) |>
  summarise(has_missing = any(is.na(leftImage) | is.na(rightImage)),
            .groups = "drop")

judgment_performance <- complex_raw |>
  filter(screenID == "memory") |>
  left_join(missing_images, by = c("participant", "blockID", "trialID")) |>
  filter(!has_missing) |>
  mutate(responded = response != "NULL" & !is.na(response)) |>
  summarise(pResp = mean(responded),
            pAcc = mean(acc[responded], na.rm = TRUE), .by = participant)
excluded_ids <- judgment_performance |>
  filter(pResp < 0.5 | pAcc < 0.7) |>
  pull(participant)

## 3.3 Classify responses
# Identify each target, its paired distractor, and the other images in its trial.
memory <- complex_raw |>
  filter(screenID == "memory", !participant %in% excluded_ids) |>
  left_join(missing_images, by = c("participant", "blockID", "trialID")) |>
  filter(!has_missing) |>
  mutate(target = if_else(cue == "left", leftImage, rightImage),
         distractor = if_else(cue == "left", rightImage, leftImage)) |>
  select(participant, blockID, trialID, condition, target, distractor)

trial_lookup <- memory |>
  group_by(participant, blockID, trialID, condition) |>
  summarise(all_targets = list(target), all_distractors = list(distractor),
            .groups = "drop")
pair_lookup <- memory |>
  select(participant, blockID, trialID, target, distractor)

retrieval <- complex_raw |>
  filter(screenID == "retrieval", !participant %in% excluded_ids) |>
  select(participant, blockID, trialID, condition, correctObject, response) |>
  semi_join(trial_lookup, by = c("participant", "blockID", "trialID")) |>
  left_join(pair_lookup, by = c("participant", "blockID", "trialID",
                                "correctObject" = "target")) |>
  left_join(select(trial_lookup, -condition),
            by = c("participant", "blockID", "trialID")) |>
  mutate(rcat = case_when(
    response == "NULL" ~ "noRes",
    response == correctObject ~ "corr",
    response == distractor ~ "distc",
    map2_lgl(response, all_targets, ~ .x %in% .y) ~ "other",
    map2_lgl(response, all_distractors, ~ .x %in% .y) ~ "disto",
    TRUE ~ "npl"
  ))

## 3.4 Aggregate responses
# Count only completed retrieval responses, as in the companion analysis.
complex_span <- retrieval |>
  filter(rcat != "noRes") |>
  count(participant, condition, rcat) |>
  pivot_wider(names_from = rcat, values_from = n, values_fill = 0)

## 3.5 Response options
# All tests contain 12 options; control tests contain no distractors.
response_options <- tibble(
  condition = c("control", "pre", "retro"),
  n_corr = c(1, 1, 1), n_other = c(2, 2, 2),
  n_distc = c(0, 1, 1), n_disto = c(0, 2, 2), n_npl = c(9, 6, 6)
)
complex_span <- complex_span |>
  left_join(response_options, by = "condition") |>
  mutate(condition = factor(condition, levels = c("control", "pre", "retro"))) |>
  select(participant, condition, corr, other, distc, disto, npl,
         n_corr, n_other, n_distc, n_disto, n_npl)

## 3.6 Save the pre-cue teaching subset
complex_span <- complex_span |> filter(condition == "pre")
write_csv(complex_span, file.path("data", "m3_complex_span.csv"))
