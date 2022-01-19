\name{Hellinger_trans}
\title{Hellinger transform}

\description{Hellinger transforms data (see Nunerical Ecology, Legendre and Legendre). Mutates the original dataset with a column containing Hellinger transformed values.}
\usage{Hellinger_trans(data, col, site)}
\arguments{
  \item{data}{The dataframe to use.}
  \item{col}{The column on which change is measured.}
  \item{site}{The column containing the site of each sample.}}
\details{Returns the original dataset, with an added column ``hellinger_trans_vals``, containing hellinger transformed values for each data point.}
