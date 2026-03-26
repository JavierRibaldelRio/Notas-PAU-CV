#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import bslib
#'
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Main page
    page_fillable(
      theme = bslib::bs_theme(version = 5, bootswatch = "litera"),

      # Main UI of the page
      page_navbar(
        title = "Notas PAU CV",
        id = "page_selector",

        # Navbar settings
        navbar_options = navbar_options(
          class = "bg-primary",
          theme = c("light", "auto", "dark"),
          underline = TRUE
        ),

        # Main page (dashboard)
        nav_panel(
          value="home",
          "Inicio",

          mod_main_dashboard_ui("main_dashboard_1")
        ),

        # Page 1 subjects
        nav_panel(
          value = "subjects",
          "Asignaturas",

          mod_subjects_page_ui("subjects_page_1", 2024)
        ),

        # Menu of regions
        nav_menu(
          "Regiones",
          nav_panel(
            "Provincia",
            value = "regions-provincia",
            "WIP"
          ),
          nav_panel(
            "Comarca",
            value = "regions-comarca",
            mod_map_region_ui("map_region_1")
          ),
          nav_panel(
            "Municipio",
            value = "regions-municipio",
            mod_regions_municipalities_ui("regions_municipalities_1")
          )
        ),

        nav_panel(
          "Guía de centros",
          value = "centros",
          mod_center_guide_ui("center_guide_1")
        ),

        nav_panel(
          "Mapa de centros",
          value = "centros-mapa",
          mod_map_centers_ui("map_centers_1")
        ),

        # About us
        nav_panel("Sobre nosotros", value = "about",
          mod_about_page_ui("about_page")
        ),
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "notaspaucv"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
