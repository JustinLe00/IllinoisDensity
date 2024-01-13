install.packages("sf")
install.packages("tigris")
install.packages("tidyverse")
install.packages("stars")
install.packages("units")
install.packages("remotes")
install.packages("MetBrewer")
remotes::install_github("https://github.com/tylermorganwall/rayrender")
remotes::install_github("https://github.com/tylermorganwall/rayshader")
library(sf)
library(remotes)
library(tigris)
library(tidyverse)
library(stars)
library(units)
library(rayrender)
library(rayshader)
library(MetBrewer)
library(colorspace)

data <- st_read("data/kontur_population_US_20231101.gpkg")

st <- states()

illinois <- st |>
  filter(NAME == "Illinois") |>
  st_transform(crs = st_crs(data))

illinois |>
  ggplot() +
  geom_sf()

st_illinois <- st_intersection(data, illinois)

bb <- st_bbox(st_illinois)

bottom_left <- st_point(c(bb[["xmin"]], bb[["ymin"]])) |> 
  st_sfc(crs = st_crs(data))

bottom_right <- st_point(c(bb[["xmax"]], bb[["ymin"]])) |> 
  st_sfc(crs = st_crs(data))

illinois |> 
  ggplot() +
  geom_sf() +
  geom_sf(data = bottom_left) +
  geom_sf(data = bottom_right, color = "red")

width <- st_distance(bottom_left, bottom_right)

top_left <- st_point(c(bb[["xmin"]], bb[["ymax"]])) |> 
  st_sfc(crs = st_crs(data))

height <- st_distance(bottom_left, top_left)

if (width > height) {
  w_ratio <- 1
  h_ratio <- height / width
} else {
  h_ratio <- 1
  w_ratio <- width / height
}

con

hsize <- 5000
wsize <- 2790

illinois_rast <- st_rasterize(st_illinois,
                              nx = wsize,
                              ny = hsize)


mat <- matrix(illinois_rast$population,
              nrow = wsize,
              ncol = hsize)

c1 <- met.brewer("Cassatt1")
swatchplot(c1)

c2 <- met.brewer("OKeeffe2")

texture <- grDevices::colorRampPalette(c("#219ebc", "#023047", "#fb8500", "#ffb703"), bias = 1.2)(256)
swatchplot(texture)

rgl::close3d()

mat |> 
  height_shade(texture) |> 
  plot_3d(heightmap = mat,
          zscale = 100/5,
          solid = FALSE,
          shadowdepth = 0)

render_camera(theta = -20,
              phi = 25,
              zoom = 0.6)

outfile <- "renders/final_plot.png"

{
  start_time <- Sys.time()
  cat(crayon::cyan(start_time), "\n")
  render_highquality(
    filename = "renders/final_plot.png",
    interactive = FALSE,
    lightdirection = 280,
    lightaltitude = c(20, 80),
    lightcolor = c(c2[2], "white"),
    lightintensity = c(600, 100),
    samples = 300,
    width = 3000,
    height = 3000
  )
  end_time <- Sys.time()
  diff <- end_time - start_time
  cat(crayon::cyan(diff), "\n")
}
