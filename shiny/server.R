# libraries
library(stringr)
library(vistime)
library(ggplot2)
library(ggrepel)

# prepare data to plot
data.tidy <- readRDS(file="data_conductors.Rds")

# abbreviate names
orchestras <- unique(data.tidy$orchestra)
get_first_letters <- function(str) {
  str_flatten( str_sub( strsplit(str, split=" ")[[1]], 1, 1)  )
}
orchestra.abbr <- data.tidy[c('orchestra')]
for (i in 1:length(orchestras)) {
  orchestra.abbr$orchestra <- str_replace_all( orchestra.abbr$orchestra, orchestras[[i]], get_first_letters(orchestras[[i]]) )
}

# Orchestra colors
data.tidy$color = NA;
#cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7", "#999999")
cbPalette <- RColorBrewer::brewer.pal(12, name='Set3');
for (i in 1:length(orchestras)) {
  data.tidy[data.tidy$orchestra==orchestras[[i]], ]$color = cbPalette[(i %% length(cbPalette)) + 1];
}

# change default text size
#update_geom_defaults("text", list(size = 6))
#theme_set(theme_gray(base_size = 32)) # not working
          
function(input, output) {
  # text element 
  # output$selected_var <- renderText({
  #   #date.range <- as.POSIXct(as.character(input$dates)) ;
  #   date.range <- as.POSIXct(c(paste0(input$dates[1], "-01-01"), paste0(input$dates[2], "-12-31")))
  #   paste("You have selected", date.range[1], date.range[2] )
  # }
  #output$timeline_plot <- renderPlot({ hist(rnorm(100) ) } )
  
  # plot time line
  output$timeline_plot <- renderPlot({
    date.range <- as.POSIXct(c(paste0(input$dates[1], "-01-01"), paste0(input$dates[2], "-12-31")))
    
    # subset data
    row.filt <- data.tidy$orchestra %in% input$selectOrchestra
    data.tidy.sel <- data.tidy[row.filt, ]
    
    # if start or end outside range: crop
    cond1 = (data.tidy.sel$start < date.range[[1]]) & (data.tidy.sel$end > date.range[[1]]) 
    if (sum(cond1>0)) { data.tidy.sel[ cond1, ]$start = date.range[[1]] }
    cond2 = (data.tidy.sel$start < date.range[[2]]) & (data.tidy.sel$end > date.range[[2]]) 
    if (sum(cond2>0)) {data.tidy.sel[ cond2, ]$end = date.range[[2]] }
    cond3 = (data.tidy.sel$start >= date.range[[1]]) & (data.tidy.sel$end <= date.range[[2]])
    data.tidy.sel <- data.tidy.sel[cond3,]
    
    # conductor: only last names?
    if (as.logical(input$radio)) {
      tmp <- strsplit(data.tidy.sel$conductor, split=" ")
      data.tidy.sel$conductor <- sapply( tmp, function(x) { x[[length(x)]] } )
    }
    
    # text size
    update_geom_defaults("text", list(size = 4.5 + 1.5/( sum(cond3)/15 )))
    
    # Plot results
    if (length(input$selectOrchestra)==0) { stop("Please select an orchestra!") }
    if (length(input$selectOrchestra)>1) {
      if (length(data.tidy.sel)>0) {
        row.filt <- data.tidy$orchestra %in% input$selectOrchestra
        orchestra.abbr.sel <- orchestra.abbr[row.filt, ]
        orchestra.abbr.sel <- orchestra.abbr.sel[cond3]
        data.tidy.sel$orchestra <- orchestra.abbr.sel
      } else{ stop("Please select a valid date range!") }
    
      gg_vistime(data.tidy.sel, optimize_y = FALSE,
                 col.event = "conductor",
                 col.start = "start",
                 col.end = "end",
                 col.group = "orchestra",
                 col.color = "color")+
        xlim(date.range[1], date.range[2]) +
        labs(x="year") +
        theme(text = element_text(size = 20)) 
    } else{
      if (length(data.tidy.sel)==0) {stop("Please select a valid date range!")}
      
      gg_vistime(data.tidy.sel, optimize_y = FALSE, 
                 col.event = "conductor",
                 col.start = "start",
                 col.end = "end",
                 col.color = "color",
                 show_labels = TRUE) +
        labs(x="year", title=input$selectOrchestra) +
        xlim(date.range[1], date.range[2]) +
        theme(text = element_text(size = 20)) 
    }
    
  } )
}

