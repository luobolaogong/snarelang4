import 'package:petitparser/petitparser.dart';

enum Dynamic {
  ppp,
  pp,
  p,
  mp,
  mf,
  f,
  ff,
  fff,
//  dim,
//  decresc,
//  cresc,
  ramp
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
    case Dynamic.ramp:
      break;
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
      print('What kinda string is that? -->$dynamicString<--');
      return Dynamic.mf;
  }
}

///
/// DynamicParser
///
Parser dynamicParser = (
    string('\\mf') |
    string('\\mp') |
    string('\\ppp') |
    string('\\pp') |
    string('\\p') |
    string('\\fff') |
    string('\\ff') |
    string('\\f') |
    string('\\>') |
    string('\\<') |
    string('\\dim') |
    string('\\decresc') |
    string('\\cresc')
).trim().map((value) { // trim?  Yes!  Makes a difference
  //print('\nIn Dynamicparser');
  Dynamic dynamic;
  switch (value) {
    case '\\ppp':
      dynamic = Dynamic.ppp;
      break;
    case '\\pp':
      dynamic =  Dynamic.pp;
      break;
    case '\\p':
      dynamic =  Dynamic.p;
      break;
    case '\\mp':
      dynamic =  Dynamic.mp;
      break;
    case '\\mf':
      dynamic =  Dynamic.mf;
      break;
    case '\\f':
      dynamic =  Dynamic.f;
      break;
    case '\\ff':
      dynamic =  Dynamic.ff;
      break;
    case '\\fff':
      dynamic =  Dynamic.fff;
      break;
    case '\\>':
    case '\\<':
    case '\\cresc':
    case '\\dim':
    case '\\decresc':
      dynamic =  Dynamic.ramp;
      break;
  }
  //print('Leaving DynamicParser returning value $dynamic');
  return dynamic;
});
