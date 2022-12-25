# sijil_proc.R

# init ----
library(dplyr)
# main rtn ----
## Data
res <- readr::read_csv("respon.csv")
## Loop
for (i in 1:nrow(res)){
  rmarkdown::render(input = "sijil.Rmd",
                    output_format = "pdf_document",
                    output_file = paste("sijil_", i, ".pdf", sep=''),
                    output_dir = "sijil/")
}
