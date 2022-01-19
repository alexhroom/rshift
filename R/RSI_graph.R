RSI_graph <- function(data, col, time, rsi){
  #creates two graphs, one of data and one of the RSI,
  #as seen in Rodionov (2004)

  #while Rodionov() requires quotes, this doesn't work if you put quotes around col or time
  p1 <- ggplot(data) + geom_col(aes(x = .data[[time]], y = .data[[col]]))
  p2 <- ggplot(data) + geom_col(aes(x = .data[[time]], y = .data[[rsi]]))
  grid::pushViewport(grid::viewport(layout = grid::grid.layout(2, 1)))
  vplayout <- function(x, y) grid::viewport(layout.pos.row = x, layout.pos.col = y)
  print(p1, vp = vplayout(1, 1))
  print(p2, vp = vplayout(2, 1))
}
