library(shiny)
library(ggplot2)

ui <- fluidPage(
  titlePanel("Shiny App with Sidebar and Four Panels"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("xvar", "X-axis variable:",
                  choices = names(mtcars), selected = "wt"),
      selectInput("yvar", "Y-axis variable:",
                  choices = names(mtcars), selected = "mpg"),
      selectInput("colorvar", "Color by:",
                  choices = names(mtcars), selected = "cyl")
    ),
    
    mainPanel(
      fluidRow(
        column(6, plotOutput("plot1")),
        column(6, plotOutput("plot2"))
      ),
      fluidRow(
        column(6, plotOutput("plot3")),
        column(6, plotOutput("plot4"))
      )
    )
  )
)

server <- function(input, output) {
  
  base_plot <- reactive({
    ggplot(mtcars, aes_string(x = input$xvar, y = input$yvar, color = input$colorvar)) +
      geom_point(size = 3) +
      theme_minimal()
  })
  
  output$plot1 <- renderPlot({
    base_plot() + ggtitle("Plot 1")
  })
  
  output$plot2 <- renderPlot({
    base_plot() + ggtitle("Plot 2")
  })
  
  output$plot3 <- renderPlot({
    base_plot() + ggtitle("Plot 3")
  })
  
  output$plot4 <- renderPlot({
    base_plot() + ggtitle("Plot 4")
  })
}

shinyApp(ui = ui, server = server)
