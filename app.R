library(shiny)
source("R/bike_hires.R", local = TRUE)
source("R/server.R", local = TRUE)

data <- read_bike_hires("tfl-daily-cycle-hires.csv")
ui <- bslib::page_sidebar(
  title = "London bike hires",
  theme = bslib::bs_theme(version = 5, bootswatch = "flatly"),
  sidebar = bslib::sidebar(
    title = "Explore a date range",
    dateRangeInput("dates", "Dates (inclusive)", start = min(data$day), end = max(data$day),
                   min = min(data$day), max = max(data$day), format = "yyyy-mm-dd"),
    textOutput("selected_range"),
    tags$hr(),
    tags$p("Historical snapshot: 30 July 2010–28 February 2015. No live availability data."),
    tags$a("Source: London Datastore", href = "https://data.london.gov.uk/dataset/number-bicycle-hires"),
    tags$a("Open Government Licence v2", href = "https://www.nationalarchives.gov.uk/doc/open-government-licence/version/2/")
  ),
  bslib::card(
    bslib::card_header("Mean daily bike hires"),
    tags$div(style = "font-size: 2.5rem; font-weight: 700;", textOutput("mean_hires")),
    tags$p("Hires per day, rounded to the nearest whole number.")
  ),
  bslib::card(
    bslib::card_header("Daily hires · full history"),
    plotOutput("history", height = "360px"),
    tags$p("The shaded area and teal line mark your selected range.")
  )
)
shinyApp(ui, make_server(data))
