import 'package:petitparser/petitparser.dart';
// import 'package:logging/logging.dart';

// final log = Logger('Voice');
// The following is perhaps not the way to do this thing of switching between solo and unison.
// Seems to me that could just use another track for the unison parts, while the solo track continues on.


// So I think I'll abandon this for now




/// I don't know what to call this yet.  The idea is that sometimes maybe a soloist should play,
/// and other times all should play (unison), and maybe other times a different instrument should
/// play the part.  For now, all we want is to handle the "unison" sections, which are sometimes
/// called "chips", or "forte parts" or something else.  And for now, "unison" will mean use
/// the sound font recordings made of a group of drummers playing, rather than a single instrument
/// recording.  I have my snare drum, and I'm adding on recordings from SLOT, as a group.
/// So I want to be able to play a score where there are sections of solo and sections of unison.
// enum Voice {
//   solo,
//   unison
// }
//
// ///
// /// VoiceParser
// ///
// Parser voiceParser = (
//     string('/unison') |
//     string('/chips') |
//     string('/tutti') |
//     string('/solo') |
//     string('/tip')
// ).trim().map((value) { // trim?  Yes!  Makes a difference
//   Voice voice;
//   switch (value) {
//     case '/unison':
//     case '/chips':
//     case '/tutti':
//       voice = Voice.unison;
//       break;
//     case '/solo':
//     case '/tip':
//       voice =  Voice.solo;
//       break;
//   }
//   //log.info('Leaving VoiceParser returning value $voice');
//   return voice;
// });
