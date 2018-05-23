#!/usr/bin/bash

INFO_FILE=playlist-info.txt

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

parse_playlist_title() {
    local title=$(echo $1 | sed -e 's/\s/-/')
    echo "$title"
}

get_title() {
    local full_title=$(echo $1 | sed -E -e 's/^[^ ]*\s//' )
    echo $full_title
}

line_count=$(wc -l $INFO_FILE | awk '{print $1}')

for ((i=1; i<=$line_count; i++))
do
    current_line=$(sed "${i}q;d" $INFO_FILE)


    if [[ $current_line =~ Playlist.* ]]
    then
        CURRENT_PLAYLIST=$(parse_playlist_title "$current_line")
        echo "Processing: $CURRENT_PLAYLIST"
    else
        current_line_timestamp=$(get_timestamp $current_line)
        current_line_title=$(get_title "$current_line")

        next_line_num=$(($i + 1))
        next_line=$(sed "${next_line_num}q;d" $INFO_FILE)
        
        if [[ $next_line =~ Playlist.* ]] || [[ -z $next_line ]]
        then
            # Execute ffmpeg with no end
            echo "$current_line_title: $current_line_timestamp -> END"
        else
            next_line_timestamp=$(get_timestamp $next_line)
            # Execute ffmpeg with 
            echo "$current_line_title: $current_line_timestamp -> $next_line_timestamp"
        fi
    fi
done
