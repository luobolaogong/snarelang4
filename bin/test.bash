#!/bin/bash
echo "In a test bash file"

declare -a tuneNameArray=(44MarchSnare \
BeginnerMarch \
BlackBear \
JigSnare \
CameronianRantSnare5 \
JigSnare \
March44 \
MassedBand24JLV1P60 \
MassedBand44JLV1P59 \
SlowMarchNo1 \
SlowMarchNo2 \
Strath1SnareMet \
SuperSlowMarchNo2 )

#rm -f /home/rob/MyHobby/mp3s/*.mp3
for f in ${tuneNameArray[@]}; do
  dart bin/snl.dart -i tunes/${f}.snl -o midifiles/${f}.mid
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ~/Desktop/MySoundFonts/DrumLine202103081351.sf2  midifiles/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - /home/rob/MyHobby/mp3s/${f}.mp3
done

# What about the tunes that have multiple .mid files?

# Now zip up the tunes
[ -e "/home/rob/MyHobby/mp3s/tunes.zip" ] && rm "/home/rob/MyHobby/mp3s/tunes.zip"
#rm /home/rob/MyHobby/mp3s/tunes.zip
zip /home/rob/MyHobby/mp3s/tunes.zip  /home/rob/MyHobby/mp3s/*.mp3


exit 0
