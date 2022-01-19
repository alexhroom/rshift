\name{absolute_to_percentage}
\title{Absolute to Percentage}

\description{Converts absolute abundance data for each site into percentage of total abundance per site.}
\usage{absolute_to_percentage(data, col, site)}
\arguments{
  \item{data}{The dataframe to use.}
  \item{col}{The column on which change is measured.}
  \item{site}{The column containing the site of each sample.}}
\details{Returns the original dataframe with an added column 'percentage', containing percentage abundance values for each data point.}
