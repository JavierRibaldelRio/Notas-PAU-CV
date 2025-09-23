DB_PATH <- "data/notas-pau.db"

source("R/server/subjects_server.R")

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
