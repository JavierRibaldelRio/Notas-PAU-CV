#' regions_municipalities UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_regions_municipalities_ui <- function(id) {
  ns <- NS(id)
  tagList(
    navset_card_tab(
      title = "Resultados por municipio",
      sidebar = sidebar(
        width = "40%",

        # enhances responsive plotly
        open = "always",

        # call selector
        mod_mean_year_selector_ui(
          ns("mean_year_selector_3"),
          label = "Nivel de agregación",
          global_option = "Media interanual"
        ),

        layout_columns(
          widths = c(6, 6), # two columns with the same width
          mod_select_call_ui(ns("select_call_2")),
          mod_select_high_school_type_ui(ns("select_high_school_type_2"))
        ),

        hr(),
        
        radioButtons(
          inputId = ns("varname_2"),
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

        # id values from SQL table
        selectizeInput(
          inputId = ns("regions_selectize_1"),
          label = "Selecciona la comarca",
          choices = list(
            "La Marina Alta" = 1,
            "L'Alicantí" = 2,
            "El Comtat" = 3,
            "La Vega Baja" = 4,
            "L'Alcoià" = 5,
            "La Marina Baixa" = 6,
            "El Vinalopó Medio" = 7,
            "Alto Vinalopó" = 8,
            "El Baix Vinalopó" = 9,
            "L'Alt Mestrat" = 10,
            "La Plana Baixa" = 11,
            "El Baix Mestrat" = 12,
            "L'Alcalatén" = 13,
            "El Alto Palancia" = 14,
            "La Plana Alta" = 15,
            "El Alto Mijares" = 16,
            "Els Ports" = 17,
            "El Rincón de Ademuz" = 18,
            "La Safor" = 19,
            "La Vall d'Albaida" = 20,
            "L'Horta Sud" = 21,
            "La Ribera Baixa" = 22,
            "L'Horta Nord" = 23,
            "El Camp de Morvedre" = 24,
            "La Ribera Alta" = 25,
            "La Hoya de Buñol" = 26,
            "Los Serranos" = 27,
            "La Costera" = 28,
            "El Canal de Navarrés" = 29,
            "El Valle de Cofrentes-Ayora" = 30,
            "El Camp del Túria" = 31,
            "La Plana de Utiel-Requena" = 32,
            "València" = 33
          )
        )

      ),
      nav_panel(
        title = "Tabla",
        class = "mod-ranking",
        DTOutput(ns("tabla_municipios"))
      )

    ) 
  )
}

# read data
data_municipality <- readRDS("inst/app/data/data_municipality.rds") |>
  mutate(code_region = as.character(code_region))
    
#' regions_municipalities Server Functions
#'
#' @noRd 
# read data
mod_regions_municipalities_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    selector_year <- mod_mean_year_selector_server("mean_year_selector_3")
    get_call      <- mod_select_call_server("select_call_2")
    get_type      <- mod_select_high_school_type_server("select_high_school_type_2")

    selected_data <- reactive({
      req(get_call(), selector_year(), get_type())

      data_municipality |>
        filter(
          call      == get_call() &
          year      == selector_year() &
          type_id_high_school   == get_type() &              
          code_region == as.character(input$regions_selectize_1)  # filtrer region
        )
    })

    output$tabla_municipios <- renderDT({
      req(selected_data(), input$varname_2)

      label_var <- switch(input$varname_2,
        "candidates_total_sum"       = "Presentados",
        "pass_total"                 = "Aprobados",
        "pass_percentatge"           = "Aprobados (%)",
        "average_bach"               = "Media Bachillerato",
        "average_compulsory_pau"     = "Media Fase Obligatoria",
        "diference_average_bach_pau" = "Diferencia Media Bach. - Media Pau"
      )

      sketch <- withTags(table(
        class = 'display cell-border compact',
        thead(
          tr(
            th('Municipio'),
            th(label_var)
          )
        )
      ))

      selected_data() |>
        arrange(desc(!!sym(input$varname_2))) |>  # ordered with original name
        select(
          Municipio = municipios,
          !!label_var := !!sym(input$varname_2)   # then rename
        ) |>
        datatable(
          filter     = list("none"),
          rownames   = FALSE,
          container  = sketch,
          selection  = "single",
          options    = list(
            pageLength   = 40,
            lengthChange = FALSE,
            dom          = "tl",
            columnDefs   = list(
              list(className = 'comarca-name', targets = 0)
            )
          )
        ) |>
        formatRound(
          columns  = c(2),
          dec.mark = ",",
          mark     = "."
        )
    })
    
  })
}
## To be copied in the UI
# mod_regions_municipalities_ui("regions_municipalities_1")
    
## To be copied in the server
# mod_regions_municipalities_server("regions_municipalities_1")
