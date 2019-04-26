
# Load necessary libraries

library(gganimate)
library(ggthemes)
library(sf)
library(tigris)
library(tidyverse)


# Read in the ShotSpotter data for Washington, D.C. directly from the link
# address housed within Justice Tech Lab's website, reading in the variable
# "type" as a factor (not doing so will return all NA values, as "type" gets
# read in as a logical otherwise); store in a new dataset called
# "washington_dc_new_years_data"

washington_dc_new_years_data <- read_csv(url("http://justicetechlab.org/wp-content/uploads/2018/05/washington_dc_2006to2017.csv"), 
                                         col_types = cols(type = col_factor())) %>% 
  
  # Add leading zeros to the single-digit values of "month" (1, 2, etc.) so that
  # every value of "month" is two characters long ("12, "01", etc.); do the same
  # for "day" and "hour"
  
  mutate(month = str_pad(month, 2, side = "left", pad = "0"), 
         day = str_pad(day, 2, side = "left", pad = "0"), 
         hour = str_pad(hour, 2, side = "left", pad = "0")) %>% 
  
  # Create a new variable called "date" by pasting together the values of
  # "year", "month", and "day" separated by a hyphen (like "2015-01-01")
  
  mutate(date = paste(year, month, day, sep = "-")) %>% 
  
  # Create a new variable called "date_hour" by pasting together the values of
  # "date" and "hour", separated by " Hour " (like "2015-01-01 Hour 00")
  
  mutate(date_hour = paste(date, hour, sep = " Hour ")) %>% 
  
  # Filter the data to keep only observations where "date" is either
  # "2014-12-31" or "2015-01-01"; I choose the span of these two days, as
  # fireworks celebrations typically happen on the midnight of New Year's Eve,
  # bleeding into New Year's Day
  
  filter(date %in% c("2014-12-31", "2015-01-01")) %>% 
  
  # Modify the variable "type", removing the underscores from each level (so
  # that "Single_Gunshot" reads "Single Gunshot", for example) so that the
  # legend in the animation has clean, English levels
  
  mutate(type = case_when(type == "Single_Gunshot" ~ "Single Gunshot", 
                          type == "Multiple_Gunshots" ~ "Multiple Gunshots", 
                          type == "Gunshot_or_Firecracker" ~ "Gunshot or Firecracker")) %>% 
  
  # Reorder the levels of the variable "type" so that the levels appear in a
  # logical way, with "Single Gunshot" being followed by "Multiple Gunshots",
  # which is then followed by "Gunshot or Firecracker", a different sort of
  # level altogether
  
  mutate(type = fct_relevel(type, c("Single Gunshot", 
                                    "Multiple Gunshots", 
                                    "Gunshot or Firecracker")))


# Using the "places" function from the "tigris" package, grab the Washington,
# D.C. shapefile and assign it to "washington_dc_shape"

washington_dc_shape <- places(state = "DC", class = "sf")


# Use "st_as_sf" to turn the "washington_dc_new_years_data" dataset into the
# proper format to be used by geom_sf, specifying which column refers to
# longitude and which column refers to latitude and ensuring that the coordinate
# reference system matches that of "washington_dc_shape"; store as
# "washington_dc_new_years_locations"

washington_dc_new_years_locations <- st_as_sf(washington_dc_new_years_data, 
                                              coords = c("longitude", "latitude"), 
                                              crs = st_crs(washington_dc_shape))


# Create a ggplot animation using the "washington_dc_shape" data; store as
# "washington_dc_new_years_animation" in order to be able to save the animation
# as a gif below

washington_dc_new_years_animation <- ggplot(data = washington_dc_shape) + 
  
  # Apply "geom_sf" to the "washington_dc_shape" data so that Washington, D.C.
  # is properly displayed in the animation
  
  geom_sf() + 
  
  # Call "geom_sf" on the "washington_dc_new_years_locations" dataset so that
  # the locations of shots appear as points on the map; color by the variable
  # "type" so that "Single Gunshot", "Multiple Gunshots", and "Gunshot or
  # Firecracker" shots appear in different colors; set the legend to "point" to
  # reflect the points on the animation more accurately (to match them)
  
  geom_sf(data = washington_dc_new_years_locations, aes(color = type), 
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
  
  # Apply the brewer color scale to the animation, using the qualitative palette
  # "Paired" so that, fortunately, "Single Gunshot" and "Multiple Gunshot"
  # appear as different shades of blue ("Multiple Gunshots" naturally appearing
  # as the darker shade of blue), with "Gunshot or Firecracker", slightly
  # different, appearing as green
  
  scale_color_brewer(palette = "Paired") + 
  
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
  
  labs(title = "Locations and Types of Shots (Gunshots and Firecrackers)\nin Washington, D.C. on: {closest_state}", 
       subtitle = "On the midnight of New Year's Eve, the beginning of the new year,\nthere is a dramatic spike in the number of gunshots and firecrackers", 
       caption = "Source: Justice Tech Lab, ShotSpotter Data", 
       color = "Type of Shot") + 
  
  # Use the "transition_states" function to create an animation that updates by
  # "date_hour" to show the locations and types of shots in Washington, D.C. per
  # hour on the days 2014-12-31 to 2015-01-01
  
  transition_states(date_hour)


# Save the animation "washington_dc_new_years_animation" as a gif, called
# "washington_dc_new_years_animation.gif" in the folder
# "shotspotter_washington_dc_app"

anim_save("shotspotter_washington_dc_app/washington_dc_new_years_animation.gif", animate(washington_dc_new_years_animation))
