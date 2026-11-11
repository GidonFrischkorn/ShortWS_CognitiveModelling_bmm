# Draw the three parameter slides for slides/03_EZDDM.qmd.
#
# Each figure has two rows and three columns. The rows are two values of
# one parameter. The columns are one trial, the choice probabilities, and
# the response-time densities.
#
# Run from the repo root:
#   Rscript slides/make_ddm_parameter_figures.R
#
# Diffusion scale is 1 and the path starts halfway between the bounds,
# matching ezdm(version = "3par").

library(here)
library(rtdists)

correct_fill <- "#b6ef4a"
error_fill <- "#ffb347"
correct_line <- "#4f8f12"
error_line <- "#e07a00"
bound_grey <- "#4a4a4a"
mark_red <- "#d00000"

# Choice probability for a centered start and diffusion scale 1.
probability_correct <- function(drift, bound) {
  1 / (1 + exp(-bound * drift))
}

# Subdensities of RT for a correct response and an error.
rt_subdensity <- function(drift, bound, ndt, time_grid) {
  start_point <- bound / 2
  density_correct <- rtdists::ddiffusion(time_grid, response = "upper",
                                          a = bound, v = drift, t0 = ndt,
                                          z = start_point, s = 1)
  density_error <- rtdists::ddiffusion(time_grid, response = "lower",
                                        a = bound, v = drift, t0 = ndt,
                                        z = start_point, s = 1)
  density_correct[!is.finite(density_correct)] <- 0
  density_error[!is.finite(density_error)] <- 0
  list(correct = density_correct, error = density_error)
}

# Wiener path with unit diffusion, absorbed at either bound.
one_absorbing_path <- function(drift, bound, ndt, time_limit, seed_value) {
  set.seed(seed_value)
  step_dt <- 0.001
  evidence_now <- bound / 2
  time_now <- ndt
  n_steps <- ceiling((time_limit - ndt) / step_dt) + 2
  evidence_path <- numeric(n_steps)
  time_path <- numeric(n_steps)
  evidence_path[1] <- evidence_now
  time_path[1] <- time_now
  last_step <- 1
  for (step_index in 2:n_steps) {
    evidence_now <- evidence_now + drift * step_dt + rnorm(1, sd = sqrt(step_dt))
    time_now <- time_now + step_dt
    if (evidence_now >= bound) {
      evidence_now <- bound
    }
    if (evidence_now <= 0) {
      evidence_now <- 0
    }
    evidence_path[step_index] <- evidence_now
    time_path[step_index] <- time_now
    last_step <- step_index
    if (evidence_now == 0 || evidence_now == bound || time_now >= time_limit) {
      break
    }
  }
  list(time_s = time_path[1:last_step], evidence = evidence_path[1:last_step])
}

# One noisy path. Prefer a correct response near the mean RT.
representative_path <- function(drift, bound, ndt, time_limit, seed_value) {
  q_value <- exp(-bound * drift)
  mean_rt <- ndt + (bound / (2 * drift)) * (1 - q_value) / (1 + q_value)
  best_path <- NULL
  best_gap <- Inf
  for (attempt in 0:40) {
    candidate <- one_absorbing_path(drift, bound, ndt, time_limit,
                                    seed_value + attempt)
    reached_correct <- tail(candidate$evidence, 1) >= bound - 1e-8
    if (!reached_correct) {
      next
    }
    gap <- abs(tail(candidate$time_s, 1) - mean_rt)
    if (gap < best_gap) {
      best_path <- candidate
      best_gap <- gap
    }
  }
  if (is.null(best_path)) {
    best_path <- one_absorbing_path(drift, bound, ndt, time_limit, seed_value)
  }
  best_path
}

# Time by which almost all responses have arrived.
time_horizon <- function(drift, bound, ndt) {
  objective <- function(rt_value) {
    start_point <- bound / 2
    upper <- rtdists::pdiffusion(rt_value, response = "upper",
                                  a = bound, v = drift, t0 = ndt,
                                  z = start_point, s = 1)
    lower <- rtdists::pdiffusion(rt_value, response = "lower",
                                  a = bound, v = drift, t0 = ndt,
                                  z = start_point, s = 1)
    upper + lower - 0.98
  }
  uniroot(objective, interval = c(ndt + 0.05, ndt + 12))$root
}

open_window <- function(horizontal_limit, vertical_low, vertical_high) {
  plot.new()
  plot.window(xlim = c(0, horizontal_limit),
              ylim = c(vertical_low, vertical_high),
              xaxs = "i", yaxs = "i")
}

