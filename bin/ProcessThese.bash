#!/bin/bash
echo "Processing .snl and .ppl files, to create .mid and audio files under ~/MyHobby/ which can be copied into Google Drive for the .org website use."
echo This is being run out of the bin directory of the snarelang4 project, and not the pipelang project, so later pipes wont work right
echo We are here: `pwd`

declare myHobby=/home/rob/MyHobby
echo myHobby is $myHobby and it has `ls $myHobby`

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
cp /home/rob/Desktop/MySoundFonts/${soundFontName} ${myHobby}/SoundFonts
cp /home/rob/Desktop/MySoundFonts/${soundFontName} ${myHobby}/SoundFonts
cp /home/rob/Desktop/MySoundFonts/${soundFontName} ${myHobby}/SoundFonts
declare soundFontFile=${myHobby}/SoundFonts/${soundFontName}
#cp /home/rob/Desktop/MySoundFonts/PipesAndDrums202011060735.sf2 ${myHobby}/MySoundFonts
echo soundfont is $soundFontFile
#cd /home/rob/WebstormProjects/snarelang4/bin



# The website has a Band Tunes area under MIDI, and also under For Drummers.  But the MyHobby directory
# on my machine just has BandTunes and NonBandTunes.  And then there's the Google Drive storage, and
# I don't remember if it has two BandTunes areas or just one.  There should be just one.
# But in any case, it's a manual copy from MyHobby to the Google Drive, and so it's either two
# copies or just one, depending.  It should be just one copy, and then the website pages should
# both reference the same area on the Google Drive.




echo Starting to process tunes snare scores that have only one file ...
declare -a tuneNameArray=( \
44MarchSnare \
#BadgeOfScotland \
BanjoBreakdown \
BattleOfWaterloo \
BeginnerMarch \
BlackBear \
CastleDangerousSnareAndMet \
JigSnare \
March44 \
MassedBand24JLV1P60 \
MassedBand44JLV1P59 \
SlowMarchNo1 \
SlowMarchNo2 \
Strath1SnareMet \
SuperSlowMarchNo2 )

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
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/${f}.mp3
  #rm -f ${myHobby}/BandTunes/Oggs/Tunes/${f}.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/${f}.ogg
  #rm -f ${myHobby}/BandTunes/Wavs/${f}.wav
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/${f}.wav
done

# What about the tunes that have multiple .mid files?
# Probably better just to combine files into one.
#rm -f ${myHobby}/BandTunes/Midis/BlackBearSnareAndMidSection.mid
dart $snareLangExecutable -i tunes/BlackBear.snl,tunes/BlackBearMidSection.snl -o ${myHobby}/BandTunes/Midis/BlackBearDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BlackBearDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/BlackBearDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BlackBearDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/BlackBearDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BlackBearDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/BlackBearDrums.wav


dart $snareLangExecutable -i tunes/CaptEwingMet.snl,tunes/CaptEwingSnare.snl,tunes/CaptEwingTenor.snl,tunes/CaptEwingBass.snl -o ${myHobby}/BandTunes/Midis/CaptEwingDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CaptEwingDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/CaptEwingDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CaptEwingDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/CaptEwingDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CaptEwingDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/CaptEwingDrums.wav
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/CaptEwingChanter.ppl -o ${myHobby}/Pipes/Midis/CaptEwingChanter.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/CaptEwingChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Pipes/Mp3s/CaptEwingChanter.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/CaptEwingChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Pipes/Oggs/CaptEwingChanter.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/CaptEwingChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Pipes/Wavs/CaptEwingChanter.wav
dart $tracksFile -l WARNING -i ${myHobby}/BandTunes/Midis/CaptEwingDrums.mid,${myHobby}/Pipes/Midis/CaptEwingChanter.mid -o ${myHobby}/BandTunes/Midis/CaptEwingChanterAndDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CaptEwingChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/CaptEwingChanterAndDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CaptEwingChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/CaptEwingChanterAndDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CaptEwingChanterAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/CaptEwingChanterAndDrums.wav



dart $snareLangExecutable -i tunes/FlettFromFlottaMet.snl,tunes/FlettFromFlottaSnare.snl,tunes/FlettFromFlottaTenor.snl,tunes/FlettFromFlottaBass.snl -o ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/FlettFromFlottaDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/FlettFromFlottaDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/FlettFromFlottaDrums.wav

