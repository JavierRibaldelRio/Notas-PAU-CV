# Core libraries
library(shiny)
library(bslib)
library(DBI) # also install rsqlite
library(pool)
library(tidyverse)
library(glue)
library(rlang)

# Shiny options
options(shiny.fullstacktrace = TRUE) # Set to FALSE on production
