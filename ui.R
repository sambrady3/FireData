library(shiny)
library(leaflet)

shinyUI(navbarPage("Albemarle County Fire Data",
        tabPanel("Map",
                 titlePanel("Mapping Fire Station Calls"),
                 p("It may seem counterintuitive, but only a small percentage of calls
                   that a fire station receives are actually for fires. This map
                   allows you to plot calls received by fire stations in Albemarle County,
                   Virginia, and filter by which type of call you're interested in."),
                 sidebarLayout(position = "right",
                               sidebarPanel(
                                       radioButtons(inputId = "dateButtons",
                                                    label = "Date Type",
                                                    choices = c("Single Date" = "single", 
                                                                "Date Range" = "range"),
                                                    inline = TRUE),
                                       conditionalPanel(condition = "input.dateButtons == 'single'",
                                                        dateInput(inputId = "singleDate",
                                                                  label = "Date",
                                                                  value = "2013-08-31",
                                                                  max = "2013-09-28")),
                                       conditionalPanel(condition = "input.dateButtons == 'range'",
                                                        dateRangeInput(inputId = "dateRange", 
                                                                       label ="Date Range", 
                                                                       end = "2013-09-28", 
                                                                       start = "2013-09-26", 
                                                                       max="2013-09-28")),
                                       
                                       checkboxGroupInput(inputId = "cat", 
                                                          label = "Pick a category",
                                                          choices = as.character(uniquecat),
                                                          selected = as.character(uniquecat))
                                       ),
                               
                               mainPanel(fluidRow(
                                       column(8,
                                       conditionalPanel(condition = "input.dateButtons == 'range'",
                                                        leafletOutput("map_range")),
                                       conditionalPanel(condition = "input.dateButtons == 'single'",
                                                        leafletOutput("map_single"))),
                                       column(3,
                                       img(src='map_legend.png',align='left'))
                        
                               )))),
        tabPanel("Plots",
                 titlePanel("Average Number of Calls per Shift"),
                 p("My brother is a volunteer firefighter in Albemarle County, VA,
                   and wanted to know if certain shifts during the week got more
                   calls than others. Each day is divided into two 12-hour 
                   shifts: 6am-6pm (the day shift), and 6pm-6am (the night shift).
                   It's clear from the data that day shifts are significantly more busy,
                   averaging about 6 more calls than night shifts. The other interesting
                   feature of the data (though perhaps not surprising) is that weekend
                   nights are busier than weeknights, and weekend days are less busy
                   than weekdays."),
                 sidebarLayout(position = "right",
                         sidebarPanel(
                                 checkboxGroupInput(inputId = "barcat", 
                                                            label = "Pick a category",
                                                            choices = as.character(uniquecat),
                                                            selected = as.character(uniquecat))),
                         mainPanel(
                                 plotOutput("shiftFreq", height="400px"))
                 ))
        
        ))
