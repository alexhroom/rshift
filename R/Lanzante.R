#' Lanzante L-test
#'
#' performs the L-method for detection of regime shifts (Lanzante, 1996)
#'
#' @param data The dataframe to be used.
#' @param col The column we are measuring change on.
#' @param time The column containing time units (e.g. age of a subsample)
#' @param p The largest p-value you want to check regime shifts for. Defaults to p = 0.05.  
#' @param merge Sets the result to be either a regime-shift only table (if FALSE), or an addition to the original table (if TRUE)
#' @return If merge = FALSE (default), produces a 2-column table of time (the time value for each regime shift) and p (the p-value for each regime shift). If merge = TRUE, returns the original dataset with an extra p-value column, giving the p-value for each time unit - 0 for non-shift years.
#' @examples 
#' Lanzante(lake_data, "DCA1", "Age")
#' Lanzante(lake_data, "DCA1", "Age", p=0.10, merge=TRUE)
#' @import dplyr
#' @importFrom stats pnorm
#' @importFrom tibble as_tibble
#' @export 
Lanzante <- function(data, col, time, p =0.05, merge = FALSE){

  #ranks values in column - also gets rows because
  #the for loop doesn't like me putting it straight in
  nrows_full <- nrow(data)

  #imports a copy of the data so we can remove rows for iteration
  db <- data

  #vectors for later
  shift_years <- vector()
  p_vals <- vector()

  #creates rank sum and adjusted sum table
  for(n in 1:nrows_full){
    
    #vectors for SR and SA
    SR_vec <- vector()
    SA_vec <- vector()
    
    ranks <- rank(db[[col]])
    nrows <- nrow(db)
    for(i in 1:nrows){
      SR <- sum(ranks[1:i])
      SR_vec <- c(SR_vec, SR)
      SA <- abs(2 * SR - i * (nrows + 1))
      SA_vec <- c(SA_vec, SA)
    }
  #creates table of SR and corresponding SA
    sum_vals <- as.data.frame(cbind(SR_vec, SA_vec))

  #gets row with maximum SA value (referred to as n_1 in paper)
    n_1 <- which.max(sum_vals$SA_vec)
    W <- sum_vals$SA_vec[n_1]

  #defines variables for test statistic
    n_2 <- nrows - n_1
    W_crit <- ((n_1 * (nrows + 1)) / 2)
    S_w <- sqrt((n_1 * n_2 * (nrows + 1))/12)
  #conditionals required for sigma
    if(W < W_crit){
      sigma <- 0.5
    } else if (W > W_crit){
      sigma <- -0.5
    } else{
      sigma = 0
  }
    z <- (W - W_crit + sigma) / S_w

  #creates vectors for shift years and their corresponding p-values
    if(pnorm(z) <= p){
      p_vals <- c(p_vals, pnorm(z))
      shift_at <- select(slice(db, n_1), all_of(time))
      shift_years <- c(shift_years, as.numeric(shift_at))
      db <- slice(db, -c(n_1))
    } else {
      break
    }
  }

  #creates results table
  results <- as_tibble(cbind(shift_years, p_vals))

  timename <- select(data, all_of(time))
  timename <- colnames(timename)

  names(results)[1] <- timename

  if(merge == FALSE){
    return(results)}
  else{
    results <- full_join(data, results, by = time)
    results[is.na(results)] <- 0
    return(results)}
  }
