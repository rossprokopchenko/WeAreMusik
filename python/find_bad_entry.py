import csv

filepath = "\\wsl.localhost\\Ubuntu-24.04\\home\\rostiku\\mbdump\\musicbrainz-canonical-dump-20250603-080003\\canonical\\canonical_musicbrainz_data.csv"
filename = ""

with open(filepath, newline='', encoding='utf-8') as infile, \
     open(filepath + "malformed_rows.csv", "w", newline='', encoding='utf-8') as bad, \
     open(filepath + "valid_rows.csv", "w", newline='', encoding='utf-8') as good:

    reader = csv.reader(infile)
    bad_writer = csv.writer(bad)
    good_writer = csv.writer(good)

    for i, row in enumerate(reader, 1):
        if len(row) != 10:
            print(f"Line {i} has {len(row)} columns: {row}")
            bad_writer.writerow(row)
        else:
            good_writer.writerow(row)
