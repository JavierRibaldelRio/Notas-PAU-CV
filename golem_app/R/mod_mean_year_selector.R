#' mean_year_selector UI Function
#'
#' @description Un selector formado por radiobuttons que permite elegir entre media y año  .
#'
#' @param id,label,selected Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_mean_year_selector_ui <- function(
  id,
  label,
  selected = NULL,
  global_option = "Global"
) {
  ns <- NS(id)

  # Prepare the select
  other <- selectInput(
    ns("other"),
    label = "Año",
    choices = 2010:2024,
    selectize = FALSE, # Avoids using JS
    width = "100%"
  )
  names <- c(global_option)
  values <- c(0)

  div(
    class = "mean-year-input", # All the logic of the placement of the select is made through CSS

    # Render the radio and the selec
    radioButtons(
      ns("primary"),
      label = label,
      choiceValues = c(values, "other"),
      choiceNames = c(as.list(names), list(other)),
      selected = selected,
      inline = TRUE
    )
  )
}


#' mean_year_selector Server Functions
#' Returns the year selected of 0 if its global
#' @noRd
mod_mean_year_selector_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # On change at select, select its radio-button
    observeEvent(
      input$other,
      {
        updateRadioButtons(
          session,
          inputId = "primary",
          selected = "other"
        )
      },
      ignoreInit = TRUE
    )

    # return 0 or the value of the select
    reactive({
      if (input$primary == "other") {
        input$other
      } else {
        input$primary
      }
    })
  })
}

## To be copied in the UI
# mod_mean_year_selector_ui("mean_year_selector_1")

## To be copied in the server
# mod_mean_year_selector_server("mean_year_selector_1")
