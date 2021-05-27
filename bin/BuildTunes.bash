#!/bin/bash
# Will build the tunes that go into the 'Band Tunes' area of the band's website.
# Generally these files will consist of Drums and Chanter and Metronome.
# Not building exercises, or drum salutes or non-band things.
# Still need to copy the results to the Google Drive area.
# But have a mirror image on this computer's drive.
# Probably should have an automated way to push these to GitHub some day.
# These files consist of *.mid, *.mp3, *.wav, and *.ogg files.
# The source files are of course .snl and .ppl files

# The organization in the build area of the computer is:
# snarelang4/exercises/LaughlinVol1
# snarelang4/exercises/LaughlinVol2
# snarelang4/exercises/LeoBrowne
# snarelang4/exercises/warmups
# snarelang4/FanfaresSalutes
# snarelang4/Metronomes
# snarelang4/tunes

# pipelang/midis
# pipelang/tunes

# The organization of the "transfer area" on disk is:
# ~/MyHobby/BandTunes (with subdirs Midis, Mp3s, Oggs, Wavs)
# ~/MyHobby/Books/JLV1 (with subdirs Midis, Mp3s, Oggs, Wavs)
# ~/MyHobby/Books/JLV2 (with subdirs Midis, Mp3s, Oggs, Wavs)
# ~/MyHobby/Exercises (with subdirs Midis, Mp3s, Oggs, Wavs)
# ~/MyHobby/Exercises/LeoBrowne (with subdirs Midis, Mp3s, Oggs, Wavs)
# ~/MyHobby/Exercises/warmups (with subdirs Midis, Mp3s, Oggs, Wavs)
# ~/MyHobby/FanfaresSalutes (with subdirs Midis, Mp3s, Oggs, Wavs)
# ~/MyHobby/Metronomes/Midis
# ~/MyHobby/NonBandTunes (with subdirs Midis, Mp3s, Oggs, Wavs)
# ~/MyHobby/Pipes (with subdirs Midis, Mp3s, Oggs, Wavs)
# ~/MyHobby/SoundFonts

# But the transfer area should be:
# LearnWithMidi/BandTunes (Chanter and Drums) (with Midis, Mp3s, Wavs, Oggs)
# LearnWithMidi/ForPipers/BandTunes (with Midis, Mp3s, Wavs, Oggs) No Drums?????
# LearnWithMidi/ForDrummers/BandTunes (with Midis, Mp3s, Wavs, Oggs)  Maybe no chanter?????????????????????
# LearnWithMidi/ForDrummers/Books (with Midis, Mp3s, Wavs, Oggs)
# LearnWithMidi/ForDrummers/Exercises/.../ (with Midis, Mp3s, Wavs, Oggs)
# LearnWithMidi/ForDrummers/FanfaresSalutes/.../ (with Midis, Mp3s, Wavs, Oggs)

# The organization of the 'Learn With Midi' pages on the website is
# Learn With MIDI --> Band Tunes
# Learn With MIDI --> For Pipers
# Learn With MIDI --> Metronomes
# Learn With MIDI --> For Drummers --> Band Tunes (what's the difference from above?  Make it from the same list in the Drive?)
# Learn With MIDI --> For Drummers --> Fanfares/Salutes --> Duthart
# Learn With MIDI --> For Drummers --> Fanfares/Salutes --> IoMP Salutes
# Learn With MIDI --> For Drummers --> Fanfares/Salutes
# Learn With MIDI --> For Drummers --> Exercises
# Learn With MIDI --> For Drummers --> Books --> Vol 1 Laughlin
# Learn With MIDI --> For Drummers --> Books --> Vol 2 Laughlin
# Learn With MIDI --> For Drummers --> Books --> Maxwell
# Learn With MIDI --> For Drummers --> Books
# Learn With MIDI --> For Drummers --> Books
# Learn With MIDI --> For Drummers --> Videos
# Learn With MIDI --> For Drummers --> NonBand Tunes
#
# The organization of the Google Drive pages is way different, kinda flat:
# My Drive > Websiteresources > MIDI > BandTunes
# My Drive > Websiteresources > MIDI > Books
# My Drive > Websiteresources > MIDI > Exercises
# My Drive > Websiteresources > MIDI > Fanfares
# My Drive > Websiteresources > MIDI > FanfareSalutes
# My Drive > Websiteresources > MIDI > Metronomes
# My Drive > Websiteresources > MIDI > MidiFiles
# My Drive > Websiteresources > MIDI > MpeFiles
# My Drive > Websiteresources > MIDI > NonBandTunes
# My Drive > Websiteresources > MIDI > OggFiles
# My Drive > Websiteresources > MIDI > Pipes
# My Drive > Websiteresources > MIDI > Pipes and Drums
# My Drive > Websiteresources > MIDI > SnareScoresFromClassRoom
# My Drive > Websiteresources > MIDI > SnlFiles
# My Drive > Websiteresources > MIDI > SoundFonts
# My Drive > Websiteresources > MIDI > Videos
# My Drive > Websiteresources > MIDI > WavFiles
# My Drive > Websiteresources > MIDI > Zips
# My Drive > Websiteresources > MIDI >

