#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import bslib
#' @import glue
#' @import leaflet
#' @import purrr
#' @import DBI
#' @import tools
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
  # =====================================================
  # ROUTER GLOBAL (poner en server principal)
  # =====================================================

  # -----------------------------------------------------
# 1) UI → URL  (click en navbar)
#     conservar query SOLO para #centros
# -----------------------------------------------------

  # Database
  pool <- golem::get_golem_options("pool")

  # al things related to routes wheremoved to this module
  mod_center_guide_server("center_guide_1", input, output, session, pool)

  # pagina principal y
  mod_main_dashboard_server("main_dashboard_1", pool)
  mod_subjects_page_server("subjects_page_1", pool)

  # Maps
  mod_map_region_server("map_region_1", pool)
  mod_map_centers_server("map_centers_1", pool)
  
  # Municipalities
  mod_regions_municipalities_server("regions_municipalities_1")

  # About page
  mod_about_page_server("about_page")
}
