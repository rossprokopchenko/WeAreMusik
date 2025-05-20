from fastapi import FastAPI

import csvReader
from csvReader import readTrackDataset
from typing import List
from fastapi import FastAPI, Query
from fastapi.responses import JSONResponse
from operator import itemgetter
import random
import learning

pathToDataset = 'datasets/spotify_millsongdata.csv/tracks_features.csv'
trackset = csvReader.readTrackDataset(pathToDataset)

app = FastAPI()

@app.get("/tracks")
async def get_tracks() -> JSONResponse:
    return JSONResponse(content=trackset)

@app.get("/recommend/")
async def get_recommendations(ids: List[str] = Query(...)) -> JSONResponse:
    print("Received IDs: {}".format(ids))

    recommendations = learning.find_similar_tracks(ids)

    print("Processed recommendations: {}".format(recommendations))

    return JSONResponse(content={"track_ids": recommendations})