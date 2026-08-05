# _common.R -- shared plotting constants for all decks and notebooks.
#
# Source from any .qmd (slides or examples):
#   source(here::here("_common.R"))
#
# Using these constants keeps figures visually consistent across all three
# segments without copy-pasting hex codes. The colors match slides/custom.scss
# and are a colorblind-safe blue/orange pair.

wk_colors <- c(
  blue   = "#0028a5",  # primary: data, model predictions
  orange = "#dc6800",  # accent: highlights, reference lines
  grey   = "#7f7f7f"   # de-emphasis: chance lines, raw-data background
)

# Shared ggplot2 theme -- large base size for projection.
theme_workshop <- function(base_size = 18) {
  ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(face = "bold")
    )
}
