#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

##TO DO: (Updated: 5/22/2019)
#1) Clean up
#2) Get action button to work such that the program doesn't keep running and waiting.
#3) Test in Linux.
#4) Set up to be hosted.

#install.packages("data.table")
#install.packages("DT")

#Load relevant libraries.
library(shiny) #required for R shiny apps.
library(data.table) #efficiency
library(DT) #has a built-in table that's sortable and easy to manipulate.

#Source the supporting function
source("D:/Users/Ludume/Documents/UWM/Bugni Lab/AntiBase Project/AntiBase/support.R")
##Run once when the app is launched.
#Load excel sheet.
#Fread is fast.
abTableChar = fread("D:/Users/Ludume/Documents/UWM/Bugni Lab/AntiBase Project/AntiBase/dataHolder/antibase_tableout_modified.csv",header = TRUE)

# DEFINE UI---- -----------------------------------------------------------

ui <- fluidPage(
   
   # Application title
   titlePanel("AntiBase Reader"),
   
   # Section for values that you input into the system. 
   sidebarLayout(
      sidebarPanel(
           helpText("Upload a .dat, .txt, or .csv file here, with each entry
             separated by tabs or enters."),
           helpText("Data should look like this:"),
           helpText("123.4151", br(),
                    "99.21341"),
           #Allows user to upload one file, must be CSV at a time.
           fileInput("file", "Choose File", h3("File input"),
                     #accept = c("text/csv", "text/comma-separated-values,text/plain",
                                #".csv"),
                     multiple = FALSE),
           hr(),
           #Displays a general summary of the text file.
           fluidRow(column(12, verbatimTextOutput("file", placeholder = FALSE))),
           #Allows user input ppm value.
           numericInput("ppm", h3("Parts Per Million (ppm)"), value = "0"),
           br(),
           #Allows for button press to signify start.
           actionButton(inputId = "action", label = "RUN"),
           hr(),
           #Allows for user to download the returned data.
           downloadButton("DL", "Download Data")
      ),
      
      # Shows table of potential compound values, and potentially structures.
      mainPanel(
         dataTableOutput("data")
      )
   )
)

# SERVER LOGIC---- -------------------------------------------------------
server <- function(input, output) {
  #returns the summary of the text file
  output$file <- renderPrint({
    str(input$file)
  })
  #Reactive to action button being pressed.
  observeEvent(input$action, {
    inFile = input$file
    readFile = fread(inFile$datapath)
    #Generate reactive expression with a dataframe version of the input file.
    returnedData <- reactive(findSC(readFile, input$ppm, abTableChar))
    output$data <- DT::renderDataTable({
      returnedData()
    })
    output$DL <- downloadHandler(
      filename = function(){
        paste("data-", Sys.Date(),"-ppm-",input$ppm, ".csv", sep="")
      },
      content = function(file) {
        fwrite(returnedData(), file)
      }
    )
  })
}


# RUN APP---- ------------------------------------------------------------

shinyApp(ui = ui, server = server)
