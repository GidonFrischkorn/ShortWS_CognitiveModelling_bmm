# Fitting Cognitive Measurement Models with bmm

Materials for a 90-minute lunchtime workshop at the **Psychonomic Society
Annual Meeting, November 2026, San Diego**.

Applying cognitive measurement models requires translating theoretical
constructs — working memory capacity, signal sensitivity, evidence
accumulation — into statistical models that analyze data on the process
level. For many researchers, the translation step into specialized software
such as JAGS or Stan is the main barrier to adoption. The
[bmm](https://cran.r-project.org/package=bmm) (Bayesian Measurement Models)
R package removes it with a model-first interface: you specify the cognitive
model, bmm handles the translation for Bayesian hierarchical estimation in
Stan.

The workshop introduces three broadly applicable model families through
demonstration-based segments that all follow the same bmm workflow.
Participants leave with reusable scripts and pointers to tutorial papers.

**Audience:** PhD students and postdocs in cognitive psychology, cognitive
neuroscience, and related fields who collect behavioral data from memory,
recognition, or speeded decision tasks. Basic R proficiency is sufficient —
no prior exposure to Bayesian modeling, Stan, or brms is assumed.

## Schedule

| Time | Segment | Presenter |
| --- | --- | --- |
| ~10 min | Welcome & the bmm workflow | Gidon T. Frischkorn |
| ~20 min | Part 1: Signal Detection Theory | Gidon T. Frischkorn |
| ~25 min | Part 2: The Memory Measurement Model (M3) | Chenyu Li |
| ~25 min | Part 3: The EZ-Drift Diffusion Model | Adriana F. Chávez De la Peña |
| ~10 min | Q&A and wrap-up | all |

## Repository map

| Path | Contents |
| --- | --- |
| `slides/` | Quarto reveal.js decks (`00_template.qmd` = shared pattern reference) |
| `examples/` | Take-home Quarto notebooks, one per segment |
| `data/` | Datasets used in slides and notebooks (see its README for codebooks) |
| `models/` | Pre-fitted bmm models (`.rds`) — no Stan toolchain needed to follow along |
| `resources/` | Tutorial papers and background reading per segment |
| `Install_Packages.R` | One-time package installation script |

## Setup for participants

1. Install [R](https://cran.r-project.org/) (≥ 4.3) and an IDE
   ([RStudio](https://posit.co/download/rstudio-desktop/) or
   [Positron](https://positron.posit.co/)).
2. Clone or download this repository.
3. Run `source("Install_Packages.R")` once. Part 1 of the script is all you
   need: every model shown in the workshop ships pre-fitted in `models/`, so
   the Stan toolchain (Part 2) is **optional** and only required to re-fit
   models yourself.
4. Open `ShortWS_CognitiveModelling_bmm.Rproj` and start with the notebooks
   in `examples/`.

## Notes for presenters

- **Start from the template.** `slides/00_template.qmd` demonstrates every
  slide and code pattern (section dividers, line-stepped code, cached-fit
  loading, interactive webR cells, speaker notes). Shared deck options live
  in `slides/_metadata.yml`; your deck YAML stays minimal.
- **Never fit live.** Fit models locally, `saveRDS()` into `models/` using
  the file names contracted in `models/README.md`, and load the cached fit
  on the slide. Commit the `.rds` with your deck.
- **webR cells need internet.** Interactive cells (quarto-live) load webR
  from a CDN at presentation time. Every webR demo must have a static
  pre-rendered fallback figure in the deck in case the venue network fails.
  Stan/bmm cannot run in webR — interactive cells are for closed-form demos
  and posterior exploration only.
- **Rendering.** While iterating: `quarto render slides/02_M3.qmd` (executes
  only your deck). Before handing off: run `quarto render` at the repo root
  once and commit the updated `_freeze/` folder — the freeze cache is what
  lets everyone else (and a fresh clone) render the full project without
  executing your chunks.
- **Literature.** Add readings to `resources/README.md` with DOIs; include
  the PDF in your segment's subfolder only if it is open access or a
  redistributable preprint — this repository is public.

## Rendering the materials

```bash
quarto render              # everything → _output/
quarto render slides/01_Intro_bmm_SDT.qmd   # a single deck
```

## License

See [LICENSE](LICENSE).
