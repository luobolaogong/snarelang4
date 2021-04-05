#!/bin/bash
echo "Processing .snl and .ppl files, to create .mid and audio files under ~/MyHobby/ which can be copied into Google Drive for the .org website use."
echo This is being run out of the bin directory of the snarelang4 project, and not the pipelang project, so later pipes wont work right
echo We are here: `pwd`

declare myHobby=/home/rob/MyHobby
echo myHobby is $myHobby and it has `ls $myHobby`

# The soundfont file must coordinate with the midi files that are created, and they're created with "pitches" in mind, so really only
# one soundfont file should exist per organization of midi files.
#declare soundFont=/home/rob/Desktop/MySoundFonts/DrumLine202103081351.sf2
declare soundFontName=DrumLine202103081351.sf2
cp /home/rob/Desktop/MySoundFonts/${soundFontName} ${myHobby}/SoundFonts
declare soundFontFile=${myHobby}/SoundFonts/${soundFontName}
#cp /home/rob/Desktop/MySoundFonts/PipesAndDrums202011060735.sf2 ${myHobby}/MySoundFonts
echo soundfont is $soundFontFile
#cd /home/rob/WebstormProjects/snarelang4/bin




if false; then




echo Starting to process snare tunes ...
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


for f in ${tuneNameArray[@]}; do
  # I doubt I really need to remove the file before create a new one.  Can probably just write on top of it.
  # If anything, I should probably just delete everything in the directory before doing a zip of everything.
  #rm -f ${myHobby}/BandTunes/Midis/${f}.mid
  dart bin/snl.dart -i tunes/${f}.snl -o ${myHobby}/BandTunes/Midis/${f}.mid
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
dart bin/snl.dart -i tunes/BlackBear.snl,tunes/BlackBearMidSection.snl -o ${myHobby}/BandTunes/Midis/BlackBearDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BlackBearDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/BlackBearDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BlackBearDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/BlackBearDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/BlackBearDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/BlackBearDrums.wav

dart bin/snl.dart -i tunes/CaptEwingMet.snl,tunes/CaptEwingSnare.snl,tunes/CaptEwingTenor.snl,tunes/CaptEwingBass.snl -o ${myHobby}/BandTunes/Midis/CaptEwingDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CaptEwingDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/CaptEwingDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CaptEwingDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/CaptEwingDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/CaptEwingDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/CaptEwingDrums.wav

dart bin/snl.dart -i tunes/FlettFromFlottaMet.snl,tunes/FlettFromFlottaSnare.snl,tunes/FlettFromFlottaTenor.snl,tunes/FlettFromFlottaBass.snl -o ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/FlettFromFlottaDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/FlettFromFlottaDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/FlettFromFlottaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/FlettFromFlottaDrums.wav

dart bin/snl.dart -i tunes/HawaiiAlohaMet.snl,tunes/HawaiiAlohaSnare.snl,tunes/HawaiiAlohaTenor.snl,tunes/HawaiiAlohaBass.snl -o ${myHobby}/BandTunes/Midis/HawaiiAlohaDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HawaiiAlohaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/HawaiiAlohaDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HawaiiAlohaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/HawaiiAlohaDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/HawaiiAlohaDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/HawaiiAlohaDrums.wav

dart bin/snl.dart -i tunes/ScotlandTheBraveMet.snl,tunes/ScotlandTheBraveSnare.snl,tunes/ScotlandTheBraveSnareChips.snl,tunes/ScotlandTheBraveTenor.snl,tunes/ScotlandTheBraveBass.snl -o ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/ScotlandTheBraveDrums.mp3
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/ScotlandTheBraveDrums.ogg
fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/ScotlandTheBraveDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/ScotlandTheBraveDrums.wav

#dart bin/snl.dart -i tunes/TireeMet.snl,tunes/TireeSnare.snl,tunes/TireeSnareChips.snl,tunes/TireeTenor.snl,tunes/TireeBass.snl -o ${myHobby}/BandTunes/Midis/TireeDrums.mid
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TireeDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/TireeDrums.mp3
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TireeDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/TireeDrums.ogg
#fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/TireeDrums.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/TireeDrums.wav


