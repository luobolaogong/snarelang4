import 'package:petitparser/petitparser.dart';
import 'package:logging/logging.dart';

final log = Logger('Dynamic');

///
/// New 8/24/23.  Changing Dynamic so that it's only the dynamic names, and not
/// hairpin cressc, decresc, and dim.  Those will be termed 'ramps'.
///
/// Dynamic markings in the text version, such as f, and fff apply to the notes
/// following it.  Likewise, Ramp marks apply to notes following it and apply to
/// all notes prior to the next Dynamic mark.
///
/// The code does not account for errors, such as hitting another ramp marker
/// before hitting another dynamic marker, or hitting the end of the score.
/// I suppose if two hairpins were next to each other, like <> or >< then
/// you could perhaps guess what the missing dynamic would be, but for now will
/// just ignore all ramps until hit the next Dynamic marker.  If there isn't
/// one, then the Ramp marker doesn't get its full value, and we should ignore
/// it when determining velocities.  So, just ignore Ramps that don't have a slope.
class Ramp {
  Dynamic startDynamic; // perhaps should store as velocity?
  Dynamic endDynamic;
  int startVelocity;
  int endVelocity;
  int totalTicksStartToEnd;
//  Duration totalDuration; // not ticks, I guess
  //num durationInTicks; // ?????????????????????
  num slope;

  String toString() {
    return 'Ramp: startDynamic: $startDynamic, endDynamic: $endDynamic, startVelocity: $startVelocity, endVelocity: $endVelocity, totalTicksStartToEnd: $totalTicksStartToEnd, Slope: $slope';
  }
}

enum Dynamic {
  ppp,
  pp,
  p,
  mp,
  mf,
  f,
  ff,
  fff
//  dim,
//  decresc,
//  cresc,
//  ramp
}

// Are these velocity numbers from 0 to 127?  Assume so.
// How are these values determined?  Is it basically a linear scale?  Looks like each diff is 16.
// And how do the recording levels affect things?  If the recording is a X db, how does that affect these velocity levels of 0 to 127?
// Should soft and medium and loud recordings all be normalized to the same level, and then if the velocity is
// low, choose the soft, and if the velocity is loud, choose the loud?  Perhaps.
// And how will the various accents affect the velocities?
// Should velocity increases for accents always produce a velocity less than the next higher up dynamic?
// No, I don't think so.  Perhaps "-" increases to next dynamic level, and ">" increases two dynamic levels, and "^" up 3?
// but there are capped limits at 127.
//
// And since each dynamic level is basically 16 more than previous level, we could just say that
// "_" add 16, ">" add 32, and "^" and 48, but cap at 127.
//
// There should also be an additional dynamic affect based on note type, that is, a flam is generally slightly louder than a tap,
// a drag louder than a flam(?), and grace notes way lower than a tap.  But these should not be as big of changes as dynamic
// levels are.
// A flam is maybe an increase of 6, a drag increases by 10 (of course with a note cap of 127).
// Grace notes are recorded with their principle notes, so there are no separate grace notes.  If there were, they'd be
// at an absolute level of about 10 (for 2/3 stroke ruffs and maybe flams, but not drags)
int dynamicToVelocity(Dynamic dynamic) {
  var velocity = 0;
  switch (dynamic) {
    case Dynamic.ppp:
      velocity = 6; // start at 10?  5?
      break;
    case Dynamic.pp:
      velocity = 22;
      break;
    case Dynamic.p:
      velocity = 38;
      break;
    case Dynamic.mp:
      velocity = 54;
      break;
    case Dynamic.mf:
      velocity = 70;
      break;
    case Dynamic.f:
      velocity = 86;
      break;
    case Dynamic.ff:
      velocity = 102;
      break;
    case Dynamic.fff:
      velocity = 117;
      break;
//    case Dynamic.ramp:
//      break;
//    case Dynamic.ppp:
//      velocity = 16; // start at 10?  5?
//      break;
//    case Dynamic.pp:
//      velocity = 32;
//      break;
//    case Dynamic.p:
//      velocity = 48;
//      break;
//    case Dynamic.mp:
//      velocity = 64;
//      break;
//    case Dynamic.mf:
//      velocity = 80;
//      break;
//    case Dynamic.f:
//      velocity = 96;
//      break;
//    case Dynamic.ff:
//      velocity = 112;
//      break;
//    case Dynamic.fff:
//      velocity = 127; // no room for accents?
//      break;
//    case Dynamic.ramp:
//      break;
    default:
      log.info('What kine dynamic was that? $dynamic');
      break;
  }
  return velocity;
}

