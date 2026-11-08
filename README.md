# London bike hires

A Shiny app and five-slide Quarto presentation exploring the original London
cycle hire snapshot: **30 July 2010–28 February 2015**. This is historical daily
demand, not live bike availability. The CSV remains byte-for-byte unchanged.

## Setup

Install R 4.4.3 (the CI version), Quarto **1.11.9**, and Chrome/Chromium for browser
tests. Install and restore the pinned R dependencies from the repository root:

```r
install.packages("renv", repos = "https://cloud.r-project.org")
renv::restore()
```

`DESCRIPTION` lists direct dependencies; `renv.lock` pins their resolved versions.
The project activation script loads the restored library in new R sessions.
System libraries required by R packages must also be installed on Linux.

## Run and develop

```sh
Rscript -e 'shiny::runApp(host="127.0.0.1", port=3838)'
quarto preview index.qmd
```

Open http://127.0.0.1:3838 for the app. The date range is inclusive, defaults to
the full history, and updates the rounded mean and highlighted chart reactively.
Missing/reversed/out-of-bounds ranges show validation messages. Invalid daily
CSV records fail loading rather than silently changing the mean.

For Shiny development, use `options(shiny.autoreload = TRUE)` before `runApp()`;
Quarto preview watches slide sources. No npm build is required.

```sh
quarto render index.qmd
python3 -m http.server 8000 --bind 127.0.0.1
```

Open http://127.0.0.1:8000/Index.html for the generated, self-contained slides.
The original capitalized HTML entry point is retained. Static hosting serves
the slides only; the app needs an R/Shiny process. Deployment is not configured.

## Structure

- `app.R`: responsive Shiny interface.
- `R/`: shared data validation/calculation and reactive server factory.
- `index.qmd`: authoritative slide source; `Index.html`: generated output.
- `assets/`: slide styling and the current application screenshot.
- `tests/testthat/`: calculations, server behavior, and real-browser tests.
- `scripts/`: test runner, dataset/HTML checks, and screenshot capture.

The shared calculation uses only the first two CSV columns. The remaining
columns contain independent monthly/yearly summaries and are deliberately ignored.
Dates are parsed explicitly; missing counts are rejected rather than removed.
The mean uses R's `round()` behavior, matching the original example.

## Validation

From the repository root:

```sh
python3 scripts/validate_data.py
Rscript scripts/test.R
RUN_BROWSER_TESTS=true Rscript scripts/test.R
quarto render index.qmd
Rscript scripts/validate_slides.R
```

With the static server above running, `Rscript scripts/smoke_slides.R` checks
desktop arrow navigation and phone scroll navigation, and saves visual previews
under `.tools/` for inspection. CI runs this browser check too.

Browser tests are opt-in locally and mandatory in CI. Set `CHROMOTE_CHROME` to
your Chrome/Chromium executable if automatic discovery fails. Without the flag,
the browser test is explicitly reported as skipped. Tests cover March 2012's
**26,394** mean, inclusive endpoints, single/leap days, bad data and ranges,
reactive output, and chart rendering. CI restores dependencies, runs these
checks, renders the deck, and uploads the generated HTML.

To refresh the slide screenshot, run `Rscript scripts/capture_app.R`, then render
the deck again. The capture also writes a mobile preview under ignored `.tools/`.

Before release, manually inspect the app at desktop/mobile widths, change dates,
check the chart and validation, and navigate all five slides with arrow keys.
See `VALIDATION.md` for the recorded checks and remaining limitations.

The generated HTML includes Quarto's bundled CSS/JavaScript. Its upstream
whitespace is excluded from Git whitespace checks; change slide sources and
regenerate rather than hand-editing the HTML.

## Data provenance

Source: [London Datastore cycle hires](https://data.london.gov.uk/dataset/number-bicycle-hires),
under the [Open Government Licence v2](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/2/)
as attributed by the original project. The original CSV SHA-256 is checked by
`scripts/validate_data.py`. Do not refresh or overwrite this historical snapshot.
