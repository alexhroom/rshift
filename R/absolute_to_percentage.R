#' Converts absolute abundance data to a percentage of total abundance for each site
#'
#' @param data The dataframe to be used.
#' @param col The column that change is being measured on.
#' @param site The column containing the site of each sample.
#' @return The `data` dataframe with an added 'percentage' column.
#' @import dplyr
#' @export 
absolute_to_percentage <- function(data, col, site){

  #creates an empty table with the original table's columns, plus the percentage values
  #i'm aware this is incredibly hacky, but i couldn't find a better way
  results <- filter(cbind(data, hellinger_trans_vals = c(1:nrow(data))), col == "hack")
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
