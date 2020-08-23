import 'package:snarelang4/snarelang4.dart';
import 'package:petitparser/petitparser.dart';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_midi/dart_midi.dart';
import 'package:logging/logging.dart';

/// Should rename this file to snl perhaps.
///
/// Take a look at WebAudioFont  https://github.com/surikov/webaudiofont
/// which is a JavaScript thing so that you can play midi in a web page.
/// Also, study this: https://github.com/truj/midica
/// which appears to be a Java app that has an interface but can be command line.
///
/// This is good for doing new Dart things: https://dart.dev/codelabs/dart-cheatsheet


void main(List<String> arguments) {


  //
  // Set up logging.  Does this somehow apply to all files?
  //
  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  final log = Logger('MyParser');


  // 'override' is probably wrong.  I don't think we override anything in the score.  If the score
  // says tempo is 60, then we're not going to override it to something else.  Same with dynamics
  // or time signature.  We can have default values, and the user can set values on the command line,
  // which would override the default values, but we're not overriding what's in the score.
  // So, this next section should be reviewed, and at least change 'override' to 'fromCommandLine'
  int overrideTempo; // deliberately null
  var defaultTempo = 82;
  const commandLineTempo = 'tempo';

  Dynamic overrideDynamic; // deliberately null
  Dynamic defaultDynamic = Dynamic.mf;
  const commandLineDynamic = 'dynamic';

  TimeSig overrideTimeSig; // deliberately null
  var defaultTimeSig = TimeSig();
  defaultTimeSig.numerator = 4;
  defaultTimeSig.denominator = 4;
  const commandLineTimeSig = 'sig';

  const inFilesList = 'input';
  const outMidiFilesPath = 'midi';
  const help = 'help';

  var now = DateTime.now();
  ArgResults argResults;
  // If no midi file given, but 1 input file given, name it same with .midi
  var timeStampedMidiOutCurDirName =
      'Tune${now.year}${now.month}${now.day}${now.hour}${now.minute}.midi';
  final parser = ArgParser()
    ..addMultiOption(inFilesList,
        abbr: 'i',
        help:
        'List as many input SnareLang input files/pieces you want, separated by commas, without spaces.',
        valueHelp: 'path1,path2,...')
    ..addOption(commandLineTempo,
        abbr: 't',
        help:
        'tempo override in bpm, assuming quarter note is a beat',
        valueHelp: 'bpmValue')
    ..addOption(commandLineDynamic,
        abbr: 'd',
        allowed: ['ppp', 'pp', 'p', 'mp', 'mf', 'f', 'ff', 'fff'],
        help:
        'initial/default dynamic, using values like mf or f or ff, etc',
        valueHelp: 'bpmValue')
    ..addOption(commandLineTimeSig, // of questionable utillity
        abbr: 's',
        help:
        'initial/default time signature, like 3/4 or 4/4 or 9/8, etc',
        valueHelp: 'bpmValue')
    ..addFlag(help,
        abbr: 'h',
        negatable: false,
        help:
        'help by showing usage then exiting')
    ..addOption(outMidiFilesPath,
        abbr: 'o',
        defaultsTo: timeStampedMidiOutCurDirName,
        help:
        'This is the output midi file name and path.  Defaults to "Tune<dateAndTime>.midi"',
        valueHelp: 'midiOutPathName');
  argResults = parser.parse(arguments);

  if (argResults.rest.isNotEmpty) {
    print('Ignoring command line arguments: -->${argResults.rest}<-- and aborting ...');
    print('Usage:\n${parser.usage}');
    print(
        'Example: <thisProg> -p Tunes/BadgeOfScotland.snl,Tunes/RowanTree.snl,Tunes/ScotlandTheBrave.snl --midi midifiles/BadgeSet.mid');
    exitCode = 2; // does anything?
    return;
  }

  if (argResults[help]) {
    print('Usage:\n${parser.usage}');
    return;
  }

  if (argResults[commandLineTempo] != null) {
    overrideTempo = int.parse(argResults[commandLineTempo]);
  }
  if (argResults[commandLineDynamic] != null) {
    String dynamicString = argResults[commandLineDynamic];
    overrideDynamic = stringToDynamic(dynamicString); // dislike global functions/methods
  }
  if (argResults[commandLineTimeSig] != null) {
    String sig = argResults[commandLineTimeSig]; // expecting num/denom
    List sigParts = sig.split('/');
    overrideTimeSig = TimeSig();
    overrideTimeSig.numerator = int.parse(sigParts[0]);
    overrideTimeSig.denominator = int.parse(sigParts[1]);
  }
  // scan score elements for initial timesig numerator and denominator, if specified???????????????????
  overrideDynamic ??= defaultDynamic;
  overrideTempo ??= defaultTempo;
  overrideTimeSig ??= defaultTimeSig;

  // Since allow for different args to do same thing, combine them.
//  List<String> piecesOfMusic = [...argResults[inPiecesList], ...argResults[inFilesList]]; // can't change to var
  List<String> piecesOfMusic = [...argResults[inFilesList]]; // can't change to var



  Result result = Score.load(piecesOfMusic);

  if (result.isFailure) {
    log.info('Failed to parse the scores. Message: ${result.message}');
    var rowCol = result.toPositionString().split(':');
    log.info('Check line ${rowCol[0]}, character ${rowCol[1]}');
    log.info('Should be around this character: ${result.buffer[result.position]}');
//    log.info('^'.padLeft(result.position));
    return;
  }
  Score score = result.value;

  // New
  var defaultFirstNoteProperties = Note();
  defaultFirstNoteProperties.duration.firstNumber = 4;
  defaultFirstNoteProperties.duration.secondNumber = 1;
  defaultFirstNoteProperties.noteType = NoteType.leftTap; // ???
  defaultFirstNoteProperties.dynamic = overrideDynamic; // new

  score.applyShorthands(defaultFirstNoteProperties);



  final ticksPerBeat = 10080; // TODO: Put this in one place, it's in 2 files now, better than 840 or 480

  // Create Midi header
  var midi = Midi(); // I guess "midi" is already defined elsewhere
  var midiHeader =  midi.createMidiHeader(ticksPerBeat); // 840 ticks per beat seems good

  // Create Midi tracks
  var midiTracks = midi.createMidiEventsTracksList(score.elements, overrideTimeSig, overrideTempo, overrideDynamic);


  // Add the header and tracks list into a MidiFile, and write it
  var midiFile = MidiFile(midiTracks, midiHeader);
  var midiWriterCopy = MidiWriter();
  var midiFileOutFile = File(argResults[outMidiFilesPath]);
  midiWriterCopy.writeMidiToFile(midiFile, midiFileOutFile); // will crash here
  print('Done writing midifile ${midiFileOutFile.path}');
}



















