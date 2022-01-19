\name{RSI_graph}
\title{Regime Shift Index Graph}

\description{Creates a pair of graphs from a dataset, one of a variable against time, and one of the RSI against time. Good for visualisation of regime shifts analysis.}
\usage{RSI_graph(data, col, time, rsi)}
\arguments{
  \item{data}{The dataframe to use.}
  \item{col}{The column on which change is measured.}
  \item{time}{The column containing time units (e.g. age of a subsample)}
  \item{rsi}{The column containing RSI values.}
}
\details{If merge = FALSE (default), produces a 2-column table of time (the time value for each regime shift) and RSI (the RSI for each regime shift). If merge = TRUE, returns the original dataset with an extra RSI column, giving the RSI for each time unit - 0 for non-shift years.

For best visualisation (i.e. both graphs on a 1:1 scale), ensure RSI values of 0 are 0's, rather than NA (for example, using the merge functionality of Rodionov()}
