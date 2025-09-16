#Downloading and converting map location icon from svg to png

library(rsvg)
library(here)

# 1. Make sure www/ exists in your app directory
if (!dir.exists(here("www"))) dir.create(here("www"))

# 2. Download FA v4.7 paint-brush SVG fontawesome (manually and save to www)
svg_file  <- "www/paintbrush-solid-full.svg"

# 3. Convert to PNG (32x32 px, adjust size if you want bigger icons)
png_file <- "www/paintbrush-solid-full.png"
rsvg_png(svg_file, file = png_file)

message("Saved PNG to: ", png_file)

#change colour of icon
library(magick)

img <- image_read("www/paintbrush-solid-full.png")
img_colored <- image_colorize(img, opacity = 100, color = "blue3")  # colorize whole image
image_write(img_colored, path = "www/paintbrush-solid-full-blue.png")