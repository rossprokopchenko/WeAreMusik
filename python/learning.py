import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.neighbors import NearestNeighbors
import umap
import matplotlib.pyplot as plt
import matplotlib
import numpy as np

def find_similar_tracks(track_ids):
    subset = dataframe[dataframe["id"].isin(track_ids)]
    subset_scaled = scaler.transform(subset[features])

    mean_vector = subset_scaled.mean(axis=0).reshape(1, -1)
    distances, indices = nn_model.kneighbors(mean_vector, n_neighbors=10)
    similar_tracks = dataframe.iloc[indices[0]]

    return similar_tracks["id"].tolist()


def visualize_data():
    print("Subsampling data for UMAP...")

    sample_size = 5000
    total_samples = X_scaled.shape[0]
    sample_indices = np.random.choice(total_samples, size=sample_size, replace=False)

    X_sampled = X_scaled[sample_indices]
    df_sampled = dataframe.iloc[sample_indices].copy()

    print("Running UMAP embedding...")
    embedding = umap.UMAP(n_neighbors=15, min_dist=0.1).fit_transform(X_sampled)

    print("Scatter plot...")
    plt.figure(figsize=(10, 6))

    # Choose a column to color by:
    color_by = "energy"  # You can also try "year" or "valence" etc.

    scatter = plt.scatter(
        embedding[:, 0], embedding[:, 1],
        c=df_sampled[color_by], cmap="viridis", s=10, alpha=0.6
    )
    plt.colorbar(scatter, label=color_by.capitalize())

    plt.xlabel("UMAP X")
    plt.ylabel("UMAP Y")
    plt.title(f"UMAP Visualization Colored by {color_by.capitalize()}")
    plt.grid(True)

    print("Showing plot...")
    plt.show()

matplotlib.use("Agg")  # Use a non-GUI backend that works in WSL

# Load data
print("Reading dataset...")
dataframe = pd.read_csv('datasets/spotify_millsongdata.csv/tracks_features.csv')

features = [
    "danceability", "energy", "key", "loudness", "mode", "speechiness",
    "acousticness", "instrumentalness", "liveness", "valence", "tempo",
    "time_signature"
]

print("Handling missing values...")
X = dataframe[features].fillna(0)

print("Normalizing data...")
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

print("Initializing nearest neighbors...")
nn_model = NearestNeighbors(n_neighbors=10, metric='cosine')
nn_model.fit(X_scaled)
