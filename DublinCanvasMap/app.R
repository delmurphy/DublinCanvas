
library(shiny)
library(bslib)
library(leaflet)

# Define UI for application that draws a histogram
ui <- fluidPage(

    leafletOutput("map")
)

# Define server logic required to draw a histogram
server <- function(input, output) {

   output$map <- renderLeaflet({
     leaflet() |> 
       addTiles() |> 
       setView(-6.2603, 53.3498, zoom = 15)
   })
}

# Run the application 
shinyApp(ui = ui, server = server)
