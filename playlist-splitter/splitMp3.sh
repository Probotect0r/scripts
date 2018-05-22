#!/usr/bin/bash

INFO_FILE=playlist-info.txt

get_timestamp() {
    local timestamp=$1
    count=$(echo $timestamp | grep -o ':' | wc -l)

    # Standardize the timestamp
    if [[ $count == 1 ]]
    then
        timestamp=$(echo $timestamp | sed -e 's/^/00:/')
    fi
    echo "$timestamp"
}

get_current_playlist() {
    local playlist=$(echo $line | sed -e 's/\s/-/')
    echo "$playlist"
}

get_title() {
    local full_time=$(echo $1 | sed -E -e 's/^.{8}\s//' )
}

while read line; do
    if [[ $line =~ Playlist.* ]]
    then
        CURRENT_PLAYLIST=$(get_current_playlist "$line")
        echo "Processing: $CURRENT_PLAYLIST"
    else
        time=$(get_timestamp $line)
        echo $time

        title=$(get_title $line)
    fi
done < $INFO_FILE 
