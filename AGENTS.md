# Slide editing rules

- Resolve rendering and layout inconsistencies in the shared style or source structure. Do not mask them with per-slide or per-row font sizes, offsets, margins, padding, manual spaces, or line breaks.
- Keep formula font size, multiline row spacing, and baseline alignment in a single shared stylesheet. Formula content edits must inherit these rules.
- If a formula does not fit, fix the shared layout rather than shrinking that formula or nudging individual elements.
- Verify rendered glyph positions and spacing, not only row bounding boxes. Check all affected formula layouts after changing shared styles; do not infer that a screenshot issue is absent because a different preview looks correct.
- Do not add explanatory text, comments, or speaker notes to slides unless explicitly requested. Preserve approved content and terminology.
