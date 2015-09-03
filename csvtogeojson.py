import csv

data = csv.reader(open('df.csv', 'rb'))

template = \
    ''' \
    { "type" : "Feature",
        "id" : %s,
            "geometry" : {
                "type" : "Point",
                "coordinates" : ["%s","%s"]},
        "properties" : { "category" : "%s", "date" : "%s", "numberofresponders" : "%s"}
        },
    '''

output = \
    ''' \
 {"type" : "Feature Collection",
    "features" : [
    '''

iter = 0
for row in data:
    iter += 1
    if iter >= 2:
        id = row[0]
        lat = row[1]
        lon = row[2]
        category = row[3]
        date = row[4]
        numberofresponders = row[5]
        output += template % (row[0], row[2], row[1], row[3], row[4], row[5])
        
output += \
    ''' \
    ]
}
    '''
    

out_file = open("output.geojson", "w")
out_file.write(output)
out_file.close()