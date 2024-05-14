#' Calculate means for each regime
#'
#' calculates the mean for each regime in a regime shift analysis.
#'
#' @param data The dataframe that will be used.
#' @param col The column we are measuring change on.
#' @param rsi The column containing RSI values.
#' @return A vector of the mean value for each regime.
#' @examples 
#' regime_means(lake_RSI, "DCA1", "RSI")
#' @importFrom ggplot2 ggplot geom_col aes
#'
#' @export
regime_means <- function(data, col, rsi){  
  col <- data[[col]]
  rsi <- data[[rsi]]
  current_regime <- c()
  regime_means <- c()
  
  for(i in seq_along(col)){
    if(rsi[i] == 0){
      current_regime <- c(current_regime, col[i])
    } 
    else {
      regime_means <- c(regime_means, rep(mean(current_regime), length(current_regime)))
      current_regime <- c(col[i])  # reset regime
    }
  }
  # calculate means for last regime
  regime_means <- c(regime_means, rep(mean(current_regime), length(current_regime)))
  return(regime_means)
}