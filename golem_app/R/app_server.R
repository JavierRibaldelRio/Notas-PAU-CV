#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import bslib
#' @import glue
#' @import DBI
#' @import pool
#' @import rlang
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic
  # bslib::bs_themer()

  pool <- golem::get_golem_options("pool")

  mod_subjects_page_server("subjects_page_1", pool)
}
