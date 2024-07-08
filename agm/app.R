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
        condition = "output.nama > ''",
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
                tags$iframe(style="height:300px; width:70%", src="cny.mp4"),
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
          nav_panel(
            title = "Minit MAT ke-13",
            card(
              full_screen = TRUE,
              card_body(
                tags$iframe(style="height:600px; width:100%", src="minit_agm.pdf"),
                selectInput(
                  inputId = "momIn",
                  label = "Kandungan",
                  choices = list(
                    "Memuaskan" = "Memuaskan",
                    "Sederhana" = "Memuaskan",
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
    card_body(h1("Mesyuarat Agong Tahunan RAFOC ke-14"))
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
  
  # Flag rec found
  output$nama <- renderText({
    if (user_verified() == "Found"){
      ahli <- db_ahli$find(query = paste0('{"no_kp": "',input$user_id, '"}'))
      # return("ahli")
      return(paste0(ahli$nama, ", ", ahli$pkt, "(BERSARA)"))
    }
  })
  
}

shinyApp(ui, server)
