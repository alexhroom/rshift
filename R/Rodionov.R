#'  Rodionov (2004)'s STARS algorithm
#'
#'  performs STARS analysis (Rodionov, 2004) on a dataset
#'
#' @param data The dataframe to be used.
#' @param col The column we are measuring change on.
#' @param time The column containing time units (e.g. age of a subsample)
#' @param l The cut-off length of a regime; affects sensitivity (see Rodionov, 2004)
#' @param prob The p-value for significance of a regime shift. Defaults to p = 0.05.  
#' @param startrow What row the analysis starts at. Defaults to 1.
#' @param merge Sets the result to be either a regime-shift only table (if FALSE), or an addition to the original table (if TRUE)
#' @return If merge = FALSE (default), produces a 2-column table of time (the time value for each regime shift) and RSI (the regime shift index for each regime shift). If merge = TRUE, returns the original dataset with an extra RSI column, giving the regime shift index for each time unit - 0 for non-shift years.
#' @examples 
#' Rodionov(lake_data, "DCA1", "Age", l=5)
#' Rodionov(lake_data, "DCA1", "Age", l=5, prob=0.01, startrow=2, merge=TRUE)
#' @importFrom stats qt
#' @export 
Rodionov <- function(data, col, time, l, prob = 0.05, startrow = 1, merge = FALSE){
  vals <- data[[col]]
  t_crit <- abs(qt(prob/2, (2 * l - 2)))  # the fiddling is to get two-tailed test
  
  # call Rust code and add padding 0's to last l rows
  RSI <- rust_rodionov(vals, t_crit, l)

  #creates results tibble
  output <- cbind(data, RSI)
  if (!merge){
    output <- output[output$RSI>0,]
  }
  return(output)
}
