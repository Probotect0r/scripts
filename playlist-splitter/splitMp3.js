const readline = require('readline')
const fs = require('fs')
const { execSync } = require("child_process")

// global variables 
let tracker = {}
let currentPlaylist
let inputDirectory = "/run/media/sagar/Data/Documents/Music"

/* Functions */
function processLine(line) {
	// Check if the line is a header
	if (line.includes("Playlist")) {
		currentPlaylist = line.trim();

		// add empty object for the playlist to tracker
		tracker[currentPlaylist] = {
			timestamps: [],
			titles: []
		}
		console.log(`Processing: ${currentPlaylist}`)
	} else {
		// it's a line containing a song for the currentPlaylist
		// get timestamp
		// find first space, and get substring til that position
		let spacePos = line.indexOf(" ")									
		let timestamp = line.substring(0, spacePos)
		let title = line.substring(spacePos + 1)

		// Add standardized timestamp and title to respective arrays in tracker object
		tracker[currentPlaylist].timestamps.push(standardizeTimestamp(timestamp.trim()))
		tracker[currentPlaylist].titles.push(title.trim())
	}
}

// standardizes a timestamp
function standardizeTimestamp(timestamp) {
	let parts = timestamp.split(":")
	// Add the hour if it doesn't exist
	if (parts.length === 2) {
		parts.unshift("00")	
	}

	let standardized = parts.join(":")
	return standardized
}

function splitFiles() {
	// 	1. 	Make a directory for the playlist - Done
	// 	2. 	Loop through each of the timestamps / titles
	// 	3. 	Split the file, using that timestamp as the start,
	//    	and the next one as the end. 
	//    	a)	Set the artist as the game the song is from
	//    	b)	Set the output file name to the song name.
	
	// Loop through each playlist
	playlists = Object.keys(tracker)
	for (let playlist of playlists) {
		// Make a directory for this playlist
		let directoryName = playlist.replace(" ", "-")
		fs.mkdirSync(directoryName)

		// Loop through each timestamp and title
		let playlistObj = tracker[playlist]
		for (let i = 0; i < playlistObj.timestamps.length; i++) {
			// Get the tille (escape slashes)
			let fullTitle = playlistObj.titles[i]
			console.log(fullTitle)

			// Set up input file and output file names
			let inputFileName = `${inputDirectory}/${playlist}.mp3`
			let outputFileName = `${directoryName}/${fullTitle}.mp3`

			// Get the title of the song and artist (the game)
			let titleParts = fullTitle.split(" - ")
			let artist = titleParts[0]
			let songTitle = titleParts[1]

			// If this is the last timestamp, set end to null
			let start = playlistObj.timestamps[i]
			let end = (playlistObj.timestamps.length) - 1 === i ? null : playlistObj.timestamps[i + 1]

			// invoke the split function
			ffmpegSplit(inputFileName, outputFileName, songTitle, artist, start, end)
		}
	}
}

/*
 * This functions actually calls ffmpeg with the relevant information
 * to split the original file to a subset of it.
 * Params:
 * inputFile - input file name
 * outputFile - output file name
 * title - title of the song to use in the metadata
 * artist - Artist of the song (usually just the game) to use in the metadata
 * start - the start time
 * end - the end time (OPTIONAL - if not specified, splits til end of file)
 */
function ffmpegSplit(inputFile, outputFile, title, artist, start, end) {
	if (end != null) {
		let commandString = `ffmpeg -i "${inputFile}" -acodec copy -ss ${start} -to ${end} -metadata title="${title}" -metadata artist="${artist}" "${outputFile}"`
		console.log(commandString)
		execSync(commandString)
	} else {
		let commandString = `ffmpeg -i "${inputFile}" -acodec copy -ss ${start} -metadata title="${title}" -metadata artist="${artist}" "${outputFile}"`
		console.log(commandString)
		execSync(commandString)
	}
}

/* Code */
const rl = readline.createInterface({
	input: fs.createReadStream('playlist-info-test.txt')
})

rl.on('line', (line) => {
	processLine(line)
})

rl.on('close', () => {
	// Completed collecting all information
	console.log("Finished building tracker object...")
	console.log("Splitting files...")
	splitFiles()
})