# Left column: corridor, one path, and the two RT subdensities.
draw_trial <- function(setting, time_limit, time_grid, density_pack,
                       density_scale, evidence_high, row_label, seed_value) {
  drift <- setting$drift
  bound <- setting$bound
  ndt <- setting$ndt
  pad <- 0.42 * evidence_high
  open_window(time_limit, -pad, evidence_high + pad)
  rect(0, 0, time_limit, bound, col = "#f4f4f4", border = NA)
  polygon(c(time_grid, rev(time_grid)),
          c(rep(bound, length(time_grid)),
            rev(bound + density_pack$correct * density_scale)),
          col = correct_fill, border = NA)
  polygon(c(time_grid, rev(time_grid)),
          c(rep(0, length(time_grid)),
            rev(-density_pack$error * density_scale)),
          col = error_fill, border = NA)
  segments(0, bound, time_limit, bound, col = bound_grey, lwd = 2.4)
  segments(0, 0, time_limit, 0, col = bound_grey, lwd = 2.4)
  path <- representative_path(drift, bound, ndt, time_limit, seed_value)
  lines(path$time_s, path$evidence, lwd = 1.5, col = "black")
  segments(0, bound / 2, ndt, bound / 2, col = mark_red, lwd = 2.2)
  points(ndt, bound / 2, pch = 16, col = mark_red, cex = 0.8)
  arrow_time <- 0.22
  arrow_end <- bound / 2 + drift * arrow_time
  arrow_end <- min(max(arrow_end, 0.08 * evidence_high), bound - 0.06)
  if (abs(drift) > 1e-8) {
    arrow_time <- (arrow_end - bound / 2) / drift
  }
  arrows(ndt, bound / 2,
         ndt + max(arrow_time, 0.08), arrow_end,
         col = mark_red, lwd = 2.1, length = 0.08)
  text(0.015 * time_limit, bound, expression(alpha),
       adj = c(0, -0.25), col = mark_red, cex = 1.05)
  text(max(ndt, 0.02) / 2, bound / 2, expression(tau),
       adj = c(0.5, 1.35), col = mark_red, cex = 1.05)
  text(ndt + max(arrow_time, 0.08), arrow_end, expression(nu),
       adj = c(0.2, -0.55), col = mark_red, cex = 1.05, xpd = TRUE)
  axis(1, line = 0)
  mtext("Time (s)", side = 1, line = 1.65, cex = 0.85)
  text(time_limit * 0.985, evidence_high + pad * 0.72, row_label,
       adj = c(1, 0.5), font = 2, cex = 0.86 * 1.4)
}

# Middle column: probability of an error and of a correct response.
draw_choice <- function(drift, bound, column_label) {
  probability_upper <- probability_correct(drift, bound)
  probability_lower <- 1 - probability_upper
  open_window(2.6, 0, 1)
  rect(c(0.35, 1.45), c(0, 0), c(1.05, 2.15),
       c(probability_lower, probability_upper),
       col = c(error_fill, correct_fill), border = NA)
  label_height <- c(probability_lower, probability_upper)
  label_height <- ifelse(label_height > 0.86, label_height - 0.08, label_height + 0.06)
  text(c(0.7, 1.8), label_height,
       sprintf("%.2f", c(probability_lower, probability_upper)),
       cex = 1.25)
  axis(1, at = c(0.7, 1.8), labels = c("Error", "Correct"),
       line = 0, tick = FALSE, lwd = 0)
  axis(1, line = 0, labels = FALSE, lwd.ticks = 0)
  axis(2, at = c(0, 0.5, 1), labels = c("0", "0.5", "1"),
       las = 1, line = 0)
  mtext("Probability", side = 2, line = 2.15, las = 0, cex = 0.85 * 0.8)
  if (nchar(column_label) > 0) {
    mtext(column_label, side = 3, line = 0.15, cex = 0.82, col = "grey30")
  }
}

# Right column: RT subdensities. Area equals the choice probability.
draw_rt <- function(time_limit, time_grid, density_pack, density_ceiling,
                    column_label, show_legend) {
  open_window(time_limit, 0, density_ceiling)
  lines(time_grid, density_pack$error, col = error_line, lwd = 2.4)
  lines(time_grid, density_pack$correct, col = correct_line, lwd = 2.4)
  axis(1, line = 0)
  axis(2, las = 1, line = 0)
  mtext("Time (s)", side = 1, line = 1.65, cex = 0.85)
  mtext("Density", side = 2, line = 2.15, las = 0, cex = 0.85 * 0.8)
  if (nchar(column_label) > 0) {
    mtext(column_label, side = 3, line = 0.15, cex = 0.82, col = "grey30")
  }
  if (show_legend) {
    legend("topright", legend = c("Correct", "Error"),
           col = c(correct_line, error_line), lwd = 2.8, bty = "n", cex = 1.15)
  }
}

