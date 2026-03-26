#' select_high_school_type UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_select_high_school_type_ui <- function(id, title = "Régimen educativo", selected = 2) {
  ns <- NS(id)
  selectInput(
    ns("select_type"),
    title,
    selected = "Todos",
    selectize = TRUE,
    list("Todos" = 3 ,"Público" = 0, "Concertado" = 1, "Privado" = 2)
  )
} 
#' select_high_school_type Server Functions
#'
#' @noRd 
mod_select_high_school_type_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    reactive({    
      input$select_type
    })
  })
}
    
## To be copied in the UImod_select_high_school_type_ui("select_high_school_type_1")
# 
    
## To be copied in the server
# mod_select_high_school_type_server("select_high_school_type_1")
