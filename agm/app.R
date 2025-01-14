library(shiny)
library(gridlayout)
library(bslib)
library(shinyWidgets)
library(mongolite)
library(readr)
library(dplyr)

# Connect to MongoDB
# Load db ----
MG_URL <- Sys.getenv("MG_URL")
db_ahli <- mongo(collection = "ahli", db = "rafoc", url = MG_URL)
db_agm <- mongo(collection = "agm", db = "rafoc", url = MG_URL)

# ui ----
ui <- grid_page(
  layout = c(
    "area1 area2",
    "area0 area0"
  ),
  row_sizes = c(
    "250px",
    "1fr"
  ),
  col_sizes = c(
    "325px",
    "1fr"
  ),
  gap_size = "1rem",
  grid_card(
    area = "area0",
    card_body(
      conditionalPanel(
        condition = "output.nama > '' & output.nama != 'Untuk ahli sahaja'",
        tabsetPanel(
          # Notis ----
          nav_panel(
            title = "Notis",
            card(
              full_screen = TRUE,
              card_body(
                tags$iframe(style="height:300px; width:70%", src="notis.pdf"),
                
              )
            )
          ),
          # Kata-kata aluan ----
          nav_panel(
            title = "Kata-kata Aluan Presiden",
            card(
              full_screen = TRUE,
              card_body(
                tags$video(src = "dsaa.mp4", type = "video/mp4", height = "400px", controls = NA),
                # tags$iframe(style="height:300px; width:70%", src="cny.mp4"),
                selectInput(
                  inputId = "introSelect",
                  label = "Kandungan",
                  choices = list(
                    "Memuaskan" = "Memuaskan",
                    "Sederhana" = "Sederhana",
                    "Tidak berkenaan" = "Tidak berkenaan"
                  )
                ),
                textInput(
                  inputId = "introText",
                  label = "Komen dan Ulasan",
                  value = "Komen anda ..."
                ),
                actionButton(inputId = "intro_btn", label = "Hantar",
                             width = "150px", class = "btn-success")
              )
            )
          ),
          # Laporan tahunan ----
          nav_panel(
            title = "Laporan Tahunan",
            card(
              full_screen = TRUE,
              card_body(
                tags$iframe(style="height:600px; width:100%", src="laporan_2023.pdf"),
                selectInput(
                  inputId = "yrpSelect",
                  label = "Kandungan",
                  choices = list(
                    "Memuaskan" = "Memuaskan",
                    "Sederhana" = "Sederhana",
                    "Tidak berkenaan" = "Tidak berkenaan"
                  )
                ),
                textInput(
                  inputId = "yrpText",
                  label = "Komen dan Ulasan",
                  value = "Komen anda ..."
                ),
                actionButton(inputId = "yrp_btn", label = "Hantar",
                             width = "150px", class = "btn-success")
              )
            )
          ),
          # Laporan akaun ----
          nav_panel(
            title = "Laporan Akaun",
            card(
              full_screen = TRUE,
              card_body(
                tags$iframe(style="height:600px; width:100%", src="akaun.pdf"),
                selectInput(
                  inputId = "annSelect",
                  label = "Kandungan",
                  choices = list(
                    "Memuaskan" = "Memuaskan",
                    "Sederhana" = "Sederhana",
                    "Tidak berkenaan" = "Tidak berkenaan"
                  )
                ),
                textInput(
                  inputId = "annText",
                  label = "Komen dan Ulasan",
                  value = "Komen anda ..."
                ),
                actionButton(inputId = "ann_btn", label = "Hantar",
                             width = "150px", class = "btn-success")
              )
            )
          ),
          # Minit AGM ----
          nav_panel(
            title = "Minit MAT ke-13",
            card(
              full_screen = TRUE,
              card_body(
                tags$iframe(style="height:600px; width:100%", src="minit_agm.pdf"),
                selectInput(
                  inputId = "momSelect",
                  label = "Kandungan",
                  choices = list(
                    "Memuaskan" = "Memuaskan",
                    "Sederhana" = "Sederhana",
                    "Tidak berkenaan" = "Tidak berkenaan"
                  )
                ),
                textInput(
                  inputId = "momText",
                  label = "Komen dan Ulasan",
                  value = "Komen anda ..."
                ),
                actionButton(inputId = "mom_btn", label = "Hantar",
                             width = "150px", class = "btn-success")
              )
            )
          )
        )
      )
    )
  ),
  grid_card(
    area = "area1",
    card_body(
      textInput(
        inputId = "user_id",
        label = "Log masuk (No Kp Awam)"
      ),
      actionButton(inputId = "login_btn", label = "Login"),
      card(card_header(textOutput(outputId = "nama")))
    )
  ),
  grid_card(
    area = "area2",
    tags$img(src = "rafoc_logo.png", width = "90px", height = "100px"),
    card_body(h3("Mesyuarat Agong Tahunan RAFOC ke-14"),height = "30%",fill = FALSE),
    card_body(h5("Sabtu, 10 Ogos 2024, 10 am - Serambi, Wisma Perwira ATM",
                 height = "30%", fill = FALSE)),
    tags$a(href="https://hamdan-yaccob.shinyapps.io/undi/", "Hantar undian di pautan ini")
  )
)

