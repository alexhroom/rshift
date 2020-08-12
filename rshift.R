#requires packages tidyverse, zoo
#a package of paleoecology-related functions, esp.
#for core samples etc.



regime_diff <- function(data, col, l, prob = 0.95){
  #finds the diff value as used in STARS regime shift analysis
  #finds sigma^2_L
  var_L <- data %>%
    select(all_of(col)) %>%
    rollapply(l, var) %>%
    mean()
  
  #creates diff value for data
  diff = qt(prob, (2 * l - 2)) * sqrt((2 * var_L) / l)
  return(diff)
}

regime_boundary <- function(data, col, l, prob = 0.95, i = 1){
  #creates necessary variables
  diff <- regime_diff(data, col, l, prob)
  regime_vals <- data %>%
    select(col) %>%
    filter((row_number() >= i & row_number() <= l))
  mean_R1 <- regime_vals %>%
    colMeans()
  shift_boundary_lower <- mean_R1 - diff
  shift_boundary_upper <- mean_R1 + diff
  results <- vector()
  
  #iterates check until regime boundary is found
  candidate = l + 1
  values <- data %>%
    select(all_of(col))
  while(candidate <= nrow(data)){
    if(values[candidate, 1] <= shift_boundary_lower | values[candidate, 1] >= shift_boundary_upper){
      print(candidate)
      break}
    else{
      regime_vals <- regime_vals %>%
        add_row(slice(values, candidate))
      mean_R1 <- regime_vals %>%
        colMeans()
      candidate <- candidate + 1
    
  
    }
  }
}