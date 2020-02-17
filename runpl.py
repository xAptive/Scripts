# This script forms an MP3 playlist, ordered by beats-per-minute of the songs 
# (in ascending order).  It determines the BPM of each song, orders them, sets
# an album name in the id3, sets the track number in the id3, and then names the
# file based on id3 information.
#
# I use this to create playlists for running, when I want BPM to increase, and
# for my device to maintain the correct ordering of songs.
#
# This script uses the bpm-tag, id3v2, and id3ren Linux commandline utilities
# to do the heavy lifting.  It doesn't do any exception handling.
#
# WARNING: This script modifies the files directly, and may result in lost
# metadata.

import subprocess
import sys
import re

# Map the beats-per-minute of the mp3 to it's file name using bmp-tag
def make_bpm_map(files):
    results = dict()
    for f in files:
        result = subprocess.run(['bpm-tag', f], capture_output=True)
        matches = re.finditer(', (\d+\.\d+) BPM', str(result.stderr))
        for match in matches:
            results[f] = float(match.group(1))
    return results

# Set the album name and track number in the id3 metadata
def set_id3(f, album, track, track_count):
    subprocess.run(['id3v2', '--TALB', album, '--TRCK', f"{track}/{track_count}", f])

# Rename the file based on it's id3 information
def name_file(f):
    subprocess.run(['id3ren', '-template=%t - %n - %a - %s.mp3', f])

# Grab the album name
album = sys.argv[1]

# Grab the file list
files =  sys.argv[2:]

# Counter the number of files (used as the total track count)
file_count = len(files)

# Get the BMP mapping
bpm_map  = make_bpm_map(files)

# Sort by BPM, iterate over files, and do the work
for index, items in enumerate(sorted(bpm_map.items(), key = lambda item: item[1])):
    set_id3(items[0], album, index + 1, file_count)
    name_file(items[0])
