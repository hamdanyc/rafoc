library(shiny)

shinyUI(fluidPage(
  titlePanel("Permohonan Kad Veteran"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("no_kp", "No Kp:"),
      textOutput("nama"),
      textOutput("alamat"),
      textOutput("foto"),
      fileInput("photo", "Muat naik foto:")
    ),
    
    mainPanel(
      h4("Status muat naik:"),
      verbatimTextOutput("Status")
    )
  )
))