dart $snareLangExecutable -i tunes/HawaiiAlohaMet.snl,tunes/HawaiiAlohaSnare.snl,tunes/HawaiiAlohaTenor.snl,tunes/HawaiiAlohaBass.snl -o ${myHobby}/BandTunes/Midis/HawaiiAlohaDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HawaiiAlohaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/HawaiiAlohaDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HawaiiAlohaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/HawaiiAlohaDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HawaiiAlohaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/HawaiiAlohaDrums.wav
# Hawaii Aloha has regular pipes, and harmony pipes, and drums, I think, somewhere
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/HawaiiAlohaChanterMelody.ppl,${pipeLangDir}/tunes/HawaiiAlohaChanterHarmony.ppl  -o ${myHobby}/Pipes/Midis/HawaiiAlohaChanterMelodyAndHarmony.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/HawaiiAlohaChanterMelodyAndHarmony.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/HawaiiAlohaChanterMelodyAndHarmony.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/HawaiiAlohaChanterMelodyAndHarmony.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/HawaiiAlohaChanterMelodyAndHarmony.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/HawaiiAlohaChanterMelodyAndHarmony.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/HawaiiAlohaChanterMelodyAndHarmony.wav

dart $tracksFile  -i ${myHobby}/BandTunes/Midis/HawaiiAlohaDrums.mid,${myHobby}/Pipes/Midis/HawaiiAlohaChanterMelodyAndHarmony.mid -o ${myHobby}/BandTunes/Midis/HawaiiAlohaChantersAndDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HawaiiAlohaChantersAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/HawaiiAlohaChantersAndDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HawaiiAlohaChantersAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/HawaiiAlohaChantersAndDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HawaiiAlohaChantersAndDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/HawaiiAlohaChantersAndDrums.wav










dart $snareLangExecutable -i tunes/ScotlandTheBraveMet.snl,tunes/ScotlandTheBraveSnare.snl,tunes/ScotlandTheBraveSnareChips.snl,tunes/ScotlandTheBraveTenor.snl,tunes/ScotlandTheBraveBass.snl -o ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/ScotlandTheBraveDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/ScotlandTheBraveDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/ScotlandTheBraveDrums.wav

#dart $snareLangExecutable -i tunes/CameronianRantSnare5.snl,tunes/CameronianRantSnare1.snl,tunes/CameronianRantSnare9.snl -o ${myHobby}/BandTunes/Midis/CameronianRantDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CameronianRantDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/CameronianRantDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CameronianRantDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/CameronianRantDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CameronianRantDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/CameronianRantDrums.wav

#dart $snareLangExecutable -i tunes/TireeMet.snl,tunes/TireeSnare.snl,tunes/TireeSnareChips.snl,tunes/TireeTenor.snl,tunes/TireeBass.snl -o ${myHobby}/BandTunes/Midis/TireeDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TireeDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/TireeDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TireeDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/TireeDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TireeDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/TireeDrums.wav




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
JlV1P62-43 \
)

