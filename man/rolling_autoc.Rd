\name{rolling_autoc}
\title{Rolling Autocorrelation}

\description{Finds rolling autocorrelation over an interval. (Used experimentally for early warning signs: see Liu, Gao & Wang, 2018).}
\usage{rolling_autoc(data, col, l)}
\arguments{
  \item{data}{The dataframe to use.}
  \item{col}{The column on which change is measured.}
  \item{l}{The time interval (no. of columns) used in the autocorrelation.}
}
\details{Returns a table of rolling lag-1 autocorrelation values.}
