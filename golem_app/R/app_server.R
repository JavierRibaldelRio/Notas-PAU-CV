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
  # =====================================================
  # ROUTER GLOBAL (poner en server principal)
  # =====================================================

  # -----------------------------------------------------
# 1) UI → URL  (click en navbar)
#     conservar query SOLO para #centros
# -----------------------------------------------------

  # Database
  pool <- golem::get_golem_options("pool")

  mod_center_guide_server("center_guide_1", input, output, session, pool)

  # pagina principal y
  mod_main_dashboard_server("main_dashboard_1", pool)
  mod_subjects_page_server("subjects_page_1", pool)

  # Maps
  mod_map_region_server("map_region_1", pool)
}
