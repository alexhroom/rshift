#'  Rodionov (2004)'s STARS algorithm
#'
#'  performs STARS analysis (Rodionov, 2004) on a dataset
#'
#' @param data The dataframe to be used.
#' @param col The column we are measuring change on.
#' @param time The column containing time units (e.g. age of a subsample)
#' @param l The cut-off length of a regime; affects sensitivity (see Rodionov, 2004)
#' @param prob The p-value for significance of a regime shift. Defaults to p = 0.05.  
#' @param startrow What row the analysis starts at. Defaults to 1.
#' @param merge Sets the result to be either a regime-shift only table (if FALSE), or an addition to the original table (if TRUE)
#' @return If merge = FALSE (default), produces a 2-column table of time (the time value for each regime shift) and RSI (the regime shift index for each regime shift). If merge = TRUE, returns the original dataset with an extra RSI column, giving the regime shift index for each time unit - 0 for non-shift years.
#' @examples 
#' Rodionov(lake_data, "DCA1", "Age", l=5)
#' Rodionov(lake_data, "DCA1", "Age", l=5, prob=0.99, startrow=2, merge=TRUE)
#' @import dplyr
#' @importFrom magrittr %>%
#' @importFrom stats qt var
#' @export 
Rodionov <- function(data, col, time, l, prob = 0.95, startrow = 1, merge = FALSE){
  #workaround for R CMD check bug
  shift_rows <- NULL
  
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
    return(results)}
}