#echo "This is being run out of the bin directory of the snarelang4 project, and not the pipelang project"
#echo We are here: `pwd`

declare snareLangDir=/home/rob/WebstormProjects/snarelang4
declare snareLangExecutable=${snareLangDir}/bin/snl.dart
declare pipeLangDir=/home/rob/WebstormProjects/pipelang
declare pipeLangDartFile=${pipeLangDir}/bin/ppl.dart
declare tracksDir=/home/rob/WebstormProjects/tracks
declare tracksFile=${tracksDir}/bin/tracks.dart

declare learnWithMidi=/home/rob/LearnWithMidi
declare forDrummers=${learnWithMidi}/ForDrummers
declare forPipers=${learnWithMidi}/ForPipers
#echo learnWithMidi is $learnWithMidi and it has `ls $learnWithMidi`

# The soundfont file must coordinate with the midi files that are created, and they're created with "pitches" in mind, so really only
# one soundfont file should exist per organization of midi files.
#declare soundFont=/home/rob/Desktop/MySoundFonts/DrumLine202103081351.sf2
#declare soundFontName=DrumLine202103081351.sf2
#declare soundFontName=DrumsChanterMelody20210407.sf2
declare soundFontName=DrumLineMelodyChanter20210518.sf2
cp /home/rob/Desktop/MySoundFonts/${soundFontName} ${learnWithMidi}/SoundFonts
declare soundFontFile=${learnWithMidi}/SoundFonts/${soundFontName}
#cp /home/rob/Desktop/MySoundFonts/PipesAndDrums202011060735.sf2 ${learnWithMidi}/MySoundFonts
echo soundfont is $soundFontFile

#cd /home/rob/WebstormProjects/snarelang4/bin

# There should be a way to tell fluidsynth or ffmpeg to make a stereo image like you can do with Rosegarden with the mixer
# Also, Fluidsynth or ffmpeg needs to boost the volume.

#rm -f ${myHobby}/BandTunes/Midis/*.mid
#rm -f ${myHobby}/BandTunes/Mp3s/*.mp3
#rm -f ${myHobby}/BandTunes/Oggs/*.ogg
#rm -f ${myHobby}/BandTunes/Wavs/*.wav

#  declare tune=PipesAnd
#  dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/BandTunes/Midis/${tune}Drums.mid
#  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/${tune}Drums.mp3
#  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/${tune}Drums.ogg
#  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/${tune}Drums.wav
#exit 5


bandTunesPipesAndDrums() {
  declare tune=$1
  dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/BandTunes/Midis/${tune}Drums.mid
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/${tune}Drums.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/${tune}Drums.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/${tune}Drums.wav
  dart $pipeLangDartFile -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipers}/BandTunes/Midis/${tune}Chanter.mid
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/${tune}Chanter.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/${tune}Chanter.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/${tune}Chanter.wav
  dart $tracksFile -l WARNING -i ${forDrummers}/BandTunes/Midis/${tune}Drums.mid,${forPipers}/BandTunes/Midis/${tune}Chanter.mid -o ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Mp3s/${tune}ChanterAndDrums.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Oggs/${tune}ChanterAndDrums.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Wavs/${tune}ChanterAndDrums.wav
}

declare -a bandTunesPipesAndDrumsNameArray=(
  TheHauntingSimple
  HauntingCastleSetSimpleAndMassedBands
  HauntingCastleSetSimple
  HauntingCastleSet
  TheHaunting
  CaptEwingMassedBands
  CastleDangerousMassedBands
  Lochanside
  24MarchSet
  CaptEwing
  Competition44Set
  Competition44SetMassedBands
  BarrenRocksOfAden
  BadgeSet
  AmazingGrace
  TheHaunting
  FlettFromFlotta
  BattleOfWaterloo
  MurdosWedding
  RowanTree
  BadgeOfScotland
  BrownHairedMaiden
  HighlandLaddie
  24MarchSet
  HawaiiAloha
  ScotlandTheBraveMassedBands
  ScotlandTheBraveMarch44
  ScotlandTheBrave
)

