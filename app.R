library(shiny)
library(bslib)
library(DBI) # also install rsqlite
library(pool)

# Import UI
source("R/ui/ui.R")

DB_PATH <- "data/notas-pau.db"


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
