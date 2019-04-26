
# Load necessary libraries

library(shinythemes)
library(shiny)


# Define the UI for "Visualizing ShotSpotter Data in Washington, D.C." app

ui <- fluidPage(
  
  # Apply the shinytheme "united" to the app
  
  theme = shinytheme("united"), 
  
  # Set up the navigation bar, titling the app "Visualizing ShotSpotter Data in
  # Washington, D.C."
  
  navbarPage(
    "Visualizing ShotSpotter Data in Washington, D.C.", 
    
    # Set up the first tab, titled "About"
    
    tabPanel(
      "About", 
      
      # Set up the page corresponding to the "About" tab
      
      mainPanel(
        
        # Add the first header, "Explore the App:"
        
        h3("Explore the App:"), 
        
        # Add the text corresponding to (and to appear below) the "Explore the
        # App:" header
        
        p("Welcome!  This app explores Justice Tech Lab's ShotSpotter data for Washington, District of Columbia.  Above, there are three tabs for you to explore: this tab, the Yearly Trends tab, and the Holidays 2014-2015 tab.  In the Yearly Trends tab, you will find an animation showing the locations and numbers of shots, either gunshots (single or multiple) or firecrackers, in Washington D.C. per month in the years 2012 to 2015.  You will also find a supplementary graphic.  In the Holidays 2014-2015 tab, you will have the opportunity to select which holiday (the Fourth of July in 2014 or New Year's in 2015) you want to explore.  The default selection is the Fourth of July, which provides you with an animation of July 4th, 2014 to July 5th, 2014, showing the locations and types of shots (single gunshot, multiple gunshots, or gunshot or firecracker) in Washington, D.C. per hour.  Select New Year's, and you will see an animation of December 31st, 2014 to January 1st, 2015, showing the locations and types of shots (again single gunshot, multiple gunshots, or gunshot or firecracker) in Washington, D.C. per hour."), 
        
        # Add the second header, "Acknowledgements:"
        
        h3("Acknowledgements:"), 
        
        # Add the text corresponding to (and to appear below) the
        # "Acknowledgements:" header
        
        p("Thank you to Justice Tech Lab.  This app could not have been made without Justice Tech Lab's generous provision of their ShotSpotter data.  As I used their data for my own research, per Justice Tech Lab's request, I am citing the following papers:"), 
        
        # Add new paragraphs so that each source is given its due space and
        # easily found, not lumped in and hidden among the thanks
        
        p('1. Carr, Jillian B., and Jennifer L. Doleac. 2018. "Keep the Kids Inside? Juvenile Curfews and Urban Gun Violence."  Review of Economics and Statistics, 100(4): 609-618.'), 
        p('2. Carr, Jillian B., and Jennifer L. Doleac. 2016. "The geography, incidence, and underreporting of gun violence: new evidence using ShotSpotter data." Brookings Research Paper.'), 
        
        # Add a new paragraph so that the link to the ShotSpotter data is given
        # its due space and easily found, not lumped in and hidden among the
        # thanks and citations
        
        p(
          "To explore more ShotSpotter data, the full collection can be found ",
          a("here.", href = "http://justicetechlab.org/shotspotter-data/")
        ), 
        
        # Add the third header, "Source Code:"
        
        h3("Source Code:"), 
        
        # Add the text corresponding to (and to appear below) the "Source Code:"
        # header, including a link to my GitHub repository for this app as well
        # as a credit to myself for making this app
        
        p(
          "To learn how I created this app, my GitHub repository is linked ",
          a("here.", href = "https://github.com/cvendler/shotspotter-washington-dc")
        ), 
        br(), 
        p("By Céline Vendler")
      )
    ), 
    
    # Set up the second tab, titled "Yearly Trends"
    
    tabPanel(
      "Yearly Trends",
      
      # Set up the page corresponding to the "Yearly Trends" tab, beginning with
      # setting up the sidebar
      
      sidebarLayout(
        
        # Set up the sidebar to include help text about the data, the animation,
        # and how to troubleshoot viewing problems
        
        sidebarPanel(
          
          # Add a note clarifying what data points the animation includes
          
          p(helpText("Note: The shots in years 2012 and 2013 do not have specified types (single gunshot, multiple gunshot, gunshot or firecracker), but, at least for years 2014 and 2015, all types of shots are included in this animation.")),
          
          # Add a note explaining my inclusion of Kyle Walker's graphic and
          # offering additional insights about the animation
          
          p(helpText(
            "Note also the consistency in where shots occur throughout Washington, D.C. from month to month and year to year.  On the right of the animation is a graphic created by Kyle Walker (find it ", 
            a("here", href = "https://walkerke.github.io/tigris-webinar/#29"), 
            '), author and maintainer of the "tigris" package, illustrating Washington, D.C.\'s income inequality.  I have placed my animation and this graphic side-by-side, as shot-location and income seem to be related, with shots tending to occur in low-income areas.  The White House is labeled to provide a point of geographic reference.')
          ), 
          
          # Add a tip for optimal viewing of the page
          
          p(helpText("Tip: If the animation and the graphic are overlapping, expand your screen."))
        ),
        
        # Set up the main section of the page
        
        mainPanel(
          
          # Thanks to
          # https://stackoverflow.com/questions/34384907/how-can-put-multiple-plots-side-by-side-in-shiny-r
          # for teaching me how to place images side-by-side on a shiny page
          
          # Add a fluid row in which to place my animation and Kyle Walker's
          # graphic
          
          fluidRow(
            
            # Divide the row into two equal parts, the left part containing my
            # animation ("Yearly_Map") and the right part containing Kyle
            # Walker's graphic ("Income_Map")
            
            splitLayout(
              imageOutput("Yearly_Map"), 
              imageOutput("Income_Map")
            )
          )
        )
      )
    ),
    
    # Set up the third and final tab, titled "Holidays 2014-2015"
    
    tabPanel(
      "Holidays 2014-2015",
      
      # Set up the page corresponding to the "Holidays 2014-2015" tab, beginning
      # with setting up the sidebar
      
      sidebarLayout(
        
        # Set up the sidebar to include a drop-down menu, which the user can use
        # to select a holiday, either the Fourth of July in 2014 or New Year's
        # in 2015, as well as help text; I choose these dates, as 2014 and 2015
        # are the most recent dates I use in my app (in my "Yearly Trends"
        # animation, I use data from 2012 to 2015)
        
        sidebarPanel(
          
          # Add the drop-down menu, assigning the input to "Holiday" in order to
          # be able to perform the if else statement below and prompting the
          # user with the text "Select a holiday:" directly above the menu
          
          selectInput("Holiday", "Select a holiday:",
                      
                      # List the choices, assigning them the values "Fourth" and
                      # "New_Years", respectively
                      
                      choices = c(
                        "Fourth of July, 2014" = "Fourth",
                        "New Year's, 2015" = "New_Years"
                      )
          ), 
          
          # Add help text to the sidebar below the drop-down menu, explaining
          # why the Fourth of July in 2014 and New Year's in 2015 are the
          # choices available
          
          p(helpText('These holidays are significant because their celebration typically involves the use of firecrackers, the sounds of which are included in this data.  I choose to use the Fourth of July in 2014 and New Year\'s in 2015 as examples of this phenomenon, as 2014 and 2015 are the most recent dates I use in my app (in my "Yearly Trends" animation, I use data from 2012 to 2015).'))
        ), 
        
        # Set up the main section of the page to include the appropriate
        # animation given the user's input ("Holiday_Map")
        
        mainPanel(imageOutput("Holiday_Map"))
      )
    )
  )
)


