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
    "asdf"
  )
}
    
#' ranking Server Functions
#'
#' @noRd 
mod_ranking_server <- function(id,pool){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    
 
  })
}
    
## To be copied in the UI
# mod_ranking_ui("ranking_1")
    
## To be copied in the server
# mod_ranking_server("ranking_1")
