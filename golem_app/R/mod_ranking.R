#' ranking UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList
mod_ranking_ui <- function(id) {
  ns <- NS(id)
  tagList(
    
    # Solución con CSS para que la cabezera de la tabla con dos celdas fusionadas esté centrada
    tags$head(
      tags$style(HTML(
        # #ns("miDataTable"), busca la tabla con el ID de tu módulo
        # thead tr:first-child, busca la PRIMERA fila del encabezado
        # th, aplica el estilo a todas las celdas de esa fila
        paste0(
          "#", ns("ranking_subjects_dt"), " thead tr:first-child th { 
            text-align: center; 
          }"
        )
      ))
    ),

    fluidRow(
      column(
        width = 4,
        # Radio buttons para elegir el método que usaremos
        radioButtons(
          inputId = ns("ranking_subjects"),
          label = "Elige una opción: ",
          inline = TRUE,
          choices = list(
            "Global", 
            "Año" 
          ),
          selected = "Global"
        )
      ),
      column(
        width = 4,
        # Si se selecciona año, entonces
        conditionalPanel(
          ns = ns,
          condition = "input.ranking_subjects == 'Año'",
          selectInput( 
            ns("ranking_subjects_select"), 
            "Select options below:", 
            list(
              "2010" = 2010, 
              "2011" = 2011, 
              "2012" = 2012,
              "2013" = 2013,
              "2014" = 2014,
              "2015" = 2015,
              "2016" = 2016,
              "2017" = 2017,
              "2018" = 2018,
              "2019" = 2019,
              "2020" = 2020,
              "2021" = 2021,
              "2022" = 2022,
              "2023" = 2023,
              "2024" = 2024
            ) 
          ), 
        ),
      )
    ),
    DTOutput(ns("ranking_subjects_dt"))
    
  )
}

# Estructura de la tabla
create_table_structure <- function(input, output, session, pool) {

  output$ranking_subjects_dt <- renderDT({
    
   # Creamos el esquema del encabezado
    sketch <- withTags(table(
      class = 'display',
      thead(
        # Fila 1 del header: aquí fusionamos
        tr(
          th(colspan = 2, 'Mejores Notas'), # Fusiona 2 columnas
          th(colspan = 2, 'Peores Notas'),
          th(colspan = 2, 'Mayor Presentados'),
          th(colspan = 2, 'Menor Presentados')
        ),
        # Fila 2 del header: los nombres reales
        tr(
          th('Asignatura'),
          th('Notas'),
          th('Asignatura'),
          th('Notas'),
          th('Asignatura'),
          th('Presentados'),
          th('Asignatura'),
          th('Presentados')
        )
      )
    ))
    # 2. Datos

    dt_calculado <- reactive({

      req(input$mi_filtro_o_boton)
  
      # 1. Llama a tu función, que DEBE devolver un data frame
      # (Asumo que esta función USA inputs, p.ej. input$mi_filtro)
      datos_brutos <- ranking_selection(input, output, session, pool) 

      # 2. Transfórmalo
      transform_to_table(datos_brutos)

      # El data frame transformado es lo que "devuelve" este bloque reactivo
    })

    # 3. Renderizar la tabla
    datatable(
      dt_calculado,
      container = sketch, # Usamos el encabezado personalizado
      rownames = FALSE,
      options = list(
        dom = 't',
        ordering = FALSE,
        columnDefs = list(
          list(
            className = 'dt-head-center',
            targets = '_all'
          )
        )
      )
    )
  })
}

transform_to_table <- function(dt) {
  umbral_presentados <- 30

  # Hacemos la mediana para la global, claro si es de un año específico la media de cada uno será lo mismo
  notas <- dt |> 
    group_by(code) |> 
    summarize(
      average = mean(average, na.rm = TRUE),
      candidates = mean(candidates, na.rm = TRUE)
    ) |> 
    ungroup()

  notas_filtradas <- notas |> 
    filter(candidates > umbral_presentados)

  # IMPORTANTE: Renombramos columnas para que bind_cols no cree duplicados
  ranking_mejores_notas <- notas_filtradas |> 
    arrange(desc(average)) |> 
    select(
      Asignatura_Mejor = code, # Renombrado
      Notas_Mejor = average
    )
  
  ranking_peores_notas <- notas_filtradas |> 
    arrange(average) |> 
    select(
      Asignatura_Peor = code, # Renombrado
      Notas_Peor = average
    )
  
  ranking_mas_presentados <- notas_filtradas |> 
    arrange(desc(candidates)) |> 
    select(
      Asignatura_Mas = code, # Renombrado
      Presentados_Mas = candidates
    )
  
  ranking_menos_presentados <- notas_filtradas |> 
    arrange(candidates) |> 
    select(
      Asignatura_Menos = code, # Renombrado
      Presentados_Menos = candidates
    )
  
  ranking_final <- bind_cols(
    ranking_mejores_notas,
    ranking_peores_notas,
    ranking_mas_presentados,
    ranking_menos_presentados
  )

  return (ranking_final)
}
    
#' ranking Server Functions
#'
#' @noRd 
mod_ranking_server <- function(id,pool){

  moduleServer(id, function(input, output, session){
    ns <- session$ns
    datos_brutos <- reactive ({

      req(input$ranking_subjects)
      opcion <- input$ranking_subjects

      if (opcion == "Global") {
        df <- dbGetQuery(
          pool,
          "SELECT subjects.code, marks.average, marks.candidates FROM marks INNER JOIN subjects ON subjects.id = marks.subject_id;"
        )
        return(df)
        
      } else {
        req(input$ranking_subjects_select)
        year <- imput$ranking_subjects_select

        sql_query <- glue_sql(
          "SELECT subjects.code, marks.average, marks.candidates FROM marks INNER JOIN subjects on subjects.id = marks.subjects_id WHERE marks.year {`year`};",
          .con = pool
        )

        df <- dbGetQuery(
          pool, 
          sql_query
        )

        return(df)
      }
    })
    # Este output reacciona a los cambios en el radio button
    # output$resultado <- input$ranking_subjects
    ranking_selection(input, output, session, pool)
    create_table_structure(input, output, session, pool)
  })
}
    
## To be copied in the UI
# mod_ranking_ui("ranking_1")
    
## To be copied in the server
# mod_ranking_server("ranking_1")
  