# There could be stray files in these various dirs, so might want to check time stamps
for f in "${bandTunesPipesAndDrumsNameArray[@]}"; do
  bandTunesPipesAndDrums ${f}
done

massedBandsDrums() {
  declare tune=$1
  dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/MassedBands/Midis/${tune}Drums.mid
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/MassedBands/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/MassedBands/Mp3s/${tune}Drums.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/MassedBands/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/MassedBands/Oggs/${tune}Drums.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/MassedBands/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/MassedBands/Wavs/${tune}Drums.wav
}

declare -a massedBandsDrumsNameArray=(
  BeginnerMarch
  March44
  MassedBands24JL
  MassedBands34JL
  MassedBands44JL
  MassedBandsJig
  Reel
  ReelStraight
  SlowMarchNo1
  SlowMarchNo2
  Strath
  SuperSlowMarchNo2

)

for f in "${massedBandsDrumsNameArray[@]}"; do
  massedBandsDrums ${f}
done

justDrums() {
  declare tune=$1
  dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/BandTunes/Midis/${tune}Drums.mid
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/${tune}Drums.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/${tune}Drums.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/${tune}Drums.wav
}

# There are things that are not part of the Set List

nonBandTunesPipesAndDrums() {
  declare tune=$1
  dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/NonBandTunes/Midis/${tune}Drums.mid
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/NonBandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/NonBandTunes/Mp3s/${tune}Drums.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/NonBandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/NonBandTunes/Oggs/${tune}Drums.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/NonBandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/NonBandTunes/Wavs/${tune}Drums.wav
  dart $pipeLangDartFile -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipers}/NonBandTunes/Midis/${tune}Chanter.mid
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/NonBandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/NonBandTunes/Mp3s/${tune}Chanter.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/NonBandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/NonBandTunes/Oggs/${tune}Chanter.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/NonBandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/NonBandTunes/Wavs/${tune}Chanter.wav
  dart $tracksFile -l WARNING -i ${forDrummers}/NonBandTunes/Midis/${tune}Drums.mid,${forPipers}/NonBandTunes/Midis/${tune}Chanter.mid -o ${learnWithMidi}/NonBandTunes/Midis/${tune}ChanterAndDrums.mid
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/NonBandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/NonBandTunes/Mp3s/${tune}ChanterAndDrums.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/NonBandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/NonBandTunes/Oggs/${tune}ChanterAndDrums.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/NonBandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/NonBandTunes/Wavs/${tune}ChanterAndDrums.wav
}

declare -a nonBandTunesPipesAndDrumsNameArray=(
  AnnettesChatter
  CameronianRant
  JaneCampbell
  JimmyRollo
  JohnWalshsWalk
)

# There could be stray files in these various dirs, so might want to check time stamps
for f in "${nonBandTunesPipesAndDrumsNameArray[@]}"; do
  echo nonBandTunesPipesAndDrums ${f} not ready with pipes parts, right?
done

exercisesPipesAndDrums() {
  declare tune=$1
  dart $snareLangExecutable -i exercises/${tune}Drums.snl -o ${forDrummers}/Exercises/Midis/${tune}Drums.mid
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/Exercises/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/Exercises/Mp3s/${tune}Drums.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/Exercises/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/Exercises/Oggs/${tune}Drums.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/Exercises/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/Exercises/Wavs/${tune}Drums.wav
  dart $pipeLangDartFile -i ${pipeLangDir}/exercises/${tune}Chanter.ppl -o ${forPipers}/Exercises/Midis/${tune}Chanter.mid
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/Exercises/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/Exercises/Mp3s/${tune}Chanter.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/Exercises/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/Exercises/Oggs/${tune}Chanter.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/Exercises/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/Exercises/Wavs/${tune}Chanter.wav
  dart $tracksFile -l WARNING -i ${forDrummers}/Exercises/Midis/${tune}Drums.mid,${forPipers}/Exercises/Midis/${tune}Chanter.mid -o ${learnWithMidi}/Exercises/Midis/${tune}ChanterAndDrums.mid
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/Exercises/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/Exercises/Mp3s/${tune}ChanterAndDrums.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/Exercises/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/Exercises/Oggs/${tune}ChanterAndDrums.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/Exercises/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/Exercises/Wavs/${tune}ChanterAndDrums.wav
}

