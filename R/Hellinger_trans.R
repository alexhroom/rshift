#' Hellinger transform
#' 
#' Hellinger transforms data (Legendre and Legendre, Numerical Ecology)
#'  
#' @param data The dataframe to be used.
#' @param col The column that change is being measured on.
#' @param site The column containing the site of each sample.
#' @return The `data` dataframe with an added 'hellinger_trans_vals' column.
#' @import dplyr
#' @export
Hellinger_trans <- function(data, col, site){


  #creates an empty table with the original table's columns, plus the hellinger values
  #i'm aware this is incredibly hacky, but i couldn't find a better way
  results <- filter(cbind(data, hellinger_trans_vals = c(1:nrow(data))), col == "hack")
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
