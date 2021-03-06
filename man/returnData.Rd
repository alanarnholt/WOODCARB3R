% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/returndata.R
\name{returnData}
\alias{returnData}
\title{Returns various intermediate calculations and data sheets.
Includes swp and paper production and trade time series.}
\usage{
returnData(DataSheet = c("USA", "Calculation", "Dumps", "SwCalc", "IPCC"),
  years = 1950:2015)
}
\arguments{
\item{DataSheet}{Several data sheets from Woodcarb II spreadsheet.}

\item{years}{years to return data for}
}
\value{
data frame of intermediate calculations corresponding to appropriate table
in Excel spreadsheet.
}
\description{
Returns various intermediate calculations and data sheets.
Includes swp and paper production and trade time series.
}
\examples{
returnData(DataSheet="SwCalc")
}

