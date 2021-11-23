#!/bin/bash
echo "This bash script is meant to build only the tunes we plan to use for the Pearl Harbor gig."
echo "This is being run out of the bin directory of the snarelang4 project, and not the pipelang project"
echo "We are here: $(pwd)"
echo ""
today=`date +%Y%m%d`
#echo "Today is ${today}"
#echo zip "PearlHarborMidis${today}.zip *.mid *.sf2"


declare snareLangDir=/home/rob/WebstormProjects/snarelang4
declare snareLangExecutable=${snareLangDir}/bin/snl.dart
declare pipeLangDir=/home/rob/WebstormProjects/pipelang
declare pipeLangExecutable=${pipeLangDir}/bin/ppl.dart
declare tracksDir=/home/rob/WebstormProjects/tracks
declare tracksExecutable=${tracksDir}/bin/tracks.dart

declare learnWithMidiDir=/home/rob/LearnWithMidi
declare forDrummersDir=${learnWithMidiDir}/ForDrummers
declare forPipersDir=${learnWithMidiDir}/ForPipers

declare targetDir=${learnWithMidiDir}/BandTunes/PearlHarbor

#echo learnWithMidiDir is $learnWithMidiDir and it has `ls $learnWithMidiDir`

# The soundfont file must coordinate with the midi files that are created, and they're created with "pitches" in mind, so really only
# one soundfont file should exist per organization of midi files.
#declare soundFont=/home/rob/Desktop/MySoundFonts/DrumLine202103081351.sf2
#declare soundFontName=DrumLine202103081351.sf2
#declare soundFontName=DrumsChanterMelody20210407.sf2
declare soundFontName=DrumLineMelodyChanter20210518.sf2
declare soundFontFile=${learnWithMidiDir}/SoundFonts/${soundFontName}

# According to Allison:
# Amazing Grace (maybe snare rolls second time through, maybe not)
# Hawaii Aloha (should change the part to be able to play together)
# Scotland the Brave (4/4 JL Massed Band)
# Haunting/Castle (Mine and the 3/4 JL Massed Band)    3 files here.  One with both, one of each individually.
# Competition 4/4 Set (4/4 JL Massed Band Don't break these out into individual songs)
# Capt Norman Orr (2/4 JL Massed Band)
# Reel Set (Undetermined)
declare -a pearlHarborBandTunesPipesAndDrumsNameArray=(
  ReelSet


  # Use only one of these, not sure which yet
  # AmazingGrace3x  this is my cool version
  AmazingGrace2x
  #  Capt Norman Orr Ewing Use 2/4 JL Massed band
  CaptEwingMassedBands
  #  HighlandLaddie
  #  Lochanside
  #  RowanTree
  # CastleDangerousMassedBands
  CastleDangerousMassedBandsShifted
  # Next one to use 4/4 JL Massed Bands setting.  How many times through?
  Competition44SetMassedBands
  # update the snare part to be able to play together
  HawaiiAloha
  # Check tempo(s) Maybe a change in tempo?  Also need to have the two pieces separate.  So, three versions only.
  # HauntingCastleSet
  #  HauntingCastleSetSimple
  HauntingCastleSetSimpleAndMassedBands
  # TheHaunting
  TheHauntingSimple


  #ReelSet

  ScotlandTheBrave
  # ScotlandTheBrave2XMassedBands
  #  ScotlandTheBraveMarch44
  # Check that next one is the full 4/4 JL massed band.  Twice through????
  ScotlandTheBraveMassedBands
)



# It appears that in bash you have to define a function before it can be used
function compileDrumsChanterTracksOneTune() {
  declare tune=$1
  echo "Compiling drums, chanter, and tracks for tune ${tune}"
  # would like to do error checking.  If the dart command doesn't work, don't do the fluidsynth or ffmpeg
  # If either the drums processing or the chanter processing fails, don't do the tracks processing.
  # If any errors, return non zero.
  # And whoever calls this should report the error, but keep going.
  echo "dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummersDir}/BandTunes/PearlHarbor/Midis/${tune}Drums.mid"
  dart $snareLangExecutable -i tunes/${tune}Drums.snl -o ${forDrummersDir}/BandTunes/PearlHarbor/Midis/${tune}Drums.mid && (
    fluidsynth -q -a alsa -g 1.5 -T raw -F - ${soundFontFile} ${forDrummersDir}/BandTunes/PearlHarbor/Midis/${tune}Drums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.5" ${forDrummersDir}/BandTunes/PearlHarbor/Mp3s/${tune}Drums.mp3
    echo "Created ${forDrummersDir}/BandTunes/PearlHarbor/Mp3s/${tune}Drums.mp3"
  )
    echo ""
  #    echo "Hey, that drum processing returned this: ${?}"
  echo "dart $pipeLangExecutable -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipersDir}/BandTunes/PearlHarbor/Midis/${tune}Chanter.mid"
  dart $pipeLangExecutable -i ${pipeLangDir}/tunes/${tune}Chanter.ppl -o ${forPipersDir}/BandTunes/PearlHarbor/Midis/${tune}Chanter.mid && (
    fluidsynth -q -a alsa -g 1.5 -T raw -F - ${soundFontFile} ${forPipersDir}/BandTunes/PearlHarbor/Midis/${tune}Chanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.5" ${forPipersDir}/BandTunes/PearlHarbor/Mp3s/${tune}Chanter.mp3
    echo "Created ${forPipersDir}/BandTunes/PearlHarbor/Mp3s/${tune}Chanter.mp3"
  )
    echo ""
  #    echo "Hey, that pipe processing returned this: ${?}"
  echo "dart $tracksExecutable -l WARNING -i ${forDrummersDir}/BandTunes/PearlHarbor/Midis/${tune}Drums.mid,${forPipersDir}/BandTunes/PearlHarbor/Midis/${tune}Chanter.mid -o ${learnWithMidiDir}/BandTunes/PearlHarbor/Midis/${tune}ChanterAndDrums.mid"
  dart $tracksExecutable -l WARNING -i ${forDrummersDir}/BandTunes/PearlHarbor/Midis/${tune}Drums.mid,${forPipersDir}/BandTunes/PearlHarbor/Midis/${tune}Chanter.mid -o ${learnWithMidiDir}/BandTunes/PearlHarbor/Midis/${tune}ChanterAndDrums.mid && (
    fluidsynth -q -a alsa -g 1.5 -T raw -F - ${soundFontFile} ${learnWithMidiDir}/BandTunes/PearlHarbor/Midis/${tune}ChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.5" ${learnWithMidiDir}/BandTunes/PearlHarbor/Mp3s/${tune}ChanterAndDrums.mp3
    echo "Created ${learnWithMidiDir}/BandTunes/PearlHarbor/Mp3s/${tune}ChanterAndDrums.mp3"
  )
    echo ""
  #    echo "Hey, that track processing returned this: ${?}"
  return ${?}
}