declare -a exercisesPipesAndDrumsNameArray=(
  ForRecording
)
for f in "${exercisesPipesAndDrumsNameArray[@]}"; do
  exercisesPipesAndDrums ${f}
done



# Now zip up the tunes
# We've got files in
# LearnWithMidi/BandTunes/Midis,Mp3s,Oggs,Wavs
# LearnWithMidi/ForDrummers/BandTunes/Midis,Mp3s,Oggs,Wavs
# LearnWithMidi/ForPipers/BandTunes/Midis,Mp3s,Oggs,Wavs

# BandTunes (pipes and drums)
pushd ${learnWithMidi}/BandTunes/Midis
rm -f *.zip
cp ${soundFontFile} .
zip BandTunesChanterAndDrumsMidis.zip *.mid ${soundFontName}
popd

pushd ${learnWithMidi}/BandTunes/Mp3s
rm -f *.zip
zip BandTunesChanterAndDrumsMp3s.zip *.mp3
popd

pushd ${learnWithMidi}/BandTunes/Oggs
rm -f *.zip
zip BandTunesChanterAndDrumsOggs.zip *.ogg
popd

pushd ${learnWithMidi}/BandTunes/Wavs
rm -f *.zip
zip BandTunesChanterAndDrumsWavs.zip *.wav
popd

# ForDrummers/BandTunes
pushd ${learnWithMidi}/ForDrummers/BandTunes/Midis
rm -f *.zip
zip BandTunesDrumsMidis.zip *.mid ${soundFontName}
cp ${soundFontFile} .
popd

pushd ${learnWithMidi}/ForDrummers/BandTunes/Mp3s
rm -f BandTunesDrumsMp3s.zip
zip BandTunesDrumsMp3s.zip *.mp3
popd

pushd ${learnWithMidi}/ForDrummers/BandTunes/Oggs
rm -f BandTunesDrumsOggs.zip
zip BandTunesDrumsOggs.zip *.ogg
popd

pushd ${learnWithMidi}/ForDrummers/BandTunes/Wavs
rm -f BandTunesDrumsWavs.zip
zip BandTunesDrumsWavs.zip *.wav
popd

# ForPipers/BandTunes
pushd ${learnWithMidi}/ForPipers/BandTunes/Midis
rm -f BandTunesChanterMidis.zip
zip BandTunesChanterMidis.zip *.mid ${soundFontName}
cp ${soundFontFile} .
popd

pushd ${learnWithMidi}/ForPipers/BandTunes/Mp3s
rm -f BandTunesChanterMp3s.zip
zip BandTunesChanterMp3s.zip *.mp3
popd

pushd ${learnWithMidi}/ForPipers/BandTunes/Oggs
rm -f BandTunesChanterOggs.zip
zip BandTunesChanterOggs.zip *.ogg
popd

pushd ${learnWithMidi}/ForPipers/BandTunes/Wavs
rm -f BandTunesChanterWavs.zip
zip BandTunesChanterWavs.zip *.wav
popd

#  ForDrummers/MassedBands
pushd ${learnWithMidi}/ForDrummers/MassedBands/Midis
rm -f MassedBandsDrumsMidis.zip
zip MassedBandsDrumsMidis.zip *.mid ${soundFontName}
cp ${soundFontFile} .
popd

pushd ${learnWithMidi}/ForDrummers/MassedBands/Mp3s
rm -f MassedBandsDrumsMp3s.zip
zip MassedBandsDrumsMp3s.zip *.mp3
popd

pushd ${learnWithMidi}/ForDrummers/MassedBands/Oggs
rm -f MassedBandsDrumsOggs.zip
zip MassedBandsDrumsOggs.zip *.ogg
popd

pushd ${learnWithMidi}/ForDrummers/MassedBands/Wavs
rm -f MassedBandsDrumsWavs.zip
zip MassedBandsDrumsWavs.zip *.wav
popd

exit 3

