#!/usr/bin/bash

INFO_FILE=playlist-info.txt

get_timestamp() {
    local timestamp=$(echo $1 | grep -E -o '^[[:alnum:]:]*\s' | sed -e 's/\s$//')
    echo "$timestamp"
}

while read line; do
    if [[ $line =~ Playlist.* ]]
    then
        echo "Processing: $line"
    else
        time=$(get_timestamp "$line")
        echo "$time"
    fi
done < $INFO_FILE 

