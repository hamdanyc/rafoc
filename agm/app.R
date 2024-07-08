library(shiny)
library(plotly)
library(gridlayout)
library(bslib)

# ui ----
ui <- grid_page(
  layout = c(
    "area1 area2",
    "area0 area0"
  ),
  row_sizes = c(
    "175px",
    "1fr"
  ),
  col_sizes = c(
    "265px",
    "1fr"
  ),
  gap_size = "1rem",
  grid_card(
    area = "area0",
    card_body(
      tabsetPanel(
        nav_panel(
          title = "Kata-kata Aluan Presiden",
          card(
            full_screen = TRUE,
            card_body(
              tags$iframe(style="height:600px; width:100%", src="cny.mp4"),
              selectInput(
                inputId = "introIn",
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
              )
            )
          )
        ),
        nav_panel(
          title = "Laporan Tahunan",
          card(
            full_screen = TRUE,
            card_body(
              tags$iframe(style="height:600px; width:100%", src="report.pdf"),
              selectInput(
                inputId = "yrpIn",
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
              )
            )
          )
        ),
        nav_panel(
          title = "Laporan Akaun",
          card(
            full_screen = TRUE,
            card_body(
              tags$iframe(style="height:600px; width:100%", src="akaun.pdf"),
              selectInput(
                inputId = "annIn",
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
              )
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
        inputId = "login",
        label = "Log Masuk",
        value = ""
      ),
      card(
        full_screen = TRUE,
        card_header(textOutput(outputId = "nama"))
      )
    )
  ),
  grid_card(
    area = "area2",
    card_body(h1("Mesyuarat Agong Tahunan RAFOC ke-14"))
  )
)


server <- function(input, output) {
  
}

shinyApp(ui, server)
