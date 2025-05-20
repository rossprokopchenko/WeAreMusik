import csv

def readTrackDataset(path):

    with open(path, newline='') as csvfile:

        spamreader = csv.reader(csvfile)
        columns = spamreader.__next__()
        jObjArray = []

        for row in spamreader:
            jObj = {}

            for index, column in enumerate(columns):
                # if index == 0:
                #     continue

                jObj[column] = row[index]

            jObjArray.append(jObj)

        return jObjArray

# jsonObjects = readTrackDataset('datasets/archive1/dataset.csv')
jsonObjects = readTrackDataset('datasets/spotify_millsongdata.csv/tracks_features.csv')
print("First record: ", jsonObjects[0])

# id -> track_id
# name -> track_name
# album -> album_name
# artists -> artists
# explicit -> explicit
# danceability -> danceability
# energy -> energy
# key -> key
# loudness -> loudness
# mode -> mode
# speechiness -> speechiness
# acousticness -> acousticness
# instrumentalness -> instrumentalness
# liveness -> liveness
# valence -> valence
# tempo -> tempo
# duration_ms -> duration_ms
# time_signature -> time_signature
# track_genre missing X

#
    #         artists: track[:artists],
    #         album_name: track[:album_name],
    #         track_name: track[:track_name],
    #         popularity: track[:popularity],
    #         duration_ms: track[:duration_ms],
    #         explicit: track[:explicit],
    #         danceability: track[:danceability],
    #         energy: track[:energy],
    #         key: track[:key],
    #         loudness: track[:key],
    #         mode: track[:mode],
    #         speechiness: track[:speechiness],
    #         acousticness: track[:acousticness],
    #         instrumentalness: track[:instrumentalness],
    #         liveness: track[:liveness],
    #         valence: track[:valence],
    #         tempo: track[:tempo],
    #         time_signature: track[:time_signature],
    #         track_genre: track[:track_genre],