#!/bin/bash
echo "This bash script was meant to build stuff that I'd play with Jack for St. Patricks Day gigs."
echo "Looks like that means only one tune, which is Cameronian Rant"
declare gig=JackPaddysDay
echo "This is being run out of the bin directory of the snarelang4 project, and not the pipelang project"
echo "We are here: $(pwd)"
echo ""
today=`date +%Y%m%d`
#echo "Today is ${today}"
#echo "echo zip ${gig}Midis${today}.zip *.mid *.sf2"
#echo "echo ${gig}MP3s${today}.zip *.mp3"


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
declare -a JackLeeTunesPipesAndDrumsNameArray=(
  CameronianRant
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


for f in "${JackLeeTunesPipesAndDrumsNameArray[@]}"; do
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


#for f in "${paddysDayDrumSettingsNameArray[@]}"; do
#  compileDrumSettings ${f}
##  echo "In loop after processing ${f},  returned this value: ${?} "
#  echo ""
#  echo ""
#done


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









































##!/bin/bash
#echo "Processing .snl and .ppl files, to create .mid and audio files under ~/MyHobby/ which can be copied into Google Drive for the .org website use."
#echo "These are in preparation to possibly playing with Jack Lee"
##echo This is being run out of the bin directory of the snarelang4 project, and not the pipelang project, so later pipes wont work right
##echo We are here: `pwd`
#
#declare myHobby=/home/rob/MyHobby
##echo myHobby is $myHobby and it has `ls $myHobby`
#
#declare snareLangDir=/home/rob/WebstormProjects/snarelang4
#declare snareLangExecutable=${snareLangDir}/bin/snl.dart
#declare pipeLangDir=/home/rob/WebstormProjects/pipelang
#declare pipeLangDartFile=${pipeLangDir}/bin/ppl.dart
#declare tracksDir=/home/rob/WebstormProjects/tracks
#declare tracksFile=${tracksDir}/bin/tracks.dart
#
## The soundfont file must coordinate with the midi files that are created, and they're created with "pitches" in mind, so really only
## one soundfont file should exist per organization of midi files.
##declare soundFont=/home/rob/Desktop/MySoundFonts/DrumLine202103081351.sf2
##declare soundFontName=DrumLine202103081351.sf2
#declare soundFontName=DrumsChanterMelody20210407.sf2
#cp /home/rob/Desktop/MySoundFonts/${soundFontName} ${myHobby}/SoundFonts
#declare soundFontFile=${myHobby}/SoundFonts/${soundFontName}
##cp /home/rob/Desktop/MySoundFonts/PipesAndDrums202011060735.sf2 ${myHobby}/MySoundFonts
#echo "soundfont is $soundFontFile"
##cd /home/rob/WebstormProjects/snarelang4/bin
#
## There should be a way to tell fluidsynth or ffmpeg to make a stereo image like you can do with Rosegarden with the mixer
## Also, Fluidsynth or ffmpeg needs to boost the volume.
#
#
#
#echo "Starting to process Non-Band tunes"
#
#
#declare -a JackLeeTunes=( \
#AnnettesChatterMetSnare \
#JaneCampbellSnare \
#JimmyRolloMetSnare \
#JohnWalshsWalkMetSnare )
#
## before doing this, make sure all the nonBand tunes are in one place
#rm -f ${myHobby}/JackLeeTunes/Midis/*.mid
#rm -f ${myHobby}/JackLeeTunes/Mp3s/*.mp3
#rm -f ${myHobby}/JackLeeTunes/Mp3s/*.ogg
#rm -f ${myHobby}/JackLeeTunes/Mp3s/*.wav
#
#
#for f in "${JackLeeTunes[@]}"; do
#  echo "dart $snareLangExecutable -i tunes/${f}.snl -o ${myHobby}/JackLeeTunes/Midis/${f}.mid"
#  dart $snareLangExecutable -i tunes/${f}.snl -o ${myHobby}/JackLeeTunes/Midis/${f}.mid
#  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/JackLeeTunes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/JackLeeTunes/Mp3s/${f}.mp3
#  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/JackLeeTunes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/JackLeeTunes/Oggs/${f}.ogg
#  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/JackLeeTunes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/JackLeeTunes/Wavs/${f}.wav
#done
#
#
#
#
#
## Cameronian Rant can have several snares, plus pipes, and met.  The met part is in snare5, and not separate, which is a bit strange
#dart $snareLangExecutable -i tunes/CameronianRantSnare5.snl,tunes/CameronianRantSnare1.snl,tunes/CameronianRantSnare9.snl -o ${myHobby}/JackLeeTunes/Midis/CameronianRantSnares.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/JackLeeTunes/Midis/CameronianRantSnares.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/JackLeeTunes/Mp3s/CameronianRantSnares.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/JackLeeTunes/Midis/CameronianRantSnares.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/JackLeeTunes/Oggs/CameronianRantSnares.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/JackLeeTunes/Midis/CameronianRantSnares.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/JackLeeTunes/Wavs/CameronianRantSnares.wav
#
#dart $pipeLangDartFile -i ${pipeLangDir}/tunes/CameronianRantStrath.ppl -o ${myHobby}/Pipes/Midis/CameronianRantStrath.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/CameronianRantStrath.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Mp3s/CameronianRantStrath.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/CameronianRantStrath.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Mp3s/CameronianRantStrath.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/CameronianRantStrath.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Mp3s/CameronianRantStrath.wav
#
#dart $tracksFile   -i ${myHobby}/JackLeeTunes/Midis/CameronianRantSnares.mid,${myHobby}/Pipes/Midis/CameronianRantStrath.mid -o ${myHobby}/JackLeeTunes/Midis/CameronianRantSnaresAndChanter.mid
## I think the ffmpeg does not do the stereo separation.  Not sure why.
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/JackLeeTunes/Midis/CameronianRantSnaresAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/JackLeeTunes/Mp3s/CameronianRantSnaresAndChanter.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/JackLeeTunes/Midis/CameronianRantSnaresAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/JackLeeTunes/Oggs/CameronianRantSnaresAndChanter.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/JackLeeTunes/Midis/CameronianRantSnaresAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/JackLeeTunes/Wavs/CameronianRantSnaresAndChanter.wav
#
#
#
#
## zip them?
#pushd ${myHobby}/JackLeeTunes/Midis/
#rm *.sf2
#cp $soundFontFile ./
#rm -f JackLeeTunesMidis.zip
#zip JackLeeTunesMidis.zip  *.mid *.sf2
#popd
#
#pushd ${myHobby}/JackLeeTunes/Mp3s/
#rm -f JackLeeTunesMp3s.zip
#zip JackLeeTunesMp3s.zip  *.mp3
#popd
#
#
#
#
#
## tunes
#
## Non-band tunes
###dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/AnnettesChatterMet.snl -o /home/rob/MyHobby/midis/AnnettesChatterMet.mid
###dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/AnnettesChatterSnare.snl -o /home/rob/MyHobby/midis/AnnettesChatterSnare.mid
###dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JaneCampbellSnare.snl -o /home/rob/MyHobby/midis/JaneCampbellSnare.mid
###dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JimmyRolloSnare.snl -o /home/rob/MyHobby/midis/JimmyRolloSnare.mid
###dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JimmyRolloMet.snl -o /home/rob/MyHobby/midis/JimmyRolloMet.mid
###dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JohnWalshsWalkMet.snl -o /home/rob/MyHobby/midis/JohnWalshsWalkMet.mid
###dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JohnWalshsWalkMetSnare.snl -o /home/rob/MyHobby/midis/JohnWalshsWalkSnare.mid
#
#
#
## I think this next part is for adding pipes to the mix.  Need to process the pipe.ppl file to create a mid, and then need to
## merge the pipes mid with the drums mid
#
#
#
##fi
#
#
#
#
#
#
## Now zip up the band tunes
##rm -f *.sf2
##cp $soundFontFile ./
##rm -f BandTunesMidis.zip
##zip BandTunesMidis.zip  *.mid *.sf2
##popd
##
##pushd ${myHobby}/BandTunes/Mp3s/
##rm -f BandTunesMp3s.zip
##zip BandTunesMp3s.zip  *.mp3
##popd
##
##pushd ${myHobby}/BandTunes/Oggs/
##rm -f BandTunesOggs.zip
##zip BandTunesOggs.zip  *.ogg
##popd
##
##pushd ${myHobby}/BandTunes/Wavs/
##rm -f BandTunesWavs.zip
##zip BandTunesWavs.zip  *.wav
##popd
#
#
#echo "Done processing files"
#exit 0
#
#
#
#
