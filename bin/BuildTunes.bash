#!/bin/
echo "Hey is this BuildTunes.bash script still being used for something?  Maybe, maybe, maybe this one is more current."
echo "I think this one is probably better for doing tunes in the way that I've set them up, such that there is a base name"
echo "like DiuRegnare, and then there are the drums version DiuRegnareDrums and pipes version DiuRegnareChanter"
echo "Maybe this is just a simplified version of the other, targeting tunes?"
echo "And what about the processing of the pipes tunes?  And what about merging them?"
echo "Obviously I've gone too long without reviewing this, and making it clear."
# This bash script works in conjunction with a script that slaps chanter and drums together, I think.



# This could be rewritten using DCli   see https://dcli.noojee.dev/dcli-api/the-evils-of-cd
# NEED A WAY TO REPORT ERRORS
#tempfiles=( )
#cleanup() {
#  rm -f "${tempfiles[@]}"
#}
#trap cleanup 0
#
#error() {
#  local parent_lineno="$1"
#  local message="$2"
#  local code="${3:-1}"
#  if [[ -n "$message" ]] ; then
#    echo "Error on or near line ${parent_lineno}: ${message}; exiting with status ${code}"
#  else
#    echo "Error on or near line ${parent_lineno}; exiting with status ${code}"
#  fi
#  exit "${code}"
#}
#trap 'error ${LINENO}' ERR

#
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
echo cp /home/rob/Desktop/MySoundFonts/${soundFontName} ${learnWithMidi}/SoundFonts
cp /home/rob/Desktop/MySoundFonts/${soundFontName} ${learnWithMidi}/SoundFonts
ls ${learnWithMidi}/SoundFonts
declare soundFontFile=${learnWithMidi}/SoundFonts/${soundFontName}
#cp /home/rob/Desktop/MySoundFonts/PipesAndDrums202011060735.sf2 ${learnWithMidi}/MySoundFonts
echo soundfont is $soundFontFile





# a way to do some conditional parts, but a bad way
#if false
#then
#echo should not get here


bandTunesPipesAndDrums() {
  declare tune=$1
  # would like to do error checking.  If the dart command doesn't work, don't do the fluidsynth or ffmpeg
  # If either the drums processing or the chanter processing fails, don't do the tracks processing.
  # If any errors, return non zero.
  # And whoever calls this should report the error, but keep going.
  dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/BandTunes/Midis/${tune}Drums.mid && (
    fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/BandTunes/Mp3s/${tune}Drums.mp3
    echo Not doing .wav or .ogg files for now
#    fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/BandTunes/Oggs/${tune}Drums.ogg
#    fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/BandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/BandTunes/Wavs/${tune}Drums.wav
  )
#    echo "Hey, that drum processing returned this: ${?}"
  dart $pipeLangDartFile -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipers}/BandTunes/Midis/${tune}Chanter.mid && (
    fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forPipers}/BandTunes/Mp3s/${tune}Chanter.mp3
#    fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forPipers}/BandTunes/Oggs/${tune}Chanter.ogg
#    fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forPipers}/BandTunes/Wavs/${tune}Chanter.wav
  )
#    echo "Hey, that pipe processing returned this: ${?}"
  dart $tracksFile -l WARNING -i ${forDrummers}/BandTunes/Midis/${tune}Drums.mid,${forPipers}/BandTunes/Midis/${tune}Chanter.mid -o ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid && (
    fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${learnWithMidi}/BandTunes/Mp3s/${tune}ChanterAndDrums.mp3
#    fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${learnWithMidi}/BandTunes/Oggs/${tune}ChanterAndDrums.ogg
#    fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${learnWithMidi}/BandTunes/Wavs/${tune}ChanterAndDrums.wav
  )
#    echo "Hey, that track processing returned this: ${?}"
  return ${?}
}

declare -a bandTunesPipesAndDrumsNameArray=(
##  AmazingGraceSimple
  DiuRegnare
#  24MarchSet
#  AmazingGrace
#  BadgeOfScotland
#  BadgeSet
#  BarrenRocksOfAden
#  BattleOfWaterloo
#  BrownHairedMaiden
#  CaptEwing
#  CaptEwingMassedBands
#  CastleDangerousMassedBands
#  CastleDangerousMassedBandsShifted
#  Competition44Set
#  Competition44SetMassedBands
#  FlettFromFlotta
#  HauntingCastleSet
###  HauntingCastleSetSimple
#  HauntingCastleSetSimpleAndMassedBands
#  HawaiiAloha
#  HighlandLaddie
#  Lochanside
#  MurdosWedding
#  RowanTree
#  ScotlandTheBrave
#  ScotlandTheBrave2XMassedBands
###  ScotlandTheBraveMarch44
#  ScotlandTheBraveMassedBands
#  TheHaunting
#  TheHaunting
##  TheHauntingSimple
)

