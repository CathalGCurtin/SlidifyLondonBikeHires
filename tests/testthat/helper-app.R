root <- normalizePath(file.path(testthat::test_path(), "../.."))
source(file.path(root, "R/bike_hires.R"))
source(file.path(root, "R/server.R"))
historical <- read_bike_hires(file.path(root, "tfl-daily-cycle-hires.csv"))