#rm -f *.sf2
#cp $soundFontFile ./
#rm -f BandTunesMidis.zip
#zip BandTunesMidis.zip  *.mid *.sf2
#popd
#
#pushd ${myHobby}/BandTunes/Mp3s/
#rm -f BandTunesMp3s.zip
#zip BandTunesMp3s.zip  *.mp3
#popd
#
#pushd ${myHobby}/BandTunes/Oggs/
#rm -f BandTunesOggs.zip
#zip BandTunesOggs.zip  *.ogg
#popd
#
#pushd ${myHobby}/BandTunes/Wavs/
#rm -f BandTunesWavs.zip
#zip BandTunesWavs.zip  *.wav
#popd

dart $snareLangExecutable -i tunes/ScotlandTheBraveMet.snl,tunes/ScotlandTheBraveSnare.snl,tunes/ScotlandTheBraveSnareChips.snl,tunes/ScotlandTheBraveTenor.snl,tunes/ScotlandTheBraveBass.snl -o ${forDrummers}/BandTunes/Midis/ScotlandTheBraveDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/ScotlandTheBraveDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/ScotlandTheBraveDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/ScotlandTheBraveDrums.wav

# I think Amber On The Rocks is pipes only
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/AmberOnTheRocks.ppl -o ${forPipers}/BandTunes/Midis/AmberOnTheRocks.mid
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/AmberOnTheRocks.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/AmberOnTheRocks.mp3
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/AmberOnTheRocks.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/AmberOnTheRocks.ogg
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/AmberOnTheRocks.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/AmberOnTheRocks.wav

# These are pipes parts, but I think they also have a snare or drum part to them somewhere too
# Already have the snare score midi because processed it from a list of single scores, not multiple that make up a midi.
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/BanjoBreakdown.ppl -o ${forPipers}/BandTunes/Midis/BanjoBreakdownChanter.mid
# I prob don't need to create audio renders of pipe midis, because they don't help pipers at this time.  Maybe when get grace notes in, and get things much better
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/BanjoBreakdownChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/BanjoBreakdownChanter.mp3
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/BanjoBreakdownChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/BanjoBreakdownChanter.ogg
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/BanjoBreakdownChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/BanjoBreakdownChanter.wav
dart $tracksFile -i ${learnWithMidi}/BandTunes/Midis/BanjoBreakdown.mid,${forPipers}/BandTunes/Midis/BanjoBreakdownChanter.mid -o ${learnWithMidi}/BandTunes/Midis/BanjoBreakdownSnareAndChanter.mid
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/BandTunes/Midis/BanjoBreakdownSnareAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Mp3s/BanjoBreakdownSnareAndChanter.mp3
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/BandTunes/Midis/BanjoBreakdownSnareAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Oggs/BanjoBreakdownSnareAndChanter.ogg
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/BandTunes/Midis/BanjoBreakdownSnareAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Wavs/BanjoBreakdownSnareAndChanter.wav

fix these for the different areas drums and pipes and both

# Now zip up the band tunes
rm -f *.sf2
cp $soundFontFile ./
rm -f BandTunesMidis.zip
zip BandTunesMidis.zip *.mid *.sf2
popd

pushd ${learnWithMidi}/BandTunes/Mp3s/
rm -f BandTunesMp3s.zip
zip BandTunesMp3s.zip *.mp3
popd

pushd ${learnWithMidi}/BandTunes/Oggs/
rm -f BandTunesOggs.zip
zip BandTunesOggs.zip *.ogg
popd

pushd ${learnWithMidi}/BandTunes/Wavs/
rm -f BandTunesWavs.zip
zip BandTunesWavs.zip *.wav
popd

echo Done processing Band Tunes files
exit 0

