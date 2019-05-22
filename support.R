#Date Started: 05/14/2019
#Started by: IALAS
#WORKS: 05/14/2019

#Updates:
#5/16/19: Incorporated adducts.
#5/20/19: Now functional with even up to 323,755 values being passed.
#5/20/19: Optimized runtime from 4 hours to 1 hour.
#5/22/19: Cleaned code for readability.

# LAYOUT ------------------------------------------------------------------

#NOTES:
#This function is designed to handle all of the backend support for the Shiny Server used in the AntiBase reader.

#Inputs include:
#1) File of values.
#2) The AntiBase dataset.
#3) The ppm value.

#Potential Libraries to include:
#1) Data.Table

#Outputs include:
#1) A data table containing:
  #1) The name of the potential compounds.
  #2) The structCalc of the potential compounds.
  #3) The original structCalc of the input values (adduct version if used).
  #4) The adduct type

#Ideally, looks like:
#  OG SC1 | NAME1 | FOUND SC1 | Adduct Type ?
#  OG SC1 | NAME2 | FOUND SC2 | Adduct Type ?
#  OG SC2 | NAME3 | FOUND SC3 | Adduct Type ?
#  OG SC2 | NAME4 | FOUND SC4 | Adduct Type ?
#and so on.

#SECTIONS (UPDATED: 5/22/2019):
#1) LAYOUT
#2) DEFINE FUNCTION
  #2A) LOAD LIBRARIES, INPUTS.
  #2B) SEPARATE AND CLEAN ANTIBASE STRUCTCALC VALUES.
  #2C) ITERATE THROUGH INPUT VALUES TO SEARCH FOR.
  #2D) ITERATE THROUGH VARIOUS ADDUCT TYPES.
  #2E) USE BETWEEN FUNCTION TO FIND INDICES OF STRUCTCALC VALUES BETWEEN PPM RANGE.
  #2F) USE THE INDICES TO FIND THE STRUCTCALC VALUES, NAMES, AND RETAIN THE ADDUCT TYPE USED TO FIND THOSE COMPOUNDS.
  #2G) GENERATE DATA TABLE WITH ORIGINAL SC, NAME, FOUND SC, AND ADDUCT TYPE.
  #2H) CONTINUE ITERATION THROUGH 2C.
  #2I) ...
  #2J) RETURN DATA TABLE CONTAINING ALL FOUND VALUES IN ANTIBASE.


# DEFINE FUNCTION ---------------------------------------------------------

findSC <- function(dataFile, ppm, antiBase) {
  #Load relevant libraries (between function).
  library(data.table)
  #Re-assign ppm, convert to proper units.
  sens <- ppm*(10^-6)
  #Load antiBase dataset
  abTable <- antiBase
  #Separate SC values
  abTableSC <- abTable$StructCalc
  #Remove trailing periods and clutter
  abTableSC[] = sapply(abTableSC,gsub,pattern=" .*",replacement="")
  #Change all empty sections to NA
  abTableSC[] = sapply(abTableSC, gsub, pattern = "^$", replacement = "IGNORE")
  #Make an empty data table to eventually return
  resultTable = setNames(data.table(matrix(nrow = 0, ncol = 4)),
                       c("givenSC", "foundName", "foundSC", "adductType"))
  #Make an empty container to store lower and upper bounds.
  container = c(0, 0)
  #Below numbers are from PoPCAR (for Adducts)
  #Proton mass in kg to mass in u
  proton = 1.6726231/1.6605402
  #Electron mass in kg to mass in u
  electron = (9.1093897/1.6605402)/(10000)
  #Protonplus
  protonPlus = proton - electron
  #Sodium
  sodium = 22.989768
  sodiumPlus = sodium - electron
  #Name the list of the various adduct possibilities (moved outside for loop for speed)
  massValNames <- c("M", "M+", "[M+H]+", "[M+Na]+")
  #moved outside of both for loop to optimize speed slightly.
  ab_SCDF = suppressWarnings(data.frame(as.numeric(abTableSC))) #introduces NAs, suppress the error warning
  ab_SCDF = replace(ab_SCDF, is.na(ab_SCDF), -10) #converts all NAs to -10
  #Iterate through .dat file.
  for (val in 1:ncol(dataFile)){ #seq_along(dataFile$V1)){
    #print(val) (use to see if running)
    #Can use paste0("V", val), then pass that as the search in the dataFile
    #Store the given SC value used to search for the SC and Name.
    massVal = dataFile[[paste0("V", val)]] #the double brackets allow us to access just the value we want
    # ^ if the column names are V#, this should work.
    #Make a list of the various adduct possibilities.
    massValList <- c(massVal, massVal - electron, massVal + protonPlus, massVal + sodiumPlus)
    #Create a counter
    counter = 0
    #Iterate through each adduct possibility.
    for (value in massValList){
      counter = counter + 1
      ##Add/Subtract sensitivity to form the boundaries of the search.
      container[1] = massValList[counter] + sens
      container[2] = massValList[counter] - sens
      #Between function returns TRUE or FALSE logicals for each index
      indTF = between(ab_SCDF, container[2], container[1], incbounds=TRUE)
      #Find SC values between given range and store them. (only returns SC values who were listed as TRUE in indTF)
      foundSC = ab_SCDF[indTF]
      #Find names of SC values between given range and store them.
      foundName = abTable$Name[indTF]
      #Generate lists of the given SC values of a size based on the found SC list
      givenSC <- rep(list(value), length(foundSC))
      #Store the type of the Adduct that was observed.
      adductType <-  massValNames[counter]
      #Make a list of the Adduct of size based on the found SC list
      adductType <- rep(list(adductType), length(foundSC))
      #Formed a data table with columns of the correct vectors (more efficient than cbind)
      dataTable = data.table(givenSC = givenSC, foundName = foundName, foundSC = foundSC, adductType = adductType)
      #Convert to list for rbindlist argument (much more efficient than rbind)
      dataList = list(resultTable, dataTable)
      #Add to previous data tables (use rbindlist)
      resultTable <- rbindlist(dataList)
    }
  }
  return(resultTable)
}