# Execution begins here, I guess

#echo cp /home/rob/Desktop/MySoundFonts/${soundFontName} ${learnWithMidiDir}/SoundFonts
cp /home/rob/Desktop/MySoundFonts/${soundFontName} ${learnWithMidiDir}/SoundFonts
#echo ls ${learnWithMidiDir}/SoundFonts
ls ${learnWithMidiDir}/SoundFonts
#cp /home/rob/Desktop/MySoundFonts/PipesAndDrums202011060735.sf2 ${learnWithMidiDir}/MySoundFonts
echo soundfont is $soundFontFile
echo ""





# There could be stray files in these various dirs, so might want to check time stamps
rm ${targetDir}/Midis/*.mid
rm ${targetDir}/Mp3s/*.mp3

for f in "${pearlHarborBandTunesPipesAndDrumsNameArray[@]}"; do
  compileDrumsChanterTracksOneTune ${f}
#  echo "In loop after processing ${f},  returned this value: ${?} "
  echo ""
  echo ""
done

# Now zip them for easy download from the website
echo "Will now change file names and zip them in the target directory, which is ${targetDir}"
#pushd /home/rob/LearnWithMidi/BandTunes/PearlHarbor/Midis
pushd ${targetDir}/Midis
rm -f *.sf2
cp $soundFontFile ./
rm -f BandTunesMidis${today}.zip
#rm -f *.zip
#rm -f *.mid
rm -f PearlHarborMidis${today}.zip
mv AmazingGrace2xChanterAndDrums.mid AmazingGrace.mid
mv CaptEwingMassedBandsChanterAndDrums.mid CaptEwingMassedBands.mid
mv CastleDangerousMassedBandsShiftedChanterAndDrums.mid CastleDangerousMassedBands.mid
mv Competition44SetMassedBandsChanterAndDrums.mid Competition44SetMassedBands.mid
mv HauntingCastleSetSimpleAndMassedBandsChanterAndDrums.mid HauntingCastleSetSimpleAndMassedBands.mid
mv HawaiiAlohaChanterAndDrums.mid HawaiiAloha.mid
mv ReelSetChanterAndDrums.mid ReelSet.mid
mv ScotlandTheBraveChanterAndDrums.mid ScotlandTheBrave.mid
mv ScotlandTheBraveMassedBandsChanterAndDrums.mid ScotlandTheBraveMassedBands.mid
mv TheHauntingSimpleChanterAndDrums.mid TheHauntingSimple.mid
#zip PearlHarborMidis.zip *.mid *.sf2
zip PearlHarborMidis${today}.zip *.mid *.sf2
popd

#pushd ${learnWithMidiDir}/BandTunes/PearlHarbor/Mp3s
pushd ${targetDir}/Mp3s
rm -f BandTunesMp3s${today}.zip
#rm -f *.mp3
mv AmazingGrace2xChanterAndDrums.mp3 AmazingGrace.mp3
mv CaptEwingMassedBandsChanterAndDrums.mp3 CaptEwingMassedBands.mp3
mv CastleDangerousMassedBandsShiftedChanterAndDrums.mp3 CastleDangerousMassedBands.mp3
mv Competition44SetMassedBandsChanterAndDrums.mp3 Competition44SetMassedBands.mp3
mv HauntingCastleSetSimpleAndMassedBandsChanterAndDrums.mp3 HauntingCastleSetSimpleAndMassedBands.mp3
mv HawaiiAlohaChanterAndDrums.mp3 HawaiiAloha.mp3
mv ReelSetChanterAndDrums.mp3 ReelSet.mp3
mv ScotlandTheBraveChanterAndDrums.mp3 ScotlandTheBrave.mp3
mv ScotlandTheBraveMassedBandsChanterAndDrums.mp3 ScotlandTheBraveMassedBands.mp3
mv TheHauntingSimpleChanterAndDrums.mp3 TheHauntingSimple.mp3
zip PearlHarborMp3s${today}.zip *.mp3
popd

echo Done processing files
exit 0