################## Amazing Grace ###################################
#declare tune=AmazingGrace
#dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/BandTunes/Midis/${tune}Drums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/${tune}Drums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/${tune}Drums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/${tune}Drums.wav
#dart $pipeLangDartFile -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipers}/BandTunes/Midis/${tune}Chanter.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/${tune}Chanter.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/${tune}Chanter.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/${tune}Chanter.wav
#dart $tracksFile -l WARNING -i ${forDrummers}/BandTunes/Midis/${tune}Drums.mid,${forPipers}/BandTunes/Midis/${tune}Chanter.mid -o ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Mp3s/${tune}ChanterAndDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Oggs/${tune}ChanterAndDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Wavs/${tune}ChanterAndDrums.wav
#
################## The Haunting  ###################################
#declare tune=TheHaunting
#dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/BandTunes/Midis/${tune}Drums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/${tune}Drums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/${tune}Drums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/${tune}Drums.wav
#dart $pipeLangDartFile -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipers}/BandTunes/Midis/${tune}Chanter.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/${tune}Chanter.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/${tune}Chanter.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/${tune}Chanter.wav
#dart $tracksFile -l WARNING -i ${forDrummers}/BandTunes/Midis/${tune}Drums.mid,${forPipers}/BandTunes/Midis/${tune}Chanter.mid -o ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Mp3s/${tune}ChanterAndDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Oggs/${tune}ChanterAndDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Wavs/${tune}ChanterAndDrums.wav
#
################## CastleDangerous  ###################################
#declare tune=CastleDangerous
#dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/BandTunes/Midis/${tune}Drums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/${tune}Drums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/${tune}Drums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/${tune}Drums.wav
#dart $pipeLangDartFile -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipers}/BandTunes/Midis/${tune}Chanter.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/${tune}Chanter.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/${tune}Chanter.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/${tune}Chanter.wav
#dart $tracksFile -l WARNING -i ${forDrummers}/BandTunes/Midis/${tune}Drums.mid,${forPipers}/BandTunes/Midis/${tune}Chanter.mid -o ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Mp3s/${tune}ChanterAndDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Oggs/${tune}ChanterAndDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Wavs/${tune}ChanterAndDrums.wav
#
################## The Haunting & Caslte Dangerous Set  ###################################
#declare tune=HauntingCastleSet
#dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/BandTunes/Midis/${tune}Drums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/${tune}Drums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/${tune}Drums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/${tune}Drums.wav
#dart $pipeLangDartFile -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipers}/BandTunes/Midis/${tune}Chanter.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/${tune}Chanter.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/${tune}Chanter.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/${tune}Chanter.wav
#dart $tracksFile -l WARNING -i ${forDrummers}/BandTunes/Midis/${tune}Drums.mid,${forPipers}/BandTunes/Midis/${tune}Chanter.mid -o ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Mp3s/${tune}ChanterAndDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Oggs/${tune}ChanterAndDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Wavs/${tune}ChanterAndDrums.wav
#
#
##################  Hawaii Aloha ###################################
#declare tune=HawaiiAloha
#dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/BandTunes/Midis/${tune}Drums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/${tune}Drums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/${tune}Drums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/${tune}Drums.wav
#dart $pipeLangDartFile -l WARNING -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipers}/BandTunes/Midis/${tune}Chanter.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/${tune}Chanter.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/${tune}Chanter.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/${tune}Chanter.wav
#dart $tracksFile -l WARNING -i ${forDrummers}/BandTunes/Midis/${tune}Drums.mid,${forPipers}/BandTunes/Midis/${tune}Chanter.mid -o ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Mp3s/${tune}ChanterAndDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Oggs/${tune}ChanterAndDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Wavs/${tune}ChanterAndDrums.wav
#
################## Captain Norman Orr Ewing ###################################
#declare tune=CaptEwing
#dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/BandTunes/Midis/${tune}Drums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/${tune}Drums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/${tune}Drums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/${tune}Drums.wav
#dart $pipeLangDartFile -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipers}/BandTunes/Midis/${tune}Chanter.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/${tune}Chanter.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/${tune}Chanter.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/${tune}Chanter.wav
#dart $tracksFile -l WARNING -i ${forDrummers}/BandTunes/Midis/${tune}Drums.mid,${forPipers}/BandTunes/Midis/${tune}Chanter.mid -o ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Mp3s/${tune}ChanterAndDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Oggs/${tune}ChanterAndDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Wavs/${tune}ChanterAndDrums.wav
#
#
################## Flett From Flotta ###################################
#declare tune=FlettFromFlotta
#dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/BandTunes/Midis/${tune}Drums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/${tune}Drums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/${tune}Drums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/${tune}Drums.wav
#dart $pipeLangDartFile -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipers}/BandTunes/Midis/${tune}Chanter.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/${tune}Chanter.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/${tune}Chanter.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/${tune}Chanter.wav
#dart $tracksFile -l WARNING -i ${forDrummers}/BandTunes/Midis/${tune}Drums.mid,${forPipers}/BandTunes/Midis/${tune}Chanter.mid -o ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Mp3s/${tune}ChanterAndDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Oggs/${tune}ChanterAndDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Wavs/${tune}ChanterAndDrums.wav
#
################## BattleOfWaterloo ###################################
#declare tune=BattleOfWaterloo
#dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/BandTunes/Midis/${tune}Drums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/${tune}Drums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/${tune}Drums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/${tune}Drums.wav
#dart $pipeLangDartFile -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipers}/BandTunes/Midis/${tune}Chanter.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/${tune}Chanter.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/${tune}Chanter.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/${tune}Chanter.wav
#dart $tracksFile -l WARNING -i ${forDrummers}/BandTunes/Midis/${tune}Drums.mid,${forPipers}/BandTunes/Midis/${tune}Chanter.mid -o ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Mp3s/${tune}ChanterAndDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Oggs/${tune}ChanterAndDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Wavs/${tune}ChanterAndDrums.wav
#
################## Murdos Wedding ###################################
#declare tune=MurdosWedding
#dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/BandTunes/Midis/${tune}Drums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/${tune}Drums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/${tune}Drums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/${tune}Drums.wav
#dart $pipeLangDartFile -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipers}/BandTunes/Midis/${tune}Chanter.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/${tune}Chanter.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/${tune}Chanter.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/${tune}Chanter.wav
#dart $tracksFile -l WARNING -i ${forDrummers}/BandTunes/Midis/${tune}Drums.mid,${forPipers}/BandTunes/Midis/${tune}Chanter.mid -o ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Mp3s/${tune}ChanterAndDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Oggs/${tune}ChanterAndDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Wavs/${tune}ChanterAndDrums.wav
#
################## Competition 4/4 Set  ###################################
#declare tune=Competition44Set
#dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/BandTunes/Midis/${tune}Drums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/${tune}Drums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/${tune}Drums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/${tune}Drums.wav
#dart $pipeLangDartFile -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipers}/BandTunes/Midis/${tune}Chanter.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/${tune}Chanter.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/${tune}Chanter.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/${tune}Chanter.wav
#dart $tracksFile -l WARNING -i ${forDrummers}/BandTunes/Midis/${tune}Drums.mid,${forPipers}/BandTunes/Midis/${tune}Chanter.mid -o ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Mp3s/${tune}ChanterAndDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Oggs/${tune}ChanterAndDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Wavs/${tune}ChanterAndDrums.wav
#
#
## Badge set next: Badge of Scotland, Rowan Tree, Scotland the Brave
#
################## Scotland The Brave ###################################
#declare tune=ScotlandTheBrave
#dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/BandTunes/Midis/${tune}Drums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/${tune}Drums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/${tune}Drums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/${tune}Drums.wav
#dart $pipeLangDartFile -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipers}/BandTunes/Midis/${tune}Chanter.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/${tune}Chanter.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/${tune}Chanter.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/${tune}Chanter.wav
#dart $tracksFile -l WARNING -i ${forDrummers}/BandTunes/Midis/${tune}Drums.mid,${forPipers}/BandTunes/Midis/${tune}Chanter.mid -o ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Mp3s/${tune}ChanterAndDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Oggs/${tune}ChanterAndDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Wavs/${tune}ChanterAndDrums.wav
exit 6

