# Implementation and validation

## PR summary

Reconstruct the missing Shiny application and replace the legacy Slidify pipeline
with Quarto. Both outputs use shared base-R data validation and inclusive date
range calculations. The app displays rounded mean hires, a date summary, and a
full-history chart with the selection highlighted. The slides retain the original
five-part narrative and `Index.html` URL, with a current app screenshot.

Fix broken highlighting/licence references, duplicate slide/theme IDs, heading
styling, and unhandled invalid ranges. Remove unused vendored frameworks,
generated Markdown, old screenshots, and tracked rendering caches after the new
deck renders. Preserve the historical CSV and the user-provided `agents.md`.

## Environment

Local validation used macOS arm64, R 4.4.1, Quarto 1.11.9, Shiny 1.14.0,
bslib 0.10.0, testthat 3.3.2, shinytest2 0.5.1, and installed Google Chrome.
Exact R dependencies are recorded in `renv.lock`. CI targets R 4.4.3, which matches
the R patch release used to build downloaded macOS binaries.

## Checks

- `python3 scripts/validate_data.py`: passed. CSV SHA-256 matches the original.
- `RUN_BROWSER_TESTS=true Rscript scripts/test.R`: **50 assertions passed**,
  zero test failures, zero test warnings, and no skipped tests. This includes
  calculations, malformed CSV fixtures, server validation, actual browser date
  changes, chart pixel changes and reproducible restoration of prior ranges, and mobile interactions at 390×844.
- `quarto render index.qmd`: passed using the pinned local Quarto executable
  `.tools/bin/quarto`; generated the self-contained `Index.html`.
- `Rscript scripts/validate_slides.R`: passed. Five sections, unique IDs, valid
  references including lazy-loaded images, embedded images, and correct licence URL.
- `Rscript scripts/smoke_slides.R`: passed on the locally served deck. All five
  desktop and phone slides were reached; image/highlighting checks passed and
  no page errors were recorded.
- `renv::status()`: project and lockfile are consistent. The project library was
  populated from locally downloaded packages; a clean remote restore was not run.
- `git diff --check`: passed; generated upstream HTML whitespace is exempt.

## Visual and browser smoke checks

The app was served locally through shinytest2. Desktop (1280×900) and phone
(390×844) screenshots were inspected: labels and controls fit, the mean is
readable, the graph renders, and the phone layout has no horizontal overflow.
Browser interactions verified full-history defaults, March 2012, a single day,
leap-day selection, invalid/reversed input, and recovery to a valid range.

The presentation was served at `http://127.0.0.1:8000/Index.html`. The automated
smoke script checks all five slides, desktop arrow navigation, phone scrolling,
image loading, syntax highlighting, and page errors. Generated previews live in
ignored `.tools/`; the app screenshot used by the deck is tracked in `assets/`.
All five desktop and phone slide previews were inspected. The phone deck retains
the scaled presentation layout; detailed code and screenshot text benefit from
zooming or viewing on a larger screen.

## Limitations and follow-up

- The testthat binary emits a startup warning that it was built under R 4.4.3;
  the tests themselves pass on local R 4.4.1. Building testthat from source was
  blocked by missing local C++ standard-library headers (`climits`). Shiny was
  successfully built from source, resolving its initial browser-startup warning.
- Sandbox restrictions prevented package downloads, subprocess initialization,
  and access to required tool caches. Authorized runs outside the sandbox completed
  the relevant build/browser checks.
- Shiny's bundled datepicker emits upstream locale deprecation warnings in the
  browser. No application JavaScript errors were observed in the app capture logs.
- The simple static slide server logs a harmless 404 for the browser's optional
  `/favicon.ico` request; all presentation resources are embedded and load.
- GitHub Actions has been configured but has not run remotely. CI and a clean
  dependency restore should be checked on the first PR run.
- No production deployment, live data connection, formal accessibility audit,
  cross-browser certification, or comprehensive vulnerability audit was performed.
  External provenance links are retained as HTTPS links; their remote content is
  not an automated test dependency.

## Review test plan

Restore dependencies, run the commands in README, then launch the app and inspect
the full range and March 2012 (**26,394 hires/day**). Check a single date and invalid
ranges. Render and open the deck, navigate all five slides, and verify the app
screenshot and source links. Repeat at a narrow phone width. Confirm the CSV
checksum and review the dependency lockfile plus the removal of legacy assets.

## PR follow-up

The chart-update review gap is addressed by comparing rendered canvas pixels at
the same viewport: full-history and March 2012 must differ, and switching back
to either range must reproduce its earlier image. The full local browser suite
passes 50 assertions. CI now runs `renv::restore(prompt = FALSE)` with
`RENV_CONFIG_CACHE_ENABLED=FALSE` on a fresh hosted runner, without restoring
a package cache. Remote results will be recorded after the PR run.
