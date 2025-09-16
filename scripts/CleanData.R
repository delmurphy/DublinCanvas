#Cleaning the DublinCanvas data for shiny app
library(here)


#read in data
df = read.csv(here("data/raw/dublin-canvas-locations-december-2021.csv"),  encoding="latin1")

# Tidy the data -----------------------------------------------------------

#remove empty columns 10-22
df = df[,1:9]
#rename columns
names(df) = c("council", "lat", "long", "artist", "title", "location", "year", "url", "img")
#remove NAs
df = df[!is.na(df$lat),]
#remove apostrophe rom end of titles
df$title = substr(df$title, 1, nchar(df$title)-1)

#some of the artworks seem to be gone (with date ranges in the year column, e.g. "2015 - 2018")
#add a column to filter for canvases that are no longer around, and another year column to give just the year of creation
df$yearrange = df$year
df$year = as.numeric(substr(df$yearrange, 1, 4))
df$historic = ifelse(as.character(df$year)==df$yearrange, 0, 1)

write.csv(df, here("data/cleaned/dublin_canvas_clean.csv"))