# One png: two settings, three columns, shared time and density scales.
draw_contrast <- function(contrast) {
  horizon_top <- time_horizon(contrast$top$drift, contrast$top$bound, contrast$top$ndt)
  horizon_bottom <- time_horizon(contrast$bottom$drift, contrast$bottom$bound,
                                 contrast$bottom$ndt)
  time_limit <- max(horizon_top, horizon_bottom) * 1.05
  time_grid <- seq(0, time_limit, length.out = 500)
  top_density <- rt_subdensity(contrast$top$drift, contrast$top$bound,
                               contrast$top$ndt, time_grid)
  bottom_density <- rt_subdensity(contrast$bottom$drift, contrast$bottom$bound,
                                  contrast$bottom$ndt, time_grid)
  evidence_high <- max(contrast$top$bound, contrast$bottom$bound)
  peak_density <- max(c(top_density$correct, top_density$error,
                        bottom_density$correct, bottom_density$error))
  # Each corridor uses its own scale so the shape stays visible.
  # The response-time column keeps one shared vertical scale.
  scale_top <- 0.36 * evidence_high / max(c(top_density$correct, top_density$error))
  scale_bottom <- 0.36 * evidence_high / max(c(bottom_density$correct, bottom_density$error))
  density_ceiling <- peak_density * 1.08

  figure_path <- here::here("slides", "images", contrast$file_name)
  png(figure_path, width = 10.8, height = 5.7, units = "in", res = 160, type = "cairo")
  par(mfrow = c(2, 3), mar = c(3.3, 4.1, 1.45, 0.55),
      oma = c(0.15, 0.15, 0.15, 0.15),
      mgp = c(2.1, 0.32, 0), tcl = -0.28, las = 1, bg = "white")
  draw_trial(contrast$top, time_limit, time_grid, top_density,
             scale_top, evidence_high, contrast$top$label, contrast$top$seed)
  draw_choice(contrast$top$drift, contrast$top$bound, "Choice")
  draw_rt(time_limit, time_grid, top_density, density_ceiling,
          "Response time", TRUE)
  draw_trial(contrast$bottom, time_limit, time_grid, bottom_density,
             scale_bottom, evidence_high, contrast$bottom$label,
             contrast$bottom$seed)
  draw_choice(contrast$bottom$drift, contrast$bottom$bound, "")
  draw_rt(time_limit, time_grid, bottom_density, density_ceiling, "", FALSE)
  dev.off()
  figure_path
}

# Build the three figures used on the parameter slides.
make_parameter_figures <- function() {
  # Drift changes. Boundary and non-decision time stay put.
  drift_contrast <- list(
    file_name = "param_drift.png",
    top = list(drift = 2.2, bound = 1.2, ndt = 0.30,
               label = expression("Large drift (" * nu == 2.2 * ")"),
               seed = 2026),
    bottom = list(drift = 0.25, bound = 1.2, ndt = 0.30,
                  label = expression("Drift near zero (" * nu == 0.25 * ")"),
                  seed = 2041)
  )
  # Boundary changes. Drift and non-decision time stay put.
  bound_contrast <- list(
    file_name = "param_bound.png",
    top = list(drift = 1.3, bound = 1.9, ndt = 0.30,
               label = expression("Wide boundary (" * alpha == 1.9 * ")"),
               seed = 2110),
    bottom = list(drift = 1.3, bound = 0.65, ndt = 0.30,
                  label = expression("Narrow boundary (" * alpha == 0.65 * ")"),
                  seed = 2124)
  )
  # Non-decision time changes. Drift and boundary stay put.
  ndt_contrast <- list(
    file_name = "param_ndt.png",
    top = list(drift = 1.4, bound = 1.2, ndt = 0.25,
               label = expression("Short non-decision time (" * tau == 0.25 * ")"),
               seed = 2202),
    bottom = list(drift = 1.4, bound = 1.2, ndt = 0.70,
                  label = expression("Long non-decision time (" * tau == 0.70 * ")"),
                  seed = 2218)
  )
  # Draw and save each contrast.
  saved <- c(
    draw_contrast(drift_contrast),
    draw_contrast(bound_contrast),
    draw_contrast(ndt_contrast)
  )
  saved
}

make_parameter_figures()
