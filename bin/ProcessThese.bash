#!/bin/bash
echo "Processing .snl and .ppl files, to create .mid and audio files under ~/MyHobby/ which can be copied into Google Drive for the .org website use."
echo "There's also the file BuildTunes.bash, which I think is old, so be careful to choose correctly"
#echo This is being run out of the bin directory of the snarelang4 project, and not the pipelang project, so later pipes wont work right
#echo We are here: `pwd`

declare myHobby=/home/rob/MyHobby
#echo myHobby is $myHobby and it has `ls $myHobby`

declare snareLangDir=/home/rob/WebstormProjects/snarelang4
declare snareLangExecutable=${snareLangDir}/bin/snl.dart
declare pipeLangDir=/home/rob/WebstormProjects/pipelang
declare pipeLangDartFile=${pipeLangDir}/bin/ppl.dart
declare tracksDir=/home/rob/WebstormProjects/tracks
declare tracksFile=${tracksDir}/bin/tracks.dart

# The soundfont file must coordinate with the midi files that are created, and they're created with "pitches" in mind, so really only
# one soundfont file should exist per organization of midi files.
#declare soundFont=/home/rob/Desktop/MySoundFonts/DrumLine202103081351.sf2
#declare soundFontName=DrumLine202103081351.sf2
declare soundFontName=DrumsChanterMelody20210407.sf2
cp /home/rob/Desktop/MySoundFonts/${soundFontName} ${myHobby}/SoundFonts
declare soundFontFile=${myHobby}/SoundFonts/${soundFontName}
#cp /home/rob/Desktop/MySoundFonts/PipesAndDrums202011060735.sf2 ${myHobby}/MySoundFonts
echo "soundfont is $soundFontFile"
#cd /home/rob/WebstormProjects/snarelang4/bin

# There should be a way to tell fluidsynth or ffmpeg to make a stereo image like you can do with Rosegarden with the mixer
# Also, Fluidsynth or ffmpeg needs to boost the volume.






