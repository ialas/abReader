# abReader

## Instructions:

### Step 1: Requirements.
1. Download app.r, support.r, and place them in the same directory.
2. Have an AntiBase database containing names and structcalc values.

### Step 2: Change file path names.
1. In app.r, change the path of source("text") to the working directory that support.r was stored in.
An example:

`source("C:/Users/User1/Documents/R/abReader/support.r")`

2. In app.r, change the path of abTableChar to match the relevant AntiBase database. An example:

`abTableChar = fread("C:/Users/User1/Documents/R/abReader/antibaseTable.csv", header = TRUE)`

### Step 3: Display Shiny App.
1. Click the button next to |> Run App, and click "Run External" (There are issues with running the Shiny server in R Studio).
2. A webpage should open up, displaying:

### Step 4: Process Data.
1. Click "Browse", and upload the file containing the values you wish to check the AntiBase database against.
2. Input a value for the parts-per-million that you wish to have as a range to search for.
3. Click "RUN" to run the search.

### Step 5: Exporting Results.
1. Click "Download Data", which should prompt you with a csv file named in the following fashion:

`"data-(the current date:)2019-05-22-ppm-(your ppm value).csv"`

2. You can open the results in Excel for ease of viewing.
