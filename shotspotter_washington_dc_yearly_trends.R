
# Load necessary libraries

library(zoo)
library(gganimate)
library(ggthemes)
library(sf)
library(tigris)
library(tidyverse)


# Read in the ShotSpotter data for Washington, D.C. directly from the link
# address housed within Justice Tech Lab's website, reading in the variable
# "type" as a factor (not doing so will return all NA values, as "type" gets
# read in as a logical otherwise); store in a new dataset called
# "washington_dc_data"

washington_dc_data <- read_csv(url("http://justicetechlab.org/wp-content/uploads/2018/05/washington_dc_2006to2017.csv"), 
                               col_types = cols(type = col_factor())) %>% 
  
  # Filter the data to include only observations where the value of "numshots"
  # is not NA, where the value of "numshots" is greater than 0, and where the
  # value of year is greater than or equal to 2012 and less than or equal to
  # 2015; I choose to examine these years, as they are relatively recent and as
  # examining all the years is not reasonably feasible
  
  filter(!is.na(numshots), 
         numshots > 0, 
         year >= 2012 & year <= 2015) %>% 
  
  # Modify the variable "numshots", making all values of "numshots" equal to 1
  # now equal to "1", making all values of "numshots" greater than or equal to 2
  # and less than or equal to 9 now equal to "2 to 9", making all values of
  # "numshots" greater than or equal to 10 and less than or equal to 19 now
  # equal to "10 to 19", and making all values of "numshots" greater than or
  # equal to 20 now equal to "20 and greater" in order to be able to represent
  # numbers of shots easily and clearly in my animation; I chose to divide
  # "numshots" up in this way by examining the data and determining what was
  # appropriate; it made sense to create one value for "1", one value for single
  # digit values of  "numshots" greater than 1, one value for values of
# "numshots" in the tens and teens, and one value for all values of "numshots"
# greater than 20, as there were a few outliers beyond but not a significant
# number

mutate(numshots = case_when(numshots == 1 ~ "1", 
                            numshots >= 2 & numshots <= 9 ~ "2 to 9", 
                            numshots >= 10 & numshots <= 19 ~ "10 to 19", 
                            numshots >= 20 ~ "20 and greater")) %>% 
  
  # Reorder the levels of the factor "numshots" so that the levels appear in
  # increasing order of "numshots" ("1", "2 to 9", etc.)
  
  mutate(numshots = fct_relevel(numshots, c("1", 
                                            "2 to 9", 
                                            "10 to 19", 
                                            "20 and greater"))) %>% 
  
  # Add leading zeros to the single-digit values of "month" (1, 2, etc.) so that
  # every value of "month" is two characters long ("12, "01", etc.)
  
  mutate(month = str_pad(month, 2, side = "left", pad = "0")) %>% 
  
  # Create a new variable called "date" by pasting together the values of "year"
  # and "month" separated by a hyphen (like "2014-07")
  
  mutate(date = paste(year, month, sep = "-"))


# Using the "places" function from the "tigris" package, grab the Washington,
# D.C. shapefile and assign it to "washington_dc_shape"

washington_dc_shape <- places(state = "DC", class = "sf")


# Use "st_as_sf" to turn the "washington_dc_data" dataset into the proper format
# to be used by geom_sf, specifying which column refers to longitude and which
# column refers to latitude and ensuring that the coordinate reference system
# matches that of "washington_dc_shape"; store as "washington_dc_shot_locations"

washington_dc_shot_locations <- st_as_sf(washington_dc_data, 
                                         coords = c("longitude", "latitude"), 
                                         crs = st_crs(washington_dc_shape))


# Create a ggplot animation using the "washington_dc_shape" data; store as
# "washington_dc_animation" in order to be able to save the animation as a gif
# below

washington_dc_animation <- ggplot(data = washington_dc_shape) + 
  
  # Apply "geom_sf" to the "washington_dc_shape" data so that Washington, D.C. is
  # properly displayed in the animation
  
  geom_sf() + 
  
  # Call "geom_sf" on the "washington_dc_shot_locations" dataset so that the
  # locations of shots appear as points on the map; color by the variable
  # "numshots" so that "1", "2 to 9", "10 to 19", and "20 and greater" shots
  # appear in different colors; set the legend to "point" to reflect the points
  # on the animation more accurately (to match them)
  
  geom_sf(data = washington_dc_shot_locations, aes(color = numshots), 
          show.legend = "point") + 
  
  # Add a fixed point to the animation, setting its x-position to -77.0365 and
  # its y-position to 38.8977--the longitude and latitude of The White House,
  # respectively--so that it appears where The White House would appear on the
  # map; set the shape to 8 so that it appears as an asterisk-like point,
  # differentiating it from the shot locations points; I add this White House
  # point as a point of geographic reference
  
  geom_point(x = -77.0365, y = 38.8977, shape = 8) + 
  
  # Add a fixed line segment to the animation, setting its x- and y-position to
  # the same White House coordinates as above so that the line segment begins at
  # the point, setting its "xend" to -77.08 so that the line segment extends to
  # the left beyond the borders of the map (doing so will help make the map less
  # crowded, as the annotation below will appear outside the borders of the map,
  # connected to the point it labels by this line segment), and setting its
  # "yend" equal to the y-positions above so that the line segment is level with
  # the White House point; make the line segment a dashed line and remove the
  # legend from view
  
geom_segment(aes(x = -77.0365, y = 38.8977, xend = -77.08, yend = 38.8977), 
             linetype = "dashed", show.legend = FALSE) + 
  
  # Add a fixed annotation to the animation, setting its x-position to -77.095
  # so that it appears to the left of the line segment, setting its y-position
  # equal to the y-positions above so that the text is level with the line
  # segment and the White House point, making the annotation read "The White
  # House", and setting the size of the annotation to 2.5
  
  annotate(geom = "text", x = -77.095, y = 38.8977, 
           label = "The White House", size = 2.5) + 
  
  # Apply the brewer color scale to the animation, using the sequential palette
  # "YlOrRd", the colors darkening from yellow to red as "numshots" increases
  # (from "1" to "2 to 9" etc.)
  
  scale_color_brewer(palette = "YlOrRd") + 
  
  # Use "theme_map", as Kieran Healy does, to get rid of the x- and y-axis ticks
  # and perform other actions to get rid of characterisitcs that would
  # unnecessarily complicate the animation
  
  theme_map() + 
  
  # Change the color of the grid in the background to white to match the actual
  # background and appear invisible, as Kieran Healy writes that such grids
  # "aren't really needed"
  
  theme(panel.grid = element_line(color = "white")) + 
  
  # Give the animation a title, subtitle, and caption; give the legend a new
  # title
  
  labs(title = "Locations and Numbers of Shots (Gunshots or Firecrackers)\nin Washington, D.C. on: {closest_state}", 
       subtitle = "Yearly spikes in the number of shots occur around January and July,\npotentially corresponding to New Year's and Fourth of July firecracker celebrations", 
       caption = "Source: Justice Tech Lab, ShotSpotter Data", 
       color = "Number of Shots") + 
  
  # Use the "transition_states" function to create an animation that updates by
  # "date" to show the locations and numbers of shots in Washington, D.C. per
  # month in the years 2012 to 2015
  
  transition_states(date)


# Save the animation "washington_dc_animation" as a gif, called
# "washington_dc_animation.gif" in the folder "shotspotter_washington_dc_app"

anim_save("shotspotter_washington_dc_app/washington_dc_animation.gif", animate(washington_dc_animation))
