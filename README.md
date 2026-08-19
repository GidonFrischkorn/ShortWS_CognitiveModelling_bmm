# Analyzing Behavioral Data at the Cognitive Process Level with bmm in R

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
| `index.qmd` | Landing page for the published site (schedule + links to all materials) |
| `slides/` | Quarto reveal.js decks (`00_template.qmd` = shared pattern reference) |
| `examples/` | Take-home Quarto notebooks, one per segment, plus `00_your_own_data.qmd` — the bridge from the demos to the attendee's own dataset |
| `data/` | Datasets used in slides and notebooks (its README is the single source for codebooks) |
| `models/` | Pre-fitted bmm models (`.rds`) — no Stan toolchain needed to follow along |
| `resources/` | Tutorial papers and background reading per segment |
| `_common.R` | Shared plot colors and ggplot theme, sourced by all decks and notebooks |
| `Install_Packages.R` | One-time package installation script |
| `Check_Setup.R` | Verifies packages and pre-fitted models load — "you're ready" check |

## Setup for participants

1. Install [R](https://cran.r-project.org/) (≥ 4.3) and an IDE
   ([RStudio](https://posit.co/download/rstudio-desktop/) or
   [Positron](https://positron.posit.co/)).
2. Clone or download this repository.
3. Open `ShortWS_CognitiveModelling_bmm.Rproj` and run
   `source("Install_Packages.R")` once. Part 1 of the script is all you
   need: every model shown in the workshop ships pre-fitted in `models/`, so
   the Stan toolchain (Part 2) is **optional** and only required to re-fit
   models yourself.
4. Run `source("Check_Setup.R")` — it verifies that the packages and the
   pre-fitted models load and tells you that you're ready.
5. Start with the notebooks in `examples/`.

⚠️ Part 1 (signal detection) currently needs the **development** version of
bmm: `sdt_yn()` and `sdt_rating()` are not in the CRAN release yet. Install it
with `remotes::install_github("venpopov/bmm")`. This goes away once the
release lands — see `models/README.md`.

Once you have run the workshop's own notebooks, `examples/00_your_own_data.qmd`
is the one to read next: which bmm model fits your paradigm, what shape your
data has to be in, how to write the formula for your design, how to set up the
Stan toolchain, and what the first error messages mean.

No time for setup? All materials are also published as a website (slides and
fully rendered notebooks) — nothing to install, readable on any device.

## Notes for presenters

- **Start from the template.** `slides/00_template.qmd` demonstrates every
  slide and code pattern (section dividers, line-stepped code, cached-fit
  loading, interactive webR cells, speaker notes). Shared deck options live
  in `slides/_metadata.yml`; your deck YAML stays minimal.
- **Follow the shared skeleton.** Every segment uses the same section order —
  model intuition → see the data → specify → fit → evaluate → extension →
  take-home — so attendees see the identical workflow three times. The
  *extension* section is the designated flex material: the schedule has no
  buffer, so draft it to be cuttable live without breaking the storyline.
- **Use the shared plot style.** `source(here::here("_common.R"))` in a
  hidden setup chunk gives you `wk_colors` and `theme_workshop()` — use them
  in every figure so the three decks look like one workshop.
- **Never fit live.** Fit models locally, `saveRDS()` into `models/` using
  the file names contracted in `models/README.md`, and load the cached fit
  on the slide with a plain `readRDS()`. Fit with **CRAN** versions of
  bmm/brms and record them in the `models/README.md` table — participants
  install from CRAN, and dev-version fits can break for them. Commit the
  `.rds` with your deck.
- **Math renders natively.** `html-math-method: mathml` in `_metadata.yml` —
  formulas are typeset by the browser itself, with no MathJax loaded from a
  CDN (Quarto's default would). Keep display math simple and avoid exotic
  fonts: write distributions as `\text{Normal}(\mu, \sigma)`, not
  `\mathcal{N}` (the calligraphic glyph has no offline fallback and renders
  as an empty box).
- **Nothing runs in the browser.** Decks are plain reveal.js: all code on the
  slides executes at render time and the output is baked in, so the venue
  network is irrelevant. For a closed-form "what if", show a few parameter
  values side by side (pattern in the template). If you want to *run*
  something in front of the audience, do it in the IDE from your `examples/`
  notebook (load the cached fit, evaluate) — the slide carries the same
  output as insurance.

- **Attendees do not follow along on a screen.** The QR code appears exactly
  twice — once early, once on the take-home slide — and the early one is
  spoken as *"scan it now and put your phone away"*. This is deliberate: an
  audience reading the notebook on a laptop follows neither the notebook nor
  you, and the notebooks contain nothing the projector is not already
  showing. Do not pace your talk to a read-along, and do not narrate page
  numbers.

- **Two interactive beats, both cheap, both with static insurance.**
  Part 1 uses them at `## Lower accuracy — but why?` (two shows of hands
  before the reveal, ~40 s) and at `## Specify: one formula per parameter`
  (live in the IDE, ~2:15). Both are documented in the deck's speaker notes
  with the exact sequence. The rule that makes a live demo safe: **never
  demo anything whose output is not already baked into an adjacent slide**,
  so you can abandon it mid-way and simply advance.

  Safe live moves on a cached fit — all sub-second, none can fail on stage:
  `hypothesis()` with any new expression (0.02 s), `spread_draws()` (0.03 s),
  `ranef()` (0.08 s), `fixef()`, `posterior_summary()`, `conditional_effects()`
  (0.9 s), and building a derived quantity from draws. Printing a model
  object or `bmm::parameters()` is instant. Do **not** re-fit live: even a
  fast model prints sampler output and needs cmdstan.

- **QR code.** `slides/images/qr_site.png` encodes the published site URL and
  is committed as a static asset — no R package, no render-time generation,
  no CDN. If the URL ever changes, regenerate it with
  `qrencode -o slides/images/qr_site.png -s 10 -m 2 -l M "<new-url>"` and
  **scan it with a phone before the session** — that is the one check the
  render cannot do for you.
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

### PDF handouts of a deck

For review, for backup on a conference laptop, and for sharing after the
session, export any deck to PDF with
[decktape](https://github.com/astefanutti/decktape) (`npm i -g decktape`):

```bash
decktape reveal --size 1280x720 \
  "file://$PWD/_output/slides/01_Intro_bmm_SDT.html" \
  _output/pdf/01_Intro_bmm_SDT.pdf
```

On macOS add `--chrome-path "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"`
if decktape does not find a browser. Fragments are printed in their final
state, i.e. one page per slide. Alternatively, open the deck in a browser,
press `e` for print view and use the browser's "Save as PDF".

## Publishing (GitHub Pages)

The rendered site — `index.qmd` landing page, all decks, all notebooks — is
published to GitHub Pages so attendees can follow along and revisit the
materials without installing anything:

```bash
quarto publish gh-pages    # render + push to the gh-pages branch
```

Run from the repo root after your changes are committed. The site is a
Quarto **website** with a docked sidebar and local search (`_quarto.yml`) —
the sidebar applies to `index.qmd` and the notebooks; Quarto does not apply
it to reveal.js output, so the decks are unaffected. Note that the notebooks
deliberately do **not** use `embed-resources`: in a website project it fights
the shared `site_libs` and inflates every page (4.1 MB → 71 KB for the SDT
notebook), which matters when a room full of people loads the site at once.

The QR code on the slides points at
`https://gidonfrischkorn.github.io/ShortWS_CognitiveModelling_bmm/`. That URL
is 52 characters and nobody types it from memory in December — if a short,
speakable URL is wanted (custom domain or a shorter repo name), decide it
*before* the conference and regenerate the QR.

## License and citation

Different parts of this repository carry different terms — the workshop
content is share-alike and non-commercial, the scripts are not.

| Path | License | What that means |
| --- | --- | --- |
| `slides/`, `examples/`, `index.qmd`, figures, prose | [CC BY-NC-SA 4.0](LICENSE) | Reuse and adapt freely for teaching and research, **credit the presenters**, no commercial use, and derivatives must carry the same license |
| `_common.R`, `Install_Packages.R`, `Check_Setup.R`, `data/prepare_*.R`, `models/fit_*.R` | [MIT](LICENSE-CODE) | Take them, adapt them to your own data, no strings — including at a company |
| `data/` | Third-party, see [data/README.md](data/README.md) | Redistributed source data; cite the original study |
| `resources/` | Third-party, see [resources/README.md](resources/README.md) | Papers copyright their authors and publishers |

The scripts are deliberately left permissive: the point of the workshop is
that you can apply these models to your own data, and that shouldn't depend
on who employs you.

To cite the materials, use the "Cite this repository" button on GitHub or see
[CITATION.cff](CITATION.cff).
