testthat::test_that("historical data and March calculation are preserved", {
  testthat::expect_equal(nrow(historical), 1675L)
  testthat::expect_equal(historical$day, seq(as.Date("2010-07-30"), as.Date("2015-02-28"), by = "day"))
  march <- summarise_hires(historical, "2012-03-01", "2012-03-31")
  testthat::expect_equal(march$days, 31L)
  testthat::expect_equal(march$mean, 26394)
})

testthat::test_that("range boundaries, single days, and leap days are inclusive", {
  all <- summarise_hires(historical, min(historical$day), max(historical$day))
  testthat::expect_equal(all$days, 1675L)
  one <- summarise_hires(historical, "2010-07-30", "2010-07-30")
  testthat::expect_equal(one$days, 1L)
  testthat::expect_equal(one$mean, 6897)
  leap <- summarise_hires(historical, "2012-02-28", "2012-03-01")
  testthat::expect_equal(leap$days, 3L)
  testthat::expect_true(as.Date("2012-02-29") %in% leap$data$day)
})

testthat::test_that("invalid selections produce actionable errors", {
  testthat::expect_error(summarise_hires(historical, NA, "2012-03-31"), "Choose both")
  testthat::expect_error(summarise_hires(historical, character(), "2012-03-31"), "Choose both")
  testthat::expect_error(summarise_hires(historical, "", "2012-03-31"), "Choose both")
  testthat::expect_error(summarise_hires(historical, "2012-02-30", "2012-03-31"), "valid dates")
  testthat::expect_error(summarise_hires(historical, "bad", "2012-03-31"), "valid dates")
  testthat::expect_error(summarise_hires(historical, "2012-03-31", "2012-03-01"), "on or before")
  testthat::expect_error(summarise_hires(historical, "2010-07-29", "2012-03-01"), "within")
  testthat::expect_error(summarise_hires(historical, "2012-03-01", "2015-03-01"), "within")
  sparse <- historical[c(1, 3), ]
  testthat::expect_error(summarise_hires(sparse, "2010-07-31", "2010-07-31"), "No daily records")
  testthat::expect_error(summarise_hires(historical[FALSE, ], "2010-07-31", "2010-07-31"), "No daily records")
})

testthat::test_that("CSV loader rejects malformed daily data and ignores summary columns", {
  path <- tempfile(fileext = ".csv")
  on.exit(unlink(path))
  write_csv <- function(rows, header = "Day,Number of Bicycle Hires,Unrelated") {
    writeLines(c(header, rows), path)
  }
  write_csv(c("31/07/2010,5,not-a-number", "30/07/2010,7,irrelevant"))
  testthat::expect_equal(read_bike_hires(path)$hires, c(7, 5))
  write_csv("31/02/2012,5,x")
  testthat::expect_error(read_bike_hires(path), "invalid dates")
  write_csv(c("30/07/2010,5,x", "30/07/2010,7,x"))
  testthat::expect_error(read_bike_hires(path), "duplicate dates")
  for (value in c("", "NA", "abc", "Inf", "-1", "1.5")) {
    write_csv(paste0("30/07/2010,", value, ",x"))
    testthat::expect_error(read_bike_hires(path), "hire counts")
  }
  write_csv(character())
  testthat::expect_error(read_bike_hires(path), "no daily records")
  write_csv("30/07/2010,5", "Date,Hires")
  testthat::expect_error(read_bike_hires(path), "Expected Day")
})
