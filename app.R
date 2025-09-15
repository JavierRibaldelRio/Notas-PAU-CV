library(shiny)
library(bslib)

source("R/ui/subjects.R")


ui <- page_navbar(
  title = "Análisis Notas PAU",
  id = "page",
  theme = bs_theme(preset = "litera"),

  navbar_options = navbar_options(
    class = "bg-primary",
    theme = c("auto", "light", "dark"),
    underline = TRUE
  ),

  # Page 1
  nav_panel(
    "Asignaturas",
    subjects()
  ),

  nav_menu(
    "Regiones",
    nav_panel(
      "Provincia",
      "1"
    ),
    nav_panel(
      "Comarca",
      "ASDF"
    ),
    nav_panel(
      "Municipio",
      "ASDF"
    )
  ),

  nav_menu(
    "Centros",
    nav_panel(
      "Centros",
      "1"
    ),
    nav_panel(
      "Buscador",
      "ASDF"
    ),
  ),

  nav_panel("Sobre nosotros", "Pau y Javier"),

  nav_item(input_dark_mode(id = "mode")),
)

server <- function(input, output) {}

shinyApp(ui = ui, server = server)
