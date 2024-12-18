# Load required libraries
library(shiny)
library(shinyWidgets)
library(mongolite)
library(readr)
library(dplyr)

# Connect to MongoDB
# Load db ----
MG_URL <- Sys.getenv("MG_URL")
db_undi <- mongo(collection = "undi", db = "rafoc", url = MG_URL)
db_ahli <- mongo(collection = "ahli", db = "rafoc", url = MG_URL)
calon <- c("Lt Jen Dato’ Sri Abdul Aziz bin Ibrahim, (Bersara)",
           "Mej Jen Datuk Mohd Halim Khalid (Bersara)",
           "Lt Kdr Phua Hean Sim, TLDM, (Bersara)",
           "Lt Kol Hj Mior Mohamad Zubir bin Mior Yahya, TUDM, (Bersara)",
           "Mej Jen Dato' Mohd Arif Soo (Bersara)",
           "Mej Jen Dato' Yusri bin Hj Anwar (Bersara)",
           "Kol Mohd Kamal bin Omar, (Bersara)",
           "Kept Tajudin bin Hj Yahya, TLDM, (Bersara)",
           "Lt Kol Mohd Yusof bin Abd Razak (Bersara)",
           "Lt Kol Dzulkarnain bin Abdullah, (Bersara)",
           "Lt Kol Ramli Kinta (Bersara)",
           "Kdr Syed Salim bin Syed Osman, TLDM, (Bersara)",
           "Lt Kol Abdullah Khir bin Mohd Saidi, TUDM, (Bersara)",
           "Lt Kol Hashimah bt Hj. Hassan TUDM, (Bersara)",
           "Mej Amir Ahmad bin Abd Majid, (Bersara)",
           "Mej Dr. Bibi Zarjan bt Akhbar Khan (Bersara)",
           "Mej Ganeson Awar, (Bersara)",
           "Mej Tengku Ahmad Nazri bin Tengku Abdul Jalil (Bersara)",
           "Lt Kdr Hj. Yusalie bin Yushak TLDM, (Bersara)",
           "Mej Ismail bin Malik, TUDM (Bersara)",
           "Kapt Asmah bt Abdul Kadir (Bersara)",
           "Kol Hamdan Yaccob (Bersara)"
           )

# Define UI ----
ui <- fluidPage(
  tags$img(src = "rafoc_cyan.png", width = "100px", height = "100px"),
  titlePanel("Pemilihan AJK Eksekutif RAFOC 2024"),
  tags$style(HTML("
    body {
            background-color: cyan;
            color: blue;
          }")),
  sidebarLayout(
    sidebarPanel(
      textInput("user_id", "Log masuk (No Kp Awam)"),
      actionButton("login_btn", "Login"),
    ),
    mainPanel(
      textOutput("rec_found"),
      textOutput("login_status"),
      conditionalPanel(
        condition = "output.login_status == 'Log masuk berjaya'",
        multiInput(
          inputId = "selection", label = "Calon-calon :",
          choices = calon,
          width = 510,
          options = list(
            enable_search = FALSE,
            non_selected_header = "Senarai:",
            selected_header = "Pilihan Anda:"
          )
        ),
        actionButton("submit_btn", "Hantar"),
        actionButton("exit","Keluar"),
        br(),
        br(),
        tags$ol(
          tags$li("Klik nama calon dipilih untuk ke kotak kanan"), 
          tags$li("Pilih calon-calon diminati"), 
          tags$li("Tekan hantar, setelah selesai")
        )
      )
    )
  )
)

# Define server logic ----
server <- function(input, output, session) {

  # Check user ID and allow login if it exists ----
  user_verified <- reactive({
    req(input$login_btn)
    user_id <- input$user_id
    user_exists <-  db_undi$count(query = paste0('{"no_kp": "',user_id, '"}'))
    member_exists <-  db_ahli$count(query = paste0('{"no_kp": "',user_id, '"}'))

    if (member_exists == 0) {
      return("Anda belum menjadi ahli. Sila daftar di https://forms.gle/y7pym2rJRkXqqb3d9")
    } else if (user_exists != 0) {
      return("Anda telah mengundi sebelum ini.")
    } else {
      return("Log masuk berjaya")
          }
  })
  
  # Display login status
  output$login_status <- renderText({
    if (is.null(input$login_btn)) {
      return("")
    } else {
      user_verified()
    }
  })
  
  # Flag rec found
  output$rec_found <- renderText({
    if (user_verified() == "Log masuk berjaya" | user_verified() == "Anda telah mengundi sebelum ini."){
      ahli <- db_ahli$find(query = paste0('{"no_kp": "',input$user_id, '"}'))
      return(paste0(ahli$nama, ", ", ahli$pkt, "(BERSARA)"))
    }
  })
  
  # Insert document to MongoDB on submit ----
  observeEvent(input$submit_btn, {
    user_id <- input$user_id
    selection <- input$selection
    # if (length(selection) != 3) {
    #   return()
    # }
    doc <- data.frame("no_kp" = user_id, "selection" = selection)
    db_undi$insert(doc)
    showNotification("Terima kasih", duration = 5)
    db_ahli$disconnect()
    db_undi$disconnect()
  })
  
  observeEvent(input$exit,{
    removeUI(selector = "body")
  })
  
}

# Run the application ----
shinyApp(ui = ui, server = server)