# There could be stray files in these various dirs, so might want to check time stamps
for f in "${bandTunesPipesAndDrumsNameArray[@]}"; do
  bandTunesPipesAndDrums ${f}
  echo "In loop after processing ${f},  returned this value: ${?} "
done
echo HEY JUST STOPPING THINGS HERE BECAUSE DO NOT WANT TO WASTE PROCESSING TIME.  LATER REMOVE THIS EXIT
exit

#else
#  echo should get here


#fi


experimentalPipesAndDrums() {
  declare tune=$1
  dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/Experimental/Midis/${tune}Drums.mid && (
    fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/Experimental/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/Experimental/Mp3s/${tune}Drums.mp3
  )
  dart $pipeLangDartFile -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipers}/Experimental/Midis/${tune}Chanter.mid && (
    fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/Experimental/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forPipers}/Experimental/Mp3s/${tune}Chanter.mp3
  )
  dart $tracksFile -l WARNING -i ${forDrummers}/Experimental/Midis/${tune}Drums.mid,${forPipers}/Experimental/Midis/${tune}Chanter.mid -o ${learnWithMidi}/Experimental/Midis/${tune}ChanterAndDrums.mid && (
    fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/Experimental/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${learnWithMidi}/Experimental/Mp3s/${tune}ChanterAndDrums.mp3
  )
  return ${?}
}

#declare -a experimentalPipesAndDrumsNameArray=(
#  AmazingGraceSimple
#  CastleDangerousSimple
#  HauntingCastleSetSimple
#  ScotlandTheBraveMarch44
#  TheHauntingSimple
#)
#
## There could be stray files in these various dirs, so might want to check time stamps
#for f in "${experimentalPipesAndDrumsNameArray[@]}"; do
#  experimentalPipesAndDrums ${f}
#done






justDrums() {
  declare tune=$1
  dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/FanfaresSalutes/Midis/${tune}Drums.mid
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/FanfaresSalutes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/FanfaresSalutes/Mp3s/${tune}Drums.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/FanfaresSalutes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/FanfaresSalutes/Oggs/${tune}Drums.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/FanfaresSalutes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/FanfaresSalutes/Wavs/${tune}Drums.wav
}

declare -a justDrumsNameArray=(
  BlackBearIntro
)

for f in "${justDrumsNameArray[@]}"; do
  justDrums ${f}
done


justMetronomes() {
  declare tune=$1
  dart $snareLangExecutable -i Metronomes/${tune}Met.snl -o ${learnWithMidi}/Metronomes/Midis/${tune}Met.mid
  # Makes no sense to render to MP3 or other audio.  This is for MIDI only
}

declare -a justMetronomesNameArray=(
  EighthNotes44
  QuarterNotes44
  TwelfthNotes44
)

for f in "${justMetronomesNameArray[@]}"; do
  justMetronomes ${f}
done





massedBandsDrums() {
  declare tune=$1
  dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/MassedBands/Midis/${tune}Drums.mid
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/MassedBands/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/MassedBands/Mp3s/${tune}Drums.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/MassedBands/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/MassedBands/Oggs/${tune}Drums.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/MassedBands/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/MassedBands/Wavs/${tune}Drums.wav
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








nonBandTunesPipesAndDrums() {
  declare tune=$1
  dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummers}/NonBandTunes/Midis/${tune}Drums.mid
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/NonBandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/NonBandTunes/Mp3s/${tune}Drums.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/NonBandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/NonBandTunes/Oggs/${tune}Drums.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/NonBandTunes/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/NonBandTunes/Wavs/${tune}Drums.wav
  dart $pipeLangDartFile -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipers}/NonBandTunes/Midis/${tune}Chanter.mid
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/NonBandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forPipers}/NonBandTunes/Mp3s/${tune}Chanter.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/NonBandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forPipers}/NonBandTunes/Oggs/${tune}Chanter.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/NonBandTunes/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forPipers}/NonBandTunes/Wavs/${tune}Chanter.wav
  dart $tracksFile -l WARNING -i ${forDrummers}/NonBandTunes/Midis/${tune}Drums.mid,${forPipers}/NonBandTunes/Midis/${tune}Chanter.mid -o ${learnWithMidi}/NonBandTunes/Midis/${tune}ChanterAndDrums.mid
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/NonBandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${learnWithMidi}/NonBandTunes/Mp3s/${tune}ChanterAndDrums.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/NonBandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${learnWithMidi}/NonBandTunes/Oggs/${tune}ChanterAndDrums.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/NonBandTunes/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${learnWithMidi}/NonBandTunes/Wavs/${tune}ChanterAndDrums.wav
}

