from fastapi import FastAPI

import csvReader
from csvReader import readArchiveOneData

pathToDataset = 'datasets/archive1/dataset.csv'
tracksetOne = csvReader.readArchiveOneData(pathToDataset)

app = FastAPI()

@app.get("/tags")
async def read_root():
    return {"Message": "Congrats! This is a sleep tagging system!"}

@app.get("/tracks")
async def get_tracks():
    return tracksetOne
