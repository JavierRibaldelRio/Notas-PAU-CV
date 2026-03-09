#' select_call UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_select_call_ui <- function(id, title = "Convocatoria", selected = 2) {
  ns <- NS(id)
  selectInput(
    ns("select_call"),
    title,
    selected = selected,
    selectize = TRUE,
    list("Ordinaria" = 0, "Extraordinaria" = 1, "Global" = 2)
  )
}
    
#' select_call Server Functions
#'
#' @noRd 
mod_select_call_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    reactive({    
      input$select_call
    })
  })
}
    
## To be copied in the UI
# mod_select_call_ui("select_call_1")
    
## To be copied in the server
# mod_select_call_server("select_call_1")