declare -a nonBandTunesPipesAndDrumsNameArray=(
  AnnettesChatter
  CameronianRant
#  JaneCampbell
#  JimmyRollo
#  JohnWalshsWalk
)

# There could be stray files in these various dirs, so might want to check time stamps
for f in "${nonBandTunesPipesAndDrumsNameArray[@]}"; do
  nonBandTunesPipesAndDrums ${f}
done




bdayPartyGig() {
  declare tune=$1
  echo "Copying ${tune} to BDayPartyGig area"
  cp ${learnWithMidi}/BandTunes/Midis/${tune}ChanterAndDrums.mid ${learnWithMidi}/BDayPartyGig/Midis
  cp ${learnWithMidi}/BandTunes/Mp3s/${tune}ChanterAndDrums.mp3 ${learnWithMidi}/BDayPartyGig/Mp3s
  cp ${learnWithMidi}/BandTunes/Wavs/${tune}ChanterAndDrums.wav ${learnWithMidi}/BDayPartyGig/Wavs
  # How about a drums-only version?  No, because the pipers would practice with chanter, and so it helps to hear chanter, I think.
#  cp ${learnWithMidi}/ForDrummers/BandTunes/Midis/${tune}Drums.mid ${learnWithMidi}/BDayPartyGig/Midis
#  cp ${learnWithMidi}/ForDrummers/BandTunes/Mp3s/${tune}Drums.mp3 ${learnWithMidi}/BDayPartyGig/Mp3s
}

# In the order played, which goes into the zip
declare -a bdayPartyGigNameArray=(
  ScotlandTheBrave2XMassedBands
  HauntingCastleSetSimpleAndMassedBands
  CaptEwingMassedBands
  HawaiiAloha
  Competition44SetMassedBands
  AmazingGrace
)

# There could be stray files in these various dirs, so might want to check time stamps
for f in "${bdayPartyGigNameArray[@]}"; do
  bdayPartyGig ${f}
done

# Try to do these zips in the same order.  Nope, didn't work for playing.  Still went alphabetic when VLC played the Zip
echo "Creating zip files for bday party gig"
pushd ${learnWithMidi}/BDayPartyGig/Midis
rm -f BDayPartyGigMidis.zip
#zip BDayPartyGigMidis.zip *.mid
zip BDayPartyGigMidis.zip \
  ScotlandTheBrave2XMassedBandsChanterAndDrums.mid \
  HauntingCastleSetSimpleAndMassedBandsChanterAndDrums.mid \
  CaptEwingMassedBandsChanterAndDrums.mid \
  HawaiiAlohaChanterAndDrums.mid \
  Competition44SetMassedBandsChanterAndDrums.mid \
  AmazingGraceChanterAndDrums.mid
cp ${soundFontFile} .
popd

pushd ${learnWithMidi}/BDayPartyGig/Mp3s
rm -f BDayPartyGigMp3s.zip
# zip BDayPartyGigMp3s.zip *.mp3
zip BDayPartyGigMp3s.zip \
  ScotlandTheBrave2XMassedBandsChanterAndDrums.mp3 \
  HauntingCastleSetSimpleAndMassedBandsChanterAndDrums.mp3 \
  CaptEwingMassedBandsChanterAndDrums.mp3 \
  HawaiiAlohaChanterAndDrums.mp3 \
  Competition44SetMassedBandsChanterAndDrums.mp3 \
  AmazingGraceChanterAndDrums.mp3 \
  ScotlandTheBrave2XMassedBandsChanterAndDrums.mp3
popd

