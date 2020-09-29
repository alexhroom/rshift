Lanzante <- function(data, col, time, merge = TRUE){
  #performs the L-method for detection of regime shifts
  #Lanzante, 1996
  
  #ranks values in column - also gets rows because
  #the for loop doesn't like me putting it straight in
  ranks <- rank(data[[col]])
  nrows <- nrow(data)
  
  #empty vectors for later
  SR_vec <- vector()
  SA_vec <- vector()

  #creates rank sum and adjusted sum table
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
  return(z)
}