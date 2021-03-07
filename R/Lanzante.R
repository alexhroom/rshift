Lanzante <- function(data, col, time, p =0.05, merge = FALSE){
  #performs the L-method for detection of regime shifts
  #Lanzante, 1996

  #ranks values in column - also gets rows because
  #the for loop doesn't like me putting it straight in
  nrows_full <- nrow(data)

  #imports a copy of the data so we can remove rows for iteration
  db <- data

  #vectors for later
  SR_vec <- vector()
  SA_vec <- vector()
  shift_years <- vector()
  p_vals <- vector()

  #creates rank sum and adjusted sum table
  for(n in 1:nrows_full){
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
      shift_at <- slice(db, n_1) %>%
        select(all_of(time))
      shift_years <- c(shift_years, as.numeric(shift_at))
      db <- db %>%
        slice(-c(n_1))
    } else {
      break
    }
  }

  #creates results table
  results <- as.tibble(cbind(shift_years, p_vals))

  timename <- data %>%
    select(all_of(time))
  timename <- colnames(timename)

  names(results)[1] <- timename

  if(merge == FALSE){
    return(results)}
  else{
    results <- full_join(data, results, by = time)
    results[is.na(results)] <- 0
    return(results)}
  }
