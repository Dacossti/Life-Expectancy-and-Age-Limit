# ============================================================
# Plot functions for HLD Life Expectancy Visualizations
# Requires: tidyverse, plotly, glue
# Choropleth relies on map_countries_to_iso3() from map_utils.R
# ============================================================

library(tidyverse)
library(plotly)
library(glue)

# ---------------------------
# Boxplot
# ---------------------------
plot_boxplot <- function(df, year, by_sex = FALSE) {
  df_year <- df %>% filter(Year == year)
  validate(need(nrow(df_year) > 0, glue("No data available for {year}")))

  if (by_sex) {
    df_plot <- df_year %>%
      group_by(Country, Sex) %>%
      summarise(e_x = mean(e_x, na.rm = TRUE), .groups = "drop")
    
    plot_ly(
      df_plot,
      x = ~Sex,
      y = ~e_x,
      type = "box",
      color = ~Sex,
      boxpoints = "all",
      jitter = 0.3,
      pointpos = -1.8,
      customdata = ~Country,
      hovertemplate = "Country: %{customdata}<br>Life expectancy: %{y:.2f}"
    ) %>%
      layout(
        title = paste0("Life Expectancy at Birth by Sex — ", year),
        yaxis = list(title = "Life expectancy (years)")
      )

  } else {
    df_plot <- df_year %>%
      group_by(Country) %>%
      summarise(e_x = mean(e_x, na.rm = TRUE), .groups = "drop")
    
    plot_ly(
      df_plot,
      y = ~e_x,
      type = "box",
      boxpoints = "all",
      marker = list(color = "lightgreen"),
      customdata = ~Country,
      hovertemplate = "Country: %{customdata}<br>Life expectancy: %{y:.2f}"
    ) %>%
      layout(
        title = paste0("Life Expectancy at Birth — All Countries — ", year),
        yaxis = list(title = "Life expectancy (years)")
      )
  }
}

# ---------------------------
# Histogram
# ---------------------------
plot_histogram <- function(df, year, by_sex = FALSE) {
  df_year <- df %>% filter(Year == year)
  validate(need(nrow(df_year) > 0, glue("No data available for {year}")))

  if (by_sex) {
    df_plot <- df_year %>%
      group_by(Country, Sex) %>%
      summarise(e_x = mean(e_x, na.rm = TRUE), .groups = "drop")
    
    plot_ly(
      df_plot,
      x = ~e_x,
      color = ~Sex,
      type = "histogram",
      bingroup = ~Sex,
      histnorm = NULL,
      customdata = ~Country,
      hovertemplate = "Country: %{customdata}<br>Life expectancy: %{x:.2f}<br>Count: %{y}"
    ) %>%
      layout(
        title = paste0("Histogram of Life Expectancy by Sex — ", year),
        xaxis = list(title = "Life expectancy (years)"),
        yaxis = list(title = "Number of countries"),
        barmode = "group"
      )

  } else {
    df_plot <- df_year %>%
      group_by(Country) %>%
      summarise(e_x = mean(e_x, na.rm = TRUE), .groups = "drop")
    
    plot_ly(
      df_plot,
      x = ~e_x,
      type = "histogram",
      marker = list(color = "lightgreen"),
      customdata = ~Country,
      hovertemplate = "Country: %{customdata}<br>Life expectancy: %{x:.2f}<br>Count: %{y}"
    ) %>%
      layout(
        title = paste0("Histogram of Life Expectancy — ", year),
        xaxis = list(title = "Life expectancy (years)"),
        yaxis = list(title = "Number of countries")
      )
  }
}

# ---------------------------
# Time series
# ---------------------------
plot_timeseries <- function(df, countries, by_sex = FALSE) {
  
  df_sel <- df %>% filter(Country %in% countries)

  yr_range <- df_sel %>% group_by(Country) %>% summarise(minY = min(Year, na.rm = TRUE), maxY = max(Year, na.rm = TRUE), .groups = "drop")
  start_year <- max(yr_range$minY, na.rm = TRUE)
  end_year   <- min(yr_range$maxY, na.rm = TRUE)
  validate(need(start_year <= end_year, paste0("No common interval : ", start_year, " > ", end_year)))
  
  df_common <- df_sel %>% filter(Year >= start_year, Year <= end_year)
  
  if (by_sex) {
    df_plot <- df_common %>%
      group_by(Country, Year, Sex) %>%
      summarise(e_x = mean(e_x, na.rm = TRUE), .groups = "drop")
    
    global_df <- df_plot %>%
      group_by(Year, Sex) %>%
      summarise(e_x = mean(e_x, na.rm = TRUE), .groups = "drop") %>%
      mutate(Country = "Global")
    
    plotting_df <- bind_rows(df_plot, global_df) %>%
      mutate(LineID = paste0(Country, " (", Sex, ")"))
    
  } else {
    df_plot <- df_common %>%
      group_by(Country, Year) %>%
      summarise(e_x = mean(e_x, na.rm = TRUE), .groups = "drop")
    
    global_df <- df_plot %>%
      group_by(Year) %>%
      summarise(e_x = mean(e_x, na.rm = TRUE), .groups = "drop") %>%
      mutate(Country = "Global")
    
    plotting_df <- bind_rows(df_plot, global_df) %>%
      mutate(LineID = Country)
  }
  
  frame_years <- seq(start_year, end_year)
  
  cumulative_df <- map_dfr(frame_years, function(fy) {
      plotting_df %>% filter(Year <= fy) %>% mutate(frame = fy)
    })

  plot_ly(
    cumulative_df,
    x = ~Year,
    y = ~e_x,
    color = ~LineID,
    split = ~LineID,
    frame = ~frame,
    type = "scatter",
    mode = "lines+markers",
    hovertemplate = "%{text}",
    text = ~paste(LineID, "<br>Year:", Year, "<br>Life expectancy:", round(e_x, 2))
  ) %>%
    layout(
      title = paste("Time Series — Countries:", paste(countries, collapse = ", ")),
      xaxis = list(title = "Year"),
      yaxis = list(title = "Life expectancy at birth (years)")
    ) %>%
    animation_opts(frame = 100, transition = 0, redraw = FALSE)
}

# ---------------------------
# Choropleth map
# ---------------------------
plot_choropleth <- function(df, year, sex = "Male + Female") {
  df_year <- df %>% filter(Year == year)
  if (sex != "Male + Female") df_year <- df_year %>% filter(Sex == sex)
  
  df_map <- df_year %>%
    group_by(Country) %>%
    summarise(e_x = mean(e_x, na.rm = TRUE), .groups = "drop") %>%
    mutate(iso_a3 = map_countries_to_iso3(Country))
  
  validate(need(nrow(df_map %>% filter(!is.na(iso_a3))) > 0, "No data available for the map"))
  
  plot_ly(
    df_map,
    type = "choropleth",
    locations = ~iso_a3,
    z = ~e_x,
    text = ~Country,
    colorscale = "Viridis",
    reversescale = FALSE,
    marker = list(line = list(color = "rgb(180,180,180)", width = 0.5)),
    colorbar = list(title = "Life expectancy")
  ) %>%
    layout(
      title = paste0("Life Expectancy (", sex, ") — ", year),
      geo = list(showframe = FALSE, showcoastlines = TRUE, projection = list(type = "natural earth"))
    )
}
