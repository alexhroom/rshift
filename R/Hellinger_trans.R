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
