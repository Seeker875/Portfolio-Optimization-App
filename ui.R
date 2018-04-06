#User interface file
#loading package
library(shiny)

#layout
shinyUI(fluidPage(
  
  #theme="bootstrap.min1.css",
  
  #fluid page scales the components to fit on all browsers
  
  #Header panel or titlePanel
  headerPanel(h1("Duck Wisdom",style="color:blue"),
              list(tags$head(tags$style("body {background-color: WhiteSmoke ;}")))),
  #headerPanel(h1("Duck Wisdom",style="color:darkblue")),
  #layout
  sidebarLayout(
                
    sidebarPanel(
      
      
      textInput("symbol","Enter the stock symbol",value = toupper("MSFT GOOG IBM")),
      submitButton("Submit"),
      p("NOTE: Only stock symbols separated by space are allowed ")
      ),
    mainPanel(#poistion="right",
      
      tabsetPanel(type="tab",
                  
       tabPanel("Risk profile",
      
      
       plotOutput("plot1"),
            
       h3("Statistics"),
       verbatimTextOutput("skew"),
       verbatimTextOutput("kurt"),
       p("Value at Risk"),
       verbatimTextOutput("var"),
       #textOutput("annRet"),
       #textOutput("std")
       h6("References"),
       p("The application has solely been created for academic purposes only."),
       p("R packages used: PerformanceAnalytics, quantmod, tseries,shiny")
      ),
      
      tabPanel("Portfolio",
      h2("Minimimum variance potfolio"),         
      plotOutput("plot2"), 
      h4("Optimised weights for the given stocks in percenatges are"),
      verbatimTextOutput("wt")         
               
               
               ),
      tabPanel("Correlation",
      h4("Correlation between the securities"),
      plotOutput("plot3")
      ),
      tabPanel("Annualized Table",
          verbatimTextOutput("tab"),
          plotOutput("plot4")
      )
      )
      )
    
  )
  
  
)
)