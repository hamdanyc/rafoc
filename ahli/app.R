# app.R

# Init ----
library(shiny)
library(mongolite)
library(dplyr)

# Connect to the database
# mongodb://[username:password@]host1[:port1]/?authSource=user-data
con <- readLines(con=".url.txt")
db <- mongolite::mongo(collection="ahli", db="rafoc", url=con)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("RAFOC - Maklumat Ahli"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            textInput("noten","Masukkan No Tentera"),
            textOutput("nama"),
            br(),
            textOutput("almt1"),
            textOutput("almt2"),
            br(),
            textOutput("pkt"),
            textOutput("ttp")
        ),

        # Show result
        mainPanel(
          tableOutput("info")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  df <- reactive({
    # output from query
    qry <- paste0('{"no_tentera":','"',input$noten,'"}')
    
    # Query data ----
    tb <- db$find(qry)
  })
  

  output$nama <- renderText({paste0("Nama: ",df()$nama)})
  
  output$almt1 <- renderText({paste0("Alamat: ",df()$alamat_tetap1)})

  output$almt2 <- renderText({paste0("",df()$alamat_tetap2)})
  
  output$pkt <- renderText({paste0("Pangkat: ",df()$pkt)})
  
  output$ttp <- renderText({paste0("TTP: ",df()$ttp)})
}

# Run the application 
shinyApp(ui = ui, server = server)
