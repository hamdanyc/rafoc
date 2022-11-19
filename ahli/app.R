# app.R

# Init ----
library(shiny)
library(mongolite)
library(dplyr)

# Connect to the database
# mongodb://[username:password@]host1[:port1]/?authSource=user-data
con <- readLines(con=".url.txt")
db <- mongolite::mongo(collection="ahli", db="rafoc", url=con)

# UI ----
ui <- fluidPage(
  
  # Application title
  titlePanel(title = span(img(src = "logo_rafoc.png", height = 75),"RAFOC - Maklumat Ahli")),
  
  # Sidebar 
  sidebarLayout(
    sidebarPanel(
      textInput("id","Masukkan id"),
      radioButtons("src", "Pilih:",
                   c("No Tentera" = "no_ten",
                     "No Kp" = "no_kp")),
      textOutput("nama"),
      textOutput("kp"),
      textOutput("nten"),
      br(),
      textOutput("almt1"),
      textOutput("almt2"),
      br(),
      textOutput("pkt"),
      textOutput("ttp"),
      
      # Edit button
      tags$hr(),
      br(),
      textInput("addr1","Alamat Tetap 1:"),
      textInput("addr2", "Alamat Tetap 2:"),
      actionButton("butEdt", label = "Pinda Alamat")
    ),
    
    # Main ----
    mainPanel(textOutput("a1"),
              textOutput("a2"))
  )
)

# Server logic ----
server <- function(input, output, clientData, session) {
  
  df <- reactive({
    # output from query
    qry <- switch(input$src,
                   no_ten = paste0('{"no_tentera":','"',input$id,'"}'),
                   no_kp = paste0('{"no_kp":','"',input$id,'"}'))
    
    # Query data ----
    tb <- db$find(qry)
  })
  
  output$nama <- renderText({paste0("Nama: ",df()$nama)})
  
  output$kp <- renderText({paste0("No Kp: ",df()$no_kp)})
  
  output$nten <- renderText({paste0("No Ten: ",df()$no_tentera)})
  
  output$almt1 <- renderText({paste0("Alamat: ",df()$alamat_tetap1)})

  output$almt2 <- renderText({paste0("",df()$alamat_tetap2)})
  
  output$pkt <- renderText({paste0("Pangkat: ",df()$pkt)})
  
  output$ttp <- renderText({paste0("TTP: ",df()$ttp)})

  # get current address ----
  observe({
    a1 <- df()$alamat_tetap1
    a2 <- df()$alamat_tetap2

    # update ui 
    updateTextInput(session, "addr1", value = a1)
    updateTextInput(session, "addr2", value = a2)
  })
  
  # Update address ----
  observeEvent(input$butEdt,{
    
    # query
    qry <- switch(input$src,
                  no_ten = paste0('{"no_tentera":','"',input$id,'"}'),
                  no_kp = paste0('{"no_kp":','"',input$id,'"}'))
    
    # Find & update ----
    # subjects$update('{}', '{"$set":{"has_age": false}}', multiple = TRUE)
    db$update(qry, paste0('{"$set": {"alamat_tetap1":', '"',input$addr1,'",
                          "alamat_tetap2":', '"',input$addr2,'"}}'))
    
    output$a1 <- renderText({input$addr1})
    output$a2 <- renderText({input$addr2})
  })

}

# Run the application 
shinyApp(ui = ui, server = server)
