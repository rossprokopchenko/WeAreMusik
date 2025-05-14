from fastapi import FastAPI

import csvReader
from csvReader import readTrackDataset

pathToDataset = 'datasets/spotify_millsongdata.csv/tracks_features.csv'
tracksetOne = csvReader.readTrackDataset(pathToDataset)

app = FastAPI()

@app.get("/tags")
async def read_root():
    return {"Message": "Congrats! This is a sleep tagging system!"}

@app.get("/tracks")
async def get_tracks():
    return tracksetOne
