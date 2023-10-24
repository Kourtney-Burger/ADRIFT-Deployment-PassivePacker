# Copy example text from DB to here
jsonText <- '{"analyst": "Cory Hom-Weaver",
"analyst_uuid": "50ef109b-7ae0-40a9-b2a5-130d1cacb919",
"quality_details":
    [
        {"quality": "Good",
        "low_freq": "20",
        "high_freq": "576000",
        "start": "2018-11-22T08:28:24",
        "end": "2018-12-03T00:49:11",
        "comments": "",
        "channels": [1]},

        {"quality": "Unusable",
        "low_freq": "0",
        "high_freq": "20",
        "start": "2018-11-22T08:28:24",
        "end": "2018-12-03T00:49:11",
        "comments": "", "channels": [1]}
        ],
"method": "",
"objectives": "",
"abstract": ""}'


library(rjson)
# Turn that into an R list
jsonList <- fromJSON(jsonText)
# We can look at this R list and use it as a template
# for the list we want to create
View(jsonList)
### Next figure out how to fill in the pieces of the above
### list with our own data from deploydetails/etc,

### And turn that list into a JSON text
jsonOut <- toJSON(jsonList)
cat(jsonOut)
# That can be used for the "BLOB" input in the db
