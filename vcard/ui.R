library(shiny)

shinyUI(fluidPage(
  titlePanel("Permohonan Kad Veteran"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("id", "No Kp:"),
      textInput("address1", "Alamat1:"),
      textInput("address2", "Alamat2:"),
      fileInput("photo", "Muat naik foto:")
    ),
    
    mainPanel(
      h4("Status muat naik:"),
      verbatimTextOutput("Status")
    )
  )
))