pushd ${learnWithMidi}/BDayPartyGig/Wavs
rm -f BDayPartyGigWavs.zip
# zip BDayPartyGigMp3s.zip *.mp3
zip BDayPartyGigWavs.zip \
  ScotlandTheBrave2XMassedBandsChanterAndDrums.wav \
  HauntingCastleSetSimpleAndMassedBandsChanterAndDrums.wav \
  CaptEwingMassedBandsChanterAndDrums.wav \
  HawaiiAlohaChanterAndDrums.wav \
  Competition44SetMassedBandsChanterAndDrums.wav \
  AmazingGraceChanterAndDrums.wav \
  ScotlandTheBrave2XMassedBandsChanterAndDrums.wav
popd



#exercisesPipesAndDrums() {
#  declare tune=$1
#  dart $snareLangExecutable -i exercises/${tune}Drums.snl -o ${forDrummers}/Exercises/Midis/${tune}Drums.mid
#  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/Exercises/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/Exercises/Mp3s/${tune}Drums
#  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/Exercises/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/Exercises/Oggs/${tune}Drums.ogg
#  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/Exercises/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/Exercises/Wavs/${tune}Drums.wav
#  dart $pipeLangDartFile -i ${pipeLangDir}/exercises/${tune}Chanter.ppl -o ${forPipers}/Exercises/Midis/${tune}Chanter.mid
#  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/Exercises/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forPipers}/Exercises/Mp3s/${tune}Chanter.mp3
#  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/Exercises/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forPipers}/Exercises/Oggs/${tune}Chanter.ogg
#  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/Exercises/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forPipers}/Exercises/Wavs/${tune}Chanter.wav
#  dart $tracksFile -l WARNING -i ${forDrummers}/Exercises/Midis/${tune}Drums.mid,${forPipers}/Exercises/Midis/${tune}Chanter.mid -o ${learnWithMidi}/Exercises/Midis/${tune}ChanterAndDrums.mid
#  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/Exercises/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${learnWithMidi}/Exercises/Mp3s/${tune}ChanterAndDrums.mp3
#  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/Exercises/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${learnWithMidi}/Exercises/Oggs/${tune}ChanterAndDrums.ogg
#  fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/Exercises/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${learnWithMidi}/Exercises/Wavs/${tune}ChanterAndDrums.wav
#}
#
#declare -a exercisesPipesAndDrumsNameArray=(
#  ForRecording
#)
#for f in "${exercisesPipesAndDrumsNameArray[@]}"; do
#  exercisesPipesAndDrums ${f}
#done

# Now zip up the tunes
# We've got files in
# LearnWithMidi/BandTunes/Midis,Mp3s,Oggs,Wavs
# LearnWithMidi/ForDrummers/BandTunes/Midis,Mp3s,Oggs,Wavs
# LearnWithMidi/ForPipers/BandTunes/Midis,Mp3s,Oggs,Wavs

# BandTunes (pipes and drums)
pushd ${learnWithMidi}/BandTunes/Midis
rm -f *.zip
echo cp ${soundFontFile} .
cp ${soundFontFile} .
echo zip BandTunesChanterAndDrumsMidis.zip *.mid ${soundFontName}
zip BandTunesChanterAndDrumsMidis.zip *.mid ${soundFontName}
rm ${soundFontName}
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
cp ${soundFontFile} .
zip BandTunesDrumsMidis.zip *.mid ${soundFontName}
rm ${soundFontName}
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
cp ${soundFontFile} .
zip BandTunesChanterMidis.zip *.mid ${soundFontName}
rm ${soundFontName}
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
cp ${soundFontFile} .
zip MassedBandsDrumsMidis.zip *.mid ${soundFontName}
rm ${soundFontName}
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

#  ForDrummers/FanfaresSalutes
pushd ${learnWithMidi}/ForDrummers/FanfaresSalutes/Midis
rm -f FanfaresSalutesDrumsMidis.zip
cp ${soundFontFile} .
zip FanfaresSalutesDrumsMidis.zip *.mid ${soundFontName}
rm ${soundFontName}
popd

pushd ${learnWithMidi}/ForDrummers/FanfaresSalutes/Mp3s
rm -f FanfaresSalutesDrumsMp3s.zip
zip FanfaresSalutesDrumsMp3s.zip *.mp3
popd

pushd ${learnWithMidi}/ForDrummers/FanfaresSalutes/Oggs
rm -f FanfaresSalutesDrumsOggs.zip
zip FanfaresSalutesDrumsOggs.zip *.ogg
popd

pushd ${learnWithMidi}/ForDrummers/FanfaresSalutes/Wavs
rm -f FanfaresSalutesDrumsWavs.zip
zip FanfaresSalutesDrumsWavs.zip *.wav
popd