////  var testString = '\\time 3/4 \\tempo 4=86  F \\cresc . . . ^ \\mf 16 T >8 \\ff _Z 24f ^6d \\dim . . . \\p F \\tempo 4:3=88 \\time 5/6 ';
////  var testString = '.^24Z..'; // Wow, no space delimiters nec!!!!!!  Awesome if this continues to work as new stuff is added and tested
////  var testString = '8r \\p ^24Z . . \\f ';
////  var testString = '8f9t10z';
////  var testString = '\\ppp _8f \\cresc >9t ^10z \\fff';
//var testString = '\\ppp 10 \\cresc . . . . . . . . \\fff .';
////  var testString = '8t';
//
//  print('Will try to parse -->$testString<--');
//
//
//  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  // Stuff below here should be in Score or somewhere, and all we should have here is
//  // something like 'process(testString)' which would generate a midi file
//  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//  // For now, i'll just experiment here.  Later this stuff will go in lib src files
//  Result result;
//  result = scoreParser.parse(testString);  // Should be able to just do this:   result = ScoreParser.parse(testString);
//  if (result.isFailure) {
//    print('Failed to parse -->$testString<--');
//    print('Message: ${result.message}');
//    return; //// ???????????????????????????????????????
//  }
//  Score score = result.value;
//  List scoreElements = score.elements;
//
//  // Now that we have a list of raw score elements, we need to apply
//  // shorthands by going through the list from top to bottom.  If a note
//  // is missing a duration of type, take it from the previous note.
//  //
//  // We also need to set velocities from dynamics.  Just setting
//  // a velocity based on the last dynamic static setting (like \mf)
//  // is easy and only takes one loop through the list (perhaps even
//  // the loop for doing shorthands),
//  //
//  // Doing a cresc or decresc would take a subsequent run through the list,
//  // and it takes analysis based on the timings of the notes, and not just the number of
//  // notes over the range.  So,
//  // 1.  Determine the total time duration from the start to the end,
//  // 2.  For each note
//  // 3.     calculate the percentage of the elapsed time to that note compared to the total time
//  // 4.     Ramp the velocity accordingly (Set the velocity to that fraction of the dynamic difference)
//
//
//  // Apply shorthands and absolute velocities
//  //
//
////  Note currentNote;
////  Dynamic currentDynamic;
////  var currentTimeSig = TimeSig();
////  currentTimeSig.numerator = 4;
////  currentTimeSig.denominator = 4;
////  var currentTempo = Tempo();
////  currentTempo.noteDuration.firstNumber = 4;
////  currentTempo.noteDuration.secondNumber = 1;
////  currentTempo.bpm = 84;
//
//  var previousNote = Note();
//  previousNote.dynamic = Dynamic.mf;
//  previousNote.duration.firstNumber = 4;
//  previousNote.duration.secondNumber = 1;
//  previousNote.noteType = NoteType.leftTap;
//  for (var element in scoreElements) {
//    if (element.runtimeType != Note) {
//      continue;
//    }
//    //print('    Element (note): $element');
//    Note elementNote = element;
//    elementNote.duration.firstNumber ??= previousNote.duration.firstNumber;
//    elementNote.duration.secondNumber ??= previousNote.duration.secondNumber;
//    elementNote.noteType ??= previousNote.noteType;
//    if (element.noteType == NoteType.previousNoteDurationOrType) {
//      elementNote.noteType = previousNote.noteType;
//    }
//    elementNote.dynamic ??= previousNote.dynamic;
//    elementNote.swapHands();
//
//    previousNote.duration = elementNote.duration;
//    previousNote.noteType = elementNote.noteType;
//    previousNote.dynamic = elementNote.dynamic;
//    //print('Now element (note): $element');
//  }
//
//  print('\nNow list should have had shorthands applied, but not dynamic ranges');
//  for (var element in scoreElements) {
//    print(element);
//  }
//
//
//
//}
