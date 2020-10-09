rolling_autoc <- function(data, col, l){
  #finds lag-1 autocorrelation in a rolling window
  #can be used to predict resilience (Liu, Gao, & Wang, 2018)
  nrows <- (nrow(data) - l)
  results <- vector()
  #applies the function to rolling groups of l data entries
  for(i in 1:nrows){
    slice<-slice(data, i:(i+l))
      autocorrelation <- acf(slice[[col]], lag.max = 1, plot = FALSE)
      results <- c(results, autocorrelation$acf[2])
  }
  return(results)
}



###DEPRECATED PART OF CODE###
#creates a function in the rolling_moran environment that calculates
#the distance matrix for the data,
#and performs autocorrelation analysis on it
#f <- function(data, col, depths){
  #dists<-cbind(data[[depths]], rep(0, nrow(data)))
  #distmat <- as.matrix(dist(dists))
  #autocorrelation <- ape::Moran.I(data[[col]], distmat)
  #return(autocorrelation)
