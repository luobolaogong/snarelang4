import 'package:petitparser/petitparser.dart';

enum Dynamic {
  ppp,
  pp,
  p,
  mp,
  mf,
  fff,
  ff,
  f,
//  dim,
//  decresc,
//  cresc,
  scale
}
int toVelocity(Dynamic dynamic) {
  var velocity = 0;
  switch (dynamic) {
    case Dynamic.ppp:
      velocity = 16;
      break;
    case Dynamic.pp:
      velocity = 33;
      break;
    case Dynamic.p:
      velocity = 49;
      break;
    case Dynamic.mp:
      velocity = 64;
      break;
    case Dynamic.mf:
      velocity = 80;
      break;
    case Dynamic.f:
      velocity = 96;
      break;
    case Dynamic.ff:
      velocity = 112;
      break;
    case Dynamic.fff:
      velocity = 127; // no room for accents?
      break;
    case Dynamic.scale:
      break;
  }
  return velocity;
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
      dynamic =  Dynamic.scale;
      break;
  }
  //print('Leaving DynamicParser returning value $dynamic');
  return dynamic;
});
