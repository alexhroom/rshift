#requires package tidyverse
#a package of paleoecology-related functions, esp.
#for core samples etc.
require(tidyverse)

RSI <- function(data, col, time, l, prob = 0.95, startrow = 1, merge = FALSE){
  #performs a STARS test (Rodionov, 2004) on a dataset.

  #creates necessary variables
  #finds sigma^2_L
  var_L <- data %>%
    select(all_of(col)) %>%
    zoo::rollapply(l, var) %>%
    mean()
  
  #creates diff value for data
  diff = qt(prob, (2 * l - 2)) * sqrt((2 * var_L) / l)  
  
  #wrangles data
  regime_vals <- data %>%
    select(all_of(col)) %>%
    filter((row_number() >= startrow & row_number() <= (startrow + l)))
  
  #creates x R1 bar
  regime_mean <- regime_vals %>%
    colMeans()

  #creates the x R2' bar interval
  shift_boundary_lower = regime_mean - diff
  shift_boundary_upper = regime_mean + diff

  #assigns variables to be used later
  shift_years <- vector()
  RSI_vals <- vector()
  RSI <- 0
  candidate = l
  down <- FALSE
  values <- data %>%
    select(all_of(col))
  
  while(candidate < nrow(data)-l){
    #iterates check until regime boundary is found
    while(candidate < nrow(data)-l){
      candidate <- candidate + 1
      if((as.numeric(values[candidate, 1]) < shift_boundary_lower) | (as.numeric(values[candidate, 1]) > shift_boundary_upper)){
        if((as.numeric(values[candidate, 1]) < shift_boundary_lower)){
          down <- TRUE}
        break}
      else{
        regime_vals <- regime_vals %>%
          add_row(slice(values, candidate))
        regime_mean <- regime_vals %>%
          colMeans()
        shift_boundary_lower = regime_mean - diff
        shift_boundary_upper = regime_mean + diff
      }
      
    }
    #calculates RSI values for candidate
    for(i in candidate:(candidate+l-1)){
      if(down == TRUE){
        x_i_star <- (shift_boundary_lower - values[i, 1])
      }
      else{
        x_i_star <- (values[i, 1] - shift_boundary_upper)
      }
    RSI = RSI + (x_i_star / (l * sqrt(var_L)))
    if(RSI < 0){
      RSI = 0
      break
      }
    }
  
    #iterates, either to continue finding R2 if failed,
    #or otherwise to find R3
    if(RSI == 0){
      regime_vals <- regime_vals %>%
        add_row(slice(values, candidate))
      }
    else{
      RSI_vals <- c(RSI_vals, as.numeric(RSI))
      shift_years <- c(shift_years, candidate)
      down <- FALSE
      regime_vals <- data %>%
        select(all_of(col)) %>%
        filter((row_number() >= candidate & row_number() <= (candidate + l - 1)))  
    }
    #calculates new X R1 bar if failed, or X R2 bar if successful,
    #as well as corresponding range
    regime_mean <- regime_vals %>%
      colMeans()
    shift_boundary_lower = regime_mean - diff
    shift_boundary_upper = regime_mean + diff
  }
  #creates results tibble
  results <- tibble(shift_rows = shift_years, RSI = RSI_vals)
  dates <- data %>%
    select(all_of(time)) %>%
    tibble::rowid_to_column("ID")
  results <- results %>%
    left_join(dates, by = c("shift_rows" = "ID")) %>%
    select(-shift_rows)
  if(merge == FALSE){
    return(results)}
  else{
    results <- full_join(data, results, by = time)
    results[is.na(results)] <- 0
    return(results)
  }
}

RSI_graph <- function(data, col, time, rsi){
  #creates two graphs, one of data and one of the RSI,
  #as seen in Rodionov (2004)
  
  #while RSI() requires quotes, this doesn't work if you put quotes around col or time
  p1 <- ggplot(data) + geom_col(aes(x = {{ time }}, y = {{ col }}))
  p2 <- ggplot(data) + geom_col(aes(x = {{ time }}, y = {{ rsi }}))
  grid::pushViewport(grid::viewport(layout = grid::grid.layout(2, 1)))
  vplayout <- function(x, y) grid::viewport(layout.pos.row = x, layout.pos.col = y)
  print(p1, vp = vplayout(1, 1))
  print(p2, vp = vplayout(2, 1))
}

Hellinger_trans <- function(data, col, site){
  #Hellinger transforms data (Legendre and Legendre, Numerical Ecology)
  #to make distance calculations better
  
  #creates an empty table with the original table's columns, plus the hellinger values
  #i'm aware this is incredibly hacky, but i couldn't find a better way
  results <- data %>%
    cbind(hellinger_trans_vals = c(1:nrow(data))) %>%
    filter(col == "bad programming")
  #finds values for each site
  unique_sites <- unique(data[[site]])
  for(s in unique_sites){
    site_obs <- data[data[[site]] == s,]
    y_i_plus <- sum(site_obs[col], na.rm = TRUE)
    site_obs <- mutate(site_obs, hellinger_trans_vals = sqrt(site_obs[col] / y_i_plus))
  #binds values for each site back into a copy of the original data set
    results <- rbind(results, site_obs)
  }
  return(results)
}