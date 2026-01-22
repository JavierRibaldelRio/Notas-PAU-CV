#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import bslib
#' @import glue
#' @import DBI
#' @import RSQLite
#' @import stats
#' @import pool
#' @import rlang
#' @import scales
#' @import ggplot2
#' @import forcats
#' @import sf
#' @import plotly
#' @import stringr
#' @import tidyr
#' @import patchwork
#' @import DT
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic
  # bslib::bs_themer()


  # observeEvent(input$page, {

  #   newURL <- paste0(
  #     session$clientData$url_protocol,
  #     "//",
  #     session$clientData$url_hostname,
  #     ":",
  #     session$clientData$url_port,
  #     session$clientData$url_pathname,
  #     "#",
  #     input$page
  #   )
  #   updateQueryString(newURL, mode = "replace", session)
  # })


  # observe({
  #   currentTab <- sub("#", "", session$clientData$url_hash) # might need to wrap this with `utils::URLdecode` if hash contains encoded characters (not the case here)
  #   if(!is.null(currentTab)){
  #     updateNavbarPage(session, "page", selected = currentTab)
  #   }
  # })

  pool <- golem::get_golem_options("pool")

  mod_subjects_page_server("subjects_page_1", pool)

  # Maps
  mod_map_region_server("map_region_1",pool)


}
