#' map_region UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_map_region_ui <- function(id) {
  ns <- NS(id)
  navset_card_tab(
    title = "Resultados por comarca",
    sidebar = sidebar(
      width = "40%",

      # enhances responsive plotly
      open = "always",

      # call selector
      mod_mean_year_selector_ui(
        ns("mean_year_selector_2"),
        label = "Nivel de agregación",
        global_option = "Media interanual"
      ),

      layout_columns(
        widths = c(6, 6), # dos columnas del mismo ancho
        mod_select_call_ui(ns("select_call_1")),
        mod_select_high_school_type_ui(ns("select_high_school_type_1"))
      ),

      hr(),

      radioButtons(
        inputId = ns("varname"),
        label = "Variable",
        choices = list(
          "Presentados" = "candidates_total_sum",
          "Aprobados" = "pass_total",
          "Aprobados (%)" = "pass_percentatge",
          "Media Bachillerato" = "average_bach",
          "Media Fase Obligatoria" = "average_compulsory_pau",
          "Diferencia Media Bach. - Media Pau" = "diference_average_bach_pau"
        )
      ),
    ),
    nav_panel(
      "Mapa",
      class = "p-0",
        plotlyOutput(ns("mapa"), height = "100%")
      
    )
  )
}

legend_titles <- c(
  candidates_total_sum = "Presentados",
  pass_total = "Aprobados",
  pass_percentatge = "Aprobados (%)",
  average_bach = "Media Bachillerato",
  average_compulsory_pau = "Media Fase Obligatoria",
  diference_average_bach_pau = "Dif. Media Bach.\n – Media PAU"
)


#' map_region Server Functions
#'
#' @noRd
mod_map_region_server <- function(id, pool) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # theme

    # get current theme
    theme <- bs_current_theme()
    primary_hex <- bs_get_variables(theme, varnames = "primary")

    # varibles from shiny-modules
    selector_year <- mod_mean_year_selector_server("mean_year_selector_2")
    get_call <- mod_select_call_server("select_call_1")
    get_type <- mod_select_high_school_type_server("select_high_school_type_1")

    # read data
    data_region <- readRDS("inst/app/data/data_region.rds") |>
      mutate(region_code = as.character(region_code)) # transform region code to character to make possible the join

    # open map
    regiones_sf <- st_read(
      "inst/app/www/maps/map-cv-comarcas-simple.gpkg",
      quiet = TRUE
    )

    # generate the map
    output$mapa <- renderPlotly({
      # get reactive props
      selected_call <- req(get_call())
      selected_year <- req(selector_year())
      selected_type_id <- req(get_type())

      # varname
      legend_title <- legend_titles[[input$varname]]

      # prepare data
      selected_data <- data_region |>
        filter(
          call == selected_call &
            year == selected_year &
            type_id == selected_type_id
        ) |>

        # generate tooltips
        mutate(
          tooltip = paste0(
            "<b>",
            str_to_title(name),
            "</b><br>",
            "<b>Presentados:</b> ",
            candidates_total_sum,
            "<br>",
            "<b>Aprobados:</b> ",
            pass_total,
            " (",
            round(pass_percentatge, 2),
            "%)<br>",
            "<b>Media Bachillerato:</b> ",
            round(average_bach, 2),
            "<br>",
            "<b>Media Fase Obligatoria:</b> ",
            round(average_compulsory_pau, 2),
            "<br>",
            "<b>Diferencia Media Bach. – Media PAU:</b> ",
            round(diference_average_bach_pau, 2)
          )
        )

      # join, must be done every time to avoid removing calls with no data
      filtered_mapa_data <- left_join(
        regiones_sf,
        selected_data,
        by = c("cod_comarc" = "region_code")
      )

      p <- ggplot(filtered_mapa_data) +
        geom_sf(
          aes(fill = !!sym(input$varname), text = tooltip),
          color = "black"
        ) +
        scale_fill_gradient(
          low = "white",
          high = primary_hex,
          na.value = "grey",
          name = legend_title,

          guide = guide_colourbar(
            frame.colour = "black",
            frame.linewidth = 0.2,
            ticks.colour = "black",
            barheight = unit(4, "cm"),
            barwidth = unit(0.5, "cm")
          )
        ) +
        theme_base() +
        theme(
          # remove grid and titles
          panel.grid = element_blank(),
          axis.line = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          axis.title = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
        )

      #Plotly
      ggplotly(p, tooltip = "text") |>
        style(
          hoveron = "fills"
        ) |>
        config(
          displayModeBar = FALSE,
          doubleClick = FALSE,
          scrollZoom = FALSE,
          responsive = TRUE
        ) |>
        layout(
          dragmode = FALSE,
          autosize = TRUE
        )
    })
  })
}

## To be copied in the UI
# mod_map_region_ui("map_region_1")

## To be copied in the server
# mod_map_region_server("map_region_1")
