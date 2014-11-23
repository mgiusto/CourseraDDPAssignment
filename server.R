library(shiny)
library(XLConnect)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  testQueryDF <- reactive({
    # read data
    excelFile = loadWorkbook("tempi.xlsx") 
    queryDetails = readWorksheet(excelFile, sheet="impala")
    testDF = readWorksheet(excelFile, sheet=paste0("test",input$testID+1))
    colnames(testDF) = testDF[1,]
    colnames(testDF)[1] = "nQueries"
    testDF = testDF[2:dim(testDF)[1],]
    testDF$nQueries = as.numeric(testDF$nQueries)
    testQueries = as.data.frame(colnames(testDF)[2:length(colnames(testDF))])
    colnames(testQueries) = c("orderedQueries")
    testQueries$idx = 1:dim(testQueries)[1]
    testDetails = merge(queryDetails, testQueries, by.x="queryID", by.y="orderedQueries")
    testDetails = testDetails[with(testDetails, order(idx)), ]
    vars = c("aggregate_peak","hdfs_read","cpu_time","time_impala_single_query")
    for(vId in 1:length(vars)){
      v = vars[vId]
      current.sum <- 0
      for (c in 1:nrow(testDetails)) {
        current.sum <- current.sum + testDetails[c, v]
        testDetails[c, paste0("total_",v)] <- current.sum
      }
    }
    testDF2 = merge(testDF, testDetails[,c("idx","total_aggregate_peak","total_hdfs_read","total_cpu_time","total_time_impala_single_query")], by.x="nQueries",by.y="idx")
    testDF2 = testDF2[with(testDF2, order(as.numeric(nQueries))), ]
    idx = input$queryIdx
    chosenQueryID = testQueries[testQueries$idx == idx,"orderedQueries"]
    queryTimes = testDF2[as.character(chosenQueryID)] 
    minRow=min(which(!is.na(queryTimes)))
    maxRow=max(which(!is.na(queryTimes)))
    testQueryDF = testDF2[minRow:maxRow,c(as.character(chosenQueryID),"nQueries","total_aggregate_peak","total_hdfs_read","total_cpu_time","total_time_impala_single_query")]
    colnames(testQueryDF)[1] = "time"
    vars = colnames(testQueryDF)
    for(vId in 1:length(vars)){
      v = vars[vId]
      minVal = as.numeric(testQueryDF[v][1,1])
      testQueryDF[paste0("multiplier_", gsub("total_", "", v))] = testQueryDF[,v]/minVal  
    }
    testQueryDF
  })
  output$timePlot <- renderPlot({
    plot(testQueryDF()$nQueries, testQueryDF()$time, type="o", xlab="# query in execution", ylab="seconds to finish")
    grid()
  })
  output$plot2text <- renderText({ 
    paste0("Plot of the increase of time required to complete the selected query, compared to increase of ", 
          gsub("_", " ", input$multiplierVar), ".")
  })  
  output$multiplierPlot <- renderPlot({
    v = paste0("multiplier_",input$multiplierVar)
    maxVal=max(max(testQueryDF()[,v]),max(testQueryDF()$multiplier_time))
    plot(testQueryDF()[,v],testQueryDF()$multiplier_time, pch=15, xlim=c(1,maxVal), ylim=c(1,maxVal),col="red", xlab=v, ylab="multiplier")
    points(testQueryDF()[,v],testQueryDF()[,v], col="blue", pch=15)
    legend("topleft", legend=c("multiplier_time",paste0("multiplier_",input$multiplierVar)), col=c("red","blue"), 
                               pch=c(15,15), lwd=2)
    grid()
  })
})