library(shiny)
library(ggplot2)
library(deeptime)
library(palaeoverse)
# Custom functions
source("utils.R")
# Data
df <- readRDS("PBDB.RDS")
bins <- readRDS("stages.RDS")

# UI --------------------------------------------------------------------

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(width = 2, 
      radioButtons("type", "Type",
                   c(Sampling = "sampling", Range = "range", 
                     Diversity = "richness", Diversification = "rates")),
      radioButtons("rank", "Taxonomic rank",
                   c(Species = "species", Genus = "genus", Family = "family"), selected = "genus"),
      selectInput("group", "Group by",
                  c(None = ".", Family = "family", Genus = "genus", Country = "cc")),
      selectInput("region", "Geographic region",
                  c("Global", "Caribbean", "Mediterranean", "Arabia", "Indo-Australian Archipelago"),
                  selected = "Caribbean"),
      selectInput("family", "Family",
                  c(All = ".", "Acroporidae"),
                  selected = "All")
  ),
  
  # Main panel for displaying outputs ----
  mainPanel(width = 10,
            plotOutput(outputId = "plot",
                       height = "100vh")
            
  ),
  position = c("left", "right"),
  fluid = TRUE
)
)


# Server ----------------------------------------------------------------

server <- function(input, output) {
  plot_data <- reactive({
    # Filter data
    tmp <- df |>
      filter_region(region = input$region) |>
      filter_rank(rank = input$rank) |>
      filter_family(fam = input$family)
    get_temporal_ranges(tmp, name = input$rank, group = input$group)
  })
  
  output$plot <- renderPlot({
    plot_data()
  })
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)

