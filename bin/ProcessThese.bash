#!/bin/bash
echo "Processing .snl and .ppl files, to create .mid and audio files under ~/MyHobby/ which can be copied into Google Drive for the .org website use."

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


echo Starting to process easy snare tunes ...
declare -a tuneNameArray=(44MarchSnare \
BeginnerMarch \
BlackBear \
JigSnare \
CameronianRantSnare5 \
JigSnare \
March44 \
MassedBand24JLV1P60 \
MassedBand44JLV1P59 \
SlowMarchNo1 \
SlowMarchNo2 \
Strath1SnareMet \
SuperSlowMarchNo2 )

for f in ${tuneNameArray[@]}; do
  rm -f ${myHobby}/BandTunes/Midis/${f}.mid
  dart bin/snl.dart -i tunes/${f}.snl -o ${myHobby}/BandTunes/Midis/${f}.mid
  rm -f ${myHobby}/BandTunes/Mp3s/${f}.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/${f}.mp3
  rm -f ${myHobby}/BandTunes/Oggs/Tunes/${f}.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Oggs/${f}.ogg
  rm -f ${myHobby}/BandTunes/Wavs/${f}.wav
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Wavs/${f}.wav
done

# What about the tunes that have multiple .mid files?

# Now zip up the tunes
rm -f "${myHobby}/BandTunes/Midis/BandTunesMids.zip"
zip ${myHobby}/BandTunes/Midis/BandTunesMids.zip  ${myHobby}/BandTunes/Midis/*.mid

rm -f "${myHobby}/BandTunes/Mp3s/BandTunesMp3s.zip"
zip ${myHobby}/BandTunes/Mp3s/BandTunesMp3s.zip  ${myHobby}/BandTunes/Mp3s/*.mp3

rm -f "${myHobby}/BandTunes/Oggs/BandTunesOggs.zip"
zip ${myHobby}/BandTunes/Oggs/BandTunesOggs.zip  ${myHobby}/BandTunes/Oggs/*.ogg

rm -f "${myHobby}/BandTunes/Wavs/BandTunesWavs.zip"
zip ${myHobby}/BandTunes/Wavs/BandTunesWavs.zip  ${myHobby}/BandTunes/Wavs/*.wav

exit 3





echo Starting to process regular tunes with just one file ...
declare -a regularTuneNameArray=( \
BadgeOfScotland \
BanjoBreakdownBattleOfWaterloo \
CastleDangerousSnareAndMet \
)

for f in ${regulartuneNameArray[@]}; do
  rm -f midifiles/${f}.mid
  dart bin/snl.dart -i tunes/${f}.snl -o ${myHobby}/BandTunes/Midis/${f}.mid
  rm -f ${myHobby}/BandTunes/Mp3s/${f}.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/${f}.mp3
  rm -f ${myHobby}/Oggs/Tunes/${f}.ogg
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Oggs/Tunes/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Oggs/Tunes/${f}.ogg
  rm -f ${myHobby}/Wavs/Tunes/${f}.wav
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/Wavs/Tunes/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/Wavs/Tunes/${f}.wav
done

# What about the tunes that have multiple .mid files?

# Now zip up the tunes
rm -f "${myHobby}/BandTunes/Midis/regTunesMids.zip"
zip ${myHobby}/BandTunes/Midis/regTunesMids.zip  ${myHobby}/BandTunes/Midis/*.mid          no can do  need separate areas.

rm -f "${myHobby}/BandTunes/Mp3s/tunesMp3s.zip"
zip ${myHobby}/BandTunes/Mp3s/tunesMp3s.zip  ${myHobby}/BandTunes/Mp3s/*.mp3

rm -f "${myHobby}/Oggs/Tunes/tunesOggs.zip"
zip ${myHobby}/Oggs/Tunes/tunesOggs.zip  ${myHobby}/Oggs/Tunes/*.ogg

rm -f "${myHobby}/Wavs/Tunes/tunesWavs.zip"
zip ${myHobby}/Wavs/Tunes/tunesWavs.zip  ${myHobby}/Wavs/Tunes/*.wav

exit 0







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

#rm -f ${myHobby}/mp3s/JLV1/*.mp3
for f in ${JlV1NameArray[@]}; do
    rm -f "${myHobby}/midis/JLV1midis/${f}.mid"
    dart bin/snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/LaughlinVol1/${f}.snl -o ${myHobby}/midis/JLV1midis/${f}.mid -S 1.25
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/midis/JLV1midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/mp3s/JLV1/${f}.mp3
done

# Now zip
[ -e "${myHobby}/mp3s/JLV1/JlV1Mp3s.zip" ] && rm "${myHobby}/mp3s/JLV1/JlV1Mp3s.zip"
zip ${myHobby}/mp3s/JLV1/JlV1Mp3s.zip  ${myHobby}/mp3s/JLV1/*.mp3
#do same for wavs and oggs etc.




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

#rm -f ${myHobby}/mp3s/JLV2/*.mp3
for f in ${JlV2NameArray[@]}; do
    rm -f "${myHobby}/midis/JLV2midis/${f}.mid"
    dart bin/snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/LaughlinVol2/${f}.snl -o ${myHobby}/midis/JLV2midis/${f}.mid
    rm -f "${myHobby}/mp3s/JLV2/${f}.mp3"
    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/midis/JLV2midis/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/mp3s/JLV2/${f}.mp3
done

# Now zip
[ -e "${myHobby}/mp3s/JLV2/JlV2Mp3s.zip" ] && rm "${myHobby}/mp3s/JLV2/JlV2Mp3s.zip"
zip ${myHobby}/mp3s/JLV2/JlV2Mp3s.zip  ${myHobby}/mp3s/JLV2/*.mp3





#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/MaxwellPg1.snl -o /home/rob/MyHobby/midis/ForDrummers/MaxwellPg1.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/MaxwellPg2.snl -o /home/rob/MyHobby/midis/ForDrummers/MaxwellPg2.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/MaxwellPg27.snl -o /home/rob/MyHobby/midis/ForDrummers/MaxwellPg27.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/MaxwellPg27Swing.snl -o /home/rob/MyHobby/midis/ForDrummers/MaxwellPg27Swing.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/MaxwellPg3.snl -o /home/rob/MyHobby/midis/ForDrummers/MaxwellPg3.mid

#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/warmups/LeoBrowne/8s.snl -o /home/rob/MyHobby/midis/ForDrummers/LeoBrowne8s.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/warmups/LeoBrowne/Accents.snl -o /home/rob/MyHobby/midis/ForDrummers/LeoBrowneAccents.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/warmups/LeoBrowne/Accents8ths.snl -o /home/rob/MyHobby/midis/ForDrummers/LeoBrowneAccents8ths.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/warmups/LeoBrowne/LeoFlams.snl -o /home/rob/MyHobby/midis/ForDrummers/LeoBrownFlams.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/exercises/warmups/LeoBrowne/Wipers.snl -o /home/rob/MyHobby/midis/ForDrummers/LeoBrowneWipers.mid



# tunes


##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/AnnettesChatterMet.snl -o /home/rob/MyHobby/midis/AnnettesChatterMet.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/AnnettesChatterSnare.snl -o /home/rob/MyHobby/midis/AnnettesChatterSnare.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/44MarchSnare.snl -o /home/rob/MyHobby/midis/44MarchSnare.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/BadgeOfScotland.snl -o /home/rob/MyHobby/midis/BadgeOfScotland.mid # compile error?
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/BanjoBeakdown.snl -o /home/rob/MyHobby/midis/BanjoBreakdown.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/BattleOfWaterloo.snl -o /home/rob/MyHobby/midis/BattleOfWaterloo.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/BeginnerMarch.snl -o /home/rob/MyHobby/midis/BeginnerMarch.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/BlackBear.snl -o /home/rob/MyHobby/midis/BlackBear.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/CaptEwingBass.snl -o /home/rob/MyHobby/midis/CaptEwingBass.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/CaptEwingMet.snl -o /home/rob/MyHobby/midis/CaptEwingMet.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/CaptEwingSnare.snl -o /home/rob/MyHobby/midis/CaptEwingSnare.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/CaptEwingTenor.snl -o /home/rob/MyHobby/midis/CaptEwingTenor.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/CastleDangerousSnareAndMet.snl -o /home/rob/MyHobby/midis/CastleDangerousSnareAndMet.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/FlettFromFlottaBass.snl -o /home/rob/MyHobby/midis/FlettFromFlottaBass.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/FlettFromFlottaMet.snl -o /home/rob/MyHobby/midis/FlettFromFlottaMet.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/FlettFromFlottaSnare.snl -o /home/rob/MyHobby/midis/FlettFromFlottaSnare.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/FlettFromFlottaTenor.snl -o /home/rob/MyHobby/midis/FlettFromFlottaTenor.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/HawaiiAlohaBass.snl -o /home/rob/MyHobby/midis/HawaiiAlohaBass.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/HawaiiAlohaMet.snl -o /home/rob/MyHobby/midis/HawaiiAlohaMet.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/HawaiiAlohaSnare.snl -o /home/rob/MyHobby/midis/HawaiiAlohaSnare.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/HawaiiAlohaTenor.snl -o /home/rob/MyHobby/midis/HawaiiAlohaTenor.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JaneCampbellSnare.snl -o /home/rob/MyHobby/midis/JaneCampbellSnare.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JimmyRolloSnare.snl -o /home/rob/MyHobby/midis/JimmyRolloSnare.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JimmyRolloMet.snl -o /home/rob/MyHobby/midis/JimmyRolloMet.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JohnWalshsWalkMet.snl -o /home/rob/MyHobby/midis/JohnWalshsWalkMet.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/JohnWalshsWalkSnare.snl -o /home/rob/MyHobby/midis/JohnWalshsWalkSnare.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/March44.snl -o /home/rob/MyHobby/midis/March44.mid  # errors in this
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/MassedBand24JLV1P60.snl -o /home/rob/MyHobby/midis/MassedBand24JLV1P60.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/MassedBand44JLV1P59.snl -o /home/rob/MyHobby/midis/MassedBand44JLV1P59.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/ReelSnareMet.snl -o /home/rob/MyHobby/midis/ReelSnareMet.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/ReelStraightSnareMet.snl -o /home/rob/MyHobby/midis/ReelStraightSnareMet.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/ScotlandTheBraveBass.snl -o /home/rob/MyHobby/midis/ScotlandTheBraveBass.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/ScotlandTheBraveMet.snl -o /home/rob/MyHobby/midis/ScotlandTheBraveMet.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/ScotlandTheBraveSnare.snl -o /home/rob/MyHobby/midis/ScotlandTheBraveSnare.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/ScotlandTheBraveSnareChips.snl -o /home/rob/MyHobby/midis/ScotlandTheBraveSnareChips.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/ScotlandTheBraveTenor.snl -o /home/rob/MyHobby/midis/ScotlandTheBraveTenor.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/SlowMarchNo1.snl -o /home/rob/MyHobby/midis/SlowMarchNo1.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/SlowMarchNo2.snl -o /home/rob/MyHobby/midis/SlowMarchNo2.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/StrathSnareMet.snl -o /home/rob/MyHobby/midis/StrathSnareMet.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/SuperSlowMarchNo2.snl -o /home/rob/MyHobby/midis/SuperSlowMarchNo2.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/TireeBass.snl -o /home/rob/MyHobby/midis/TireeBass.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/TireeMet.snl -o /home/rob/MyHobby/midis/TireeMet.mid
#dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/TireeSnare.snl -o /home/rob/MyHobby/midis/TireeSnare.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/TireeSnareChips.snl -o /home/rob/MyHobby/midis/TireeSnareChips.mid
##dart snl.dart -i /home/rob/WebstormProjects/snarelang4/tunes/TireeTenor.snl -o /home/rob/MyHobby/midis/TireeTenor.mid
#
#zip /home/rob/MyHobby/BandTunes/MidisMidis.zip /home/rob/MyHobby/midis/*.mid



# Now try creating tunes .mid and .mp3 and others, and .zip files

echo Starting to process tunes ...
declare -a tuneNameArray=(44MarchSnare \
BeginnerMarch \
BlackBear \
JigSnare \
CameronianRantSnare5 \
JigSnare \
March44 \
MassedBand24JLV1P60 \
MassedBand44JLV1P59 \
SlowMarchNo1 \
SlowMarchNo2 \
Strath1SnareMet \
SuperSlowMarchNo2 )

#rm -f ${myHobby}/mp3s/*.mp3
for f in ${tuneNameArray[@]}; do
  rm -f midifiles/${f}.mid
  dart bin/snl.dart -i tunes/${f}.snl -o ${myHobby}/BandTunes/Mp3s/${f}.mid
  rm -f ${myHobby}/BandTunes/Mp3s/${f}.mp3
  fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  ${myHobby}/BandTunes/Mp3s/${f}.mid | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - ${myHobby}/BandTunes/Mp3s/${f}.mp3
done

# What about the tunes that have multiple .mid files?

# Now zip up the tunes
[ -e "${myHobby}/mp3s/tunes.zip" ] && rm "${myHobby}/mp3s/tunes.zip"
#rm ${myHobby}/mp3s/tunes.zip
zip ${myHobby}/BandTunes/Mp3s/tunes.zip  ${myHobby}/BandTunes/Mp3s/*.mp3


#pushd /home/rob/MyHobby/midis
#for f in *.mid
#do
#    bn=`basename $f .mid`
#    fluidsynth -q -a alsa -g 2.0 -T raw  -F - ${soundFontFile}  $f | ffmpeg -y -hide_banner -loglevel panic -f s32le -i - /home/rob/MyHobby/mp3s/${bn}.mp3
#    echo Created /home/rob/MyHobby/mp3s/${bn}.mp3
#done
#zip /home/rob/MyHobby/mp3s/tunes.zip  /home/rob/MyHobby/mp3s/*.mp3 &

#zip JLV1midis.zip  *.mid &
#zip /home/rob/MyHobby/mp3s/JLV1/JLV1mp3s.zip  /home/rob/MyHobby/mp3s/JLV1/*.mp3 &
#zip /home/rob/MyHobby/wavs/JLV1/JLV1wavs.zip  /home/rob/MyHobby/wavs/JLV1/*.wav &
#zip /home/rob/MyHobby/oggs/JLV1/JLV1oggs.zip  /home/rob/MyHobby/oggs/JLV1/*.ogg &

#popd



exit 1








cd /home/rob/WebstormProjects/pipelang/bin
dart ppl.dart -i /home/rob/WebstormProjects/pipelang/exercises/rf1.ppl -o ${myHobby}/midis/ForPipers/rf1.mid
dart ppl.dart -i /home/rob/WebstormProjects/pipelang/exercises/rf5.ppl -o ${myHobby}/midis/ForPipers/rf5.mid
dart ppl.dart -i /home/rob/WebstormProjects/pipelang/tunes/AmberOnTheRocks.ppl -o ${myHobby}/midis/AmberOnTheRocks.mid
dart ppl.dart -i /home/rob/WebstormProjects/pipelang/tunes/BanjoBreakdown.ppl -o ${myHobby}/midis/BanjoBreakdownChanter.mid
dart ppl.dart -i /home/rob/WebstormProjects/pipelang/tunes/CaptEwingChanter.ppl -o ${myHobby}/midis/CaptEwingChanter.mid
dart ppl.dart -i /home/rob/WebstormProjects/pipelang/tunes/HawaiiAlohaChanterHarmony.ppl -o ${myHobby}/midis/HawaiiAlohaChanterHarmony.mid
dart ppl.dart -i /home/rob/WebstormProjects/pipelang/tunes/HawaiiAlohaChanterMelody.ppl -o ${myHobby}/midis/HawaiiAlohaChanterMelody.mid

sleep 15
cd /home/rob/WebstormProjects/tracks/bin

dart tracks.dart -l WARNING  -i ${myHobby}/midis/ScotlandTheBraveSnare.mid,${myHobby}/midis/ScotlandTheBraveSnareChips.mid,${myHobby}/midis/ScotlandTheBraveTenor.mid,${myHobby}/midis/ScotlandTheBraveBass.mid,${myHobby}/midis/ScotlandTheBraveMet.mid -o ${myHobby}/midis/ForDrummers/ScotlandTheBraveDrums.mid
sleep 3
dart tracks.dart -l WARNING  -i ${myHobby}/midis/BanjoBreakdownSnare.mid,${myHobby}/midis/BanjoBreakdownChanter.mid -o ${myHobby}/midis/ForBand/BanjoBreakdownSnareAndChanter.mid -l ALL
sleep 3
dart tracks.dart -l WARNING -i ${myHobby}/midis/CaptEwingSnare.mid,${myHobby}/midis/CaptEwingTenor.mid,${myHobby}/midis/CaptEwingBass.mid,${myHobby}/midis/CaptEwingMet.mid -o ${myHobby}/midis/CaptEwingDrums.mid
sleep 3
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

