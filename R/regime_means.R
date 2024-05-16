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
#'
#' @export
regime_means <- function(data, col, rsi){
  col <- data[[col]]
  rsi <- data[[rsi]]
  regime_means <- rust_regime_means(col, rsi)
  return(regime_means)
}