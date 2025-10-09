#' Run the Shiny Application
#'
#' @param ... arguments to pass to golem_opts.
#' See `?golem::get_golem_options` for more details.
#' @inheritParams shiny::shinyApp
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(
  onStart = NULL,
  options = list(
    host = "0.0.0.0",
    port = 3000,
    launch.browser = FALSE
  ),
  enableBookmarking = NULL,
  uiPattern = "/",
  ...
) {
  with_golem_options(
    app = shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = onStart,
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    golem_opts = list(
      pool = create_sqlite_pool()
    )
  )
}


# Creates the sqlite pool

create_sqlite_pool <- function(
  db_path = "notas-pau.db",
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
