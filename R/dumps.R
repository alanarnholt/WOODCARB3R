#' Calculates carbon in landfills and dumps.
#'
#' @param years years to calculate values for
#' @param approach approach to use
#' @return total carbon from solid waste disposal sites
carbonfromdumps <- function(years, approach = c("Production", "Stock Change")) {


    a <- match.arg(approach)

    environment(calculatedumpcarbonproduction) <- environment()
    environment(calculatedumpcarbonstockchange) <- environment()
    if (approach == "Production") {
        return(calculatedumpcarbonproduction(years, totalcarbonstockchange = TRUE))
    } else if (approach == "Stock Change") {
        return(calculatedumpcarbonstockchange(years, totalcarbonstockchange = TRUE))
    }
}

#' Calculate carbon in SWDS for the Stock Change Method
#'
#' @param years years to calculate
#' @param totalcarbonstockchange Whether to return data frame of intermedate calculations or
#'  just totals
#' @return If totalcarbonstockchange is false: a data frame of intermediate
#'  calculations.  If totalcarbonstockchange is true: a numeric vector of stock change
#'  for total carbon from dumps.
calculatedumpcarbonstockchange <- function(years, totalcarbonstockchange = FALSE) {
    ys <- minyr:max(years)

    environment(calcUSApaper) <- environment()
    usa <- calcUSApaper(ys)

    c <- calcplacediu(ys, approach = "Stock Change")
    swp <- swpcarbontotal(Yrs = ys, approach = "Stock Change")

    PRM45 <- 1 - swpSwdsNondegradable
    PRM46 <- 1 - paperSwdsNondegradable
    CalcUSA <- data.frame(Years = ys)

    CalcUSA$TotalCarbonOutputStockChange <- sapply(ys, function(year) {
        if (year == minyr) {
            return(c[year - (minyr - 1)] - swpcarbontotal(Yrs = year,
                lumberpre = FALSE, approach = "Stock Change"))
        } else {
            return((swp[year - minyr] + c[year - (minyr - 1)]) - (swp[year -
                (minyr - 1)]))
        }
    })

    CalcUSA$ParamResults_Q <- woodToDumps[ys - (minyr - 1), 1]

    CalcUSA$Dumps_C <- PRM57 * CalcUSA$TotalCarbonOutputStockChange *
        woodToCarbon * CalcUSA$ParamResults_Q


    for (year in ys) {
        if (year == 1900)
            CalcUSA$Dumps_D[1] <- (1/(1 + swpDumpDecay)) * CalcUSA$Dumps_C[year -
                (minyr - 1)] else CalcUSA$Dumps_D[year - (minyr - 1)] <- (1/(1 + swpDumpDecay)) *
                    (CalcUSA$Dumps_D[year - minyr] + CalcUSA$Dumps_C[year - (minyr - 1)])
    }

    CalcUSA$Q <- woodToLandFills[ys - (minyr - 1), 1] * PRJ96 * CalcUSA$TotalCarbonOutputStockChange *
        woodToCarbon

    for (year in ys) {
        if (year == minyr) {
            CalcUSA$Dumps_F[year - (minyr - 1)] <- CalcUSA$Dumps_D[year -
                (minyr - 1)]
        } else {
            CalcUSA$Dumps_F[year - (minyr - 1)] <- CalcUSA$Dumps_D[year -
                (minyr - 1)] - CalcUSA$Dumps_D[year - minyr]
        }
    }

    CalcUSA$X <- PRM45 * CalcUSA$Q

    for (year in ys) {
        if (year == minyr) {
          CalcUSA$Y[year - (minyr - 1)] <- (1/(1 + swpLandfillDecay)) * CalcUSA$X[year -
                                                                 (minyr - 1)]
        } else {
          CalcUSA$Y[year - (minyr - 1)] <- (1/(1 + swpLandfillDecay)) * (CalcUSA$Y[year -
                                                                  (minyr)] + CalcUSA$X[year - (minyr - 1)])

        }
    }


    CalcUSA$AA <- sapply(ys, function(year) {
        if (year == minyr) {
            return(CalcUSA$Y[year - (minyr - 1)])
        }
        return(CalcUSA$Y[year - (minyr - 1)] - CalcUSA$Y[year - minyr])
    })

    CalcUSA$V <- swpSwdsNondegradable * CalcUSA$Q

    CalcUSA$D <- paperToCarbon * usa$`Percent of Wood Pulp For Paper` * usa$`Paper+Paperboard Consumption`

    for (year in ys) {
        if (year == minyr) {
            CalcUSA$J[year - (minyr - 1)] <- (exp(-log(2)/PRP10)) *
                (CalcUSA$D[year - (minyr - 1)])
        } else {
            CalcUSA$J[year - (minyr - 1)] <- (exp(-log(2)/PRP10)) *
                (CalcUSA$D[year - (minyr - 1)] + CalcUSA$J[year - minyr])
        }
    }

    for (year in ys) {
        if (year == minyr) {
            CalcUSA$K[year - (minyr - 1)] <- CalcUSA$D[year - (minyr -
                1)] - CalcUSA$J[year - (minyr - 1)]
        } else {
            CalcUSA$K[year - (minyr - 1)] <- CalcUSA$J[year - (minyr)] +
                CalcUSA$D[year - (minyr - 1)] - CalcUSA$J[year - (minyr -
                1)]
        }
    }


    CalcUSA$Dumps_H <- PRM57 * CalcUSA$K * woodToDumps[ys - (minyr -
        1), 1]

    for (y in ys) {
        if (y == minyr) {
            CalcUSA$Dumps_I[y - (minyr - 1)] <- (1/(1 + paperDumpDecay)) * CalcUSA$Dumps_H[y - (minyr - 1)]
        } else {
            CalcUSA$Dumps_I[y - (minyr - 1)] <- (1/(1 + paperDumpDecay)) * (CalcUSA$Dumps_I[y -minyr] +
                                                                     CalcUSA$Dumps_H[y - (minyr - 1)])
        }
    }

    CalcUSA$R <- PRI96 * CalcUSA$K * paperToLandFills[ys - (minyr - 1), 1]

    CalcUSA$AG <- paperSwdsNondegradable * CalcUSA$R

    for (y in ys) {
        if (y == minyr) {
            CalcUSA$Dumps_K[y - (minyr - 1)] <- CalcUSA$Dumps_I[y -
                (minyr - 1)]
        } else {
            CalcUSA$Dumps_K[y - (minyr - 1)] <- CalcUSA$Dumps_I[y -
                (minyr - 1)] - CalcUSA$Dumps_I[y - (minyr)]
        }
    }


    CalcUSA$AI <- PRM46 * CalcUSA$R

    for (y in ys) {
        if (y == minyr) {
            CalcUSA$AJ[y - (minyr - 1)] <- (1/(1 + paperLandfillDecay)) * CalcUSA$AI[y -
                (minyr - 1)]
        } else {
            CalcUSA$AJ[y - (minyr - 1)] <- (1/(1 + paperLandfillDecay)) * (CalcUSA$AJ[y -
                minyr] + CalcUSA$AI[y - (minyr - 1)])
        }
    }

    CalcUSA$AL <- sapply(ys, function(y) {
        if (y < 1901) {
            return(CalcUSA$AJ[y - (minyr - 1)])
        }
        if (y > 1900) {
            return(CalcUSA$AJ[y - (minyr - 1)] - CalcUSA$AJ[y - minyr])
        }
    })

    CalcUSA$Total_swpstock_change_LD <- CalcUSA$AA + CalcUSA$V + CalcUSA$Dumps_F

    CalcUSA$Total_paper_stock_change_LD <- CalcUSA$AG + CalcUSA$AL + CalcUSA$Dumps_K

    CalcUSA$Var1b_STOCKCHANGE_TOTAL <- (CalcUSA$Total_swpstock_change_LD +
        CalcUSA$Total_paper_stock_change_LD)

    if (totalcarbonstockchange == TRUE) {
        return(CalcUSA$Var1b_STOCKCHANGE_TOTAL[years - (minyr - 1)])
    } else {
        CalcUSA[years - (minyr - 1), ]
    }
}

