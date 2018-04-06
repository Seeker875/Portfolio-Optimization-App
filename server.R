#server file
#loading packages
library(shiny)
library(quantmod)
library(PerformanceAnalytics)
library(tseries)
library(ggfortify)
library(ggthemes)
library(PortfolioAnalytics)
library(ROI)
#library(ROI.plugin.glpk)
library(ROI.plugin.quadprog)
#library(ROI.plugin.symphony)



shinyServer(
  function(input,output){
    
    #getting returns for the stocks 
    df <- reactive({
      #splitting the input
      syms <- unlist(strsplit(input$symbol, " "))
      #getting stocks with 10 year data and subsetting for close prices 
      Stocks = lapply(syms, function(sym) {
        na.omit(getSymbols(sym,auto.assign=FALSE,src="yahoo")[,4])
      })
      
      #removing na's for stocks which dont have 10 yr data
      x<-do.call(cbind, Stocks)
      df<-x[complete.cases(x), ]
      
      #changing colnames of df
      for(name in names(df)){
        colnames(df)[colnames(df)==name] <- strsplit(name,"\\.")[[1]][1]}
      
      return(df)
      #returning df withclosing prices of stocks
      
    })
    
    returns<-reactive({
      return(Return.calculate(df())[-1])
      
    })
    
    
    opt<-reactive({
      
      # Create the portfolio specification
      port_spec <- portfolio.spec(colnames(returns()))
      
      # Add a full investment constraint such that the weights sum to 1
      port_spec <- add.constraint(portfolio = port_spec, type = "full_investment")
      
      # Add a long only constraint such that the weight of an asset is between 0 and 1
      port_spec <- add.constraint(portfolio = port_spec, type = "long_only")
      
      # Add an objective to minimize portfolio standard deviation
      port_spec <- add.objective(portfolio = port_spec, type = "risk", name = "StdDev")
      
      # Solve the optimization problem
      opt <- optimize.portfolio(returns(), portfolio = port_spec, optimize_method = "ROI")
      
      return(opt)
    })
    
    wts<-reactive({
      
      return(extractWeights(opt()))
      
    })
    
    # 
    # pf_weights<-reactive({
    #   # Create pf_weights
    #   pf_weights <- portfolio.optim(returns())$pw
    #   
    #   # Assign asset names
    #   names(pf_weights) <- colnames(returns())
    #   return(pf_weights)
    # })
    
    #getting output using desired functions 
    output$plot1 <- renderPlot(autoplot(returns(),ts.colour = 'orange')+theme_hc())
    #output$plot1 <- renderPlot(plot.zoo(returns(),col = "orange",main = "Returns chart",xlab = "Year"))
    output$skew <- renderPrint(round(skewness(returns()),2))
    output$kurt <- renderPrint(round(kurtosis(returns()),2))
    output$var <- renderPrint(round(VaR(returns()),2))
    #output$annRet <- renderText(paste("Annual Return Percenatge:",round(Return.annualized(returns())*100,2)))
    #output$std <- renderText(paste("Annualised Stanadard deviation:",round(StdDev.annualized(returns()),2)) ) 
    
    output$wt<-renderPrint(round(wts()*100,2))
    output$plot2<-renderPlot(barplot(wts(),
                                     col="wheat",ylab="Weights", main ="Optimised weights" ))
    
    output$plot3<-renderPlot(chart.Correlation(returns()))
    
    output$tab<-renderPrint(table.AnnualizedReturns(returns()))
    output$plot4<-renderPlot(chart.TimeSeries(df(),main="Prices",legend.loc="topleft")
)
    
  }
  
)
