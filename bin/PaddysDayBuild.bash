#!/bin/bash
echo "This bash script is meant to build only the tunes we plan to use for the St. Patricks Day gigs."
declare gig=PaddysDay
echo "This is being run out of the bin directory of the snarelang4 project, and not the pipelang project"
echo "We are here: $(pwd)"
echo ""
today=`date +%Y%m%d`
#echo "Today is ${today}"
echo "echo zip ${gig}Midis${today}.zip *.mid *.sf2"
echo "echo ${gig}MP3s${today}.zip *.mp3"


declare snareLangDir=/home/rob/WebstormProjects/snarelang4
declare snareLangExecutable=${snareLangDir}/bin/snl.dart
declare pipeLangDir=/home/rob/WebstormProjects/pipelang
declare pipeLangExecutable=${pipeLangDir}/bin/ppl.dart
declare tracksDir=/home/rob/WebstormProjects/tracks
declare tracksExecutable=${tracksDir}/bin/tracks.dart

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
declare -a paddysDayPipesAndDrumsNameArray=(
#  HawaiiAlohaFast
  RowanTreeScotBrave2xJL24MassedBands
  JigSetGeneralJig
  BanjoBreakdownGeneralJig
  SkymansJig
  CastleDangerousJL34MassedBands
  RowanTreeJL24MassedBands
# CompSet Flett, BattleW, Cockney, Murdos
# CaptNormanOrr
  ScotlandTheBraveJL24MassedBands
#  GreenHillsJL34MassedBands
#  BattlesOrJL34MassedBands
  ReelSet
#  WearingGreenJL44MassedBands
#  MinstrelBoyJL44MassedBands
#  BarrenRocksJL24MassedBands
#  BrownHairedJL24MassedBands
#  HighlandLaddieJL24MassedBands
#  Competition44SetMassedBands
#  # update the snare part to be able to play faster
)

# Sources for these are in tunes dir, but should be elsewhere.
# For example the warmups should be in exercises/warmups
# and massed bands should be in massed bands or something
declare -a paddysDayDrumSettingsNameArray=(
  MassedBands24JLDrums
  MassedBands34JLDrums
  MassedBands44JLDrums
  GeneralJigDrums
#  WarmUpsSets
)

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

#echo cp /home/rob/Desktop/MySoundFonts/${soundFontName} ${learnWithMidiDir}/SoundFonts
cp /home/rob/Desktop/MySoundFonts/${soundFontName} ${learnWithMidiDir}/SoundFonts
#echo ls ${learnWithMidiDir}/SoundFonts
#ls ${learnWithMidiDir}/SoundFonts
#cp /home/rob/Desktop/MySoundFonts/PipesAndDrums202011060735.sf2 ${learnWithMidiDir}/MySoundFonts
#echo soundfont is $soundFontFile
#echo ""





# There could be stray files in these various dirs, so might want to check time stamps
rm ${targetDir}/Midis/*.mid
rm ${targetDir}/Mp3s/*.mp3

for f in "${paddysDayPipesAndDrumsNameArray[@]}"; do
  compileDrumsChanterTracksOneTune ${f}
#  echo "In loop after processing ${f},  returned this value: ${?} "
  echo ""
  echo ""
done

for f in "${paddysDayDrumSettingsNameArray[@]}"; do
  compileDrumSettings ${f}
#  echo "In loop after processing ${f},  returned this value: ${?} "
  echo ""
  echo ""
done

for f in "${warmUpsNameArray[@]}"; do
  compileWarmUps ${f}
  echo ""
  echo ""
done


## Now zip them for easy download from the website
#echo "Will now change file names and zip them in the target directory, which is ${targetDir}"
##pushd /home/rob/LearnWithMidi/Gigs/${gig}/Midis
#pushd ${targetDir}/Midis
#rm -f *.sf2
#cp $soundFontFile ./
#rm -f GigsMidis${today}.zip
##rm -f *.zip
##rm -f *.mid
#rm -f ${gig}Midis${today}.zip
#mv AmazingGrace2xChanterAndDrums.mid AmazingGrace.mid
#mv CaptEwingMassedBandsChanterAndDrums.mid CaptEwingMassedBands.mid
#mv CastleDangerousMassedBandsShiftedChanterAndDrums.mid CastleDangerousMassedBands.mid
#mv Competition44SetMassedBandsChanterAndDrums.mid Competition44SetMassedBands.mid
#mv HauntingCastleSetSimpleAndMassedBandsChanterAndDrums.mid HauntingCastleSetSimpleAndMassedBands.mid
#mv HawaiiAlohaChanterAndDrums.mid HawaiiAloha.mid
#mv ReelSetChanterAndDrums.mid ReelSet.mid
#mv ScotlandTheBraveChanterAndDrums.mid ScotlandTheBrave.mid
#mv ScotlandTheBraveMassedBandsChanterAndDrums.mid ScotlandTheBraveMassedBands.mid
#mv TheHauntingSimpleChanterAndDrums.mid TheHauntingSimple.mid
##zip ${gig}Midis.zip *.mid *.sf2
#zip ${gig}Midis${today}.zip *.mid *.sf2
#popd
#
##pushd ${learnWithMidiDir}/Gigs/${gig}/Mp3s
#pushd ${targetDir}/Mp3s
#rm -f GigsMp3s${today}.zip
##rm -f *.mp3
#mv AmazingGrace2xChanterAndDrums.mp3 AmazingGrace.mp3
#mv CaptEwingMassedBandsChanterAndDrums.mp3 CaptEwingMassedBands.mp3
#mv CastleDangerousMassedBandsShiftedChanterAndDrums.mp3 CastleDangerousMassedBands.mp3
#mv Competition44SetMassedBandsChanterAndDrums.mp3 Competition44SetMassedBands.mp3
#mv HauntingCastleSetSimpleAndMassedBandsChanterAndDrums.mp3 HauntingCastleSetSimpleAndMassedBands.mp3
#mv HawaiiAlohaChanterAndDrums.mp3 HawaiiAloha.mp3
#mv ReelSetChanterAndDrums.mp3 ReelSet.mp3
#mv ScotlandTheBraveChanterAndDrums.mp3 ScotlandTheBrave.mp3
#mv ScotlandTheBraveMassedBandsChanterAndDrums.mp3 ScotlandTheBraveMassedBands.mp3
#mv TheHauntingSimpleChanterAndDrums.mp3 TheHauntingSimple.mp3
#zip ${gig}Mp3s${today}.zip *.mp3
#popd

echo Done processing files
exit 0


