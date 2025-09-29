# Core libraries
library(shiny)
library(bslib)
library(DBI) # also install rsqlite
library(pool)
library(tidyverse)
library(glue)
library(rlang)

# Shiny options
options(shiny.fullstacktrace = TRUE) # Set to FALSE on production


# UI

# Subjects

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
    subjects("dsfa")
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


DB_PATH <- "data/notas-pau.db"


# Main function of logic of server
server <- function(input, output, session) {
  pool <- create_sqlite_pool(DB_PATH)

  # Results by Subject
  subjects_server(input, output, session, pool)
}


# creates the connection to the database
create_sqlite_pool <- function(
  db_path,
  flags = RSQLite::SQLITE_RO,
  pragmas = c(
    journal_mode = "WAL",
    busy_timeout = 5000,
    synchronous = "NORMAL",
    cache_size = 10000
  )
) {
  # Create pool
  pool <- pool::dbPool(
    drv = RSQLite::SQLite(),
    dbname = db_path,
    flags = flags
  )

  # Pragma
  for (i in seq_along(pragmas)) {
    key <- names(pragmas)[i]
    val <- pragmas[[i]]
    stmt <- sprintf(
      "PRAGMA %s = %s;",
      key,
      if (is.character(val)) val else as.character(val)
    )
    try(DBI::dbExecute(pool, stmt), silent = TRUE)
  }

  # Auto stop on shiny stop app
  shiny::onStop(function() pool::poolClose(pool))

  pool
}


shinyApp(ui = ui, server = server)
