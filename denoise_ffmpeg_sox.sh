#!/bin/sh

# From https://gist.githubusercontent.com/jace/88b81c51cd8044409ddbce97d582eaac/raw/eb49020ca2e896aea58549a5581f159340caafcb/denoise.sh :

# 1. extract audio from all videos (assuming .mp4 videos).
for FILE in *.mp4; do ffmpeg -i "$FILE" "${FILE%%.mp4}.wav"; done
# for FILE in *.m4a; do ffmpeg -i $FILE ${FILE%%.mp4}.wav; done

# 2. use the first second of the first audio file as the noise sample.
# sox `ls *.wav | head -1` -n trim 0 1 noiseprof noise.prof
for FILE in *.wav; do sox "$FILE" -n trim 0 1 noiseprof "${FILE%%.wav}.noise.prof"; done

# Replace with a specific noise sample file if the first second doesn't work for you:
# sox noise.wav -n noiseprof noise.prof

# 3. clean the audio with noise reduction and normalise filters.
# for FILE in *.wav; do sox -S --multi-threaded --buffer 131072 $FILE ${FILE%%.wav}.norm.wav noisered noise.prof 0.21 norm; done
for FILE in *.wav; do sox -S --multi-threaded --buffer 131072 "$FILE" "${FILE%%.wav}.norm.wav" noisered "${FILE%%.wav}.noise.prof" 0.21 norm; done

# 4. re-insert audio into the videos.
# If you need to include an audio offset (+/- n seconds), add parameter "-itsoffset n" after the second -i parameter.
# for FILE in *.norm.wav; do ffmpeg -i ${FILE%%.norm.wav}.mp4 -i $FILE -c:v copy -c:a aac -strict experimental -map 0:v:0 -map 1:a:0 ${FILE%%.norm.wav}.sync.mp4; done

# 5. That's it. You're done!

###

# See also http://www.zoharbabin.com/how-to-do-noise-reduction-using-ffmpeg-and-sox/ :

# 1. Split the audio and video streams into 2 separate files:
	# The VIDEO stream: ffmpeg -i input.mp4 -sameq -an tmpvid.mp4
	# The AUDIO stream: ffmpeg -i input.mp4 -sameq tmpaud.wav 
# 2. Generate a sample of noise from the audio of the file:
	# ffmpeg -i input.mp4 -vn -ss 00:00:00 -t 00:00:01 noiseaud.wav
	# -ss: the time offset from beginning. (h:m:s.ms).
	# -t duration: record or transcode duration seconds of audio/video.
	# Choose a segment of the audio where there’s no speech, only noise (e.g. speaker was silent for a sec).
# 3. Generate a noise profile in sox:
	# sox noiseaud.wav -n noiseprof noise.prof
# 4. Clean the noise samples from the audio stream:
	# sox tmpaud.wav tmpaud-clean.wav noisered noise.prof 0.21
	# Change 0.21 to adjust the level of sensitivity in the sampling rates (I found 0.2-0.3 often provides best result).
# 5. Merge the audio and video streams back together:
	# ffmpeg -i tmpaud-clean.wav -i tmpvid.mp4 -sameq vid.mp4
