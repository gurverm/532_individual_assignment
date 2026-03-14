# 532_individual_assignment
# Student Performance Factors (R Re-implementation)

## Purpose
This application is a re-implementation of our group project (originally in Python) into **R/Shiny**. It visualizes the impact of various demographic and behavioral factors on academic performance.

## Deployed App
**URL:** <add your Posit Connect Cloud URL here>

## Instructions
1. **Install Dependencies (first time):**
   `install.packages(c("shiny", "bslib", "ggplot2", "dplyr", "arrow"))`
2. **Local Run (RStudio):** Open `app.R` and click "Run App".
3. **Local Run (Terminal):** `R -q -e "shiny::runApp('.')"`
4. **Data:** The app expects the dataset at `data/processed/StudentPerformanceFactors.parquet`.
