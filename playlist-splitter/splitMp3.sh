#!/usr/bin/bash

INFO_FILE=playlist-info.txt
INPUT_DIR=${1:-'/home/sagar/Music'}
echo "Reading from: $INPUT_DIR"

get_timestamp() {
    local timestamp=$1
    
    # Standardize the timestamp
    count=$(echo "$timestamp" | grep -o ':' | wc -l)

    if [[ $count == 1 ]]
    then
        # timestamp=$(echo "$timestamp" | sed -e 's/^/00:/')
        timestamp=${timestamp/#/00:}
    fi
    echo "$timestamp"
}

parse_playlist_title() {
    echo "$title"
}

get_full_title() {
    local full_title
    full_title=$(echo $1 | sed -E -e 's/^[^ ]*\s//' )
    echo "$full_title"
}

get_song_title() {
    local title
    title=$(echo "$1" | sed -E -e 's/^.*-\s//')
    echo "$title"
}

get_artist_name() {
    local artist
    artist=$(echo "$1" | sed -E -e 's/\s-.*$//')
    echo "$artist"
}

execute_ffmpeg() {
    input_file="$1"
    output_file="$2"
    song="$3"
    artist="$4"
    start="$5"
    end="$6"

    if [[ -n $end ]]
    then
        ffmpeg -i "$input_file" -acodec copy -ss "$start" -to "$end" -metadata title="$song" -metadata artist="$artist" "$output_file"
    else
        ffmpeg -i "$input_file" -acodec copy -ss "$start" -metadata title="$song" -metadata artist="$artist" "$output_file"
    fi
}

line_count=$(wc -l $INFO_FILE | awk '{print $1}')

for ((i=1; i<=line_count; i++))
do
    current_line=$(sed "${i}q;d" $INFO_FILE)

    if [[ $current_line =~ Playlist.* ]]
    then
        CURRENT_PLAYLIST_ORIG="$current_line"
        #CURRENT_PLAYLIST=$(echo "$CURRENT_PLAYLIST_ORIG" | sed -e 's/\s/-/')
        CURRENT_PLAYLIST=${CURRENT_PLAYLIST_ORIG/ /-}

        echo "Processing: $CURRENT_PLAYLIST"
        mkdir "$CURRENT_PLAYLIST"
    else
        start_time=$(get_timestamp $current_line)
        full_title=$(get_full_title "$current_line")

        artist=$(get_artist_name "$full_title")
        song_title=$(get_song_title "$full_title")

        next_line_num=$((i + 1))
        next_line=$(sed "${next_line_num}q;d" $INFO_FILE)

        input_file="$INPUT_DIR/$CURRENT_PLAYLIST_ORIG.mp3"
        output_file="./${CURRENT_PLAYLIST}/${full_title}.mp3"

        if [[ $next_line =~ Playlist.* ]] || [[ -z $next_line ]]
        then
            # Execute ffmpeg with no end
            execute_ffmpeg "$input_file" "$output_file" "$song_title" "$artist" "$start_time"
        else
            end_time=$(get_timestamp $next_line)
            execute_ffmpeg "$input_file" "$output_file" "$song_title" "$artist" "$start_time" "$end_time"
        fi
    fi
done
