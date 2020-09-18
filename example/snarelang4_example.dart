// import 'package:snarelang4/snarelang4.dart';
// import 'package:petitparser/petitparser.dart';
// import 'dart:io';
//
// import 'package:args/args.dart';
// import 'package:dart_midi/dart_midi.dart';
// import 'package:logging/logging.dart';
//
// /// Should rename this file to "snl.dart" perhaps, and it should NOT be in the example area.  Maybe in bin dir
// ///
// /// Take a look at WebAudioFont  https://github.com/surikov/webaudiofont
// /// which is a JavaScript thing so that you can play midi in a web page.
// /// Also, study this: https://github.com/truj/midica
// /// which appears to be a Java app that has an interface but can be command line.
// ///
// /// This is good for doing new Dart things: https://dart.dev/codelabs/dart-cheatsheet
//
//
// void main(List<String> arguments) {
//
//
//   //
//   // Set up logging.  Does this somehow apply to all files?
//   //
//   // Logger.root.level = Level.ALL; // get this from the command line, as a secret setting
//   Logger.root.level = Level.WARNING; // get this from the command line, as a secret setting
//   Logger.root.onRecord.listen((record) {
//     print('${record.level.name}: ${record.time}: ${record.message}');
//   });
//   final log = Logger('MyParser');
//
//
//   // 'override' is probably wrong.  I don't think we override anything in the score.  If the score
//   // says tempo is 60, then we're not going to override it to something else.  Same with dynamics
//   // or time signature.  We can have default values, and the user can set values on the command line,
//   // which would override the default values, but we're not overriding what's in the score.
//   // So, this next section should be reviewed, and at least change 'override' to 'fromCommandLine'
//   // int overrideTempo; // deliberately null.  Perhaps change name to commandLineTempo, and change other to commandLineTempoIndexName
//   Tempo overrideTempo; // deliberately null.  Perhaps change name to commandLineTempo, and change other to commandLineTempoIndexName
//   // var defaultTempo = 84;
//   var defaultTempo = Tempo(); // 84;
//   // defaultTempo.noteDuration = NoteDuration(); // allow for null/unspecified
//   // defaultTempo.noteDuration.firstNumber = 4;
//   // defaultTempo.noteDuration.secondNumber = 1;
//   defaultTempo.bpm = 84;
//   const commandLineTempo = 'tempo'; // change to commandLineTempoIndexName
//
//   Dynamic overrideDynamic; // deliberately null
//   Dynamic defaultDynamic = Dynamic.mf;
//   const commandLineDynamic = 'dynamic';
//
//   TimeSig overrideTimeSig; // deliberately null
//   var defaultTimeSig = TimeSig();
//   defaultTimeSig.numerator = 4;
//   defaultTimeSig.denominator = 4;
//   const commandLineTimeSig = 'sig';
//
//   const inFilesList = 'input';
//   const outMidiFilesPath = 'midi';
//   const help = 'help';
//
//   var now = DateTime.now();
//   ArgResults argResults;
//   // If no midi file given, but 1 input file given, name it same with .midi
//   var timeStampedMidiOutCurDirName =
//       'Tune${now.year}${now.month}${now.day}${now.hour}${now.minute}.midi';
//   final parser = ArgParser()
//     ..addMultiOption(inFilesList,
//         abbr: 'i',
//         help:
//         'List as many input SnareLang input files/pieces you want, separated by commas, without spaces.',
//         valueHelp: 'path1,path2,...')
//     ..addOption(commandLineTempo,
//         abbr: 't',
//         help:
//         'tempo override in bpm, assuming quarter note is a beat',
//         valueHelp: 'bpmValue')
//     ..addOption(commandLineDynamic,
//         abbr: 'd',
//         allowed: ['ppp', 'pp', 'p', 'mp', 'mf', 'f', 'ff', 'fff'],
//         help:
//         'initial/default dynamic, using values like mf or f or ff, etc',
//         valueHelp: 'bpmValue')
//     ..addOption(commandLineTimeSig, // of questionable utillity
//         abbr: 's',
//         help:
//         'initial/default time signature, like 3/4 or 4/4 or 9/8, etc',
//         valueHelp: 'bpmValue')
//     ..addFlag(help,
//         abbr: 'h',
//         negatable: false,
//         help:
//         'help by showing usage then exiting')
//     ..addOption(outMidiFilesPath,
//         abbr: 'o',
//         defaultsTo: timeStampedMidiOutCurDirName,
//         help:
//         'This is the output midi file name and path.  Defaults to "Tune<dateAndTime>.midi"',
//         valueHelp: 'midiOutPathName');
//   argResults = parser.parse(arguments);
//
//   if (argResults.rest.isNotEmpty) {
//     print('Ignoring command line arguments: -->${argResults.rest}<-- and aborting ...');
//     print('Usage:\n${parser.usage}');
//     print(
//         'Example: <thisProg> -p Tunes/BadgeOfScotland.snl,Tunes/RowanTree.snl,Tunes/ScotlandTheBrave.snl --midi midifiles/BadgeSet.mid');
//     exitCode = 2; // does anything?
//     return;
//   }
//
//   if (argResults[help]) {
//     print('Usage:\n${parser.usage}');
//     return;
//   }
//
//   if (argResults[commandLineTempo] != null) {
//     // overrideTempo = int.parse(argResults[commandLineTempo]);
//     overrideTempo.bpm = int.parse(argResults[commandLineTempo]);
//   }
//   if (argResults[commandLineDynamic] != null) {
//     String dynamicString = argResults[commandLineDynamic];
//     overrideDynamic = stringToDynamic(dynamicString); // dislike global functions/methods
//   }
//   if (argResults[commandLineTimeSig] != null) {
//     String sig = argResults[commandLineTimeSig]; // expecting num/denom
//     List sigParts = sig.split('/');
//     overrideTimeSig = TimeSig();
//     overrideTimeSig.numerator = int.parse(sigParts[0]);
//     overrideTimeSig.denominator = int.parse(sigParts[1]);
//   }
//   // scan score elements for initial timesig numerator and denominator, if specified???????????????????
//   overrideDynamic ??= defaultDynamic;
//   overrideTempo ??= defaultTempo;
//   overrideTimeSig ??= defaultTimeSig;
//
//   // Since allow for different args to do same thing, combine them.
// //  List<String> piecesOfMusic = [...argResults[inPiecesList], ...argResults[inFilesList]]; // can't change to var
//   List<String> piecesOfMusic = [...argResults[inFilesList]]; // can't change to var
//
//   // What are the phases?
//   // 1.  Parse the score text, creating a List of raw score elements; no note dynamics, velocities, or ticks.
//   // 2.  Apply shorthands so that each note has full note property values including dynamic, and no "." notes,
//   //     and notes should have no velocities or ticks.  (or maybe they do have dynamics)
//   // 3.  Scan the elements list for dynamicRamp markers,
//   // 4.  Go through the elements and set velocities based on dynamics and dynamicRamps
// //Result testResult = timeSigParser.parse('/time 3/4');
// //print(testResult);
//
//   Result result = Score.load(piecesOfMusic);
//
//   if (result.isFailure) {
//     log.severe('Failed to parse the scores. Message: ${result.message}');
//     var rowCol = result.toPositionString().split(':');
//     log.severe('Check line ${rowCol[0]}, character ${rowCol[1]}');
//     log.severe('Should be around this character: ${result.buffer[result.position]}');
// //    log.info('^'.padLeft(result.position));
//     return;
//   }
//   Score score = result.value;
//
//   // New
//   var defaultFirstNoteProperties = Note();
//   defaultFirstNoteProperties.duration.firstNumber = 4;
//   defaultFirstNoteProperties.duration.secondNumber = 1;
//   defaultFirstNoteProperties.noteType = NoteType.leftTap; // ???
//   defaultFirstNoteProperties.dynamic = overrideDynamic; // new
//
//
//   //
//   // Apply shorthands to the list, meaning fill in the blanks that are in the raw list, including Dynamics.
//   //
//   score.applyShorthands(defaultFirstNoteProperties);
//   for (var element in score.elements) {
//     log.finer('After shorthand phase: $element');
//   }
//
//   score.applyDynamics();
//
//   // Create Midi header
//   var midi = Midi(); // I guess "midi" is already defined elsewhere
//   var midiHeader =  midi.createMidiHeader(); // 840 ticks per beat seems good
//
//   // Create Midi tracks.  This overrideTempo thing, and probably also TimeSig and Dynamic don't make sense.  These should probably be 'default' values
//   // next line should have overrideTempo be a Tempo, not an int
//   var midiTracks = midi.createMidiEventsTracksList(score.elements, overrideTimeSig, overrideTempo, overrideDynamic);
//
//
//   // Add the header and tracks list into a MidiFile, and write it
//   var midiFile = MidiFile(midiTracks, midiHeader);
//   var midiWriterCopy = MidiWriter();
//   var midiFileOutFile = File(argResults[outMidiFilesPath]);
//   midiWriterCopy.writeMidiToFile(midiFile, midiFileOutFile); // will crash here
//   print('Done writing midifile ${midiFileOutFile.path}');
// }
//
