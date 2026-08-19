## What this adds

<!-- One or two lines: which part, what changed. -->

Closes #

## Before you ask for review

- [ ] `_freeze/` committed after a root `quarto render` (CI checks this — the build runs with R made unavailable)
- [ ] file names match the contracts in `data/README.md` and `models/README.md` — renamed something? Say so here, the notebook and the deck have to follow
- [ ] codebook filled in `data/README.md` (columns, types, ranges, what one row is, N, design)
- [ ] `models/README.md` row filled: model function, parameterization, bmm and brms versions
- [ ] fits cached with brms `file =`, every `.rds` well under 50 MB
- [ ] readings and DOIs in `resources/README.md`; PDFs only if open access or a redistributable preprint

## For the reviewers

<!-- Anything you specifically want a second opinion on: level, timing, a modelling choice. -->

Reviewers are the other two presenters.
