#!/usr/bin/bash
INFO_FILE=playlist-info.txt
while read line; do
    if [[ $line =~ Playlist.* ]]
    then
        echo "Processing: $line"
    fi
done < $INFO_FILE 
