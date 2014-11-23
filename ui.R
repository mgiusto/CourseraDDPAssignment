library(shiny)

shinyUI(
  navbarPage("Cloudera Impala timing benchmark",
    tabPanel("Plots",
             sidebarLayout(
               sidebarPanel(
                 sliderInput("testID",
                             "Select the number of test:",
                             min = 1,
                             max = 7,
                             value = 1),
                 sliderInput("queryIdx",
                             "Select the number of query:",
                             min = 1,
                             max = 5,
                             value = 1),
                 selectizeInput("multiplierVar", "Select the multiplier to visualize:"
                                , options = list(dropdownParent = 'body')
                                , choices = c("aggregate_peak","hdfs_read","cpu_time"))
               ),    
               mainPanel(
                 h2("Time required to complete query"),
                 p("Plot of the time required to complete the selected query when other queries are added."),
                 plotOutput("timePlot"),
                 h2("Multiplier comparison"),
                 textOutput("plot2text"),
                 plotOutput("multiplierPlot")
               )
             )                        
    ),
    tabPanel("Docs",
       h1("Aim of the experiment"),
       p("Aim of the experiment is to understand how execution time of various SQL queries executed with Cloudra Impala 
         changes when more queries are executed in parallel."),
       h1("Experiment execution"),
       p("At first, queries are executed alone and aggregate peak, HDFS byte read and CPU time are saved."),
       p("Following, in each test queries are randomly ordered and executed. At first iteration 
         only first query is executed, second iteration executes first+second+third queries, third iteration executes 
         first+second+third+fourth+fifth queries, and so on until 23 queries are running."),
       h1("Time plot"),
       p("Time plot shows how execution time changes when more queries are added. The first point is the first execution
         of the selected query, then the other points make reference to the followings iteration."),
       h1("Multiplier plot"),
       p("Multiplier plot shows how the selected variable (aggregate peak/HDFS byte read/cpu time) increase in the different
         iteration. This is compared to the increase in the execution time of the selected queries. 
         To clarify, if at first iteration query execution time is 10 seconds and HDFS byte read 1 GB and at second iteration
         query takes 20 seconds while HDFS byte read is 10 GB, time multiplier is 2 (20/10), HDFS byte read multiplier is 10 
         (10/1)."),
       h1("Input selection"),
       p("It is possible to select the number of the test to plot (from 1 to 6). In the selected test, it is possible to select
         the query number (1=first executed query, 2=second executed query, ...). Finally, it is also possible to select which
         multiplier variable to plot (aggregate peak/HDFS byte read/CPU time).")
       
    )
))