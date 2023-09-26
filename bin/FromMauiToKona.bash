#!/bin/bash
echo "This bash script only builds the tune FromMauiToKona by invoking the three build segments:"
echo "1. Cleanup, 2. Build Snare, 3. Build Changer, 4. Assemble Tracks"
declare gig=FromMauiToKona
echo "This is being run out of the bin directory of the snarelang4 project"
echo "We are here: $(pwd)"
echo ""
today=`date +%Y%m%d`
#echo "Today is ${today}"
#echo "echo zip ${gig}Midis${today}.zip *.mid *.sf2"
#echo "echo ${gig}MP3s${today}.zip *.mp3"


#declare snareLangDir=/home/rob/WebstormProjects/snarelang4
declare snareLangDir=/home/rob/WebstormProjects/SnareLang4
declare snareLangExecutable=${snareLangDir}/bin/snl.dart
declare pipeLangDir=/home/rob/WebstormProjects/pipelang
declare pipeLangExecutable=${pipeLangDir}/bin/ppl.dart
declare tracksDir=/home/rob/WebstormProjects/tracks
declare tracksExecutable=${tracksDir}/bin/tracks.dart

# What do I need all this for?
declare learnWithMidiDir=/home/rob/LearnWithMidi
declare forDrummersDir=${learnWithMidiDir}/ForDrummers
declare forPipersDir=${learnWithMidiDir}/ForPipers

declare warmupsSrcDir=${snareLangDir}/exercises/warmups

#declare targetDir=${learnWithMidiDir}/Gigs/${gig}
declare targetDir=${forDrummersDir}/Gigs/${gig}

# The soundfont file must coordinate with the midi files that are created, and they're created with "pitches" in mind, so really only
# one soundfont file should exist per organization of midi files.
declare soundFontName=DrumLineMelodyChanter20210518.sf2
declare soundFontFile=${learnWithMidiDir}/SoundFonts/${soundFontName}

# Some of the following should be put into a set and played without break.
# And there's a flaw in design.  Should have a mapping between drum and pipe tune names.
# But it's not worth my time to rearrange everything right now.
declare -a FromMauiToKonaPipesAndDrumsNameArray=(
  FromMauiToKona
#  BanjoBreakdownGeneralJig
#  JohnWalshsWalk
#  AnnettesChatter
#  JimmyRollo
#  JaneCampbell
#  LegalRepercussions
)

#declare -a SomeOtherKindaTunesPipesAndDrumsNameArray=(
#  CameronianRant
##  BanjoBreakdownGeneralJig
#)

# Sources for these are in tunes dir, but should be elsewhere.
# For example the warmups should be in exercises/warmups
# and massed bands should be in massed bands or something
#declare -a paddysDayDrumSettingsNameArray=(
##  MassedBands24JLDrums
##  MassedBands34JLDrums
##  MassedBands44JLDrums
#  GeneralJigDrums
#)

# source for these should be in exercises/warmups
declare -a warmUpsNameArray=(
  WarmUpsSets
)

function compileDrumSettings() {
  declare setting=$1
  echo "Compiling drum setting ${setting}"
  echo "dart $snareLangExecutable -i tunes/${setting}.snl -o ${forDrummersDir}/Gigs/${gig}/Midis/${setting}.mid"
  dart $snareLangExecutable -i tunes/${setting}.snl -o ${forDrummersDir}/Gigs/${gig}/Midis/${setting}.mid && (
    fluidsynth -q -a alsa -g 1.5 -T raw -F - ${soundFontFile} ${forDrummersDir}/Gigs/${gig}/Midis/${setting}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.5" ${forDrummersDir}/Gigs/${gig}/Mp3s/${setting}.mp3
    echo "Created ${forDrummersDir}/Gigs/${gig}/Mp3s/${setting}.mp3"
  )
  return ${?}

}
function compileWarmUps() {
  declare warmUp=$1
  echo "Compiling WarmUp ${warmUp}"
  echo "dart $snareLangExecutable -i ${warmupsSrcDir}/${warmUp}.snl -o ${forDrummersDir}/Gigs/${gig}/Midis/${warmUp}.mid"
  dart $snareLangExecutable -i ${warmupsSrcDir}/${warmUp}.snl -o ${forDrummersDir}/Gigs/${gig}/Midis/${warmUp}.mid && (
    fluidsynth -q -a alsa -g 1.5 -T raw -F - ${soundFontFile} ${forDrummersDir}/Gigs/${gig}/Midis/${warmUp}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.5" ${forDrummersDir}/Gigs/${gig}/Mp3s/${warmUp}.mp3
    echo "Created ${forDrummersDir}/Gigs/${gig}/Mp3s/${warmUp}.mp3"
  )
  return ${?}

}

