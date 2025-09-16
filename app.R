library(shiny)
library(bslib)
library(DBI) # also install rsqlite
library(pool)

source("R/ui/subjects.R")

DB_PATH <- "data/notas-pau.db"

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

  # Dark mode selector
  nav_item(input_dark_mode(id = "mode")),
)

server <- function(input, output, session) {
  # Conection to the database
  pool <- dbPool(
    drv = RSQLite::SQLite(),
    dbname = DB_PATH,
    flags = RSQLite::SQLITE_RO
  )

  # Settings of sqlite
  try(dbExecute(pool, "PRAGMA journal_mode = WAL;"), silent = TRUE)
  try(dbExecute(pool, "PRAGMA busy_timeout = 5000;"), silent = TRUE)
  try(dbExecute(pool, "PRAGMA synchronous = NORMAL;"), silent = TRUE)
  try(dbExecute(pool, "PRAGMA cache_size = 10000;"), silent = TRUE)

  onStop(function() poolClose(pool))

  # get options of selectize
  observe({
    df <- dbGetQuery(pool, "SELECT id, name FROM subjects")
    print(df)

    choices <- setNames(df$id, df$name)

    # Cargar en el selectize (server=TRUE mejora rendimiento con muchas opciones)
    updateSelectizeInput(
      session,
      "select-subject",
      choices = choices,
      server = TRUE
    )
  })
}

shinyApp(ui = ui, server = server)
