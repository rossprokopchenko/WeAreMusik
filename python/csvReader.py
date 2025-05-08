import csv
import json

def readArchiveOneData(path):

    with open(path, newline='') as csvfile:

        spamreader = csv.reader(csvfile)
        columns = spamreader.__next__()
        jObjArray = []

        for row in spamreader:
            jObj = {}

            for index, column in enumerate(columns):
                if index == 0:
                    continue

                jObj[column] = row[index]

            jObjArray.append(jObj)

        return jObjArray


jsonObjects = readArchiveOneData('datasets/archive1/dataset.csv')
print(jsonObjects[0])