# It appears that in bash you have to define a function before it can be used
function compileDrumsChanterTracksOneTune() {
  declare tune=$1
  echo "Compiling drums, chanter, and tracks for tune ${tune}"
  # would like to do error checking.  If the dart command doesn't work, don't do the fluidsynth or ffmpeg
  # If either the drums processing or the chanter processing fails, don't do the tracks processing.
  # If any errors, return non zero.
  # And whoever calls this should report the error, but keep going.
  echo "dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummersDir}/Gigs/${gig}/Midis/${tune}Drums.mid"
  dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummersDir}/Gigs/${gig}/Midis/${tune}Drums.mid && (
    fluidsynth -q -a alsa -g 1.5 -T raw -F - ${soundFontFile} ${forDrummersDir}/Gigs/${gig}/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.5" ${forDrummersDir}/Gigs/${gig}/Mp3s/${tune}Drums.mp3
    echo "Created ${forDrummersDir}/Gigs/${gig}/Mp3s/${tune}Drums.mp3"
  )
    echo ""
  #    echo "Hey, that drum processing returned this: ${?}"
  echo "dart $pipeLangExecutable -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipersDir}/Gigs/${gig}/Midis/${tune}Chanter.mid"
  dart $pipeLangExecutable -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipersDir}/Gigs/${gig}/Midis/${tune}Chanter.mid && (
    fluidsynth -q -a alsa -g 1.5 -T raw -F - ${soundFontFile} ${forPipersDir}/Gigs/${gig}/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.5" ${forPipersDir}/Gigs/${gig}/Mp3s/${tune}Chanter.mp3
    echo "Created ${forPipersDir}/Gigs/${gig}/Mp3s/${tune}Chanter.mp3"
  )
    echo ""
  #    echo "Hey, that pipe processing returned this: ${?}"
#  echo "dart $tracksExecutable -l WARNING -i ${forDrummersDir}/Gigs/${gig}/Midis/${tune}Drums.mid,${forPipersDir}/Gigs/${gig}/Midis/${tune}Chanter.mid -o ${learnWithMidiDir}/Gigs/${gig}/Midis/${tune}ChanterAndDrums.mid"
  echo "dart $tracksExecutable -l WARNING -i ${forDrummersDir}/Gigs/${gig}/Midis/${tune}Drums.mid,${forPipersDir}/Gigs/${gig}/Midis/${tune}Chanter.mid -o ${forDrummersDir}/Gigs/${gig}/Midis/${tune}ChanterAndDrums.mid"
  dart $tracksExecutable -l WARNING -i ${forDrummersDir}/Gigs/${gig}/Midis/${tune}Drums.mid,${forPipersDir}/Gigs/${gig}/Midis/${tune}Chanter.mid -o ${forDrummersDir}/Gigs/${gig}/Midis/${tune}ChanterAndDrums.mid && (
#    fluidsynth -q -a alsa -g 1.5 -T raw -F - ${soundFontFile} ${learnWithMidiDir}/Gigs/${gig}/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.5" ${learnWithMidiDir}/Gigs/${gig}/Mp3s/${tune}ChanterAndDrums.mp3
    fluidsynth -q -a alsa -g 1.5 -T raw -F - ${soundFontFile} ${forDrummersDir}/Gigs/${gig}/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.5" ${forDrummersDir}/Gigs/${gig}/Mp3s/${tune}ChanterAndDrums.mp3
#    echo "Created ${learnWithMidiDir}/Gigs/${gig}/Mp3s/${tune}ChanterAndDrums.mp3"
    echo "Created ${forDrummersDir}/Gigs/${gig}/Mp3s/${tune}ChanterAndDrums.mp3"
  )
    echo ""
  #    echo "Hey, that track processing returned this: ${?}"
  return ${?}
}


# Execution begins here, I guess

echo cp -v /home/rob/Desktop/MySoundFonts/${soundFontName} ${learnWithMidiDir}/SoundFonts
#cp /home/rob/Desktop/MySoundFonts/${soundFontName} ${learnWithMidiDir}/SoundFonts
#echo ls ${learnWithMidiDir}/SoundFonts
#ls ${learnWithMidiDir}/SoundFonts
#cp /home/rob/Desktop/MySoundFonts/PipesAndDrums202011060735.sf2 ${learnWithMidiDir}/MySoundFonts
#echo soundfont is $soundFontFile
#echo ""





# There could be stray files in these various dirs, so might want to check time stamps
rm -v ${targetDir}/Midis/*.mid
rm -v ${targetDir}/Mp3s/*.mp3


for f in "${FromMauiToKonaPipesAndDrumsNameArray[@]}"; do
  compileDrumsChanterTracksOneTune ${f}
#  echo "In loop after processing ${f},  returned this value: ${?} "
  echo ""
  echo ""
done

for f in "${warmUpsNameArray[@]}"; do
  compileWarmUps ${f}
  echo ""
  echo ""
done


echo Done processing files
exit 0

