
library(shiny)
library(bslib)
library(leaflet)
library(here)

#read in data
df = read.csv(here("data/cleaned/dublin_canvas_clean.csv"))

#get map marker icon from awesome font
brush = makeIcon(
  here("www/paintbrush-solid-full-blue.png"),
  iconWidth = 38, iconHeight = 38)


# UI -----------------------------------------------------------

# Define UI
ui <- bootstrapPage(
  
  tags$style(HTML("
/* Full-page map */
html, body {width:100%; height:100%; margin:0; padding:0;}

/* Controls panel */
.controls-panel {
  background-color: rgba(255, 255, 255, 0.6); /* white with 60% opacity */
  padding: 10px;
  border-radius: 8px;
  box-shadow: 0 0 15px rgba(0,0,0,0.3);
}

/* Inputs inside panel */
.controls-panel .form-group {
  margin-bottom: 10px;
}

/* Marker clusters: outer and inner circles */
/* Outer circle */
.marker-cluster {
  background-color: rgba(31, 119, 180, 0.6) !important; /* blue3 */
  border: 2px solid rgba(31, 119, 180, 0.6) !important;
  border-radius: 50% !important;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Inner circle */
.marker-cluster div {
  background-color: #1f77b4 !important; /* solid blue inner */
  border: 2px solid #1f77b4 !important;
  border-radius: 50% !important;
  margin: auto !important;
}

/* Cluster number text */
.marker-cluster span {
  color: white !important; font-weight: bold;
}
")),
    
  #title
  titlePanel("Dublin Canvas locations"),
    
  #map
  leafletOutput("map", width = "100%", height = "100%"),
  
  #sidebar
  absolutePanel(top = 100, right = 10, class = "controls-panel",
    title = "Search for Canvases",
    
    textInput("search", "Search for an artist or artwork", value = ""), 
    
    checkboxInput("historic", "Include historic (no longer existing) canvases", value = TRUE),
    
    p(br()),
    actionButton("reset", "Reset zoom", icon("expand")),
    
    p(class = "text-muted",
      br(),
      "For more information visit", a("Dublin Canvas", href = "https://www.dublincanvas.com", target = "_blank")
      )
  )
)





# Server -----------------------------------------------------------

# Define server logic 
server <- function(input, output) {
  
  # filtered data based on checkbox
  filteredData <- reactive({
    # if(input$historic){
    #   df
    # }
    # else{
    #   df[df$historic==0,]
    # }
    df[
      df$historic <= as.numeric(input$historic) &
      (grepl(input$search, df$artist, ignore.case = TRUE)|
         grepl(input$search, df$title, ignore.case = TRUE))
    ,]
  })

  # Base map
   output$map <- renderLeaflet({
     # Use leaflet() here, and only include aspects of the map that
     # won't need to change dynamically (at least, not unless the
     # entire map is being torn down and recreated).
     leaflet() |> 
       #add base tiled map
       addTiles() |> 
       #set view and zoom
       setView(-6.2603, 53.3498, zoom = 10)
   })
   
  #add/updated markers dynamically (include historic artworks)
   observe({
     leafletProxy("map", data = filteredData()) |>
       #clear the markers from the map
       clearMarkers() |>
       clearMarkerClusters() |>
       #add location markers for artworks with hover-over label
       addMarkers(~long, ~lat, 
                  icon = brush,
                  label = ~paste(title, "by", artist, yearrange),
                  #make markers clickable to take you to URL with more info
                  popup = ~paste("<a href='", url, "'target='_blank'>",
                                  "<img src='", img, "'width='200px'>",
                                  "</a><br>", title, " by", artist, yearrange),
                  #cluster the locations that are close together
                  clusterOptions = markerClusterOptions(
                    maxClusterRadius = 40  # smaller clusters form only if markers are very close
                  )
       )
   })
   
   # Reset to original view
   observeEvent(input$reset, {
     leafletProxy("map") |>
       setView(lng = -6.2603, lat = 53.3498, zoom = 10)
   })
   
   # Reset to original view when searching
   observeEvent(input$search, {
     leafletProxy("map") |>
       setView(lng = -6.2603, lat = 53.3498, zoom = 10)
   })

}




# Run the application 
shinyApp(ui = ui, server = server)
