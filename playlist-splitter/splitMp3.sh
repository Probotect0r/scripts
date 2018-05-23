#!/usr/bin/bash

INFO_FILE=playlist-info.txt
line_count=$(wc -l $INFO_FILE | awk '{print $1}')
echo $line_count

get_timestamp() {
    local timestamp=$1
    
    # Standardize the timestamp
    count=$(echo $timestamp | grep -o ':' | wc -l)

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
    local full_title=$(echo $1 | sed -E -e 's/^.{8}\s//' )
    echo $full_title
}

for ((i=1; i<=$line_count; i++))
do
    line=$(sed "${i}q;d" $INFO_FILE)
    if [[ $line =~ Playlist.* ]]
    then
        CURRENT_PLAYLIST=$(get_current_playlist "$line")
        echo "Processing: $CURRENT_PLAYLIST"
    else
        time=$(get_timestamp $line)
        title=$(get_title $line)
        echo $title
    fi
done
