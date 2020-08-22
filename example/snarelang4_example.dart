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



//// What?  Are these the initial default values if not specified either on command line or in the files?
//var tempoOverrideBpm = 82;
//var numerator = 4;
//var denominator = 4;
//var nominalVolume = 70;
////var nominalVolume = 50;

void main(List<String> arguments) {


  //
  // Set up logging
  //
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  final log = Logger('MyParser');

  // tempo is something that should be provided in the text score.
  // But if specified on the command line, it should be considered an override.
  // But if not in the score and not on the command line, then there should be a default value.
  // So, we've got "textScoreTempo", "commandLineTempo", and "defaultTempo"
  //

// What?  Are these the initial default values if not specified either on command line or in the files?
  int overrideTempo; // deliberately null
  var defaultTempo = 82;
  const commandLineTempo = 'tempo';

  Dynamic overrideDynamic; // deliberately null
  Dynamic defaultDynamic = Dynamic.mf;
  const commandLineDynamic = 'dynamic';

  TimeSig overrideTimeSig; // deliberately null
  TimeSig defaultTimeSig = TimeSig();
  defaultTimeSig.numerator = 4;
  defaultTimeSig.denominator = 4;
  const commandLineTimeSig = 'sig';

//  var numerator = 4;
//  var denominator = 4;
//  var nominalVolume = 70;
////var nominalVolume = 50;

  //
  // Handle command line args/options/flags
  // * list of tunes/pieces, p or f
  // * name out output midi, m
  // * tempo/bpm, t
  // * output volume???, (secret) v
  //
  const inFilesList = 'input';
//  const inPiecesList = 'pieces'; // get rid of this later
//  const inFilesList = 'files';
  const outMidiFilesPath = 'midi';
  const help = 'help';
  //const signature = 'signature';

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

//    ..addMultiOption(inPiecesList,
//        abbr: 'p', // or 'i'
//        help:
//        'List as many input SnareLang input pieces/files you want, separated by commas, without spaces.',
//        valueHelp: '<path1>,<path2>,...')
//    ..addMultiOption(inFilesList,
//        abbr: 'f', // or 'i'
//        help:
//        'List as many input SnareLang input files/pieces you want, separated by commas, without spaces.',
//        valueHelp: '<path1>,<path2>,...')
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
    ..addOption(commandLineTimeSig,
        abbr: 's',
        help:
        'initial/default time signature, using ratio notation like 3:4 or 4:4 or 9:8, etc',
        valueHelp: 'bpmValue')
    ..addFlag(help,
        abbr: 'h',
        negatable: false,
        help:
        'help by showing usage then exiting')
//    ..addMultiOption(signature,
//        abbr: 's',
//        help:
//            'time signature as two numbers, notes per bar followed by the type of note that gets one beat',
//        valueHelp: '3 4')
    ..addOption(outMidiFilesPath,
        abbr: 'o',
        defaultsTo: timeStampedMidiOutCurDirName,
        help:
        'This is the output midi file name and path.  Defaults to "Tune<dateAndTime>.midi"',
        valueHelp: 'midiOutPathName');
//    ..addOption(outMidiFilesPath,
//        abbr: 'm', // or 'o'
//        defaultsTo: timeStampedMidiOutCurDirName,
//        help:
//        'This is the output midi file name and path.  Defaults to "Tune<dateAndTime>.midi"',
//        valueHelp: '<midiOutPathName>');
  // how do you add a --help option?
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
//    overrideDynamic = argResults[commandLineDynamic]; // wrong
    String dynamicString = argResults[commandLineDynamic];
    overrideDynamic = toDynamic(dynamicString); // dislike global functions/methods
  }
  if (argResults[commandLineTimeSig] != null) {
    String sigWithColon = argResults[commandLineTimeSig]; // wrong
//    List<String> sigParts = sigWithColon.split(new RegExp(r'\:'));
    List sigParts = sigWithColon.split(':');
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



//  Score score = Score();
  Result result = Score.load(piecesOfMusic);

  if (result.isFailure) {
    print('Failed to parse some part of one of the scores parts, and message: ${result.message}');
    return;
  }
  Score score = result.value;
  score.applyShorthands();
  score.applyDynamics();



  final ticksPerBeat = 10080; // TODO: Put this in one place, it's in 2 files now, better than 840 or 480

  // Create Midi header
  var midi = Midi(); // I guess "midi" is already defined elsewhere
  var midiHeaderOut =  midi.fillInHeader(ticksPerBeat); // 840 ticks per beat seems good

  // Create Midi tracks
//  var tracks = midi.fillInTracks(numerator, denominator, tempoOverrideBpm, ticksPerBeat, result.value.elements, nominalVolume);
  var tracks = midi.fillInTracks(score.elements, overrideTimeSig, overrideTempo, overrideDynamic);


  // Add the header and tracks list into a MidiFile, and write it
  var midiFileOut = MidiFile(tracks, midiHeaderOut);
  var midiWriterCopy = MidiWriter();
  var midiFileOutFile = File(argResults[outMidiFilesPath]);
  midiWriterCopy.writeMidiToFile(midiFileOut, midiFileOutFile); // will crash here
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
//  // 4.     Scale the velocity accordingly (Set the velocity to that fraction of the dynamic difference)
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
