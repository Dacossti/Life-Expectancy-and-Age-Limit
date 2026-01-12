# ============================================================
# Human Life-Table Database (HLD) 
# Shiny + Plotly
# Life expectancy at birth (Age = 0)
# ============================================================

# ------------------------
# Libraries
# ------------------------
library(shiny)
library(shinythemes)
library(tidyverse)
library(plotly)
library(glue)
library(sf)
# ------------------------
# Source helper scripts
# ------------------------
source("scripts/plot_functions.R")
source("scripts/map_utils.R")

# ------------------------
# Paths
# ------------------------
data_file <- "data/HLD_database.csv"

# ------------------------
# Load & clean data
# ------------------------
hld_raw <- read_csv(data_file, show_col_types = FALSE)

hld_clean <- hld_raw %>%
  filter(
    Year1 >= 1900,
    Age == 0,
    `e(x)` < 150,
    !is.na(`e(x)`),
    Sex %in% c(1, 2)
  ) %>%
  select(
    Country,
    Year1,
    Year2,
    Sex,
    Age,
    e_x = `e(x)`
  ) %>%
  mutate(
    Year1 = as.integer(Year1),
    Year2 = as.integer(Year2),
    Year1 = pmin(Year1, Year2, na.rm = TRUE),
    Year2 = pmax(Year1, Year2, na.rm = TRUE)
  ) %>%
  rowwise() %>%
  mutate(Year = list(seq(Year1, Year2))) %>%
  ungroup() %>%
  unnest(Year) %>%
  mutate(
    Sex = factor(Sex, levels = c(1, 2), labels = c("Male", "Female"))
  ) %>%
  group_by(Country, Year, Sex) %>%
  summarise(
    e_x = mean(e_x, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(Country, Year, Sex)

available_years     <- sort(unique(hld_clean$Year))
available_countries <- sort(unique(hld_clean$Country))

# ============================================================
# UI
# ============================================================

ui <- fluidPage(
  theme = shinytheme("flatly"),
  
  titlePanel("🌍 Life Expectancy at Birth"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      
      sliderInput(
        "year",
        "Year",
        min = min(available_years),
        max = max(available_years),
        value = max(available_years),
        step = 1,
        sep = ""
      ),
      
      checkboxInput(
        "by_sex",
        "Split by sex",
        value = FALSE
      ),
      
      hr(),
      
      conditionalPanel(
        condition = "input.tab_selected == 'timeseries'",
        selectizeInput(
          "country",
          "Countries (multi-selection)",
          choices = available_countries,
          selected = "FRA",
          multiple = TRUE,
          options = list(maxItems = 10)
        )
      ),
      
      hr(),
      
      actionButton(
        "refresh",
        "Refresh",
        class = "btn btn-primary",
        width = "100%"
      ),
      
      hr(),
      verbatimTextOutput("debug_info")
    ),
    
    mainPanel(
      width = 9,
      
      tabsetPanel(
        id = "tab_selected",
        
        tabPanel(
          "Boxplot",
          value = "boxplot",
          br(),
          plotlyOutput("boxplot_plot", height = "600px")
        ),
        
        tabPanel(
          "Histogram",
          value = "histogram",
          br(),
          plotlyOutput("hist_plot", height = "600px")
        ),
        
        tabPanel(
          "Time Series",
          value = "timeseries",
          br(),
          fluidRow(
            column(
              6,
              actionButton(
                "build_ts_plot",
                "Build Time Series",
                class = "btn btn-info",
                width = "100%"
              )
            ),
            column(
              6,
              actionButton(
                "clear_ts_plot",
                "Reset",
                class = "btn btn-warning",
                width = "100%"
              )
            )
          ),
          br(),
          plotlyOutput("ts_plotly", height = "600px")
        ),
        
        tabPanel(
          "Choropleth Map",
          value = "choropleth",
          br(),
          selectInput(
            "chor_sex",
            "Sex",
            choices = c("Male", "Female", "Male + Female"),
            selected = "Male + Female"
          ),
          plotlyOutput("chor_plot", height = "600px")
        )
      )
    )
  )
)

# ============================================================
# Server
# ============================================================

server <- function(input, output, session) {
  
  # ------------------------
  # Reactive trigger for refresh button
  # ------------------------
  trigger <- reactiveVal(0)
  observeEvent(input$refresh, { trigger(trigger() + 1) })
  
  data_reactive <- reactive({
    trigger()
    hld_clean
  })
  
  output$debug_info <- renderText({
    glue(
      "Rows: {nrow(hld_clean)} | Years: {min(available_years)}–{max(available_years)}"
    )
  })
  
  # ------------------------
  # Boxplot
  # ------------------------
  output$boxplot_plot <- renderPlotly({
    plot_boxplot(
      df     = data_reactive(),
      year   = input$year,
      by_sex = input$by_sex
    )
  })
  
  # ------------------------
  # Histogram
  # ------------------------
  output$hist_plot <- renderPlotly({
    plot_histogram(
      df     = data_reactive(),
      year   = input$year,
      by_sex = input$by_sex
    )
  })
  
  # ------------------------
  # Choropleth
  # ------------------------
  output$chor_plot <- renderPlotly({
    plot_choropleth(
      df   = data_reactive(),
      year = input$year,
      sex  = input$chor_sex
    )
  })
  
  # ------------------------
  # Time series
  # ------------------------
  ts_plot_built <- reactiveVal(FALSE)
  ts_plot_obj   <- reactiveVal(NULL)
  
  observeEvent(input$clear_ts_plot, {
    ts_plot_built(FALSE)
    ts_plot_obj(NULL)
  })
  
  observeEvent(input$build_ts_plot, {
    
    req(input$country)
    
    ts_plot <- plot_timeseries(
      df        = data_reactive(),
      countries = input$country,
      by_sex    = input$by_sex
    )
    
    ts_plot_built(TRUE)
    ts_plot_obj(ts_plot)
  })
  
  output$ts_plotly <- renderPlotly({
    req(ts_plot_built())
    ts_plot_obj()
  })
}

# ============================================================
# Run app
# ============================================================

shinyApp(ui = ui, server = server)