#' Calculate carbon in SWDS for the Production Method
#'
#' Column names with only letters come from Calc sheet, otherwise sheet is specified (need to change names)
#'
#' @param years years to calculate
#' @param totalcarbonstockchange If true, returns carbon stock change, or returns data
#' frame of intermediate calculations
#' @return Either a data frame of values from Calculation spreadsheet or total carbon output
calculatedumpcarbonproduction <- function(years, totalcarbonstockchange = FALSE) {
    ys <- minyr:max(years)

    environment(calcUSApaper) <- environment()
    usa <- calcUSApaper(ys)

    c <- calcplacediu(ys, approach = "Production")#.135 seconds

    swp <- as.numeric(swpcarbontotal(Yrs = ys))
    CalcUSA <- data.frame(Years = ys)

    PRM45 <- 1- swpSwdsNondegradable
    PRM46 <- 1 - paperSwdsNondegradable
    for (y in ys) {
        if (y == minyr) {
            CalcUSA$CA[1] <- exp(-log(2)/PRP10) * (usa$`Production Approach-C Input from Paper Products(Calc BU)`[y -
                (minyr - 1)])
        } else {
            CalcUSA$CA[y - (minyr - 1)] <- exp(-log(2)/PRP10) * (usa$`Production Approach-C Input from Paper Products(Calc BU)`[y -
                (minyr - 1)] + CalcUSA$CA[y - minyr])
        }
    }

    for (y in ys) {
        if (y == minyr) {
            CalcUSA$CB[y - (minyr - 1)] <- usa$`Production Approach-C Input from Paper Products(Calc BU)`[y -
                (minyr - 1)] - CalcUSA$CA[y - (minyr - 1)]
        } else {
            CalcUSA$CB[y - (minyr - 1)] <- CalcUSA$CA[y - minyr] + usa$`Production Approach-C Input from Paper Products(Calc BU)`[y -
                (minyr - 1)] - CalcUSA$CA[y - (minyr - 1)]
        }
    }

    CalcUSA$ParamResults_V <- paperToLandFills[ys - (minyr - 1),1]

    CalcUSA$ParamResults_P <- PRI96 * CalcUSA$ParamResults_V

    CalcUSA$CI <- CalcUSA$ParamResults_P * CalcUSA$CB

    CalcUSA$CS <- paperSwdsNondegradable * CalcUSA$CI

    CalcUSA$CU <- PRM46 * CalcUSA$CI

    for (year in ys) {
        if (year == minyr)
            CalcUSA$CV[1] <- (1/(1 + paperLandfillDecay)) * CalcUSA$CU[year - (minyr -
                1)] else CalcUSA$CV[year - (minyr - 1)] <- (1/(1 + paperLandfillDecay)) * (CalcUSA$CV[year -
            minyr] + CalcUSA$CU[year - (minyr - 1)])
    }

    CalcUSA$CX <- sapply(ys, function(y) {
        if (y == minyr) {
            return(0)
        } else {
            return(CalcUSA$CV[y - (minyr - 1)] - CalcUSA$CV[y - minyr])
        }
    })

    CalcUSA$ParamResults_Q <- woodToDumps[ys - (minyr - 1), 1]

    CalcUSA$Dumps_S <- PRM57 * CalcUSA$CB * CalcUSA$ParamResults_Q

    ### P+R 'O200' column, woodTolandfills is data linked to another site,
    ### not sure how it's calculated.
    CalcUSA$ParamResults_O <- woodToLandFills[ys - (minyr - 1), ] * PRJ96

    for (year in ys) {
        if (year == minyr)
            CalcUSA$Dumps_T[1] <- (1/(1 + paperDumpDecay)) * CalcUSA$Dumps_S[year -
                (minyr - 1)] else CalcUSA$Dumps_T[year - (minyr - 1)] <- (1/(1 + paperDumpDecay)) *
            (CalcUSA$Dumps_T[year - minyr] + CalcUSA$Dumps_S[year -
                (minyr - 1)])
    }

    CalcUSA$Dumps_V <- sapply(ys, function(year) {
        if (year == minyr) {
            return(CalcUSA$Dumps_T[year - (minyr - 1)])
        } else {
            return(CalcUSA$Dumps_T[year - (minyr - 1)] - CalcUSA$Dumps_T[year -
                minyr])
        }
    })

    CalcUSA$TotalCarbonOutput <- sapply(ys, function(year) {
        if (year == minyr) {
            return(c[year - (minyr - 1)] - swpcarbontotal(Yrs = year,
                lumberpre = FALSE))
        } else {
            return((swp[year - minyr] + c[year - (minyr - 1)]) - (swp[year -
                (minyr - 1)]))
        }
    })

    CalcUSA$CM <- woodToCarbon * PRM45 * CalcUSA$ParamResults_O * CalcUSA$TotalCarbonOutput


    for (year in ys) {
        if (year == minyr)
            CalcUSA$CN[1] <- (1/(1 + swpLandfillDecay)) * CalcUSA$CM[year - (minyr -
                1)] else CalcUSA$CN[year - (minyr - 1)] <- (1/(1 + swpLandfillDecay)) * (CalcUSA$CN[year -
            minyr] + CalcUSA$CM[year - (minyr - 1)])
    }

    CalcUSA$Dumps_N <- PRM57 * CalcUSA$TotalCarbonOutput * woodToCarbon * CalcUSA$ParamResults_Q

    for (year in ys) {
        if (year == minyr)
            CalcUSA$Dumps_O[1] <- (1/(1 + swpDumpDecay)) * CalcUSA$Dumps_N[year -
                (minyr - 1)] else CalcUSA$Dumps_O[year - (minyr - 1)] <- (1/(1 + swpDumpDecay)) *
            (CalcUSA$Dumps_O[year - minyr] + CalcUSA$Dumps_N[year -
                (minyr - 1)])
    }

    CalcUSA$BX <- woodToCarbon * CalcUSA$TotalCarbonOutput

    CalcUSA$CH <- CalcUSA$ParamResults_O * CalcUSA$BX

    CalcUSA$CK <- swpSwdsNondegradable * CalcUSA$CH

    for (year in ys) {
        if (year == minyr)
            CalcUSA$CL[1] <- CalcUSA$CK[year - (minyr - 1)] else CalcUSA$CL[year - (minyr - 1)] <- CalcUSA$CL[year - minyr] +
            CalcUSA$CK[year - (minyr - 1)]
    }

    for (year in ys) {
        if (year == minyr)
            CalcUSA$CT[1] <- CalcUSA$CS[year - (minyr - 1)] else CalcUSA$CT[year - (minyr - 1)] <- CalcUSA$CT[year - minyr] +
            CalcUSA$CS[year - (minyr - 1)]
    }

    CalcUSA$C_SWP_StockChange_LFDumps <- sapply(ys, function(y) {
        if (y == 1900) {
            return(swpSwdsNondegradable * CalcUSA$ParamResults_O[y - (minyr -
                1)] * CalcUSA$TotalCarbonOutput[y - (minyr - 1)] * woodToCarbon +
                (CalcUSA$CM[y - (minyr - 1)]) + CalcUSA$Dumps_O[y -
                (minyr - 1)])
        } else {
            return(swpSwdsNondegradable * CalcUSA$ParamResults_O[y - (minyr -
                1)] * CalcUSA$TotalCarbonOutput[y - (minyr - 1)] * woodToCarbon +
                (CalcUSA$CN[y - (minyr - 1)] - CalcUSA$CN[y - minyr]) +
                (CalcUSA$Dumps_O[y - (minyr - 1)] - CalcUSA$Dumps_O[y -
                  minyr]))
        }
    })

    CalcUSA$C_PAPER_StockChange_LFDumps <- CalcUSA$CS + CalcUSA$CX + CalcUSA$Dumps_V

    CalcUSA$TotalC_StockChange_SWDSProduction <- CalcUSA$C_PAPER_StockChange_LFDumps +
        CalcUSA$C_SWP_StockChange_LFDumps


    if (totalcarbonstockchange == TRUE) {
        return(CalcUSA$TotalC_StockChange_SWDSProduction[years - (minyr -
            1)])
    }
    CalcUSA[years - (minyr - 1), ]
}











