library(shiny)
library(bslib)

# Change
last_year <- 2024

# Structure of the page
subjects <- function() {
  card(
    layout_sidebar(
      sidebar = sidebar_content(),
      main_panel_content()
    )
  )
}

# Content of the sidebar, main configurations
sidebar_content <- function() {
  # Form that selects
  tagList(
    # Stat selector
    radioButtons(
      inputId = "radio",
      label = "Variable",
      choices = list(
        "Presentados" = "candidates",
        "Aprobados" = "pass",
        "Media" = "average",
        "Desviación Típica" = "standard_dev"
      )
    ),

    # Call selector
    selectInput(
      "select-call",
      "Convocatoria",
      list("Ordinaria" = 0, "Extraordinaria" = 1, "Global" = 2)
    ),

    # Graph selector
    input_switch(
      "visualization-mode",
      "Mostrar como gráfico de barras"
    ),

    # Years selector
    sliderInput(
      "years",
      "Años seleccionados",
      min = 2010,
      max = last_year,
      value = c(2010, last_year),
      sep = "",
    ),

    # Arima prediction
    checkboxInput("predict", "Predicción", FALSE),
  )
}

main_panel_content <- function() {
  selectizeInput(
    "select-subject",
    "Asignaturas",
    list(),
    multiple = TRUE,
    width = "100%"
  )
}
