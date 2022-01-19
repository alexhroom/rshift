\name{Lanzante}
\title{Lanzante L-test}

\description{Performs a L-test (Lanzante, 1996) to find regime shifts.}
\usage{Lanzante(data, col, time, [p, merge])}
\arguments{
  \item{data}{The dataframe that will be used.}
  \item{col}{The column that we are measuring change on.}
  \item{time}{The column containing time units (e.g. age of a subsample)}
  \item{p}{(optional) The largest p-value you want to check regime shifts for. Defaults to 0.05.}
  \item{merge}{(optional) changes the result to be either a regime-shift only table (if FALSE), or an addition to the original table (if TRUE). Defaults to FALSE.}
}
\details{If merge = FALSE, produces a 2-column table of time (the time value for each regime shift) and p (the p-value for each regime shift). If merge = TRUE, returns the original dataset with an extra p-value column, giving the p-value for each time unit - 0 for non-shift years.}
