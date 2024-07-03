# app.R
# Repositori minit mesyuarat

library(mongolite)
library(dplyr)
library(jsonlite)
library(googlesheets4)
library(kableExtra)

ui <- fluidPage(
  title = "Shiny Application",
  theme = bslib::bs_theme(4),
  h1(
    "Repositori Minit Mesyuarat"
  ),
  selectInput(
    inputId = "jenis",
    label = "Jenis",
    choices = c("Jawatankuasa","Mesyuarat Agong Tahunan","Majlis Makan Malam")
  ),
  # Pilih tahun
  sliderInput(
    inputId = "tahun",
    label = "Tahun",
    min = 22,
    max = 24,
    value = c(22)
  ),
  sliderInput(
    inputId = "siri",
    label = "Siri",
    min = 1,
    max = 4,
    value = c(1)
  ),
  actionButton("view_btn", "Papar"),
  mainPanel(
    uiOutput("document_viewer")
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  # Load db ----
  MG_URL <- Sys.getenv("MG_URL")
  db <- mongo(collection = "minit", db = "rafoc", url = MG_URL)
  
  # Get doc from db ----
  # siri <- paste0(input$siri, input$tahun)
  # jenis <- input$jenis
  
  # Function to query document from MongoDB
  getDocument <- function(siri, jenis) {
    
    jenis <- case_when(
      jenis == "Jawatankuasa" ~ "exco",
      jenis == "Majlis Makan Malam" ~ "mmmt",
      jenis == "Mesyuarat Agong Tahunan" ~ "agm"
    )

    doc <- list(Siri = siri, Jenis = jenis)
    query <- toJSON(doc, auto_unbox = TRUE) %>% 
      as.character()
    result <- db$find(query)
    if (nrow(result) > 0) {
      return(result)
    } else {
      return(NULL)
    }
  }
 
  # Render document viewer when View Document button is clicked
  observeEvent(input$view_btn, {
    siri <- paste0(input$siri, "/", input$tahun)
    jenis <- input$jenis
    minit <- getDocument(siri, jenis)
    input <- case_when(
      jenis == "Jawatankuasa" ~ "exco.Rmd",
      jenis == "Majlis Makan Malam" ~ "mmmt.Rmd",
      jenis == "Mesyuarat Agong Tahunan" ~ "agm.Rmd"
    )
    if (!is.null(minit)) {
      rmarkdown::render(
        input = input,
        output_dir = "www/",
        output_file = "report.pdf"
      )
      output$document_viewer <- renderUI({
        tags$iframe(style="height:600px; width:130%", src="report.pdf")
      })
    } else {
      output$document_viewer <- renderText("Dokumen tidak ditemukan.")
    }
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
