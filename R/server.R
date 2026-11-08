make_server <- function(data) {
  function(input, output, session) {
    selection <- shiny::reactive({
      dates <- input$dates
      result <- tryCatch(
        summarise_hires(data, dates[1], dates[2]),
        error = function(e) e
      )
      if (inherits(result, "error")) {
        shiny::validate(shiny::need(FALSE, conditionMessage(result)))
      }
      result
    })
    output$selected_range <- shiny::renderText({
      x <- selection()
      sprintf("%s to %s · %s days", format(x$start, "%d %b %Y"),
              format(x$end, "%d %b %Y"), format(x$days, big.mark = ","))
    })
    output$mean_hires <- shiny::renderText({
      format(selection()$mean, big.mark = ",", scientific = FALSE, trim = TRUE)
    })
    output$history <- shiny::renderPlot({
      x <- selection()
      graphics::par(mar = c(4, 4, 1, 1))
      graphics::plot(data$day, data$hires, type = "n", xlab = "Date", ylab = "Daily hires")
      graphics::rect(as.numeric(x$start) - 0.5, graphics::par("usr")[3],
                     as.numeric(x$end) + 0.5, graphics::par("usr")[4],
                     col = "#e0f2ef", border = NA)
      graphics::lines(data$day, data$hires, col = "#6b7280")
      graphics::lines(x$data$day, x$data$hires, col = "#087f75", lwd = 2)
      if (x$days == 1L) graphics::points(x$data$day, x$data$hires, col = "#087f75", pch = 19)
    }, res = 96, alt = "Daily London bike hires across the historical dataset; the selected date range is highlighted in teal.")
  }
}
