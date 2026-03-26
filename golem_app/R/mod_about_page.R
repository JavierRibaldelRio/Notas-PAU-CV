#' about_page UI Function
#'
#' @description A shiny Module.
#'
#' @param id Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList div h2 h3 h4 p tags a
mod_about_page_ui <- function(id) {
  ns <- NS(id)

  tagList(
    tags$div(
      class = "about-wrapper",

      # CABECERA PRINCIPAL
      tags$div(
        class = "about-hero",
        tags$h2("Notas PAU CV"),
        tags$p(
          class = "about-lead",
          "Aplicación interactiva para el análisis de los resultados de la PAU en la Comunitat Valenciana a lo largo de los últimos 14–15 años."
        ),
        tags$p(
          class = "about-text",
          "Desarrollada con R, Shiny y golem, combina análisis académico, consulta de centros y exploración territorial en un entorno visual y accesible."
        )
      ),

      # EQUIPO DETALLADO
      tags$div(
        class = "about-card about-team-card",
        tags$h3("Equipo de desarrollo"),

        tags$div(
          class = "team-grid",

          tags$div(
            class = "team-member",
            tags$h4("Javier Ribal del Río"),
            tags$p("Doble grado en Administración y Dirección de Empresas e Ingeniería Informática"),
            tags$p("Universitat Politècnica de València"),
            tags$p(
              tags$strong("Email: "),
              tags$a(href = "mailto:javierribaldelrio@gmail.com", "javierribaldelrio@gmail.com")
            ),
            tags$p(
              tags$strong("GitHub: "),
              tags$a(href = "https://github.com/JavierRibaldelRio", target = "_blank", "@JavierRibaldelRio")
            ),
            tags$p(
              tags$strong("LinkedIn: "),
              tags$a(href = "https://www.linkedin.com/in/javier-ribal-del-rio/", target = "_blank", "Javier Ribal del Río")
            )
          ),

          tags$div(
            class = "team-member",
            tags$h4("Pau Minguet Micó"),
            tags$p("Doble grado en Administración y Dirección de Empresas e Ingeniería Informática"),
            tags$p("Universitat Politècnica de València"),
            tags$p(
              tags$strong("Email: "),
              tags$a(href = "mailto:pminmic@gmail.com", "pminmic@gmail.com")
            ),
            tags$p(
              tags$strong("GitHub: "),
              tags$a(href = "https://github.com/pminmic", target = "_blank", "@pminmic")
            ),
            tags$p(
              tags$strong("LinkedIn: "),
              tags$a(href = "https://www.linkedin.com/in/pau-minguet-mico/", target = "_blank", "Pau Minguet Micó")
            )
          )
        )
      ),

      # UNA ÚNICA TARJETA CON TODA LA INFO DEL PROYECTO
      tags$div(
        class = "about-card about-project-card",
        tags$h3("Proyecto"),

        tags$div(
          class = "project-sections",

          tags$div(
            class = "project-section",
            tags$h4("Objetivo"),
            tags$p(
              "Facilitar la exploración y comprensión de la evolución de los resultados de la PAU mediante visualizaciones interactivas, comparativas históricas y herramientas de consulta por asignaturas, regiones y centros."
            )
          ),

          tags$div(
            class = "project-section",
            tags$h4("Público destinatario"),
            tags$ul(
              tags$li("Profesorado de Bachillerato."),
              tags$li("Alumnado interesado en comparar resultados y consultar centros."),
              tags$li("Personas que deseen interpretar tendencias académicas históricas.")
            )
          ),

          tags$div(
            class = "project-section",
            tags$h4("¿Qué permite hacer la aplicación?"),
            tags$ul(
              tags$li("Analizar tendencias globales de resultados."),
              tags$li("Explorar información detallada por asignaturas."),
              tags$li("Consultar resultados por regiones y municipios."),
              tags$li("Examinar información y evolución de centros educativos."),
              tags$li("Visualizar datos de forma clara e interactiva.")
            )
          ),

          tags$div(
            class = "project-section",
            tags$h4("Fuente de datos"),
            tags$p(
              "Los datos proceden de ",
              tags$a("documentos oficiales", href = "https://universitats.gva.es/es/estadistiques", target = "_blank") ,
              " publicados por la Generalitat Valenciana."
            ),
            tags$p(
              "La extracción, transformación y estructuración de la información se ha realizado mediante un proceso propio apoyado en código Python."
            )
          ),

          tags$div(
            class = "project-section",
            tags$h4("Tecnologías"),
            tags$ul(
              tags$li(tags$strong("Lenguaje: "), "R"),
              tags$li(tags$strong("Framework: "), "Shiny"),
              tags$li(tags$strong("Arquitectura: "), "golem"),
              tags$li(tags$strong("Filosofía: "), "tidyverse"),
              tags$li(tags$strong("Extracción y gestión de datos:"), "Python y SQLite")
            )
          ),

          tags$div(
            class = "project-section",
            tags$h4("Información del proyecto"),
            tags$p(tags$strong("Versión: "), as.character(utils::packageVersion("notaspaucv"))),
            tags$p(tags$strong("Estado: "), "En desarrollo"),
            tags$p(tags$strong("Licencia: "), "MIT"),
            tags$p(
              tags$strong("Repositorio: "),
              tags$a(
                href = "https://github.com/JavierRibaldelRio/Notas-PAU-CV",
                target = "_blank",
                "GitHub"
              )
            ),
            tags$p(
              tags$strong("Incidencias: "),
              tags$a(
                href = "https://github.com/JavierRibaldelRio/Notas-PAU-CV/issues",
                target = "_blank",
                "Abrir issues"
              )
            )
          )
        )
      )
    )
  )
}

#' about_page Server Functions
#'
#' @noRd
mod_about_page_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
  })
}