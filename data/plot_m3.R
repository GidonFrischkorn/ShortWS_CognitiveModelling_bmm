# Generate review figures from the open-set and pre-cue M3 fits.
# Run from the repository root: Rscript data/plot_m3.R

library(bmm)
library(brms)
library(tidyverse)
library(tidybayes)
source('_common.R')

dir.create(file.path('data', 'figures'), showWarnings = FALSE)
parameter_colors <- c(a = '#0028a5', c = '#dc6800', f = '#28a745')
source_colors <- c(Observed = '#008577', Predicted = '#8054a1')
source_shapes <- c(Observed = 16, Predicted = 17)
source_lines <- c(Observed = 'solid', Predicted = 'dashed')

dat_simple <- read_csv('data/m3_simple_span.csv', show_col_types = FALSE)
dat_complex <- read_csv('data/m3_complex_span.csv', show_col_types = FALSE)
fit_simple <- readRDS('models/m3_simple.rds')
fit_complex <- readRDS('models/m3_complex.rds')

# 1. Simple-span posterior predictive check
set.seed(2026)
expected_simple <- posterior_epred(fit_simple, ndraws = 200)
predicted_simple <- dat_simple |> select(id, setsize)
predicted_simple[c('corr', 'other', 'npl')] <- apply(expected_simple, c(2, 3), mean)
pp_simple <- bind_rows(
  Observed = dat_simple |> select(id, setsize, corr, other, npl),
  Predicted = predicted_simple,
  .id = 'source'
) |>
  summarise(across(c(corr, other, npl), sum), .by = c(source, id, setsize)) |>
  mutate(total = corr + other + npl) |>
  pivot_longer(c(corr, other, npl), names_to = 'category', values_to = 'count') |>
  mutate(proportion = count / total,
         category = factor(category, levels = c('corr', 'other', 'npl'),
                           labels = c('Correct', 'Other items', 'NPL'))) |>
  summarise(se = sd(proportion) / sqrt(n()), proportion = mean(proportion),
            .by = c(source, setsize, category))

dodge <- position_dodge(width = 0.25)
simple_predictive <- pp_simple |>
  ggplot(aes(setsize, proportion, color = source, shape = source,
             linetype = source, group = source)) +
  geom_errorbar(aes(ymin = pmax(0, proportion - se), ymax = pmin(1, proportion + se)),
                width = 0.12, position = dodge) +
  geom_line(position = dodge) +
  geom_point(size = 3, position = dodge) +
  facet_wrap(~category, nrow = 1, scales = 'free_y') +
  scale_color_manual(values = source_colors) +
  scale_shape_manual(values = source_shapes) +
  scale_linetype_manual(values = source_lines) +
  scale_x_continuous(breaks = c(2, 4, 6, 8)) +
  labs(x = 'Set size', y = 'Response proportion', color = NULL, shape = NULL, linetype = NULL) +
  theme_workshop() + theme(legend.position = 'right')
ggsave('data/figures/m3_simple_predictive.png', simple_predictive, width = 12, height = 4.8, dpi = 180)

# 2. Simple-span parameters on the activation scale
simple_parameters <- as.data.frame(fit_simple) |>
  select(matches('^b_[ac]_ss_fac[2468]$')) |>
  pivot_longer(everything(), names_to = c('parameter', 'setsize'),
               names_pattern = '^b_([ac])_ss_fac([2468])$', values_to = 'value') |>
  mutate(setsize = as.integer(setsize), parameter = factor(parameter, levels = c('a', 'c'))) |>
  summarise(median_qi(value), .by = c(parameter, setsize))
simple_posterior <- simple_parameters |>
  ggplot(aes(setsize, y, color = parameter, group = parameter)) +
  geom_line(position = dodge) +
  geom_pointrange(aes(ymin = ymin, ymax = ymax), position = dodge) +
  facet_wrap(~parameter, nrow = 1, labeller = as_labeller(c(
    a = 'Item memory (a)', c = 'Binding memory (c)'
  ))) +
  scale_color_manual(values = parameter_colors, guide = 'none') +
  scale_y_continuous(limits = c(0, 6), breaks = 0:6, expand = expansion(mult = 0)) +
  scale_x_continuous(breaks = c(2, 4, 6, 8)) +
  labs(x = 'Set size', y = 'Activation', color = NULL) +
  theme_workshop() + theme(legend.position = 'bottom')
ggsave('data/figures/m3_simple_parameters.png', simple_posterior, width = 12, height = 5, dpi = 180)

