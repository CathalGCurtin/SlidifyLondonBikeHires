# Start a static server at 127.0.0.1:8000 before running this browser check.
dir.create(".tools", showWarnings = FALSE)
browser <- chromote::ChromoteSession$new(width = 1280, height = 900)
tryCatch({
  browser$Page$addScriptToEvaluateOnNewDocument(source =
    "window.smokeErrors=[]; window.addEventListener('error', e => window.smokeErrors.push(e.message || 'resource error')); window.addEventListener('unhandledrejection', e => window.smokeErrors.push(String(e.reason)));")
  browser$Page$navigate("http://127.0.0.1:8000/Index.html")
  js <- function(code) browser$Runtime$evaluate(code, returnByValue = TRUE, awaitPromise = TRUE)$result$value
  js("new Promise(resolve => { const check = () => window.Reveal && Reveal.isReady() ? resolve(true) : setTimeout(check, 50); check(); })")
  stopifnot(js("Reveal.getTotalSlides()") == 5)
  js("document.fonts.ready.then(() => new Promise(resolve => setTimeout(resolve, 250)))")
  for (i in 0:4) {
    cat("Desktop slide", i + 1L, "index", js("Reveal.getIndices().h"), "\n")
    stopifnot(js("Reveal.getIndices().h") == i)
    shot <- browser$Page$captureScreenshot(format = "png")
    writeBin(jsonlite::base64_dec(shot$data), sprintf(".tools/slide-%s.png", i + 1L))
    stopifnot(js("[...Reveal.getCurrentSlide().querySelectorAll('img')].every(img => img.complete && img.naturalWidth > 0)"))
    if (i < 4L) {
      browser$Input$dispatchKeyEvent(type = "keyDown", key = "ArrowRight", code = "ArrowRight", windowsVirtualKeyCode = 39)
      browser$Input$dispatchKeyEvent(type = "keyUp", key = "ArrowRight", code = "ArrowRight", windowsVirtualKeyCode = 39)
      js("new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(() => resolve(true))))")
    }
  }
  stopifnot(js("document.querySelectorAll('#code-usage pre.sourceCode span').length > 0"))
  browser$Emulation$setDeviceMetricsOverride(width = 390, height = 844, deviceScaleFactor = 1, mobile = TRUE)
  js("new Promise(resolve => setTimeout(resolve, 500))")
  for (i in 0:4) {
    js(sprintf("document.querySelectorAll('.scroll-page')[%s].scrollIntoView({behavior: 'instant', block: 'center'});", i))
    js("new Promise(resolve => setTimeout(resolve, 500))")
    cat("Mobile slide", i + 1L, "index", js("Reveal.getIndices().h"), "\n")
    stopifnot(js("Reveal.getIndices().h") == i)
    shot <- browser$Page$captureScreenshot(format = "png")
    writeBin(jsonlite::base64_dec(shot$data), sprintf(".tools/slide-mobile-%s.png", i + 1L))
    stopifnot(!js("document.documentElement.scrollWidth > window.innerWidth"))
  }
  errors <- js("window.smokeErrors")
  stopifnot(length(errors) == 0L)
  cat("Browser smoke: five slides, arrow navigation, images, highlighting, mobile widths; no page errors.\n")
}, finally = browser$close())