# Define the server for the app

server <- function(input, output) {
  
  # Render the image "Yearly_Map" called by imageOutput("Yearly_Map") earlier
  
  output$Yearly_Map <- renderImage({
    
    # Return a list, containing the filename, the file type, and its alignment
    # on the page, which will then be used to render the image housed within
    # "washington_dc_animation.gif"
    
    list(
      src = "washington_dc_animation.gif", 
      contentType = "image/gif", 
      align = "left"
    )
  }, 
  
  # Override the default setting of "deleteFile" so that
  # "washington_dc_animation.gif" is not deleted
  
  deleteFile = FALSE
  )
  
  # Render the image "Income_Map" called by imageOutput("Income_Map") earlier
  
  output$Income_Map <- renderImage({
    
    # Return a list, containing the filename, the file type, and its alignment
    # on the page, which will then be used to render the image housed within
    # "washington_dc_income_inequality.png"
    
    list(
      src = "washington_dc_income_inequality.png", 
      contentType = "image/png", 
      align = "left"
    )
  }, 
  
  # Override the default setting of "deleteFile" so that
  # "washington_dc_income_inequality.png" is not deleted
  
  deleteFile = FALSE
  )
  
  # Create the function "get_holiday_animation", which reactively outputs the
  # filename for the animation selected by the user in the drop-down menu of the
  # "Holidays 2014-2015" tab
  
  get_holiday_animation <- reactive({
    
    # Require that there be a "Holiday" selection in order to return a filename
    
    req(input$Holiday)
    
    # If the "Holiday" input is equal to "Fourth", then return the filename for
    # the Fourth of July animation, "washington_dc_july_4th_animation.gif"
    
    if (input$Holiday == "Fourth") {
      get_holiday_animation <- "washington_dc_july_4th_animation.gif"
    }
    
    # Else (effectively, if the "Holiday" input is equal to "New_Years"), return
    # the filename for the New Year's animation,
    # "washington_dc_new_years_animation.gif"
    
    else {
      get_holiday_animation <- "washington_dc_new_years_animation.gif"
    }
  })
  
  # Render the image "Holiday_Map" called by imageOutput("Holiday_Map") earlier
  
  output$Holiday_Map <- renderImage({
    
    # Return a list, containing the appropriate filename, returned by the
    # function "get_holiday_animation" based on the "Holiday" selection, and
    # file type, which will then be used to render the appropriate image
    
    list(
      src = get_holiday_animation(), 
      contentType = "image/gif"
    )
  }, 
  
  # Override the default setting of "deleteFile" so that the file returned is not
  # deleted
  
  deleteFile = FALSE
  )
}


# Create shiny app

shinyApp(ui = ui, server = server)
