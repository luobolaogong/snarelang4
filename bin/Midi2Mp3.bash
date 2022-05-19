#!/bin/
echo "Hey is this BuildTunes.bash script still being used for something?  Maybe, maybe, maybe this one is more current."
declare snareLangDir=/home/rob/WebstormProjects/snarelang4
declare snareLangExecutable=${snareLangDir}/bin/snl.dart
declare pipeLangDir=/home/rob/WebstormProjects/pipelang
declare pipeLangDartFile=${pipeLangDir}/bin/ppl.dart
declare tracksDir=/home/rob/WebstormProjects/tracks
declare tracksFile=${tracksDir}/bin/tracks.dart

declare learnWithMidi=/home/rob/LearnWithMidi
declare forDrummers=${learnWithMidi}/ForDrummers
declare forPipers=${learnWithMidi}/ForPipers

declare soundFontFile=DrumLineMelodyChanter20210518.sf2
#echo soundfont is $soundFontFile

declare tune=ExerciseSets

fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} midifiles/${tune}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/Exercises/Mp3s/${tune}.mp3
echo forDrummers: ${forDrummers}
echo Wrote ${forDrummers}/Exercises/Mp3s/${tune}.mp3