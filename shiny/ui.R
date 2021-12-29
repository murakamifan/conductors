library(shiny)

## list of orchestras
data.tidy <- readRDS(file="data_conductors.Rds")
orchestras <- unique(data.tidy$orchestra)

ui <- fluidPage(

  titlePanel("Principal Conductors of Leading Orchestras"),

  sidebarLayout(

    sidebarPanel(
      
      # Select box
      # selectInput("selectOrchestra", label = h4("Select orchestra"),
      #             choices = orchestras,
      #             selected = "Royal Concertgebouw Orchestra"),
      
      #Multiple selections
      #orchestras <- c("Royal Concertgebouw Orchestra"),
      checkboxGroupInput("selectOrchestra", label = h4("Orchestras"),
                         choices = orchestras,
                         selected = "Royal Concertgebouw Orchestra"),
      
      ## Range of dates
      #dateRangeInput(inputId = "dates", label = h4("Date range"),
      #               start = "1882-01-01", end="2021-12-31"),
      
      # Slider for dates
      sliderInput("dates", label = h4("Date Range"), 
                  min = 1500, max = 2100, value = c(1850, 2035)
                  ),
      
      ## Conductor names
      radioButtons("radio", label = h3("Conductor names:"),
                   choices = list("Show full name" = FALSE, "Show last name" = TRUE), 
                   selected = FALSE),
      
    ),

    mainPanel(
      textOutput("selected_var"),
      
      plotOutput(outputId = "timeline_plot", height="700px"),
    )
  )
)
