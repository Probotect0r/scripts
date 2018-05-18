const { execSync } = require('child_process')

// take each mp4 and convert it to mp3
let outputName = "Video Game Music for Studying"
let inputName = "playlist"
for (let i = 8; i < 19; i++) {
	console.log(`started playlist ${i}`)
	try {
		execSync(`ffmpeg -i "/run/media/sagar/Data/Desktop/music/${inputName}${i}.mp4" -q:a 0 -map a "/run/media/sagar/Data/Documents/Music/${outputName} ${i}.mp3"`)
	} catch(err) {
		console.log(err)
	}
	console.log(`finished playlist ${i}`)
}
