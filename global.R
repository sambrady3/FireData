library(dplyr)
library(stringr)
library(ggplot2)
library(ggthemes)
library(ggvis)
library(leaflet)

df <- read.csv("datasets/FireData.csv", strip.white=TRUE)
df <- distinct(df)

# Function for returning last n-characters of a string
substrRight <- function(x, n){
        substr(x, nchar(x) - n + 1, nchar(x))
}

# Separate date and time into different columns
df  <- mutate(df, AlarmDateTime = as.character(AlarmDateTime))
df  <- mutate(df, AlarmTime = substrRight(AlarmDateTime, 5))
df$AlarmDate <- sub("(.*?) .*", "\\1",df$AlarmDateTime)
df$AlarmTime <- str_replace(df$AlarmTime, pattern = " ", replacement = "")
df$AlarmDateTime <- NULL

# methods to convert AlarmDate to format that R likes
addTrailingZero <- function(x){
        if(substr(x,2,2) == "/"){
                x <- paste("0",x, sep = "")
        }  
        else x
}

addMiddleZero <- function(x){
        if(substr(x,5,5) == "/"){
                x <- paste(substr(x,1,3),"0",substr(x,4,9), sep = "")
        }  
        else x   
}

formatDate <- function(x){
        addTrailingZero(x) %>% addMiddleZero
}

formatTime <- function(x){
        if(nchar(x) == 4){
                x <- paste("0",x,sep = "")
        }
        else x
}

shiftType <- function(time){
        hour <- as.numeric(substr(time,1,2))
        ifelse(hour < 6 | hour >= 18, "Night", "Day")
}

df$AlarmDate <- lapply(df$AlarmDate, formatDate)
df$AlarmDate <- as.character(df$AlarmDate)
df$AlarmDate <- as.Date(df$AlarmDate, format = "%m/%d/%Y")

stripped.df <- select(df, lat, lon, AlarmDate, numberofresponders, 
                      Top_Category, AddressComposite, AlarmTime)

# For shinyapps deploying we must compare dates as numerics do to
# localization issues
stripped.df <- mutate(stripped.df, dateNum = as.numeric(AlarmDate))

# get list of categories and remove NULL as an option
uniquecat <- as.character(unique(stripped.df$Top_Category))[-4]
uniquecat <- as.factor(uniquecat)

df$AlarmTime <- as.character(lapply(df$AlarmTime, formatTime))
df$ShiftType <- as.factor(as.character(lapply(df$AlarmTime, shiftType)))

# Add Weekday column
df$Weekday <- weekdays(df$AlarmDate)
df$Weekday <- as.character(df$Weekday)
df$Weekday <- as.factor(df$Weekday)
df$Weekday <- factor(df$Weekday, levels = c("Monday", "Tuesday", "Wednesday", 
                                            "Thursday", "Friday", "Saturday", 
                                            "Sunday"))

df <- filter(df, !is.na(AlarmDate))
df <- filter(df, AlarmDate > as.Date("2008-12-31"))

df <- group_by(df,IncidentNumber)

# Create dataframe of unique incidents and their weekdays
uniqueIncidents <- distinct(select(df, IncidentNumber, Top_Category, numberofresponders, AlarmDate, AlarmTime, Weekday, ShiftType))

numberOfWeeks <- as.numeric(difftime(max(uniqueIncidents$AlarmDate), 
                                     min(uniqueIncidents$AlarmDate),
                                     units = "weeks"))

numberOfWeeks.stripped <- as.numeric(difftime(max(tail(uniqueIncidents$AlarmDate,20000)),
                                              min(tail(uniqueIncidents$AlarmDate,20000)),
                                     units = "weeks"))

weekdayFreq <- data.frame(table(uniqueIncidents$Weekday) / numberOfWeeks)
colnames(weekdayFreq) <- c("Weekday", "Frequency")


uniqueIncidents$shift <- as.factor(paste(uniqueIncidents$Weekday,uniqueIncidents$ShiftType))
uniqueIncidents$shift <- factor(uniqueIncidents$shift, 
                                levels = c("Monday Day", "Monday Night", 
                                           "Tuesday Day", "Tuesday Night",
                                           "Wednesday Day", "Wednesday Night", 
                                           "Thursday Day", "Thursday Night",
                                           "Friday Day", "Friday Night", 
                                           "Saturday Day", "Saturday Night",
                                           "Sunday Day", "Sunday Night"))

# Function for returning an image of just the legend of a plot
g_legend<-function(a.gplot){ 
        tmp <- ggplot_gtable(ggplot_build(a.gplot)) 
        leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box") 
        legend <- tmp$grobs[[leg]] 
        return(legend)} 

leg.df <- as.data.frame(cbind(as.character(uniquecat),
                              c("orange","red","green",
                                "yellow","black","blue",
                                "purple", "darkseagreen", 
                                "lightsalmon")))

pal <- colorFactor(
        palette = c("orange","red","green","yellow","black","blue",
                    "purple", "darkseagreen", "lightsalmon") ,
        levels = uniquecat,
        ordered = TRUE
)