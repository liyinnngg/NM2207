library(shiny)
library(tidyverse)
# Define UI for dataset viewer app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Observations"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Select a dataset ----
      selectInput("dataset", "Choose a dataset:",
                  choices = c("rock", "pressure", "cars")),
      
      # Input: Specify the number of observations to view ----
      numericInput("obs", "Number of observations to view:", 20),
      
      # Include clarifying text ----
      helpText("Note: while the data view will show only the specified",
               "number of observations, the summary will still be based",
               "on the full dataset."),
      
      # Input: actionButton() to defer the rendering of output ----
      # until the user explicitly clicks the button (rather than
      # doing it immediately when inputs change). This is useful if
      # the computations required to render output are inordinately
      # time-consuming.
      actionButton("update", "Update View"),
      
      #image insertion
      img(src = "rocks.jpg", height = 200, width = 300)
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Header + summary of distribution ----
      h4("Summary"),
      verbatimTextOutput("summary"),
      
      # Output: Header + table of distribution ----
      h4("Observations"),
      tableOutput("view"),
      
      plotOutput(outputId="plot_rock"),
      plotOutput(outputId="plot_area"),
      plotOutput(outputId="plot_peri"),
      plotOutput(outputId="plot_shape"),
      plotOutput(outputId="plot_perm")
    )
  )
)

# Define server logic to summarize and view selected dataset ----
server <- function(input, output) {
  
  # Return the requested dataset ----
  # Note that we use eventReactive() here, which depends on
  # input$update (the action button), so that the output is only
  # updated when the user clicks the button
  datasetInput <- eventReactive(input$update, {
    switch(input$dataset,
           "rock" = rock,
           "pressure" = pressure,
           "cars" = cars)
  }, ignoreNULL = FALSE)
  
  # Generate a summary of the dataset ----
  output$summary <- renderPrint({
    dataset <- datasetInput()
    summary(dataset)
  })
  
  # Show the first "n" observations ----
  # The use of isolate() is necessary because we don't want the table
  # to update whenever input$obs changes (only when the user clicks
  # the action button)
  output$view <- renderTable({
    head(datasetInput(), n = isolate(input$obs))
  })
  
  # Plot graph of area against perimeter for rock
  output$plot_rock <- renderPlot({
    inputdataset <- datasetInput()
    ggplot(inputdataset) +
    aes(x=area,y=peri) +
    geom_point()})
  
  # Plot boxplot for area
  output$plot_area <- renderPlot({
    req(datasetInput())
    inputdataset <- datasetInput()
    ggplot(inputdataset) +
      aes(x=area) +
      geom_boxplot()})
  
  # Plot boxplot for peri
  output$plot_peri <- renderPlot({
    req(datasetInput())
    inputdataset <- datasetInput()
    ggplot(inputdataset) +
      aes(x=peri) +
      geom_boxplot()})
  
  # Plot boxplot for shape
  output$plot_shape <- renderPlot({
    req(datasetInput())
    inputdataset <- datasetInput()
    ggplot(inputdataset) +
      aes(x=shape) +
      geom_boxplot()})
  
  # Plot boxplot for perm
  output$plot_perm <- renderPlot({
    req(datasetInput())
    inputdataset <- datasetInput()
    ggplot(inputdataset) +
      aes(x=perm) +
      geom_boxplot()})
  
}

# Create Shiny app ----
shinyApp(ui, server)


