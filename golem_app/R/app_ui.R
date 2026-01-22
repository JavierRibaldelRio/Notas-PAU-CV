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
        title = "Análisis Notas PAU",
        id = "page",

        # Navbar settings
        navbar_options = navbar_options(
          class = "bg-primary",
          theme = c("light", "auto", "dark"),
          underline = TRUE
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
            "ahsdfasdf"
          ),
          nav_panel(
            "Comarca",
            value = "regions-comarca",
            mod_map_region_ui("map_region_1")
          ),
          nav_panel(
            "Municipio",
            value = "regions-municipio",
            "ASDF - Desde UI"
          )
        ),

        # # Menu of centers
        # nav_menu(
        #   "Centros",
        #   nav_panel(
        #     "Centros",
        #     "1"
        #   ),
        #   nav_panel(
        #     "Buscador",
        #     "ASDF"
        #   ),
        # ),

        # About us
        nav_panel("Sobre nosotros", value = "about", "Pau y Javier"),
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
