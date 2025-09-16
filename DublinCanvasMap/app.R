
library(shiny)
library(bslib)
library(leaflet)
library(here)

#read in data
df = read.csv(here("data/cleaned/dublin_canvas_clean.csv"))


# UI -----------------------------------------------------------

# Define UI
ui <- fluidPage(
    
    titlePanel("Dublin Canvas locations"),
    
    sidebar(selectInput(inputId = "y", label = "Y-axis:",
                            choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"),
                            selected = "audience_score")),

    leafletOutput("map", width = "100%", height = 700)
)




# Server -----------------------------------------------------------

# Define server logic 
server <- function(input, output) {

   output$map <- renderLeaflet({
     leaflet(data = df) |> 
       #add base tiled map
       addTiles() |> 
       #add location markers for artworks with hover-over label
       addMarkers(~long, ~lat, 
                  label = ~paste(title, "by", artist),
                  #make markers clickable to take you to URL with more info
                  popup = ~paste0("<a href='", url, "' target='_blank'>",
                                  "<img src='", img, "' width='200px'>",
                                  "</a><br>", title, " by ", artist)) |>
       #set view and zoom
       setView(-6.2603, 53.3498, zoom = 11)
   })
}

# Run the application 
shinyApp(ui = ui, server = server)
