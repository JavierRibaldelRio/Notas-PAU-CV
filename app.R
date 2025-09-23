# Import UI
source("R/ui/ui.R")

# Import Server
source("R/server/server.R")

shinyApp(ui = ui, server = server)
