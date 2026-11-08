# The CSV also contains unrelated monthly/yearly series. Only read daily columns.
read_bike_hires <- function(path) {
  header <- names(utils::read.csv(path, nrows = 0, check.names = FALSE))
  if (length(header) < 2L || !identical(header[1:2], c("Day", "Number of Bicycle Hires"))) {
    stop("Expected Day and Number of Bicycle Hires as the first two columns.", call. = FALSE)
  }
  raw <- utils::read.csv(path, colClasses = c("character", "character", rep("NULL", length(header) - 2L)))
  if (!nrow(raw)) stop("The dataset contains no daily records.", call. = FALSE)
  dates <- as.Date(raw[[1]], format = "%d/%m/%Y")
  if (anyNA(dates) || any(format(dates, "%d/%m/%Y") != raw[[1]])) {
    stop("Daily records contain invalid dates.", call. = FALSE)
  }
  if (anyDuplicated(dates)) stop("Daily records contain duplicate dates.", call. = FALSE)
  counts <- suppressWarnings(as.numeric(raw[[2]]))
  if (anyNA(counts) || any(!is.finite(counts) | counts < 0 | counts != floor(counts))) {
    stop("Daily hire counts must be finite, nonnegative whole numbers.", call. = FALSE)
  }
  data.frame(day = dates, hires = counts)[order(dates), , drop = FALSE]
}

parse_range_date <- function(value) {
  if (length(value) != 1L || is.na(value) || identical(value, "")) {
    stop("Choose both a start and an end date.", call. = FALSE)
  }
  if (inherits(value, "Date") && is.finite(as.numeric(value))) return(value)
  if (!is.character(value)) stop("Use valid dates in YYYY-MM-DD format.", call. = FALSE)
  parsed <- as.Date(value, format = "%Y-%m-%d")
  if (is.na(parsed) || format(parsed, "%Y-%m-%d") != value) {
    stop("Use valid dates in YYYY-MM-DD format.", call. = FALSE)
  }
  parsed
}

summarise_hires <- function(data, start, end) {
  start <- parse_range_date(start)
  end <- parse_range_date(end)
  if (start > end) stop("Start date must be on or before end date.", call. = FALSE)
  if (!nrow(data)) stop("No daily records are available.", call. = FALSE)
  if (start < min(data$day) || end > max(data$day)) {
    stop("Choose dates within the historical dataset.", call. = FALSE)
  }
  selected <- data[data$day >= start & data$day <= end, , drop = FALSE]
  if (!nrow(selected)) stop("No daily records exist in this range.", call. = FALSE)
  list(start = start, end = end, days = nrow(selected),
       mean = round(mean(selected$hires), 0), data = selected)
}