# Now zip up the tunes
rm -f "${myHobby}/BandTunes/Midis/BandTunesMids.zip"
zip ${myHobby}/BandTunes/Midis/BandTunesMids.zip  ${myHobby}/BandTunes/Midis/*.mid

rm -f "${myHobby}/BandTunes/Mp3s/BandTunesMp3s.zip"
zip ${myHobby}/BandTunes/Mp3s/BandTunesMp3s.zip  ${myHobby}/BandTunes/Mp3s/*.mp3

rm -f "${myHobby}/BandTunes/Oggs/BandTunesOggs.zip"
zip ${myHobby}/BandTunes/Oggs/BandTunesOggs.zip  ${myHobby}/BandTunes/Oggs/*.ogg

rm -f "${myHobby}/BandTunes/Wavs/BandTunesWavs.zip"
zip ${myHobby}/BandTunes/Wavs/BandTunesWavs.zip  ${myHobby}/BandTunes/Wavs/*.wav




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
rm -f ${myHobby}/Books/JLV1/Mp3s/*.mp3
rm -f ${myHobby}/Books/JLV1/Oggs/*.ogg
rm -f ${myHobby}/Books/JLV1/Wavs/*.wav

#rm -f ${myHobby}/mp3s/JLV1/*.mp3
for f in ${JlV1NameArray[@]}; do
    #rm -f "${myHobby}/Books/JLV1/Midis/${f}.mid"
    dart bin/snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/LaughlinVol1/${f}.snl -o ${myHobby}/Books/JLV1/Midis/${f}.mid -S 1.25
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV1/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Books/JLV1/Mp3s/${f}.mp3
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV1/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Books/JLV1/Oggs/${f}.ogg
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV1/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Books/JLV1/Wavs/${f}.wav
done

# Now zip
rm -f "${myHobby}/Books/JLV1/Midis/Books/JLV1Mids.zip"
zip ${myHobby}/Books/JLV1/Midis/JLV1Mids.zip  ${myHobby}/Books/JLV1/Midis/*.mid

rm -f "${myHobby}/Books/JLV1/Mp3s/Books/JLV1Mp3s.zip"
zip ${myHobby}/Books/JLV1/Mp3s/JLV1Mp3s.zip  ${myHobby}/Books/JLV1/Mp3s/*.mp3

rm -f "${myHobby}/Books/JLV1/Oggs/Books/JLV1Oggs.zip"
zip ${myHobby}/Books/JLV1/Oggs/JLV1Oggs.zip  ${myHobby}/Books/JLV1/Oggs/*.ogg

rm -f "${myHobby}/Books/JLV1/Wavs/Books/JLV1Wavs.zip"
zip ${myHobby}/Books/JLV1/Wavs/JLV1Wavs.zip  ${myHobby}/Books/JLV1/Wavs/*.wav



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
    dart bin/snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/LaughlinVol2/${f}.snl -o ${myHobby}/Books/JLV2/Midis/${f}.mid
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV2/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Books/JLV2/Mp3s/${f}.mp3
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV2/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Books/JLV2/Oggs/${f}.ogg
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Books/JLV2/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Books/JLV2/Wavs/${f}.wav
done

# Now zip
rm -f "${myHobby}/Books/JLV2/Midis/JLV2Mids.zip"
zip ${myHobby}/Books/JLV2/Midis/JLV2Mids.zip  ${myHobby}/Books/JLV2/Midis/*.mid

rm -f "${myHobby}/Books/JLV2/Mp3s/JLV2Mp3s.zip"
zip ${myHobby}/Books/JLV2/Mp3s/JLV2Mp3s.zip  ${myHobby}/Books/JLV2/Mp3s/*.mp3

rm -f "${myHobby}/Books/JLV2/Oggs/JLV2Oggs.zip"
zip ${myHobby}/Books/JLV2/Oggs/JLV2Oggs.zip  ${myHobby}/Books/JLV2/Oggs/*.ogg

rm -f "${myHobby}/Books/JLV2/Wavs/JLV2Wavs.zip"
zip ${myHobby}/Books/JLV2/Wavs/JLV2Wavs.zip  ${myHobby}/Books/JLV2/Wavs/*.wav

exit 8


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
#CameronianRant

# I think this next part is for adding pipes to the mix.  Need to process the pipe.ppl file to create a mid, and then need to
# merge the pipes mid with the drums mid



fi
echo skipped to here

# This stuff doesn't make sense until have soundfont that has pipes in it

declare pipeLangDir=/home/rob/WebstormProjects/pipelang
declare pipeLangDartFile=${pipeLangDir}/bin/ppl.dart


#dart ppl.dart -i ${pipeLangDir}/exercises/rf1.ppl -o ${myHobby}/midis/ForPipers/rf1.mid
#dart ppl.dart -i ${pipeLangDir}/exercises/rf5.ppl -o ${myHobby}/midis/ForPipers/rf5.mid
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/AmberOnTheRocks.ppl -o ${myHobby}/Pipes/Midis/AmberOnTheRocks.mid
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/BanjoBreakdown.ppl -o ${myHobby}/Pipes/Midis/BanjoBreakdownChanter.mid
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/CaptEwingChanter.ppl -o ${myHobby}/Pipes/Midis/CaptEwingChanter.mid
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/HawaiiAlohaChanterHarmony.ppl -o ${myHobby}/Pipes/Midis/HawaiiAlohaChanterHarmony.mid
dart $pipeLangDartFile -i ${pipeLangDir}/tunes/HawaiiAlohaChanterMelody.ppl -o ${myHobby}/Pipes/Midis/HawaiiAlohaChanterMelody.mid

exit 9

cd /home/rob/WebstormProjects/tracks/bin

dart tracks.dart -l WARNING  -i ${myHobby}/midis/ScotlandTheBraveSnare.mid,${myHobby}/midis/ScotlandTheBraveSnareChips.mid,${myHobby}/midis/ScotlandTheBraveTenor.mid,${myHobby}/midis/ScotlandTheBraveBass.mid,${myHobby}/midis/ScotlandTheBraveMet.mid -o ${myHobby}/midis/ForDrummers/ScotlandTheBraveDrums.mid
dart tracks.dart -l WARNING  -i ${myHobby}/midis/BanjoBreakdownSnare.mid,${myHobby}/midis/BanjoBreakdownChanter.mid -o ${myHobby}/midis/ForBand/BanjoBreakdownSnareAndChanter.mid -l ALL
dart tracks.dart -l WARNING -i ${myHobby}/midis/CaptEwingSnare.mid,${myHobby}/midis/CaptEwingTenor.mid,${myHobby}/midis/CaptEwingBass.mid,${myHobby}/midis/CaptEwingMet.mid -o ${myHobby}/midis/CaptEwingDrums.mid
dart tracks.dart -l WARNING -i ${myHobby}/midis/CaptEwingDrums.mid,${myHobby}/midis/CaptEwingChanter.mid -o ${myHobby}/midis/ForBand/CaptEwingChanterAndDrums.mid
sleep 3

dart tracks.dart -l WARNING -i ${myHobby}/midis/FlettFromFlottaSnare.mid,${myHobby}/midis/FlettFromFlottaTenor.mid,${myHobby}/midis/FlettFromFlottaBass.mid,${myHobby}/midis/FlettFromFlottaMet.mid -o ${myHobby}/midis/ForDrummers/FlettFromFlottaDrums.mid
sleep 3

#dart tracks.dart -l WARNING -i ${myHobby}/midis/JimmyRolloSnare.mid,${myHobby}/midis/JimmyRolloMet.mid -o ${myHobby}/midis/JimmyRolloSnareAndMet.mid -l ALL
#sleep 3

#dart tracks.dart -l WARNING -i ${myHobby}/midis/JohnWalshsWalkSnare.mid,${myHobby}/midis/JohnWalshsWalkMet.mid -o ${myHobby}/midis/JohnWalshsWalkSnareAndMet.mid
#sleep 3

dart tracks.dart -l WARNING -i ${myHobby}/midis/ScotlandTheBraveSnare.mid,${myHobby}/midis/ScotlandTheBraveSnareChips.mid,${myHobby}/midis/ScotlandTheBraveTenor.mid,${myHobby}/midis/ScotlandTheBraveBass.mid,${myHobby}/midis/ScotlandTheBraveMet.mid -o ${myHobby}/midis/ForDrummers/ScotlandTheBraveDrums.mid
sleep 3

dart tracks.dart -l WARNING -i ${myHobby}/midis/TireeSnare.mid,${myHobby}/midis/TireeSnareChips.mid,${myHobby}/midis/TireeTenor.mid,${myHobby}/midis/TireeBass.mid,${myHobby}/midis/TireeMet.mid -o ${myHobby}/midis/ForDrummers/TireeDrums.mid
sleep 3


dart tracks.dart -l WARNING -i ${myHobby}/midis/HawaiiAlohaSnare.mid,${myHobby}/midis/HawaiiAlohaTenor.mid,${myHobby}/midis/HawaiiAlohaBass.mid,${myHobby}/midis/HawaiiAlohaMet.mid -o ${myHobby}/midis/HawaiiAlohaDrums.mid
sleep 3
dart tracks.dart -l WARNING -i ${myHobby}/midis/HawaiiAlohaChanterMelody.mid,${myHobby}/midis/HawaiiAlohaChanterHarmony.mid -o ${myHobby}/midis/HawaiiAlohaChanter.mid
sleep 3
dart tracks.dart -l WARNING -i ${myHobby}/midis/HawaiiAlohaDrums.mid,${myHobby}/midis/HawaiiAlohaChanter.mid -o ${myHobby}/midis/ForBand/HawaiiAlohaChantersAndDrums.mid

