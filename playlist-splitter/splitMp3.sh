#!/usr/bin/bash

INFO_FILE=playlist-info.txt

get_timestamp() {
    local timestamp=$(echo $1 | grep -E -o '^[[:alnum:]:]*\s' | sed -e 's/\s$//')
    count=$(echo $timestamp | grep -c ':')
    echo $count
    echo "$timestamp"
}

get_current_playlist() {
    local playlist=$(echo $line | sed -e 's/\s/-/')
    echo "$playlist"
}

while read line; do
    if [[ $line =~ Playlist.* ]]
    then
        CURRENT_PLAYLIST=$(get_current_playlist "$line")
        echo "Processing: $CURRENT_PLAYLIST"
    else
        time=$(get_timestamp "$line")
    fi
done < $INFO_FILE 