#################  ###################################

#dart $snareLangExecutable -i tunes/FlettFromFlottaDrums.snl -o ${forDrummers}/BandTunes/Midis/FlettFromFlottaDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/FlettFromFlottaDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/FlettFromFlottaDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/FlettFromFlottaDrums.wav
#
#dart $pipeLangDartFile -i ${pipeLangDir}/tunes/FlettFromFlottaChanter.ppl -o ${forPipers}/BandTunes/Midis/FlettFromFlottaChanter.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/FlettFromFlottaChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/FlettFromFlottaChanter.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/FlettFromFlottaChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/FlettFromFlottaChanter.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/FlettFromFlottaChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/FlettFromFlottaChanter.wav
#
#dart $tracksFile -l WARNING -i ${forDrummers}/BandTunes/Midis/FlettFromFlottaDrums.mid,${forPipers}/BandTunes/Midis/FlettFromFlottaChanter.mid -o ${forDrummers}/BandTunes/Midis/FlettFromFlottaChanterAndDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/FlettFromFlottaChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/FlettFromFlottaChanterAndDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/FlettFromFlottaChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/FlettFromFlottaChanterAndDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/FlettFromFlottaChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/FlettFromFlottaChanterAndDrums.wav

#dart $snareLangExecutable -i tunes/BattleOfWaterlooDrums.snl -o ${forDrummers}/BandTunes/Midis/BattleOfWaterlooDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/BattleOfWaterlooDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/BattleOfWaterlooDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/BattleOfWaterlooDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/BattleOfWaterlooDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/BattleOfWaterlooDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/BattleOfWaterlooDrums.wav
#
#dart $pipeLangDartFile -i ${pipeLangDir}/tunes/BattleOfWaterlooChanter.ppl -o ${forPipers}/BandTunes/Midis/BattleOfWaterlooChanter.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/BattleOfWaterlooChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/BattleOfWaterlooChanter.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/BattleOfWaterlooChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/BattleOfWaterlooChanter.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/BattleOfWaterlooChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/BattleOfWaterlooChanter.wav
#
#dart $tracksFile -l WARNING -i ${forDrummers}/BandTunes/Midis/BattleOfWaterlooDrums.mid,${forPipers}/BandTunes/Midis/BattleOfWaterlooChanter.mid -o ${learnWithMidi}/BandTunes/Midis/BattleOfWaterlooChanterAndDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/BattleOfWaterlooChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Mp3s/BattleOfWaterlooChanterAndDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/BattleOfWaterlooChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Oggs/BattleOfWaterlooChanterAndDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/BattleOfWaterlooChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Wavs/BattleOfWaterlooChanterAndDrums.wav

