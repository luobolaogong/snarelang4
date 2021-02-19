import 'dart:math';
import 'package:petitparser/petitparser.dart';
import 'package:logging/logging.dart';

final log = Logger('Dynamic');

///
/// New 8/24/23.  Changing Dynamic so that it's only the dynamic names, and not
/// hairpin cressc, decresc, and dim.  Those will be termed 'dynamicRamps'.
///
/// Dynamic markings in the text version, such as f, and fff apply to the notes
/// following it.  Likewise, DynamicRamp marks apply to notes following it and apply to
/// all notes prior to the next Dynamic mark.
///
/// The code does not account for errors, such as hitting another dynamicRamp marker
/// before hitting another dynamic marker, or hitting the end of the score.
/// I suppose if two hairpins were next to each other, like <> or >< then
/// you could perhaps guess what the missing dynamic would be, but for now will
/// just ignore all dynamicRamps until hit the next Dynamic marker.  If there isn't
/// one, then the DynamicRamp marker doesn't get its full value, and we should ignore
/// it when determining velocities.  So, just ignore DynamicRamps that don't have a slope.
///
/// 10/24/2020 Adding default dynamic, because some scores don't specify any dynamics
/// but have crescendos in the score, expecting the player to know what dynamic ranges
/// work in the environment.  When not specified, the default has been mf, but the
/// user can specify a starting dynamic on the command line to overwrite the default.
/// As a shorthand, in the score I could create a new dynamic marker, like '/dd' to
/// mean "return to the default dynamic, whatever that is".  This is not the most
/// recent dynamic.  It's the default value, which would be /mf if the user didn't
/// overwrite it.
class DynamicRamp {
  Dynamic startDynamic; // perhaps should store as velocity?
  Dynamic endDynamic;
  int startVelocity;
  int endVelocity;
  int totalTicksStartToEnd;
  num slope;

  @override
  String toString() {
    return 'DynamicRamp: startDynamic: $startDynamic, endDynamic: $endDynamic, startVelocity: $startVelocity, endVelocity: $endVelocity, totalTicksStartToEnd: $totalTicksStartToEnd, Slope: $slope';
  }
}

// Probably should change this to be a class, then can add other things like
// default dynamic.  Maybe, maybe not.  be careful
enum Dynamic {
  ppp,
  pp,
  p,
  mp,
  mf,
  f,
  ff,
  fff,
  dd
}


// Let's maybe just use the parabolic equation
// velocity = 1.7 * dynamic^2 + 5
int dynamicToVelocity(Dynamic dynamic) {
  if (dynamic == Dynamic.dd) {
    print('stop here, do we want to use a Dynamic.dd for a value to convert?');
  }
  // parabolic2
  num newVelocity = (10 * 0.19 * (dynamic.index + 1) * (dynamic.index + 1)).round();
  log.finest('\t\t\t\tdynamic $dynamic, with index ${dynamic.index} gets a velocity of ${newVelocity}');
  return newVelocity;

  // Parabolic1:
  // num newVelocity = (20 * (3.0 * sin(((pi / 2) * (dynamic.index+1) - 6.3)/4.0) + 3.0)).round();
  // print('\t\t\t\tHey, dynamic $dynamic, with index ${dynamic.index} gets a velocity of ${newVelocity}');
  // return newVelocity;
  // //return (1.7 * dynamic.index * dynamic.index + 5).round();
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
// All of these tokens map down into a single DynamicRamp object, but all its fields are null
Parser dynamicRampParser = (
    string('/>') |
    string('/<') |
    string('/dim') |
    string('/decresc') |
    string('/cresc')
).trim().map((value) {
  log.finest('In dynamicRampParser, and the value was $value');
  DynamicRamp dynamicRamp;
  switch (value) {
    case '/>':
    case '/<':
    case '/cresc':
    case '/dim':
    case '/decresc':
      dynamicRamp =  DynamicRamp();
      break;
  }
  log.finest('Leaving dynamicRampParser returning a DynamicRamp object $dynamicRamp');
  return dynamicRamp;
});

///
/// DynamicParser
/// /dd means use the default dynamic, which is the one from the command line.  But
/// this is a problem when a file has more than one /track per file, or multiple tracks on a
/// command line, because snare and bass tracks may have been recorded at different volumes.  So
/// maybe allow a "definition", as in "/dd=ff" whereafter "/dd" would mean "/ff".
/// I should probably do something like that.  But also dynamics should probably also
/// be relative, as in /+1 or /-2 or something like that, so that it all depends on
/// what you start with.  Maybe do this stuff later.
///
Parser dynamicParser = (
    string('/mf') |
    string('/mp') |
    string('/ppp') |
    string('/pp') |
    string('/p') |
    string('/fff') |
    string('/ff') |
    string('/f') |
    string('/dd')
).trim().map((value) { // trim?  Yes!  Makes a difference
  log.finest('In Dynamicparser');
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
    case '/dd':
      dynamic =  Dynamic.dd;
      break;
  }
  //log.info('Leaving DynamicParser returning value $dynamic');
  return dynamic;
});
