install.packages("magick")
library(magick)
library(MetBrewer)
library(colorspace)

colors <- met.brewer("OKeeffe2")
swatchplot(colors)

img <- image_read("renders/final_plot.png")
img |> 
  image_crop(gravity = "center",
             geometry = "2700x3000") |> 
  image_annotate("Illinois Population Density",
                 gravity = "northwest",
                 location = "+100+50",
                 color = "#023047",
                 size = 175,
                 font = "Impact") |> 
  image_annotate("Population estimates are grouped into 400-meter hexagons",
                 gravity = "northwest",
                 location = "+100+250",
                 color = "#023047",
                 size = 70,
                 font = "Impact") |> 
  image_annotate("Graphic: Justin Le\nProjection: EPSG:3857\nData: Kontur Population (2023-11-01)",
                 gravity = "southwest",
                 location = "+100+50",
                 color = "#023047",
                 size = 60,
                 font = "Impact") |> 
  image_write("renders/annotated_final.png")