# Experimental stuff (pipes and drums)
# PROBABLY WRONG
pushd ${learnWithMidi}/Experimental/Midis
rm -f *.zip
cp ${soundFontFile} .
zip ExperimentalChanterAndDrumsMidis.zip *.mid
popd

pushd ${learnWithMidi}/Experimental/Mp3s
rm -f *.zip
zip ExperimentalChanterAndDrumsMp3s.zip *.mp3
popd

pushd ${learnWithMidi}/ForDrummers/Experimental/Midis
rm -f ExperimentalDrumsMidis.zip
cp ${soundFontFile} .
zip ExperimentalDrumsMidis.zip *.mid ${soundFontName}
rm ${soundFontName}
popd

pushd ${learnWithMidi}/ForDrummers/Experimental/Mp3s
rm -f ExperimentalDrumsMp3s.zip
zip ExperimentalDrumsMp3s.zip *.mp3
popd

pushd ${learnWithMidi}/ForPipers/Experimental/Midis
rm -f ExperimentalChanterMidis.zip
cp ${soundFontFile} .
zip ExperimentalChanterMidis.zip *.mid ${soundFontName}
rm ${soundFontName}
popd

pushd ${learnWithMidi}/ForPipers/Experimental/Mp3s
rm -f ExperimentalChanterMp3s.zip
zip ExperimentalChanterMp3s.zip *.mp3
popd



#################################################################################

# Temporary thing here to get ready for the B'day Gig
# Everything should have been created (midis and sound files, and zips)
# so just copy them into a new place.


exit 0











dart $snareLangExecutable -i tunes/ScotlandTheBraveMet.snl,tunes/ScotlandTheBraveSnare.snl,tunes/ScotlandTheBraveSnareChips.snl,tunes/ScotlandTheBraveTenor.snl,tunes/ScotlandTheBraveBass.snl -o ${forDrummers}/BandTunes/Midis/ScotlandTheBraveDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/BandTunes/Mp3s/ScotlandTheBraveDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/BandTunes/Oggs/ScotlandTheBraveDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forDrummers}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forDrummers}/BandTunes/Wavs/ScotlandTheBraveDrums.wav

# I think Amber On The Rocks is pipes only
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/AmberOnTheRocks.ppl -o ${forPipers}/BandTunes/Midis/AmberOnTheRocks.mid
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/AmberOnTheRocks.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forPipers}/BandTunes/Mp3s/AmberOnTheRocks.mp3
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/AmberOnTheRocks.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forPipers}/BandTunes/Oggs/AmberOnTheRocks.ogg
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/AmberOnTheRocks.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forPipers}/BandTunes/Wavs/AmberOnTheRocks.wav

# These are pipes parts, but I think they also have a snare or drum part to them somewhere too
# Already have the snare score midi because processed it from a list of single scores, not multiple that make up a midi.
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/BanjoBreakdown.ppl -o ${forPipers}/BandTunes/Midis/BanjoBreakdownChanter.mid
# I prob don't need to create audio renders of pipe midis, because they don't help pipers at this time.  Maybe when get grace notes in, and get things much better
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/BanjoBreakdownChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forPipers}/BandTunes/Mp3s/BanjoBreakdownChanter.mp3
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/BanjoBreakdownChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forPipers}/BandTunes/Oggs/BanjoBreakdownChanter.ogg
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${forPipers}/BandTunes/Midis/BanjoBreakdownChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${forPipers}/BandTunes/Wavs/BanjoBreakdownChanter.wav
dart $tracksFile -i ${learnWithMidi}/BandTunes/Midis/BanjoBreakdown.mid,${forPipers}/BandTunes/Midis/BanjoBreakdownChanter.mid -o ${learnWithMidi}/BandTunes/Midis/BanjoBreakdownSnareAndChanter.mid
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/BandTunes/Midis/BanjoBreakdownSnareAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${learnWithMidi}/BandTunes/Mp3s/BanjoBreakdownSnareAndChanter.mp3
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/BandTunes/Midis/BanjoBreakdownSnareAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${learnWithMidi}/BandTunes/Oggs/BanjoBreakdownSnareAndChanter.ogg
fluidsynth -q -a alsa -g 2.0 -T raw -F - ${soundFontFile} ${learnWithMidi}/BandTunes/Midis/BanjoBreakdownSnareAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.25" ${learnWithMidi}/BandTunes/Wavs/BanjoBreakdownSnareAndChanter.wav

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

echo Done processing files
exit 0




