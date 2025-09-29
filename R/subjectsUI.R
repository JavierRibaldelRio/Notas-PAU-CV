# Change
last_year <- 2024

# Structure of the page
subjects <- function(id) {
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
      inputId = "variable",
      label = "Variable",
      choices = list(
        "Presentados" = "candidates",
        "Aprobados" = "pass",
        "Aprobados (%)" = "pass_percentatge",
        "Media" = "average",
        "Coeficiente de variación" = "coefficient_variation"
      )
    ),

    # Call selector
    selectInput(
      "select_call",
      "Convocatoria",
      list("Ordinaria" = 0, "Extraordinaria" = 1, "Global" = 2)
    ),

    #Graph selector
    input_switch(
      "visualization_mode",
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
    # checkboxInput("predict", "Predicción", FALSE),
  )
}

main_panel_content <- function() {
  tagList(
    # Selector of subjects
    selectizeInput(
      "select_subject",
      "Asignaturas",
      list(),
      multiple = TRUE,
      width = "100%"
    ),

    plotOutput(outputId = "subjects_main")
  )
}
