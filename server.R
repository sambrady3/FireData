library(shiny)
library(leaflet)
library(dplyr)
library(ggthemes)

shinyServer(function(input, output, session) {
        output$map_range <- renderLeaflet({              
                leaflet() %>%
                addTiles() %>%
                addCircleMarkers(data = filter(stripped.df,
                                        dateNum <= as.numeric(input$dateRange[2]) &
                                        dateNum >= as.numeric(input$dateRange[1]) &
                                        Top_Category %in% input$cat),
                                        fillOpacity = 0.25,
                                        color =~pal(Top_Category),  
                                        fillColor = ~pal(Top_Category), 
                                        popup = ~sprintf("Type: %s<br>
                                                        Number of responders: %s<br>
                                                        %s", Top_Category,
                                                        numberofresponders,
                                                        AddressComposite)) 
                })
                output$map_single <- renderLeaflet({              
                        leaflet() %>%
                        addTiles() %>%
                        addCircleMarkers(data = 
                                        filter(stripped.df,
                                        dateNum == as.numeric(input$singleDate) &
                                                Top_Category %in% input$cat),
                                                fillOpacity = 0.25,
                                                color =~pal(Top_Category),  
                                                fillColor = ~pal(Top_Category), 
                                                popup = ~sprintf("Type: %s<br>
                                                                 Number of responders: %s<br>
                                                                 %s", Top_Category,
                                                                 numberofresponders,
                                                                 AddressComposite))
                })
                
                output$shiftFreq <- renderPlot({
                          tail(uniqueIncidents,20000) %>% 
                          filter(Top_Category %in% input$barcat) %>% 
                          group_by(shift, ShiftType) %>% 
                          summarise(count = n() / numberOfWeeks.stripped) %>%
                          ggplot(aes(x=shift,y=count,fill=ShiftType)) +
                          geom_bar(stat="identity") +
                          coord_flip() +
                          xlab(label = "Shift") +
                          ylab(label = "Average # of Calls") +
                          theme_economist() +
                          scale_fill_economist() +
                          theme(legend.title=element_blank())
                  })
})
                
        