echo "Starting to process drum salutes/fanfares ..."
declare -a FanfaresSalutesNameArray=( \
DrumSaluteIoMPB \
)
rm -f ${myHobby}/FanfaresSalutes/Midis/*.mid
rm -f ${myHobby}/FanfaresSalutes/Midis/*.sf2
rm -f ${myHobby}/FanfaresSalutes/Mp3s/*.mp3
rm -f ${myHobby}/FanfaresSalutes/Oggs/*.ogg
rm -f ${myHobby}/FanfaresSalutes/Wavs/*.wav

for f in "${FanfaresSalutesNameArray[@]}"; do
  dart $snareLangExecutable -i FanfaresSalutes/${f}.snl -o ${myHobby}/FanfaresSalutes/Midis/${f}.mid
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/FanfaresSalutes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/FanfaresSalutes/Mp3s/${f}.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/FanfaresSalutes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/FanfaresSalutes/Oggs/${f}.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/FanfaresSalutes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/FanfaresSalutes/Wavs/${f}.wav
done

pushd ${myHobby}/FanfaresSalutes/Midis/ > /dev/null
rm -f *.sf2
cp $soundFontFile ./
rm -f FanfaresSalutesMidis.zip
zip FanfaresSalutesMidis.zip  *.mid *.sf2
popd > /dev/null

pushd ${myHobby}/FanfaresSalutes/Mp3s/
rm -f FanfaresSalutesMp3s.zip
zip FanfaresSalutesMp3s.zip  *.mp3
popd

pushd ${myHobby}/FanfaresSalutes/Oggs/
rm -f FanfaresSalutesOggs.zip
zip FanfaresSalutesOggs.zip  *.ogg
popd

pushd ${myHobby}/FanfaresSalutes/Wavs/
rm -f FanfaresSalutesWavs.zip
zip FanfaresSalutesWavs.zip  *.wav
popd









# The website has a Band Tunes area under MIDI, and also under For Drummers.  But the MyHobby directory
# on my machine just has BandTunes and NonBandTunes.  And then there's the Google Drive storage, and
# I don't remember if it has two BandTunes areas or just one.  There should be just one.
# But in any case, it's a manual copy from MyHobby to the Google Drive, and so it's either two
# copies or just one, depending.  It should be just one copy, and then the website pages should
# both reference the same area on the Google Drive.


echo ""
echo "Starting to process metronomes ..."
declare -a metronomeNameArray=( \
QuarterNotes44Met \
EighthNotes44Met \
TwelfthNotes44Met )
rm -f ${myHobby}/Metronomes/Midis/*.mid
rm -f ${myHobby}/Metronomes/Midis/*.sf2
# rm -f ${myHobby}/Metronomes/Mp3s/*.mp3
# rm -f ${myHobby}/Metronomes/Oggs/*.ogg
# rm -f ${myHobby}/Metronomes/Wavs/*.wav

for f in "${metronomeNameArray[@]}"; do
  dart $snareLangExecutable -i Metronomes/${f}.snl -o ${myHobby}/Metronomes/Midis/${f}.mid
  # fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Metronomes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Metronomes/Mp3s/${f}.mp3
  # fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Metronomes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Metronomes/Oggs/${f}.ogg
  # fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Metronomes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Metronomes/Wavs/${f}.wav
done

pushd ${myHobby}/Metronomes/Midis/ > /dev/null
rm -f *.sf2
cp $soundFontFile ./
rm -f MetronomesMidis.zip
zip MetronomesMidis.zip  *.mid *.sf2
popd > /dev/null

# It doesn't make any sense to do MP3's or other renderings because they'd play at 100bpm always
# pushd ${myHobby}/Metronomes/Mp3s/
# rm -f MetronomesMp3s.zip
# zip MetronomesMp3s.zip  *.mp3
# popd

# pushd ${myHobby}/Metronomes/Oggs/
# rm -f MetronomesOggs.zip
# zip MetronomesOggs.zip  *.ogg
# popd

# pushd ${myHobby}/Metronomes/Wavs/
# rm -f MetronomesWavs.zip
# zip MetronomesWavs.zip  *.wav
# popd




echo "I think BanjoBreakdownDrums.snl is missing???"

echo "Starting to process tunes snare scores that have only one file ..."
declare -a tuneNameArray=( \
44MarchSnare \
#BadgeOfScotland \
BanjoBreakdownDrums \
BattleOfWaterlooDrums \
#BattleOfWaterlooMcWhirterDrums \
BeginnerMarchDrums \
BlackBear \
CastleDangerousDrums \
CastleDangerousMassedBandsShiftedDrums \
CastleDangerousMassedBandsDrums \
#JigSnare \
# March44 \ Fix/check this one
#MassedBand24JLV1P60 \
#MassedBand44JLV1P59 \
SlowMarchNo1Drums \
SlowMarchNo2Drums \
Strath1SnareMet \
SuperSlowMarchNo2Drums )

rm -f ${myHobby}/BandTunes/Midis/*.mid
rm -f ${myHobby}/BandTunes/Mp3s/*.mp3
rm -f ${myHobby}/BandTunes/Oggs/*.ogg
rm -f ${myHobby}/BandTunes/Wavs/*.wav


for f in "${tuneNameArray[@]}"; do
  # I doubt I really need to remove the file before create a new one.  Can probably just write on top of it.
  # If anything, I should probably just delete everything in the directory before doing a zip of everything.
  #rm -f ${myHobby}/BandTunes/Midis/${f}.mid
  dart $snareLangExecutable -i tunes/${f}.snl -o ${myHobby}/BandTunes/Midis/${f}.mid
  #rm -f ${myHobby}/BandTunes/Mp3s/${f}.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/${f}.mp3
  #rm -f ${myHobby}/BandTunes/Oggs/Tunes/${f}.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/${f}.ogg
  #rm -f ${myHobby}/BandTunes/Wavs/${f}.wav
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/${f}.wav
done

# What about the tunes that have multiple .mid files?
# Probably better just to combine files into one.
#rm -f ${myHobby}/BandTunes/Midis/BlackBearSnareAndMidSection.mid
dart $snareLangExecutable -i tunes/BlackBear.snl,tunes/BlackBearMidSection.snl -o ${myHobby}/BandTunes/Midis/BlackBearDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BlackBearDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/BlackBearDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BlackBearDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/BlackBearDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BlackBearDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/BlackBearDrums.wav




dart $snareLangExecutable -i tunes/TheHauntingDrums.snl -o ${myHobby}/BandTunes/Midis/TheHauntingDrums.mid
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/TheHauntingChanter.ppl -o ${myHobby}/Pipes/Midis/TheHauntingChanter.mid
dart $tracksFile -l WARNING -i ${myHobby}/BandTunes/Midis/TheHauntingDrums.mid,${myHobby}/Pipes/Midis/TheHauntingChanter.mid -o ${myHobby}/BandTunes/Midis/TheHauntingChanterAndDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TheHauntingChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/TheHauntingChanterAndDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TheHauntingChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/TheHauntingChanterAndDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TheHauntingChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/TheHauntingChanterAndDrums.wav


dart $snareLangExecutable -i tunes/CastleDangerousDrums.snl -o ${myHobby}/BandTunes/Midis/CastleDangerousDrums.mid
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/CastleDangerousChanter.ppl -o ${myHobby}/Pipes/Midis/CastleDangerousChanter.mid
dart $tracksFile -l WARNING -i ${myHobby}/BandTunes/Midis/CastleDangerousDrums.mid,${myHobby}/Pipes/Midis/CastleDangerousChanter.mid -o ${myHobby}/BandTunes/Midis/CastleDangerousChanterAndDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CastleDangerousChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/CastleDangerousChanterAndDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CastleDangerousChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/CastleDangerousChanterAndDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CastleDangerousChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/CastleDangerousChanterAndDrums.wav



# Here is the first "set" I've tried
dart $snareLangExecutable -i tunes/HauntingCastleSetDrums.snl -o ${myHobby}/BandTunes/Midis/HauntingCastleSetDrums.mid
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/HauntingCastleSetChanter.ppl -o ${myHobby}/Pipes/Midis/HauntingCastleSetChanter.mid
dart $tracksFile -l WARNING -i ${myHobby}/BandTunes/Midis/HauntingCastleSetDrums.mid,${myHobby}/Pipes/Midis/HauntingCastleSetChanter.mid -o ${myHobby}/BandTunes/Midis/HauntingCastleSetChanterAndDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HauntingCastleSetChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/HauntingCastleSetChanterAndDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HauntingCastleSetChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/HauntingCastleSetChanterAndDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HauntingCastleSetChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/HauntingCastleSetChanterAndDrums.wav


dart $snareLangExecutable -i tunes/AmazingGraceDrums.snl -o ${myHobby}/BandTunes/Midis/AmazingGraceDrums.mid
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/AmazingGraceChanter.ppl -o ${myHobby}/Pipes/Midis/AmazingGraceChanter.mid
dart $tracksFile -l WARNING -i ${myHobby}/BandTunes/Midis/AmazingGraceDrums.mid,${myHobby}/Pipes/Midis/AmazingGraceChanter.mid -o ${myHobby}/BandTunes/Midis/AmazingGraceChanterAndDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/AmazingGraceChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/AmazingGraceChanterAndDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/AmazingGraceChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/AmazingGraceChanterAndDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/AmazingGraceChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/AmazingGraceChanterAndDrums.wav


dart $snareLangExecutable -i tunes/CaptEwingMet.snl,tunes/CaptEwingSnare.snl,tunes/CaptEwingTenor.snl,tunes/CaptEwingBass.snl -o ${myHobby}/BandTunes/Midis/CaptEwingDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CaptEwingDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/CaptEwingDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CaptEwingDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/CaptEwingDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CaptEwingDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/CaptEwingDrums.wav
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/CaptEwingChanter.ppl -o ${myHobby}/Pipes/Midis/CaptEwingChanter.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/CaptEwingChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Mp3s/CaptEwingChanter.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/CaptEwingChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Oggs/CaptEwingChanter.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/CaptEwingChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Wavs/CaptEwingChanter.wav
dart $tracksFile -l WARNING -i ${myHobby}/BandTunes/Midis/CaptEwingDrums.mid,${myHobby}/Pipes/Midis/CaptEwingChanter.mid -o ${myHobby}/BandTunes/Midis/CaptEwingChanterAndDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CaptEwingChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/CaptEwingChanterAndDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CaptEwingChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/CaptEwingChanterAndDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CaptEwingChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/CaptEwingChanterAndDrums.wav




dart $snareLangExecutable -i tunes/FlettFromFlottaDrums.snl -o ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/FlettFromFlottaDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/FlettFromFlottaDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/FlettFromFlottaDrums.wav

dart $pipeLangDartFile -i ${pipeLangDir}/tunes/FlettFromFlottaChanter.ppl -o ${myHobby}/Pipes/Midis/FlettFromFlottaChanter.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/FlettFromFlottaChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Mp3s/FlettFromFlottaChanter.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/FlettFromFlottaChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Oggs/FlettFromFlottaChanter.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/FlettFromFlottaChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Wavs/FlettFromFlottaChanter.wav

dart $tracksFile -l WARNING -i ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid,${myHobby}/Pipes/Midis/FlettFromFlottaChanter.mid -o ${myHobby}/BandTunes/Midis/FlettFromFlottaChanterAndDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/FlettFromFlottaChanterAndDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/FlettFromFlottaChanterAndDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/FlettFromFlottaChanterAndDrums.wav



dart $snareLangExecutable -i tunes/BattleOfWaterlooDrums.snl -o ${myHobby}/BandTunes/Midis/BattleOfWaterlooDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BattleOfWaterlooDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/BattleOfWaterlooDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BattleOfWaterlooDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/BattleOfWaterlooDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BattleOfWaterlooDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/BattleOfWaterlooDrums.wav

dart $pipeLangDartFile -i ${pipeLangDir}/tunes/BattleOfWaterlooChanter.ppl -o ${myHobby}/Pipes/Midis/BattleOfWaterlooChanter.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/BattleOfWaterlooChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Mp3s/BattleOfWaterlooChanter.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/BattleOfWaterlooChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Oggs/BattleOfWaterlooChanter.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/BattleOfWaterlooChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Wavs/BattleOfWaterlooChanter.wav

dart $tracksFile -l WARNING -i ${myHobby}/BandTunes/Midis/BattleOfWaterlooDrums.mid,${myHobby}/Pipes/Midis/BattleOfWaterlooChanter.mid -o ${myHobby}/BandTunes/Midis/BattleOfWaterlooChanterAndDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BattleOfWaterlooChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/BattleOfWaterlooChanterAndDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BattleOfWaterlooChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/BattleOfWaterlooChanterAndDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BattleOfWaterlooChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/BattleOfWaterlooChanterAndDrums.wav


#dart $snareLangExecutable -i tunes/BattleOfWaterlooMcWhirterDrums.snl -o ${myHobby}/BandTunes/Midis/BattleOfWaterlooMcWhirterDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BattleOfWaterlooMcWhirterDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/BattleOfWaterlooMcWhirterDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BattleOfWaterlooMcWhirterDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/BattleOfWaterlooMcWhirterDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BattleOfWaterlooMcWhirterDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/BattleOfWaterlooMcWhirterDrums.wav

dart $pipeLangDartFile -i ${pipeLangDir}/tunes/BattleOfWaterlooChanter.ppl -o ${myHobby}/Pipes/Midis/BattleOfWaterlooChanter.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/BattleOfWaterlooChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Mp3s/BattleOfWaterlooChanter.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/BattleOfWaterlooChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Oggs/BattleOfWaterlooChanter.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/BattleOfWaterlooChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Wavs/BattleOfWaterlooChanter.wav

#dart $tracksFile -l WARNING -i ${myHobby}/BandTunes/Midis/BattleOfWaterlooMcWhirterDrums.mid,${myHobby}/Pipes/Midis/BattleOfWaterlooChanter.mid -o ${myHobby}/BandTunes/Midis/BattleOfWaterlooChanterAndMcWhirterDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BattleOfWaterlooChanterAndMcWhirterDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/BattleOfWaterlooChanterAndMcWhirterDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BattleOfWaterlooChanterAndMcWhirterDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/BattleOfWaterlooChanterAndMcWhirterDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BattleOfWaterlooChanterAndMcWhirterDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/BattleOfWaterlooChanterAndMcWhirterDrums.wav


dart $snareLangExecutable -i tunes/MurdosWeddingDrums.snl -o ${myHobby}/BandTunes/Midis/MurdosWeddingDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/MurdosWeddingDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/MurdosWeddingDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/MurdosWeddingDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/MurdosWeddingDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/MurdosWeddingDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/MurdosWeddingDrums.wav

dart $pipeLangDartFile -i ${pipeLangDir}/tunes/MurdosWeddingChanter.ppl -o ${myHobby}/Pipes/Midis/MurdosWeddingChanter.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/MurdosWeddingChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Mp3s/MurdosWeddingChanter.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/MurdosWeddingChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Oggs/MurdosWeddingChanter.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/MurdosWeddingChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Wavs/MurdosWeddingChanter.wav

dart $tracksFile -l WARNING -i ${myHobby}/BandTunes/Midis/MurdosWeddingDrums.mid,${myHobby}/Pipes/Midis/MurdosWeddingChanter.mid -o ${myHobby}/BandTunes/Midis/MurdosWeddingChanterAndDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/MurdosWeddingChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/MurdosWeddingChanterAndDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/MurdosWeddingChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/MurdosWeddingChanterAndDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/MurdosWeddingChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/MurdosWeddingChanterAndDrums.wav









dart $snareLangExecutable -i tunes/HawaiiAlohaMet.snl,tunes/HawaiiAlohaSnare.snl,tunes/HawaiiAlohaTenor.snl,tunes/HawaiiAlohaBass.snl -o ${myHobby}/BandTunes/Midis/HawaiiAlohaDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HawaiiAlohaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/HawaiiAlohaDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HawaiiAlohaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/HawaiiAlohaDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HawaiiAlohaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/HawaiiAlohaDrums.wav
# Hawaii Aloha has regular pipes, and harmony pipes, and drums, I think, somewhere
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/HawaiiAlohaChanterMelody.ppl,${pipeLangDir}/tunes/HawaiiAlohaChanterHarmony.ppl  -o ${myHobby}/Pipes/Midis/HawaiiAlohaChanterMelodyAndHarmony.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/HawaiiAlohaChanterMelodyAndHarmony.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/HawaiiAlohaChanterMelodyAndHarmony.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/HawaiiAlohaChanterMelodyAndHarmony.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/HawaiiAlohaChanterMelodyAndHarmony.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/HawaiiAlohaChanterMelodyAndHarmony.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/HawaiiAlohaChanterMelodyAndHarmony.wav

dart $tracksFile  -i ${myHobby}/BandTunes/Midis/HawaiiAlohaDrums.mid,${myHobby}/Pipes/Midis/HawaiiAlohaChanterMelodyAndHarmony.mid -o ${myHobby}/BandTunes/Midis/HawaiiAlohaChantersAndDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HawaiiAlohaChantersAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/HawaiiAlohaChantersAndDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HawaiiAlohaChantersAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/HawaiiAlohaChantersAndDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HawaiiAlohaChantersAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/HawaiiAlohaChantersAndDrums.wav










dart $snareLangExecutable -i tunes/ScotlandTheBraveMet.snl,tunes/ScotlandTheBraveSnare.snl,tunes/ScotlandTheBraveSnareChips.snl,tunes/ScotlandTheBraveTenor.snl,tunes/ScotlandTheBraveBass.snl -o ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/ScotlandTheBraveDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/ScotlandTheBraveDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/ScotlandTheBraveDrums.wav

#dart $snareLangExecutable -i tunes/CameronianRantSnare5.snl,tunes/CameronianRantSnare1.snl,tunes/CameronianRantSnare9.snl -o ${myHobby}/BandTunes/Midis/CameronianRantDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CameronianRantDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/CameronianRantDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CameronianRantDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/CameronianRantDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CameronianRantDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/CameronianRantDrums.wav

#dart $snareLangExecutable -i tunes/TireeMet.snl,tunes/TireeSnare.snl,tunes/TireeSnareChips.snl,tunes/TireeTenor.snl,tunes/TireeBass.snl -o ${myHobby}/BandTunes/Midis/TireeDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TireeDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/TireeDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TireeDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/TireeDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TireeDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/TireeDrums.wav




echo "Starting to process Non-Band tunes"


declare -a nonBandTunes=( \
AnnettesChatterMetSnare \
JaneCampbellSnare \
JimmyRolloMetSnare \
JohnWalshsWalkMetSnare )

# before doing this, make sure all the nonBand tunes are in one place
rm -f ${myHobby}/NonBandTunes/Midis/*.mid
rm -f ${myHobby}/NonBandTunes/Mp3s/*.mp3
rm -f ${myHobby}/NonBandTunes/Mp3s/*.ogg
rm -f ${myHobby}/NonBandTunes/Mp3s/*.wav


for f in "${nonBandTunes[@]}"; do
  dart $snareLangExecutable -i tunes/${f}.snl -o ${myHobby}/NonBandTunes/Midis/${f}.mid
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/NonBandTunes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/NonBandTunes/Mp3s/${f}.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/NonBandTunes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/NonBandTunes/Oggs/${f}.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/NonBandTunes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/NonBandTunes/Wavs/${f}.wav
done





# Cameronian Rant can have several snares, plus pipes, and met.  The met part is in snare5, and not separate, which is a bit strange
dart $snareLangExecutable -i tunes/CameronianRantSnare5.snl,tunes/CameronianRantSnare1.snl,tunes/CameronianRantSnare9.snl -o ${myHobby}/NonBandTunes/Midis/CameronianRantSnares.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/NonBandTunes/Midis/CameronianRantSnares.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/NonBandTunes/Mp3s/CameronianRantSnares.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/NonBandTunes/Midis/CameronianRantSnares.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/NonBandTunes/Oggs/CameronianRantSnares.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/NonBandTunes/Midis/CameronianRantSnares.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/NonBandTunes/Wavs/CameronianRantSnares.wav

dart $pipeLangDartFile -i ${pipeLangDir}/tunes/CameronianRantStrath.ppl -o ${myHobby}/Pipes/Midis/CameronianRantStrath.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/CameronianRantStrath.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Mp3s/CameronianRantStrath.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/CameronianRantStrath.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Mp3s/CameronianRantStrath.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/CameronianRantStrath.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Mp3s/CameronianRantStrath.wav

dart $tracksFile   -i ${myHobby}/NonBandTunes/Midis/CameronianRantSnares.mid,${myHobby}/Pipes/Midis/CameronianRantStrath.mid -o ${myHobby}/NonBandTunes/Midis/CameronianRantSnaresAndChanter.mid
# I think the ffmpeg does not do the stereo separation.  Not sure why.
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/NonBandTunes/Midis/CameronianRantSnaresAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/NonBandTunes/Mp3s/CameronianRantSnaresAndChanter.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/NonBandTunes/Midis/CameronianRantSnaresAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/NonBandTunes/Oggs/CameronianRantSnaresAndChanter.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/NonBandTunes/Midis/CameronianRantSnaresAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/NonBandTunes/Wavs/CameronianRantSnaresAndChanter.wav




# zip them?
pushd ${myHobby}/NonBandTunes/Midis/
rm *.sf2
cp $soundFontFile ./
rm -f NonBandTunesMidis.zip
zip NonBandTunesMidis.zip  *.mid *.sf2
popd

pushd ${myHobby}/NonBandTunes/Mp3s/
rm -f NonBandTunesMp3s.zip
zip NonBandTunesMp3s.zip  *.mp3
popd








#if true; then
#if false; then

# Process JlV1 files
declare -a JlV1NameArray=( \
JlV1P19-01 \
JlV1P20-02 \
JlV1P21-03 \
JlV1P22-04 \
JlV1P23-05 \
JlV1P24-06 \
JlV1P25-07 \
JlV1P26-08 \
JlV1P27-09 \
JlV1P28-10 \
JlV1P29-11 \
JlV1P30-12 \
JlV1P31-13 \
JlV1P32-14 \
JlV1P33-15 \
JlV1P34-16 \
JlV1P35-17 \
JlV1P36-18 \
JlV1P37-19 \
JlV1P38-20 \
JlV1P39-21 \
JlV1P40-22 \
JlV1P41-23 \
JlV1P42-24 \
JlV1P43-25 \
JlV1P44-26 \
JlV1P45-27 \
JlV1P46-28 \
JlV1P47-29 \
JlV1P48-30 \
JlV1P49-31 \
JlV1P50-32 \
JlV1P51-33 \
JlV1P52-34 \
JlV1P53-35 \
JlV1P54-36 \
JlV1P55-37 \
JlV1P56-38 \
JlV1P58-39 \
JlV1P59-40 \
JlV1P60-41 \
JlV1P61-42 \
JlV1P62-43 )

rm -f ${myHobby}/Books/JLV1/Midis/*.mid
rm -f ${myHobby}/Books/JLV1/Midis/*.sf2
rm -f ${myHobby}/Books/JLV1/Mp3s/*.mp3
rm -f ${myHobby}/Books/JLV1/Oggs/*.ogg
rm -f ${myHobby}/Books/JLV1/Wavs/*.wav

#rm -f ${myHobby}/mp3s/JLV1/*.mp3
for f in ${JlV1NameArray[@]}; do
    #rm -f "${myHobby}/Books/JLV1/Midis/${f}.mid"
    dart $snareLangExecutable -i /home/rob/WebstormProjects/snarelang4/exercises/LaughlinVol1/${f}.snl -o ${myHobby}/Books/JLV1/Midis/${f}.mid -S 1.25
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV1/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Books/JLV1/Mp3s/${f}.mp3
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV1/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Books/JLV1/Oggs/${f}.ogg
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV1/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Books/JLV1/Wavs/${f}.wav
done

# Now zip.  Need to cd into the directoryy where the files are so that unzipping doesn't duplicate the tree
pushd ${myHobby}/Books/JLV1/Midis/
rm *.sf2
cp $soundFontFile ./
rm -f JLV1Midis.zip
zip JLV1Midis.zip  *.mid *.sf2
popd

pushd ${myHobby}/Books/JLV1/Mp3s
rm -f JLV1Mp3s.zip
zip JLV1Mp3s.zip  *.mp3
popd

pushd ${myHobby}/Books/JLV1/Oggs
rm -f JLV1Oggs.zip
zip JLV1Oggs.zip  *.ogg
popd

pushd ${myHobby}/Books/JLV1/Wavs
rm -f JLV1Wavs.zip
zip JLV1Wavs.zip  *.wav
popd


# Process JlV2 files
declare -a JlV2NameArray=( \
JlV2P06-01 \
JlV2P07-02 \
JlV2P08-03 \
JlV2P09-04 \
JlV2P10-05 \
JlV2P11-06 \
JlV2P12-07 \
JlV2P13-08 \
JlV2P14-09 \
JlV2P15-10 \
JlV2P16-11 \
JlV2P17-12 \
JlV2P18-13 \
JlV2P20-14 \
JlV2P21-15 \
JlV2P22-16 \
JlV2P23-17 \
JlV2P24-18 \
JlV2P25-19 \
JlV2P26-20 \
)

rm -f ${myHobby}/Books/JLV2/Midis/*.mid
rm -f ${myHobby}/Books/JLV2/Mp3s/*.mp3
rm -f ${myHobby}/Books/JLV2/Oggs/*.ogg
rm -f ${myHobby}/Books/JLV2/Wavs/*.wav

#rm -f ${myHobby}/mp3s/JLV2/*.mp3
for f in ${JlV2NameArray[@]}; do
    #rm -f "${myHobby}/Books/JLV2/Midis/${f}.mid"
    dart $snareLangExecutable -i /home/rob/WebstormProjects/snarelang4/exercises/LaughlinVol2/${f}.snl -o ${myHobby}/Books/JLV2/Midis/${f}.mid
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV2/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Books/JLV2/Mp3s/${f}.mp3
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV2/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Books/JLV2/Oggs/${f}.ogg
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV2/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Books/JLV2/Wavs/${f}.wav
done

# Now zip Volume 2
pushd ${myHobby}/Books/JLV2/Midis/
rm -f *.sf2
cp $soundFontFile ./
rm -f JLV2Midis.zip
zip JLV2Midis.zip  *.mid *.sf2
popd

pushd ${myHobby}/Books/JLV2/Mp3s/
rm -f JLV2Mp3s.zip
zip JLV2Mp3s.zip  *.mp3
popd

pushd ${myHobby}/Books/JLV2/Oggs/
rm -f JLV2Oggs.zip
zip JLV2Oggs.zip  *.ogg
popd

pushd ${myHobby}/Books/JLV2/Wavs/
rm -f JLV2Wavs.zip
zip JLV2Wavs.zip  *.wav
popd


# Another book, kinda, Maxwell????
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/MaxwellPg1.snl -o /home/rob/MyHobby/midis/ForDrummers/MaxwellPg1.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/MaxwellPg2.snl -o /home/rob/MyHobby/midis/ForDrummers/MaxwellPg2.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/MaxwellPg27.snl -o /home/rob/MyHobby/midis/ForDrummers/MaxwellPg27.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/MaxwellPg27Swing.snl -o /home/rob/MyHobby/midis/ForDrummers/MaxwellPg27Swing.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/MaxwellPg3.snl -o /home/rob/MyHobby/midis/ForDrummers/MaxwellPg3.mid

# exercises no one's interested in:

# Leo Browne exercises.  These are not really warmups, but just technique builders.  Move later.
echo "Starting to process Leo Brown exercises"
declare -a leoBrowneExercises=( \
8s \
Accents \
Accents8ths \
Fix8s \
LeoFlams \
LeoFlamsWithTempoTrack \
Wipers )

rm -f ${myHobby}/Exercises/LeoBrowne/Midis/*.mid
rm -f ${myHobby}/Exercises/LeoBrowne/Mp3s/*.mp3
rm -f ${myHobby}/Exercises/LeoBrowne/Oggs/*.ogg
rm -f ${myHobby}/Exercises/LeoBrowne/Wavs/*.wav


for f in "${leoBrowneExercises[@]}"; do
  # If anything, I should probably just delete everything in the directory before doing a zip of everything.
  dart $snareLangExecutable -i exercises/LeoBrowne/${f}.snl -o ${myHobby}/Exercises/LeoBrowne/Midis/${f}.mid
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Exercises/LeoBrowne/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Exercises/LeoBrowne/Mp3s/${f}.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Exercises/LeoBrowne/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Exercises/LeoBrowne/Oggs/${f}.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Exercises/LeoBrowne/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Exercises/LeoBrowne/Wavs/${f}.wav
done

# zip them?
pushd ${myHobby}/Exercises/LeoBrowne/Midis/
rm *.sf2
cp $soundFontFile ./
rm -f LeoBrowneMidis.zip
zip LeoBrowneMidis.zip  *.mid *.sf2
popd

pushd ${myHobby}/Exercises/LeoBrowne/Mp3s/
rm -f LeoBrowneMp3s.zip
zip LeoBrowneMp3s.zip  *.mp3
popd

pushd ${myHobby}/Exercises/LeoBrowne/Oggs/
rm -f LeoBrowneOggs.zip
zip LeoBrowneOggs.zip  *.ogg
popd

pushd ${myHobby}/Exercises/LeoBrowne/Wavs/
rm -f LeoBrowneWavs.zip
zip LeoBrowneWavs.zip  *.wav
popd




# tunes

# Non-band tunes
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/AnnettesChatterMet.snl -o /home/rob/MyHobby/midis/AnnettesChatterMet.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/AnnettesChatterSnare.snl -o /home/rob/MyHobby/midis/AnnettesChatterSnare.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JaneCampbellSnare.snl -o /home/rob/MyHobby/midis/JaneCampbellSnare.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JimmyRolloSnare.snl -o /home/rob/MyHobby/midis/JimmyRolloSnare.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JimmyRolloMet.snl -o /home/rob/MyHobby/midis/JimmyRolloMet.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JohnWalshsWalkMet.snl -o /home/rob/MyHobby/midis/JohnWalshsWalkMet.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JohnWalshsWalkMetSnare.snl -o /home/rob/MyHobby/midis/JohnWalshsWalkSnare.mid



# I think this next part is for adding pipes to the mix.  Need to process the pipe.ppl file to create a mid, and then need to
# merge the pipes mid with the drums mid



#fi

# I think Amber On The Rocks is pipes only
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/AmberOnTheRocks.ppl -o ${myHobby}/Pipes/Midis/AmberOnTheRocks.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/AmberOnTheRocks.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Mp3s/AmberOnTheRocks.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/AmberOnTheRocks.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Oggs/AmberOnTheRocks.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/AmberOnTheRocks.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Wavs/AmberOnTheRocks.wav













# These are pipes parts, but I think they also have a snare or drum part to them somewhere too
# Already have the snare score midi because processed it from a list of single scores, not multiple that make up a midi.
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/BanjoBreakdown.ppl -o ${myHobby}/Pipes/Midis/BanjoBreakdownChanter.mid
# I prob don't need to create audio renders of pipe midis, because they don't help pipers at this time.  Maybe when get grace notes in, and get things much better
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/BanjoBreakdownChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Mp3s/BanjoBreakdownChanter.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/BanjoBreakdownChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Oggs/BanjoBreakdownChanter.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/BanjoBreakdownChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/Pipes/Wavs/BanjoBreakdownChanter.wav
dart $tracksFile   -i ${myHobby}/BandTunes/Midis/BanjoBreakdown.mid,${myHobby}/Pipes/Midis/BanjoBreakdownChanter.mid -o ${myHobby}/BandTunes/Midis/BanjoBreakdownSnareAndChanter.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BanjoBreakdownSnareAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/BanjoBreakdownSnareAndChanter.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BanjoBreakdownSnareAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/BanjoBreakdownSnareAndChanter.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BanjoBreakdownSnareAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/BanjoBreakdownSnareAndChanter.wav




# Now zip up the band tunes
rm -f *.sf2
cp $soundFontFile ./
rm -f BandTunesMidis.zip
zip BandTunesMidis.zip  *.mid *.sf2
popd

pushd ${myHobby}/BandTunes/Mp3s/
rm -f BandTunesMp3s.zip
zip BandTunesMp3s.zip  *.mp3
popd

pushd ${myHobby}/BandTunes/Oggs/
rm -f BandTunesOggs.zip
zip BandTunesOggs.zip  *.ogg
popd

pushd ${myHobby}/BandTunes/Wavs/
rm -f BandTunesWavs.zip
zip BandTunesWavs.zip  *.wav
popd




#cd /home/rob/WebstormProjects/tracks/bin

# Oh, here we put the pipes and drums together.  But there are few chanter/pipes midi files, only Amber, Banjo, Cameronian, Ewing, HawaiiAloha



#dart $tracksFile  -i ${myHobby}/BandTunes/Midis/CaptEwingSnare.mid,${myHobby}/BandTunes/Midis/CaptEwingTenor.mid,${myHobby}/BandTunes/Midis/CaptEwingBass.mid,${myHobby}/BandTunes/Midis/CaptEwingMet.mid -o ${myHobby}/BandTunes/Midis/CaptEwingDrums.mid

## Actually, isn't this rather silly?  Doing "tracks" in order to put together midi files into one midi file?  Because could have done that with regular snl or ppl dart apps.  Tracks is for merging .mid files from drums and pipes.
#dart $tracksFile  -i ${myHobby}/BandTunes/Midis/FlettFromFlottaSnare.mid,${myHobby}/BandTunes/Midis/FlettFromFlottaTenor.mid,${myHobby}/BandTunes/Midis/FlettFromFlottaBass.mid,${myHobby}/BandTunes/Midis/FlettFromFlottaMet.mid -o ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid
#
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/FlettFromFlottaDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/FlettFromFlottaDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/FlettFromFlottaDrums.wav
#
##dart $tracksFile  -i ${myHobby}/BandTunes/Midis/JimmyRolloSnare.mid,${myHobby}/BandTunes/Midis/JimmyRolloMet.mid -o ${myHobby}/BandTunes/Midis/JimmyRolloSnareAndMet.mid -l ALL
#
##dart $tracksFile  -i ${myHobby}/BandTunes/Midis/JohnWalshsWalkSnare.mid,${myHobby}/BandTunes/Midis/JohnWalshsWalkMet.mid -o ${myHobby}/BandTunes/Midis/JohnWalshsWalkSnareAndMet.mid
#
#dart $tracksFile  -i ${myHobby}/BandTunes/Midis/ScotlandTheBraveSnare.mid,${myHobby}/BandTunes/Midis/ScotlandTheBraveSnareChips.mid,${myHobby}/BandTunes/Midis/ScotlandTheBraveTenor.mid,${myHobby}/BandTunes/Midis/ScotlandTheBraveBass.mid,${myHobby}/BandTunes/Midis/ScotlandTheBraveMet.mid -o ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/ScotlandTheBraveMet.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/ScotlandTheBraveMet.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/ScotlandTheBraveMet.wav
#
#dart $tracksFile  -i ${myHobby}/BandTunes/Midis/TireeSnare.mid,${myHobby}/BandTunes/Midis/TireeSnareChips.mid,${myHobby}/BandTunes/Midis/TireeTenor.mid,${myHobby}/BandTunes/Midis/TireeBass.mid,${myHobby}/BandTunes/Midis/TireeMet.mid -o ${myHobby}/BandTunes/Midis/TireeDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TireeDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Mp3s/TireeDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TireeDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Oggs/TireeDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TireeDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - -filter:a "volume=1.3" ${myHobby}/BandTunes/Wavs/TireeDrums.wav

echo "Done processing files"
exit 0




