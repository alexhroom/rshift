#requires packages tidyverse, zoo
#a package of paleoecology-related functions, esp.
#for core samples etc.
require(tidyverse)
require(zoo)

RSI <- function(data, col, time, l, prob = 0.95, startrow = 1){
  #performs a STARS test (Rodionov, 2004) on a dataset. variables:
  #data = dataset to use
  #col = column containing regime proxy variable
  #l = cut-off length of regime
  #prob = probability value for the test (defaults to 0.05)
  #startrow = which row of the 
  
  #creates necessary variables
  #finds sigma^2_L
  var_L <- data %>%
    select(all_of(col)) %>%
    rollapply(l, var) %>%
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
    RSI = RSI + (x_i_star / (l * var_L))
    print
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
      RSI_vals <- c(RSI_vals, RSI)
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
  results <- list(shift_rows = shift_years, RSI = RSI_vals)
  dates <- data %>%
    select(all_of(time))
  results <- bind_rows(results) %>%
    mutate(age = dates[shift_rows, 1], .before = RSI) %>%
    select(-shift_rows)
  return(results)
}