library(shiny)
library(bslib)
library(DBI) # also install rsqlite
library(pool)
library(tidyverse)
library(glue)
library(rlang)

# Import UI
source("R/ui/ui.R")
source("R/server/server.R")

shinyApp(ui = ui, server = server)
