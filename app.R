library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)
library(arrow)

data_path <- "data/processed/StudentPerformanceFactors.parquet"
df <- arrow::read_parquet(data_path)

ui <- page_sidebar(
  title = "Academic Performance Dashboard (R version)",
  sidebar = sidebar(
    title = "Global Filters",
    checkboxGroupInput(
      "school_type",
      "School Type",
      choices = unique(df$School_Type),
      selected = unique(df$School_Type)
    ),
    checkboxGroupInput(
      "parent_edu",
      "Parental Education Level",
      choices = sort(unique(df$Parental_Education_Level)),
      selected = sort(unique(df$Parental_Education_Level))
    ),
    hr(),
    markdown("**Authors:** Individual Re-implementation | **DSCI 532**")
  ),
  
  layout_columns(
    value_box(
      title = "AVG Exam Score",
      value = textOutput("avg_score"),
      theme = "primary"
    ),
    value_box(
      title = "AVG Hours Studied",
      value = textOutput("avg_hours")
    ),
    value_box(
      title = "AVG Attendance",
      value = textOutput("avg_attendance")
    ),
    fill = FALSE
  ),
  
  layout_columns(
    card(
      card_header("Study Habits vs. Performance"),
      plotOutput("scatter_plot")
    ),
    card(
      card_header("Score Distribution by Family Income"),
      plotOutput("income_boxplot")
    ),
    col_widths = c(6, 6)
  )
)

server <- function(input, output, session) {
  
  filtered_df <- reactive({
    df %>%
      filter(School_Type %in% input$school_type) %>%
      filter(Parental_Education_Level %in% input$parent_edu)
  })
  
  output$avg_score <- renderText({
    data <- filtered_df()
    if (nrow(data) == 0) {
      return("N/A")
    }
    val <- mean(data$Exam_Score, na.rm = TRUE)
    paste0(round(val, 1), "%")
  })
  
  output$avg_hours <- renderText({
    data <- filtered_df()
    if (nrow(data) == 0) {
      return("N/A")
    }
    val <- mean(data$Hours_Studied, na.rm = TRUE)
    paste0(round(val, 1), " hrs")
  })
  
  output$avg_attendance <- renderText({
    data <- filtered_df()
    if (nrow(data) == 0) {
      return("N/A")
    }
    val <- mean(data$Attendance, na.rm = TRUE)
    paste0(round(val, 1), "%")
  })
  
  output$scatter_plot <- renderPlot({
    data <- filtered_df()
    validate(need(nrow(data) > 0, "No data for current filters."))
    ggplot(data, aes(x = Hours_Studied, y = Exam_Score)) +
      geom_point(alpha = 0.4, color = "#21918c") +
      geom_smooth(method = "loess", color = "red") +
      theme_minimal() +
      labs(x = "Hours Studied", y = "Exam Score")
  })
  
  output$income_boxplot <- renderPlot({
    plot_data <- filtered_df()
    validate(need(nrow(plot_data) > 0, "No data for current filters."))
    plot_data$Family_Income <- factor(plot_data$Family_Income, levels = c("Low", "Medium", "High"))
    
    ggplot(plot_data, aes(x = Family_Income, y = Exam_Score, fill = Family_Income)) +
      geom_boxplot() +
      scale_fill_viridis_d() +
      theme_minimal() +
      labs(x = "Family Income", y = "Exam Score") +
      theme(legend.position = "none")
  })
}

shinyApp(ui, server)
