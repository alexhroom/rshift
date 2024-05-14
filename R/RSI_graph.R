#' Regime Shift Index graph
#'
#' creates two graphs, one of data and one of the RSI, as seen in Rodionov (2004)
#'
#' @param data The dataframe that will be used.
#' @param col The column we are measuring change on.
#' @param time The column containing time units (e.g. age of a subsample)
#' @param rsi The column containing RSI values (for best visualisation use Rodionov() with merge=TRUE)
#' @param mean_lines If true, add lines over the data indicating the mean of each regime.
#' @return Two graphs, one on top of the other; one of col against time and one of RSI against time.
#' @examples 
#' RSI_graph(lake_RSI, "DCA1", "Age", "RSI")
#' @importFrom ggplot2 ggplot geom_col geom_line aes
#'
#' @export
RSI_graph <- function(data, col, time, rsi, mean_lines = FALSE){
  p1 <- ggplot(data) + geom_col(aes(x = .data[[time]], y = .data[[col]]))
  if(mean_lines){  # add mean lines if asked for
    means <- regime_means(data, col, rsi)
    p1 <- p1 + geom_line(aes(x = .data[[time]], y = means), color='red')
  }
  p2 <- ggplot(data) + geom_col(aes(x = .data[[time]], y = .data[[rsi]]))
  grid::pushViewport(grid::viewport(layout = grid::grid.layout(2, 1)))
  vplayout <- function(x, y) grid::viewport(layout.pos.row = x, layout.pos.col = y)
  print(p1, vp = vplayout(1, 1))
  print(p2, vp = vplayout(2, 1))
}
