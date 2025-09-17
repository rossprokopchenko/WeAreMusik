from fastapi import FastAPI, Query
from fastapi.responses import JSONResponse
from typing import List
import recommender
from contextlib import asynccontextmanager
import asyncio

class FastAPIWrapper:
    def __init__(self):
        self._recommender = None

        # Define lifespan event handler
        @asynccontextmanager
        async def lifespan(app: FastAPI):
            # This runs after uvicorn starts
            print("Initializing ListenBrainzRecommender in background...")
            # Use asyncio.to_thread if initialization is blocking
            self._recommender = await asyncio.to_thread(recommender.ListenBrainzRecommender)
            yield
            # Optional cleanup after shutdown
            print("Shutting down...")

        # Create app with lifespan handler
        self.app = FastAPI(lifespan=lifespan)
        self._add_routes()

    @property
    def recommender(self):
        if self._recommender is None:
            self._recommender = recommender.ListenBrainzRecommender()
        return self._recommender

    def _add_routes(self):
        @self.app.get("/recommend/")
        async def get_recommendations(
                artist_mbid: str = Query(..., description="The MBID of the artist to query"),
                limit: int = Query(10, description="Number of similar artists to return")) -> JSONResponse:
            # Use the single instance of recommender
            recommendations = self.recommender.get_similar_artists(artist_mbid, limit)
            return JSONResponse(content={"artist_mbids": recommendations})

# Create a single instance at module level
wrapper = FastAPIWrapper()
app = wrapper.app  # uvicorn uses this

# Optional: allow running with `python my_module.py`
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
