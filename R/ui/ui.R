library(shiny)
library(bslib)
library(DBI) # also install rsqlite
library(pool)

# Subjects
source("R/ui/subjects_ui.R")

# Main UI of the page
ui <- page_navbar(
  title = "Análisis Notas PAU",
  id = "page",
  theme = bs_theme(preset = "litera"),

  # Navbar settings
  navbar_options = navbar_options(
    class = "bg-primary",
    theme = c("light", "auto", "dark"),
    underline = TRUE
  ),

  # Page 1 subjects
  nav_panel(
    "Asignaturas",
    subjects()
  ),

  # # Menu of regions
  # nav_menu(
  #   "Regiones",
  #   nav_panel(
  #     "Provincia",
  #     "1"
  #   ),
  #   nav_panel(
  #     "Comarca",
  #     "ASDF"
  #   ),
  #   nav_panel(
  #     "Municipio",
  #     "ASDF - Desde UI"
  #   )
  # ),

  # # Menu of centers
  # nav_menu(
  #   "Centros",
  #   nav_panel(
  #     "Centros",
  #     "1"
  #   ),
  #   nav_panel(
  #     "Buscador",
  #     "ASDF"
  #   ),
  # ),

  # About us
  nav_panel("Sobre nosotros", "Pau y Javier"),
)
