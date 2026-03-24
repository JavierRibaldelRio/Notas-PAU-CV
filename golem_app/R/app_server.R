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

  # 1. actualizar URL cuando cambia navbar
  observeEvent(input$page, {

    newURL <- paste0(
      session$clientData$url_protocol,
      "//",
      session$clientData$url_hostname,
      ":",
      session$clientData$url_port,
      session$clientData$url_pathname,
      session$clientData$url_search,
      "#",
      input$page
    )

    updateQueryString(newURL, mode = "replace", session)

  }, ignoreInit = TRUE)


  # 2. sincronizar URL con estado
  observe({

    query <- parseQueryString(session$clientData$url_search)
    tab <- sub("#", "", session$clientData$url_hash)

    center_id <- query$center_id

    # si hay center -> forzar centros
    if (!is.null(center_id) && tab != "centros") {

      updateNavbarPage(session, "page", selected = "centros")
      return()

    }

    # si salimos de centros -> borrar center_id
    if (tab != "centros" && !is.null(center_id)) {

      newURL <- paste0(
        session$clientData$url_protocol,
        "//",
        session$clientData$url_hostname,
        ":",
        session$clientData$url_port,
        session$clientData$url_pathname,
        "#",
        tab
      )

      updateQueryString(newURL, mode = "replace", session)
      return()

    }

    if (!is.null(tab) && tab != "") {
      updateNavbarPage(session, "page", selected = tab)
    }

  })

  
  # Database
  pool <- golem::get_golem_options("pool")


  # reactivo center
  center_id <- reactive({
    parseQueryString(session$clientData$url_search)$center_id
  })


  output$center_page <- renderUI({

    id <- center_id()

    if (is.null(id)) {
      return(page_home_ui(pool))
    }

    if (id != "23") {
      return(page_center_ui(id,pool))
    }

    page_invalid_ui()

  })



  # pagina principal y
  mod_main_dashboard_server("main_dashboard_1", pool)
  mod_subjects_page_server("subjects_page_1", pool)

  # Maps
  mod_map_region_server("map_region_1",pool)
  
  # Municipalities
  mod_regions_municipalities_server("regions_municipalities_1")

  center_marks <- reactive({

    req(center_id())
  
    DBI::dbGetQuery(
      pool,
      "
      SELECT year, call,
             average_compulsory_pau,
             average_bach,
             pass_percentatge,
             standard_dev_pau
      FROM high_school_marks
      WHERE high_school_id = ? and call = 2
      ",
      params = list(center_id())
    )
  
  })
  
  output$center_marks_plot <- renderPlot({
  
    req(center_marks(), input$metric)
  
    df <- center_marks()
  
    ggplot2::ggplot(
      df,
      ggplot2::aes(
        x = year,
        y = .data[[input$metric]],
        group = call
      )
    ) +
      ggplot2::geom_line(linewidth = 1) +
      ggplot2::geom_point(size = 3) +
      ggplot2::labs(
        x = "Año",
        y = NULL,
        color = "Convocatoria"
      ) +
        theme_base()
  })


}


page_home_ui <- function(con) {

  centers <- DBI::dbGetQuery(
    con,
    "SELECT name, id FROM high_schools"
  )

  tagList(
    h2("Guía de centros"),

    p("Seleccione un centro:"),

    tags$ul(

      lapply(seq_len(nrow(centers)), function(i) {

        tags$li(
          tags$a(
            href = paste0("?center_id=", centers$id[i], "#centros"),
            centers$name[i]
          )
        )

      })

    )
  )

}

page_center_ui <- function(id, pool) {

  center <- DBI::dbGetQuery(
    pool,
    "SELECT * FROM high_schools WHERE id = ?",
    params = list(id)
  )

  if (nrow(center) == 0) {
    return(
      bslib::card(
        fill = FALSE,
        bslib::card_header("Centro no encontrado"),
        "El centro solicitado no existe."
      )
    )
  }

  center <- center[1, ]

  img_base64 <- NULL
  if (!is.null(center$image[[1]])) {
    img_base64 <- base64enc::base64encode(center$image[[1]])
  }

  bslib::card(

    fill = FALSE,   # ← rompe el comportamiento fillable

    bslib::card_header(
      paste("Ficha del centro:", center$name)
    ),

    # IMAGEN
    if (!is.null(img_base64)) {

      tags$div(
        style = "margin-bottom:30px;",

        tags$img(
          src = paste0("data:image/jpeg;base64,", img_base64),
          style = "
            max-width:100%;
            max-height:420px;
            object-fit:contain;
            border-radius:10px;
            display:block;
            margin-left:auto;
            margin-right:auto;
          "
        )
      )
    },

    # INFORMACIÓN
    bslib::card(
      fill = FALSE,
      bslib::card_header("Información general"),

      tags$ul(
        tags$li(strong("Código: "), center$code),
        tags$li(strong("CIF: "), center$cif),
        tags$li(strong("Titularidad: "), center$owner),
        tags$li(strong("Dirección: "), center$address),
        tags$li(strong("Código postal: "), center$postal_code)
      )
    ),

    br(),

    # CONTACTO
    bslib::card(
      fill = FALSE,
      bslib::card_header("Contacto"),

      tags$ul(
        tags$li(strong("Email: "), center$email),
        tags$li(strong("Teléfono: "), center$phone_number),
        tags$li(
          strong("Web: "),
          tags$a(center$website,
                 href = center$website,
                 target = "_blank")
        )
      )
    ),

    br(),

    # GRÁFICA
    bslib::card(
      fill = FALSE,
      bslib::card_header("Evolución de resultados PAU"),

      selectizeInput(
        "metric",
        "Indicador",
        choices = c(
          "Nota media PAU" = "average_compulsory_pau",
          "Nota media Bachillerato" = "average_bach",
          "Aprobados (%)" = "pass_percentatge",
          "Desv. estándar PAU" = "standard_dev_pau"
        ),
        selected = "average_compulsory_pau"
      ),

      plotOutput(
        "center_marks_plot",
        height = "400px"
      )
    ),

    br(),

    tags$a(
      href = "?#centros",
      class = "btn btn-outline-secondary",
      "Volver a la guía"
    )

  )

}

page_invalid_ui <- function() {

  tagList(
    h2("Centro no encontrado"),

    p("El identificador solicitado no existe."),

    br(),

    tags$a(
      href = "?#centros",
      "Volver a la guía"
    )
  )

}