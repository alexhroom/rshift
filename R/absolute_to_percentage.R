absolute_to_percentage <- function(data, col, site){
  #converts absolute abundance data to a percentage of total abundance for each site

  #creates an empty table with the original table's columns, plus the hellinger values
  #i'm aware this is incredibly hacky, but i couldn't find a better way
  results <- data %>%
    cbind(percentage = c(1:nrow(data))) %>%
    filter(col == "bad programming")
  #finds values for each site
  unique_sites <- unique(data[[site]])
  for(s in unique_sites){
    site_obs <- data[data[[site]] == s,]
    sum <- sum(site_obs[col], na.rm = TRUE)
    site_obs <- mutate(site_obs, percentage = (site_obs[col] * 100) / sum)
    #binds values for each site back into a copy of the original data set
    results <- rbind(results, site_obs)
  }
  return(results)
}