Dynamic stringToDynamic(dynamicString) {
  switch (dynamicString) {
    case 'ppp':
      return Dynamic.ppp;
    case 'pp':
      return Dynamic.pp;
    case 'p':
      return Dynamic.p;
    case 'mp':
      return Dynamic.mp;
    case 'mf':
      return Dynamic.mf;
    case 'f':
      return Dynamic.f;
    case 'ff':
      return Dynamic.ff;
    case 'fff':
      return Dynamic.fff;
    default:
      log.info('What kinda string is that? -->$dynamicString<--');
      return Dynamic.mf;
  }
}

// something's wrong here.  Looks strange.
// Also, put in own file?  Maybe, although it's a kind of dynamic marking.
// But still, it's kinda a pseudo element.
Parser rampParser = (
    string('/>') |
    string('/<') |
    string('/dim') |
    string('/decresc') |
    string('/cresc')
).trim().map((value) {
  log.finest('In RampParser');
  Ramp ramp;
  switch (value) {
    case '/>':
    case '/<':
    case '/cresc':
    case '/dim':
    case '/decresc':
      ramp =  Ramp();
      break;
  }
  log.finest('Leaving RampParser returning value $ramp');
  return ramp;
});
//Parser rampParser = (
//    string('\\>') |
//    string('\\<') |
//    string('\\dim') |
//    string('\\decresc') |
//    string('\\cresc')
//).trim().map((value) {
//  log.fine('In RampParser');
//  Ramp ramp;
//  switch (value) {
//    case '\\>':
//    case '\\<':
//    case '\\cresc':
//    case '\\dim':
//    case '\\decresc':
//      ramp =  Ramp();
//      break;
//  }
//  log.fine('Leaving RampParser returning value $ramp');
//  return ramp;
//});

/////
///// DynamicOrRampParser
/////
//Parser dynamicOrRampParser = (dynamicParser | rampParser).trim().map((value){
//
//});

///
/// DynamicParser
///
Parser dynamicParser = (
    string('/mf') |
    string('/mp') |
    string('/ppp') |
    string('/pp') |
    string('/p') |
    string('/fff') |
    string('/ff') |
    string('/f')
//    string('\\>') |
//    string('\\<') |
//    string('\\dim') |
//    string('\\decresc') |
//    string('\\cresc')
).trim().map((value) { // trim?  Yes!  Makes a difference
  //log.info('\nIn Dynamicparser');
  Dynamic dynamic;
  switch (value) {
    case '/ppp':
      dynamic = Dynamic.ppp;
      break;
    case '/pp':
      dynamic =  Dynamic.pp;
      break;
    case '/p':
      dynamic =  Dynamic.p;
      break;
    case '/mp':
      dynamic =  Dynamic.mp;
      break;
    case '/mf':
      dynamic =  Dynamic.mf;
      break;
    case '/f':
      dynamic =  Dynamic.f;
      break;
    case '/ff':
      dynamic =  Dynamic.ff;
      break;
    case '/fff':
      dynamic =  Dynamic.fff;
      break;
//    case '\\>':
//    case '\\<':
//    case '\\cresc':
//    case '\\dim':
//    case '\\decresc':
////      dynamic =  Ramp;
//      dynamic =  Dynamic.ramp;
//      break;
  }
  //log.info('Leaving DynamicParser returning value $dynamic');
  return dynamic;
});