# 3. Five-category pre-cue posterior predictive check
set.seed(2026)
expected_complex <- posterior_epred(fit_complex, ndraws = 200)
predicted_complex <- dat_complex |> select(participant, condition)
predicted_complex[c('corr', 'distc', 'other', 'disto', 'npl')] <-
  apply(expected_complex, c(2, 3), mean)
pp_complex <- bind_rows(
  Observed = dat_complex |> select(participant, condition, corr, distc, other, disto, npl),
  Predicted = predicted_complex,
  .id = 'source'
) |>
  mutate(total = corr + distc + other + disto + npl) |>
  pivot_longer(c(corr, distc, other, disto, npl), names_to = 'category', values_to = 'count') |>
  mutate(proportion = count / total,
         category = factor(category, levels = c('corr', 'distc', 'other', 'disto', 'npl'),
                           labels = c('Correct', 'Paired distractor', 'Other targets', 'Other distractors', 'NPL'))) |>
  summarise(se = sd(proportion) / sqrt(n()), proportion = mean(proportion),
            .by = c(source, condition, category))
complex_predictive <- pp_complex |>
  mutate(response_type = factor(if_else(category == 'Correct', 'Correct', 'Errors'),
                                levels = c('Correct', 'Errors'))) |>
  ggplot(aes(category, proportion, color = source, shape = source, group = source)) +
  geom_errorbar(aes(ymin = pmax(0, proportion - se), ymax = pmin(1, proportion + se)),
                width = 0.10, position = dodge) +
  geom_point(size = 3, position = dodge) +
  facet_wrap(~response_type, nrow = 1, scales = 'free', space = 'free_x') +
  ggh4x::scale_y_facet(response_type == 'Correct',
                       breaks = seq(0.5, 0.9, 0.1), limits = c(0.5, 0.9)) +
  ggh4x::scale_y_facet(response_type == 'Errors',
                       breaks = seq(0, 0.20, 0.05), limits = c(0, 0.20)) +
  scale_color_manual(values = source_colors) +
  scale_shape_manual(values = source_shapes) +
  scale_x_discrete(labels = c('Correct' = 'Correct',
                            'Paired distractor' = 'Paired\ndistractor',
                            'Other targets' = 'Other\ntargets',
                            'Other distractors' = 'Other\ndistractors',
                            'NPL' = 'NPL')) +
  labs(x = NULL, y = 'Response proportion', color = NULL, shape = NULL) +
  theme_workshop() + theme(legend.position = 'right', strip.text = element_text(size = 16))
ggsave('data/figures/m3_complex_predictive.png', complex_predictive, width = 14, height = 4.8, dpi = 180)

# 4. Pre-cue activation and filtering parameters
complex_parameters <- as.data.frame(fit_complex) |>
  select(matches('^b_[acf]_Intercept$')) |>
  pivot_longer(everything(), names_to = 'parameter',
               names_pattern = '^b_([acf])_Intercept$', values_to = 'value') |>
  mutate(value = if_else(parameter == 'f', plogis(value), value),
         parameter = factor(parameter, levels = c('a', 'c', 'f'))) |>
  summarise(median_qi(value), .by = parameter)
complex_parameter_base <- ggplot(complex_parameters, aes(parameter, y, color = parameter)) +
  geom_pointrange(aes(ymin = ymin, ymax = ymax), linewidth = 0.7) +
  scale_color_manual(values = parameter_colors, guide = 'none') +
  labs(x = NULL) +
  theme_workshop(base_size = 14) +
  theme(panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_line(color = '#eceff1', linewidth = 0.3))
complex_activation <- (complex_parameter_base + filter(complex_parameters, parameter != 'f')) +
  scale_x_discrete(limits = c('a', 'c'), labels = c(a = 'a', c = 'c')) +
  scale_y_continuous(limits = c(0, 6), breaks = 0:6, expand = expansion(mult = 0)) +
  labs(y = 'Activation')
complex_filtering <- (complex_parameter_base + filter(complex_parameters, parameter == 'f')) +
  scale_x_discrete(labels = c(f = 'f')) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.25), expand = expansion(mult = 0)) +
  labs(y = NULL)
complex_posterior <- patchwork::wrap_plots(complex_activation, complex_filtering, nrow = 1, widths = c(2, 1))
ggsave('data/figures/m3_complex_parameters.png', complex_posterior, width = 6, height = 3.5, dpi = 180)

# Numeric summaries accompany the review figures.
write_csv(simple_parameters, 'data/figures/m3_simple_parameters.csv')
write_csv(complex_parameters, 'data/figures/m3_complex_parameters.csv')
write_csv(pp_simple, 'data/figures/m3_simple_predictive.csv')
write_csv(pp_complex, 'data/figures/m3_complex_predictive.csv')
