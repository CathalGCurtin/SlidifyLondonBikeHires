# Run explicitly when refreshing the screenshot used by the presentation.
Sys.setenv(NOT_CRAN = "true")
dir.create(".tools", showWarnings = FALSE)
app <- shinytest2::AppDriver$new(app_dir = ".", name = "screenshot", width = 1280, height = 900)
tryCatch({
  app$set_inputs(dates = c("2012-03-01", "2012-03-31"))
  stopifnot(app$get_value(output = "mean_hires") == "26,394")
  app$get_screenshot(file = "assets/app-screenshot.png")
  app$set_window_size(390, 844)
  app$get_screenshot(file = ".tools/app-mobile.png")
  cat("Mobile horizontal overflow:", app$get_js("document.documentElement.scrollWidth > window.innerWidth"), "\n")
  print(app$get_logs())
}, finally = app$stop())