#dart $snareLangExecutable -i tunes/BattleOfWaterlooMcWhirterDrums.snl -o ${forDrummers}/BandTunes/Midis/BattleOfWaterlooMcWhirterDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/BattleOfWaterlooMcWhirterDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/BattleOfWaterlooMcWhirterDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/BattleOfWaterlooMcWhirterDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/BattleOfWaterlooMcWhirterDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/BattleOfWaterlooMcWhirterDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/BattleOfWaterlooMcWhirterDrums.wav
#
#dart $pipeLangDartFile -i ${pipeLangDir}/tunes/BattleOfWaterlooChanter.ppl -o ${forPipers}/BandTunes/Midis/BattleOfWaterlooChanter.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/BattleOfWaterlooChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/BattleOfWaterlooChanter.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/BattleOfWaterlooChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/BattleOfWaterlooChanter.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/BattleOfWaterlooChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/BattleOfWaterlooChanter.wav
#
#dart $tracksFile -l WARNING -i ${forDrummers}/BandTunes/Midis/BattleOfWaterlooMcWhirterDrums.mid,${forPipers}/BandTunes/Midis/BattleOfWaterlooChanter.mid -o ${learnWithMidi}/BandTunes/Midis/BattleOfWaterlooChanterAndMcWhirterDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/BattleOfWaterlooChanterAndMcWhirterDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Mp3s/BattleOfWaterlooChanterAndMcWhirterDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/BattleOfWaterlooChanterAndMcWhirterDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Oggs/BattleOfWaterlooChanterAndMcWhirterDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/BattleOfWaterlooChanterAndMcWhirterDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Wavs/BattleOfWaterlooChanterAndMcWhirterDrums.wav

#dart $snareLangExecutable -i tunes/MurdosWeddingDrums.snl -o ${forDrummers}/BandTunes/Midis/MurdosWeddingDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/MurdosWeddingDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Mp3s/MurdosWeddingDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/MurdosWeddingDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Oggs/MurdosWeddingDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forDrummers}/BandTunes/Midis/MurdosWeddingDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forDrummers}/BandTunes/Wavs/MurdosWeddingDrums.wav
#
#dart $pipeLangDartFile -i ${pipeLangDir}/tunes/MurdosWeddingChanter.ppl -o ${forPipers}/BandTunes/Midis/MurdosWeddingChanter.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/MurdosWeddingChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Mp3s/MurdosWeddingChanter.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/MurdosWeddingChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Oggs/MurdosWeddingChanter.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${forPipers}/BandTunes/Midis/MurdosWeddingChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${forPipers}/BandTunes/Wavs/MurdosWeddingChanter.wav
#
#dart $tracksFile -l WARNING -i ${forDrummers}/BandTunes/Midis/MurdosWeddingDrums.mid,${forPipers}/BandTunes/Midis/MurdosWeddingChanter.mid -o ${learnWithMidi}/BandTunes/Midis/MurdosWeddingChanterAndDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/MurdosWeddingChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Mp3s/MurdosWeddingChanterAndDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/MurdosWeddingChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Oggs/MurdosWeddingChanterAndDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${learnWithMidi}/BandTunes/Midis/MurdosWeddingChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${learnWithMidi}/BandTunes/Wavs/MurdosWeddingChanterAndDrums.wav

#################  ###################################
#################  ###################################
#################  ###################################
