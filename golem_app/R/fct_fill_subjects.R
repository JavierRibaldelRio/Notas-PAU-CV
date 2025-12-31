#' Fill subject selectize input from database
#'
#' @description
#' Populates and updates a Shiny `selectizeInput` with subjects retrieved
#' from a database connection. The visible labels correspond to subject
#' names, while the underlying values are subject IDs.
#'
#' @param input Shiny input object.
#' @param output Shiny output object.
#' @param session Shiny session object.
#' @param pool A database connection pool used to query the subjects table.
#' @param id Character string identifying the `selectizeInput` to update.
#' @param selected Integer vector of subject IDs to be selected by default.
#'   Defaults to `c(4, 30)`.
#'
#' @details
#' The function queries the `subjects` table for subject IDs and names,
#' constructs a named vector suitable for `updateSelectizeInput()`,
#' and updates the specified selectize input using subject ID–name mappings.
#'
#' The selectize input is configured to allow up to 8 selected items.
#'
#' @return
#' This function is called for its side effects and does not return a value.
#'
#' @noRd
fill_subjects <- function(
  input,
  output,
  session,
  pool,
  id,
  selected = c(4, 30)
) {
  df <- dbGetQuery(pool, "SELECT id, name FROM subjects")

  # visible label = name, underlying value = id
  choices <- setNames(df$id, df$name)

  updateSelectizeInput(
    session,
    id,
    choices = choices,
    selected = selected,
    options = list(maxItems = 8),
    server = TRUE
  )
}
