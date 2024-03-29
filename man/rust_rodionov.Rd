% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extendr-wrappers.R
\name{rust_rodionov}
\alias{rust_rodionov}
\title{Calculate STARS RSI points and return to R as a vector}
\usage{
rust_rodionov(vals, t_crit, l)
}
\arguments{
\item{vals}{The column we are measuring change on}

\item{t_crit}{The critical value of a t-distribution at the desired p-value}

\item{l}{The cut-off length of a regime; affects sensitivity}
}
\description{
Calculate STARS RSI points and return to R as a vector
}
