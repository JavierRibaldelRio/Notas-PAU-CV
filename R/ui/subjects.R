library(shiny)
library(bslib)

subjects <- function() {
  card(
    layout_sidebar(
      sidebar_content(),
      "adsfas"
    )
  )
}

sidebar_content <- function() {
  tagList(
    # Stat selector
    radioButtons(
      inputId = "radio",
      label = "Variable",
      choices = list(
        "Aprobados" = 1,
        "Desviación Típica" = 4,
        "Presentados" = 2,
        "Media" = 3
      )
    ),
    # Years selector
    sliderInput(
      "years",
      "Años seleccionados",
      min = 2010,
      max = 2024,
      value = c(2010, 2024)
    )
  )
}
