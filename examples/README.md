# Take-home example notebooks

One runnable Quarto notebook per workshop segment:

| Notebook | Segment | Presenter |
| --- | --- | --- |
| `01_sdt.qmd` | Signal Detection Theory | Gidon T. Frischkorn |
| `02_m3.qmd` | Memory Measurement Model (M3) | Chenyu Li |
| `03_ezddm.qmd` | EZ-Drift Diffusion Model | Adriana F. Chávez De la Peña |

## How to run

1. Install packages once: `source("Install_Packages.R")` at the repo root
   (Part 1 is enough — all models ship pre-fitted in `models/`).
2. Open `ShortWS_CognitiveModelling_bmm.Rproj` in RStudio.
3. Open a notebook and run chunks interactively, or render it:
   `quarto render examples/01_sdt.qmd` (output lands in `_output/examples/`).

Each notebook loads its fitted model from `models/*.rds` and only re-fits if
the file is missing — re-fitting requires the optional Stan toolchain
(`Install_Packages.R`, Part 2).
