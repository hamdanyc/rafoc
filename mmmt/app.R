# app.R
# Majlis Makan Malam Tahunan `22`

library(shiny)
library(mongolite)

# Connect to the database
# mongodb://[username:password@]host1[:port1]/?authSource=user-data
con <- readLines(con=".url.txt")
db <- mongolite::mongo(collection="mmmt", db="rafoc", url=con)

# mm <- read.csv("mmmt_22_Kehadiran.csv")
mm <- db$find()

# Define UI for application that draws a histogram
ui <- fluidPage(
    titlePanel("MMMT `22: Kehadiran & Meja Tetamu/pasangan"),
    titlePanel("Runs on MongoDB **"),
    fluidRow(
        column(12,
               DT::dataTableOutput('table')
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    output$table <- DT::renderDataTable(mm)
}

# Run the application 
shinyApp(ui = ui, server = server)
