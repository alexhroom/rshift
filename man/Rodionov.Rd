\name{Rodionov}
\title{Rodionov STARS test}

\description{performs STARS analysis (Rodionov, 2004) on a dataset.}
\usage{Rodionov(data, col, time, l, [prob, startrow, merge])}
\arguments{
  \item{data}{The dataframe to use.}
  \item{col}{The column on which change is measured.}
  \item{time}{The column containing time units (e.g. age of a subsample)}
  \item{l}{The cut-off length of a regime; affects sensitivity (see Rodionov, 2004)}
  \item{prob}{(optional) The p-value for significance of a regime shift. Defaults to 0.05.}
  \item{startrow}{(optional) The row from which the algorithm starts - use if you want to ignore some rows. Defaults to 1.}
  \item{merge}{(optional) Changes the result to be either a regime-shift only table (if FALSE), or an addition to the original table (if TRUE. Defaults to FALSE.)}
}
\details{If merge = FALSE (default), produces a 2-column table of time (the time value for each regime shift) and RSI (the RSI for each regime shift). If merge = TRUE, returns the original dataset with an extra RSI column, giving the RSI for each time unit - 0 for non-shift years.}