rm -f ${myHobby}/Books/JLV1/Midis/*.mid
rm -f ${myHobby}/Books/JLV1/Midis/*.sf2
rm -f ${myHobby}/Books/JLV1/Mp3s/*.mp3
rm -f ${myHobby}/Books/JLV1/Oggs/*.ogg
rm -f ${myHobby}/Books/JLV1/Wavs/*.wav

#rm -f ${myHobby}/mp3s/JLV1/*.mp3
for f in ${JlV1NameArray[@]}; do
    #rm -f "${myHobby}/Books/JLV1/Midis/${f}.mid"
    dart $snareLangExecutable -i /home/rob/WebstormProjects/snarelang4/exercises/LaughlinVol1/${f}.snl -o ${myHobby}/Books/JLV1/Midis/${f}.mid -S 1.25
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV1/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Books/JLV1/Mp3s/${f}.mp3
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV1/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Books/JLV1/Oggs/${f}.ogg
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV1/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Books/JLV1/Wavs/${f}.wav
done

# Now zip.  Need to cd into the directoryy where the files are so that unzipping doesn't duplicate the tree
pushd ${myHobby}/Books/JLV1/Midis/
rm *.sf2
cp $soundFontFile ./
rm -f JLV1Mids.zip
zip JLV1Mids.zip  *.mid *.sf2
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
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV2/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Books/JLV2/Mp3s/${f}.mp3
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV2/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Books/JLV2/Oggs/${f}.ogg
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV2/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Books/JLV2/Wavs/${f}.wav
done

# Now zip Volume 2
pushd ${myHobby}/Books/JLV2/Midis/
rm -f *.sf2
cp $soundFontFile ./
rm -f JLV2Mids.zip
zip JLV2Mids.zip  *.mid *.sf2
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
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/warmups/LeoBrowne/8s.snl -o /home/rob/MyHobby/midis/ForDrummers/LeoBrowne8s.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/warmups/LeoBrowne/Accents.snl -o /home/rob/MyHobby/midis/ForDrummers/LeoBrowneAccents.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/warmups/LeoBrowne/Accents8ths.snl -o /home/rob/MyHobby/midis/ForDrummers/LeoBrowneAccents8ths.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/warmups/LeoBrowne/LeoFlams.snl -o /home/rob/MyHobby/midis/ForDrummers/LeoBrownFlams.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/warmups/LeoBrowne/Wipers.snl -o /home/rob/MyHobby/midis/ForDrummers/LeoBrowneWipers.mid



# tunes

# Non-band tunes
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/AnnettesChatterMet.snl -o /home/rob/MyHobby/midis/AnnettesChatterMet.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/AnnettesChatterSnare.snl -o /home/rob/MyHobby/midis/AnnettesChatterSnare.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JaneCampbellSnare.snl -o /home/rob/MyHobby/midis/JaneCampbellSnare.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JimmyRolloSnare.snl -o /home/rob/MyHobby/midis/JimmyRolloSnare.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JimmyRolloMet.snl -o /home/rob/MyHobby/midis/JimmyRolloMet.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JohnWalshsWalkMet.snl -o /home/rob/MyHobby/midis/JohnWalshsWalkMet.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JohnWalshsWalkSnare.snl -o /home/rob/MyHobby/midis/JohnWalshsWalkSnare.mid

# I think this next part is for adding pipes to the mix.  Need to process the pipe.ppl file to create a mid, and then need to
# merge the pipes mid with the drums mid



#fi

# I think Amber On The Rocks is pipes only
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/AmberOnTheRocks.ppl -o ${myHobby}/Pipes/Midis/AmberOnTheRocks.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/AmberOnTheRocks.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Pipes/Mp3s/AmberOnTheRocks.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/AmberOnTheRocks.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Pipes/Oggs/AmberOnTheRocks.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/AmberOnTheRocks.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Pipes/Wavs/AmberOnTheRocks.wav


# Cameronian Rant can have several snares, plus pipes, and met.  The met part is in snare5, and not separate, which is a bit strange
dart $snareLangExecutable -i tunes/CameronianRantSnare5.snl,tunes/CameronianRantSnare1.snl,tunes/CameronianRantSnare9.snl -o ${myHobby}/NonBandTunes/Midis/CameronianRantSnares.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/NonBandTunes/Midis/CameronianRantSnares.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/NonBandTunes/Mp3s/CameronianRantSnares.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/NonBandTunes/Midis/CameronianRantSnares.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/NonBandTunes/Oggs/CameronianRantSnares.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/NonBandTunes/Midis/CameronianRantSnares.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/NonBandTunes/Wavs/CameronianRantSnares.wav

dart $pipeLangDartFile -i ${pipeLangDir}/tunes/CameronianRantStrath.ppl -o ${myHobby}/Pipes/Midis/CameronianRantStrath.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/CameronianRantStrath.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Pipes/Mp3s/CameronianRantStrath.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/CameronianRantStrath.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Pipes/Mp3s/CameronianRantStrath.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/CameronianRantStrath.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Pipes/Mp3s/CameronianRantStrath.wav

dart $tracksFile   -i ${myHobby}/NonBandTunes/Midis/CameronianRantSnares.mid,${myHobby}/Pipes/Midis/CameronianRantStrath.mid -o ${myHobby}/NonBandTunes/Midis/CameronianRantSnaresAndChanter.mid
# I think the ffmpeg does not do the stereo separation.  Not sure why.
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/NonBandTunes/Midis/CameronianRantSnaresAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/NonBandTunes/Mp3s/CameronianRantSnaresAndChanter.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/NonBandTunes/Midis/CameronianRantSnaresAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/NonBandTunes/Oggs/CameronianRantSnaresAndChanter.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/NonBandTunes/Midis/CameronianRantSnaresAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/NonBandTunes/Wavs/CameronianRantSnaresAndChanter.wav




# These are pipes parts, but I think they also have a snare or drum part to them somewhere too
# Already have the snare score midi because processed it from a list of single scores, not multiple that make up a midi.
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/BanjoBreakdown.ppl -o ${myHobby}/Pipes/Midis/BanjoBreakdownChanter.mid
# I prob don't need to create audio renders of pipe midis, because they don't help pipers at this time.  Maybe when get grace notes in, and get things much better
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/BanjoBreakdownChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Pipes/Mp3s/BanjoBreakdownChanter.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/BanjoBreakdownChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Pipes/Oggs/BanjoBreakdownChanter.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Pipes/Midis/BanjoBreakdownChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Pipes/Wavs/BanjoBreakdownChanter.wav
dart $tracksFile   -i ${myHobby}/BandTunes/Midis/BanjoBreakdown.mid,${myHobby}/Pipes/Midis/BanjoBreakdownChanter.mid -o ${myHobby}/BandTunes/Midis/BanjoBreakdownSnareAndChanter.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BanjoBreakdownSnareAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/BanjoBreakdownSnareAndChanter.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BanjoBreakdownSnareAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/BanjoBreakdownSnareAndChanter.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BanjoBreakdownSnareAndChanter.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/BanjoBreakdownSnareAndChanter.wav




# Now zip up the band tunes
rm -f *.sf2
cp $soundFontFile ./
rm -f BandTunesMids.zip
zip BandTunesMids.zip  *.mid *.sf2
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


# Now zip up the non-band tunes
pushd ${myHobby}/NonBandTunes/Midis/
rm -f *.sf2
cp $soundFontFile ./
rm -f NonBandTunesMids.zip
zip NonBandTunesMids.zip  *.mid *.sf2
popd

pushd ${myHobby}/NonBandTunes/Mp3s/
rm -f NonBandTunesMp3s.zip
zip NonBandTunesMp3s.zip  *.mp3
popd

pushd ${myHobby}/NonBandTunes/Oggs/
rm -f NonBandTunesOggs.zip
zip NonBandTunesOggs.zip  *.ogg
popd

pushd ${myHobby}/NonBandTunes/Wavs/
rm -f NonBandTunesWavs.zip
zip NonBandTunesWavs.zip  *.wav





#cd /home/rob/WebstormProjects/tracks/bin

# Oh, here we put the pipes and drums together.  But there are few chanter/pipes midi files, only Amber, Banjo, Cameronian, Ewing, HawaiiAloha



#dart $tracksFile  -i ${myHobby}/BandTunes/Midis/CaptEwingSnare.mid,${myHobby}/BandTunes/Midis/CaptEwingTenor.mid,${myHobby}/BandTunes/Midis/CaptEwingBass.mid,${myHobby}/BandTunes/Midis/CaptEwingMet.mid -o ${myHobby}/BandTunes/Midis/CaptEwingDrums.mid

## Actually, isn't this rather silly?  Doing "tracks" in order to put together midi files into one midi file?  Because could have done that with regular snl or ppl dart apps.  Tracks is for merging .mid files from drums and pipes.
#dart $tracksFile  -i ${myHobby}/BandTunes/Midis/FlettFromFlottaSnare.mid,${myHobby}/BandTunes/Midis/FlettFromFlottaTenor.mid,${myHobby}/BandTunes/Midis/FlettFromFlottaBass.mid,${myHobby}/BandTunes/Midis/FlettFromFlottaMet.mid -o ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid
#
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/FlettFromFlottaDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/FlettFromFlottaDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/FlettFromFlottaDrums.wav
#
##dart $tracksFile  -i ${myHobby}/BandTunes/Midis/JimmyRolloSnare.mid,${myHobby}/BandTunes/Midis/JimmyRolloMet.mid -o ${myHobby}/BandTunes/Midis/JimmyRolloSnareAndMet.mid -l ALL
#
##dart $tracksFile  -i ${myHobby}/BandTunes/Midis/JohnWalshsWalkSnare.mid,${myHobby}/BandTunes/Midis/JohnWalshsWalkMet.mid -o ${myHobby}/BandTunes/Midis/JohnWalshsWalkSnareAndMet.mid
#
#dart $tracksFile  -i ${myHobby}/BandTunes/Midis/ScotlandTheBraveSnare.mid,${myHobby}/BandTunes/Midis/ScotlandTheBraveSnareChips.mid,${myHobby}/BandTunes/Midis/ScotlandTheBraveTenor.mid,${myHobby}/BandTunes/Midis/ScotlandTheBraveBass.mid,${myHobby}/BandTunes/Midis/ScotlandTheBraveMet.mid -o ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/ScotlandTheBraveMet.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/ScotlandTheBraveMet.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/ScotlandTheBraveMet.wav
#
#dart $tracksFile  -i ${myHobby}/BandTunes/Midis/TireeSnare.mid,${myHobby}/BandTunes/Midis/TireeSnareChips.mid,${myHobby}/BandTunes/Midis/TireeTenor.mid,${myHobby}/BandTunes/Midis/TireeBass.mid,${myHobby}/BandTunes/Midis/TireeMet.mid -o ${myHobby}/BandTunes/Midis/TireeDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TireeDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/TireeDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TireeDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/TireeDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TireeDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/TireeDrums.wav

echo Done processing files
exit 0




