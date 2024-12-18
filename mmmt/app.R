# app.R
# Majlis Makan Malam Tahunan `22`

library(shiny)
library(mongolite)
library(dplyr)
library(DT)

# conn db ----
MG_URL <- Sys.getenv("MG_URL")
db <- mongo(collection = "mmmr_24", db = "rafoc", url = MG_URL)

# library(DT)
# datatable(df, rownames = FALSE) %>%
#   formatStyle(columns = "inputval", 
#               background = styleInterval(c(0.7, 0.8, 0.9)-1e-6, c("white", "lightblue", "magenta", "white"))) %>%
#   formatStyle(columns = "outcome", 
#               background = styleEqual(c(1, 4), c("magenta", "lightblue")))

# mm <- read.csv("mmmt_22_Kehadiran.csv")
mm <- db$find()

# Define UI for application that draws a histogram
ui <- fluidPage(
    titlePanel("Majlis Makan Malam Tahunan: Kehadiran & Meja Tetamu/pasangan"),
    titlePanel("Runs on MongoDB **"),
    fluidRow(
        column(12,
               DT::dataTableOutput('table')
        )
    )
)

# Define server logic ----
server <- function(input, output) {
  output$table <- DT::datatable(mm, options = list(searchHighlight = TRUE)) %>% 
    formatStyle(columns = "Menu", 
                background = styleEqual(c("Ayam", "Daging", "Ikan", "Muhibbah"), c("green", "red", "yellow", "purple"))) %>% 
    DT::renderDataTable()
}

# Run the application 
shinyApp(ui = ui, server = server)