# server ----
server <- function(input, output) {
  
  # Check user ID and allow login if it exists ----
  user_verified <- reactive({
    req(input$login_btn)
    user_id <- input$user_id
    member <-  db_ahli$count(query = paste0('{"no_kp": "',user_id, '"}'))
    
    if (member == 0) {
      return("Not found")
    } else {
      return("Found")
    }
  })
  
  # login ----
  output$nama <- renderText({
    if (user_verified() == "Found"){
      ahli <- db_ahli$find(query = paste0('{"no_kp": "',input$user_id, '"}'))
      nama <- stringr::str_to_title(ahli$nama)
      pkt <- stringr::str_to_title(ahli$pkt)
      tkh <- lubridate::now(tz="Asia/Kuala_Lumpur")
      doc <- data.frame("no_kp" = input$user_id, "nama" = nama, 
                        "pkt" = pkt, "tkh" = tkh)
      db_agm$insert(doc)
      return(paste0(nama, ", ", pkt, "(B)"))
    }
    else{
      return("Untuk ahli sahaja")
    }
  })
  
  # Kata-kata aluan ----
  observeEvent(input$intro_btn, {
    user_id <- input$user_id
    selection <- input$introSelect
    komen <- input$introText
    doc <- data.frame("no_kp" = user_id, "kata_aluan" = selection, "komen" = komen)
    db_agm$insert(doc)
    showNotification("Terima kasih", duration = 5)
    db_ahli$disconnect()
    db_agm$disconnect()
  })
  
  # Laporan tahunan ----
  observeEvent(input$yrp_btn, {
    user_id <- input$user_id
    selection <- input$yrpSelect
    komen <- input$yrpText
    doc <- data.frame("no_kp" = user_id, "laporan_tahunan" = selection, "komen" = komen)
    db_agm$insert(doc)
    showNotification("Terima kasih", duration = 5)
    db_ahli$disconnect()
    db_agm$disconnect()
  })
  
  # Laporan akaun ----
  observeEvent(input$ann_btn, {
    user_id <- input$user_id
    selection <- input$annSelect
    komen <- input$annText
    doc <- data.frame("no_kp" = user_id, "laporan_akaun" = selection, "komen" = komen)
    db_agm$insert(doc)
    showNotification("Terima kasih", duration = 5)
    db_ahli$disconnect()
    db_agm$disconnect()
  })
  
  # Minit AGM ----
  observeEvent(input$mom_btn, {
    user_id <- input$user_id
    selection <- input$momSelect
    komen <- input$momText
    doc <- data.frame("no_kp" = user_id, "minit_agm" = selection, "komen" = komen)
    db_agm$insert(doc)
    showNotification("Terima kasih", duration = 5)
    db_ahli$disconnect()
    db_agm$disconnect()
  })
  
}

shinyApp(ui, server)
