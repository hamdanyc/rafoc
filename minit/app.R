# minit/doc
library(shiny)

# Define UI
# Application title

ui <- fluidPage(titlePanel(title = span(img(src = "logo_rafoc.png", height = 75),"RAFOC - Repositori Minit Mesyuarat")),
                selectInput("kate", "Dokumen:",width = "60%",
                            list('AJK' = list("minit_exco_1_22.pdf", "minit_exco_2_22.pdf", 
                                              "minit_exco_3_22.pdf", "minit_exco_4_22.pdf",
                                              "minit_exco_1_23.pdf", "minit_exco_2_23.pdf",
                                              "minit_exco_3_23.pdf", "minit_exco_4_23.pdf",
                                              "minit_exco_1_24.pdf", "minit_exco_2_24.pdf",
                                              "minit_exco_3_24.pdf"),
                                 'AGM' = list("minit_agm_23.pdf"),
                                 'MMMT' = list("minit_mmmt_2_22.pdf", "minit_mmmt_3_22.pdf",
                                               "minit_mmmt_4_22.pdf", "minit_mmmt_post.pdf",
                                               "minit_mmmt_1_24.pdf", "minit_mmmt_2_24.pdf",
                                               "minit_mmmt_3_24.pdf"))
                ),
                mainPanel(fluidRow(
                  htmlOutput("frame")
                ))
)

# Define server logic required to display frame
server <- function(input, output,session){
  output$frame <- renderUI({
    tags$iframe(src=input$kate, style="height:900px; width:130%; scrolling=yes")
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
