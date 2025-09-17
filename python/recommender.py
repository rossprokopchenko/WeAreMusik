import yaml
import pandas as pd
import polars as pl
import numpy as np
import implicit
from sqlalchemy import create_engine
from scipy.sparse import csr_matrix
from tqdm import tqdm

class ListenBrainzRecommender:
    def __init__(self, config_path="config.yaml"):
        self.config = self.load_config(config_path)
        self.engine = self.get_engine(self.config)
        self.model = None
        self.artist_id_to_mbid = {}
        self.mbid_to_artist_id = {}

        print("Loading listening history in chunks...")

        lazy_frames = None

        for chunk in self.load_listening_history_streaming(chunksize=200_000):
            lazy_chunk = chunk.lazy()
            if lazy_frames is None:
                lazy_frames = lazy_chunk
            else:
                lazy_frames = pl.concat([lazy_frames, lazy_chunk], rechunk=False)

        print("Building recommendation model...")
        self.build_recommendation_model(lazy_frames)

    @staticmethod
    def load_config(path):
        with open(path, "r") as f:
            return yaml.safe_load(f)

    @staticmethod
    def get_engine(config):
        db = config["listenbrainz_db"]
        url = f"postgresql+psycopg2://{db['user']}:{db['password']}@{db['host']}:{db.get('port', 5432)}/{db['database']}"
        return create_engine(url)

    def load_listening_history_streaming(self, limit=None, chunksize=200_000):
        """
        Load listening history from Postgres using server-side cursor
        for memory-efficient chunked processing.
        """
        # Get raw psycopg2 connection
        conn = self.engine.raw_connection()
        cursor = conn.cursor("streaming_cursor")  # named server-side cursor

        # Build query
        query = """
            SELECT user_id, artist_mbid::text AS artist_mbid, num_listens
            FROM artist_listens
            WHERE artist_mbid IS NOT NULL
            ORDER BY artist_mbid
        """
        if limit is not None:
            query += f" LIMIT {limit}"

        # Execute query
        cursor.execute(query)

        while True:
            rows = cursor.fetchmany(chunksize)
            if not rows:
                break
            # Convert chunk to DataFrame
            df_chunk = pl.DataFrame(rows, schema=["user_id", "artist_mbid", "num_listens"])
            yield df_chunk

        # Close cursor and connection
        cursor.close()
        conn.close()

    def build_recommendation_model(self, df, user_col="user_id", artist_col="artist_mbid",
                                   num_listens_col="num_listens",
                                   factors=10, regularization=0.1, iterations=5):
        """
        Build ALS recommender from a Polars LazyFrame df.
        Uses num_listens as implicit feedback strength (rank).
        """

        # Ensure proper dtypes (keep num_listens numeric!)
        df = df.select([user_col, artist_col, num_listens_col]).with_columns([
            pl.col(user_col).cast(pl.Utf8).str.strip_chars(),
            pl.col(artist_col).cast(pl.Utf8).str.strip_chars(),
            pl.col(num_listens_col).cast(pl.Int32)
        ])

        # Collect unique users/artists
        user_ids = df.select(pl.col(user_col).unique()).collect()[user_col].to_list()
        artist_ids = df.select(pl.col(artist_col).unique()).collect()[artist_col].to_list()

        # Build mappings
        user_to_idx = {uid: i for i, uid in enumerate(user_ids)}
        artist_to_idx = {mbid: i for i, mbid in enumerate(artist_ids)}

        # Save mappings
        self.artist_id_to_mbid = {i: mbid for mbid, i in artist_to_idx.items()}
        self.mbid_to_artist_id = artist_to_idx
        self.user_to_idx = user_to_idx

        # Convert df to mapped indices using join
        user_map_df = pl.DataFrame(
            {user_col: list(user_to_idx.keys()), "user_idx": list(user_to_idx.values())}
        ).lazy()

        artist_map_df = pl.DataFrame(
            {artist_col: list(artist_to_idx.keys()), "artist_idx": list(artist_to_idx.values())}
        ).lazy()

        df_mapped = (
            df.join(user_map_df, on=user_col)
            .join(artist_map_df, on=artist_col)
        )

        # Collect indices + num_listens into memory
        mapped_arrays = df_mapped.select(["user_idx", "artist_idx", num_listens_col]).collect()

        user_indices = mapped_arrays["user_idx"].cast(pl.Int32).to_numpy()
        artist_indices = mapped_arrays["artist_idx"].cast(pl.Int32).to_numpy()
        listen_counts = mapped_arrays[num_listens_col].cast(pl.Float32).to_numpy()

        # Build sparse interaction matrix with listen counts as weights
        interactions = csr_matrix(
            (listen_counts, (user_indices, artist_indices)),
            shape=(len(user_to_idx), len(artist_to_idx)),
            dtype=np.float32
        )

        # Train ALS model
        self.model = implicit.als.AlternatingLeastSquares(
            factors=factors,
            regularization=regularization,
            iterations=iterations
        )
        self.model.fit(interactions)

        print(f"Total artist id mappings: {len(self.artist_id_to_mbid)}")
        print("Model item factors:", self.model.item_factors.shape)
        print(f"Trained ALS on {len(user_to_idx)} users and {len(artist_to_idx)} artists "
              f"with {interactions.nnz} interactions.")

    def get_similar_artists(self, query_artist_mbid: str, N: int = 10):
        query_artist_mbid = str(query_artist_mbid).strip()

        if query_artist_mbid not in self.mbid_to_artist_id:
            print(f"Artist MBID {query_artist_mbid} not found in training data.")
            return []

        artist_idx = self.mbid_to_artist_id[query_artist_mbid]

        # Ask for N+1 so we can exclude the query artist itself
        similar_ids, _ = self.model.similar_items(artist_idx, N=N + 1)

        # Drop the first one (the query artist itself)
        similar_ids = similar_ids[1:]

        # Return only the MBIDs
        return [self.artist_id_to_mbid[idx] for idx in similar_ids]


