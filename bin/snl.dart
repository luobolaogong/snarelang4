import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_midi/dart_midi.dart';
import 'package:logging/logging.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snarelang4/snarelang4.dart';

///
/// Take a look at WebAudioFont  https://github.com/surikov/webaudiofont
/// which is a JavaScript thing so that you can play midi in a web page.
/// Also, study this: https://github.com/truj/midica
/// which appears to be a Java app that has an interface but can be command line.
///
/// This is good for doing new Dart things: https://dart.dev/codelabs/dart-cheatsheet
///
/// TODO
/// Flam/drag/ruff placement so that principle note is where it's supposed to be, and not late.
/// Add BD and tenors
/// Add metronome
/// Check absolute tempo changes
/// Add bagpipe midi (Unfortunately, http://r.fifi.free.fr/BagPipe/guide_en.htm doesn't appear to produce midi)
///
///
const commandLineTempo = 'tempo'; // change to commandLineTempoIndexName
const commandLineDynamic = 'dynamic';
const commandLineTimeSig = 'time';
const inFilesList = 'input';
const outMidiFilesPath = 'midi';
const commandLineLogLevel = 'loglevel';
const help = 'help';
const commandLineMetronome = 'met';
const commandLineContinuousSustainedLoopedBuzzes = 'loopbuzzes';
const commandLineUsePadSoundFont = 'pad';

void main(List<String> arguments) {
  print('Staring snl ...');
  var usePadSoundFont = false;
  var loopBuzzes = false;
  //
  // Set up logging.  Does this somehow apply to all files?
  //
  // Logger.root.level = Level.ALL; // get this from the command line, as a secret setting
  Logger.root.level = Level.WARNING; // get this from the command line, as a secret setting
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  final log = Logger('MyParser');

  // 'override' is probably wrong.  I don't think we override anything in the score.  If the score
  // says tempo is 60, then we're not going to override it to something else.  Same with dynamics
  // or time signature.  We can have default values, and the user can set values on the command line,
  // which would override the default values, but we're not overriding what's in the score.
  // So, this next section should be reviewed, and at least change 'override' to 'fromCommandLine'
  // int overrideTempo; // deliberately null.  Perhaps change name to commandLineTempo, and change other to commandLineTempoIndexName
  // var defaultTempo = 84;
  var defaultDynamic = Dynamic.mf;
  var defaultTempo = Tempo(); // constructor does create the NoteDuratino part.
  defaultTempo.noteDuration.firstNumber = 4;
  defaultTempo.noteDuration.secondNumber = 1;
  defaultTempo.bpm = 84;
  var defaultTimeSig = TimeSig();
  defaultTimeSig.numerator = 4;
  defaultTimeSig.denominator = 4;

  Tempo overrideTempo; // deliberately null.  Perhaps change name to commandLineTempo, and change other to commandLineTempoIndexName
  TimeSig overrideTimeSig; // deliberately null
  Dynamic overrideDynamic; // deliberately null.  Right?
  int nBarsMetronome;
  //
  // Parse the command line arguments
  //
  final argResults = parseCommandLineArgs(arguments);

  if (argResults[commandLineTempo] != null) {
    overrideTempo = parseTempo(argResults[commandLineTempo]); // expect either '104' (quarter note assumed) or '8:3=104'
  }
  if (argResults[commandLineDynamic] != null) {
    String dynamicString = argResults[commandLineDynamic];
    overrideDynamic = stringToDynamic(dynamicString); // dislike global functions/methods.  Does this update the param??????????????
  }
  if (argResults[commandLineTimeSig] != null) {
    String sig = argResults[commandLineTimeSig]; // expecting num/denom
    List sigParts = sig.split('/');
    overrideTimeSig = TimeSig();
    overrideTimeSig.numerator = int.parse(sigParts[0]);
    overrideTimeSig.denominator = int.parse(sigParts[1]);
  }
  if (argResults[commandLineMetronome] != null) { // this is for the metronome track, right?  Experimental
    nBarsMetronome = int.parse(argResults[commandLineMetronome]);
  }

  if (argResults[commandLineContinuousSustainedLoopedBuzzes]) {
    print('Hmmmm, got this flag for looping buzzes');
    loopBuzzes = true; // where does this get tied in?
  }
  var something = argResults[commandLineUsePadSoundFont];
  if (argResults[commandLineUsePadSoundFont]) {
    print('Want to use pad, eh?');
    usePadSoundFont = true;
  }

  overrideDynamic ??= defaultDynamic; // check check check check check.  And does this update the param coming in?
  overrideTempo ??= defaultTempo; // scan score first?
  overrideTimeSig ??= defaultTimeSig; // scan score first?

  //var piecesOfMusic = [...argResults[inFilesList]]; // can't change to var, why????
   List<String> piecesOfMusic = [...argResults[inFilesList]]; // can't change to var.  Why?

  // What are the phases?
  // 1.  Parse the score text, creating a List of raw score elements; no note dynamics, velocities, or ticks.
  // 2.  Apply shorthands so that each note has full note property values including dynamic, and no "." notes,
  //     and notes should have no velocities or ticks.  (or maybe they do have dynamics)
  // 3.  Scan the elements list for ramp markers,
  // 4.  Go through the elements and set velocities based on dynamics and ramps
//Result testResult = timeSigParser.parse('/time 3/4');
//print(testResult);

  var result = Score.load(piecesOfMusic); // hey, this probably parsed at least one tempo and one timesig
  // Result result = Score.load(piecesOfMusic);

  if (result.isFailure) {
    log.severe('Failed to parse the scores. Message: ${result.message}');
    var rowCol = result.toPositionString().split(':');
    log.severe('Check line ${rowCol[0]}, character ${rowCol[1]}');
    log.severe('Should be around this character: ${result.buffer[result.position]}');
//    log.info('^'.padLeft(result.position));
    return;
  }
  Score score = result.value;
  // At this point we have a list of elements that comprise the score, but haven't kept track of the first
  // timesig or tempo if they were in there.
  // New
  var defaultFirstNoteProperties = Note();
  defaultFirstNoteProperties.duration.firstNumber = 4;
  defaultFirstNoteProperties.duration.secondNumber = 1;
  defaultFirstNoteProperties.noteType = NoteType.leftTap; // ???
  defaultFirstNoteProperties.dynamic = overrideDynamic; // new    make sure has a dynamic.  If not specified, use default.


  //
  // Apply shorthands to the list, meaning fill in the blanks that are in the raw list, including Dynamics.
  //
  score.applyShorthands(defaultFirstNoteProperties);
  for (var element in score.elements) {
    log.finer('After shorthand phase: $element');
  }

  score.applyDynamics();

  var firstTimeSigInScore = score.scanForFirstTimeSig();
  var firstTempoInScore = score.scanForFirstTempo();
  // One or the other or both those objects may be null, if not specified in the file.  But if either are specified, then we should use them to create the first
  // track's time sig and/or tempo
  if (firstTimeSigInScore != null) {
    overrideTimeSig = firstTimeSigInScore;
  }
  if (firstTempoInScore != null) {
    overrideTempo = firstTempoInScore;
  }
  // overrideTimeSig ??= firstTimeSigInScore;
  // overrideTempo ??= firstTempoInScore;
  // Watch out, this is pretty much duplicate code in another place, and it's probably wrong here, 'cause slightly different
  // High chance this is faulty code in this area.
  if (overrideTempo.noteDuration.firstNumber == null || overrideTempo.noteDuration.secondNumber == null) {
    if (overrideTimeSig.denominator == 8 && overrideTimeSig.numerator % 3 == 0) { // if timesig is 6/8, or 9/8 or 12/8, or maybe even 3/8, then it should be 8:3
      overrideTempo.noteDuration.firstNumber = 8;
      overrideTempo.noteDuration.secondNumber = 3;
    }
    else {
      overrideTempo.noteDuration.firstNumber ??= overrideTimeSig.denominator; // If timeSig is anything other than 3/8, 6/8, 9/8, 12/8, ...
      overrideTempo.noteDuration.secondNumber ??= 1;
    }
  }





  // Create Midi header
  var midi = Midi(); // I guess "midi" is already defined elsewhere
  var midiHeader =  midi.createMidiHeader(); // 840 ticks per beat seems good

  // Create Midi tracks.
  overrideTimeSig ??= defaultTimeSig;
  overrideTempo ??= defaultTempo;
  overrideDynamic ??= defaultDynamic;
  var midiTracks = midi.createMidiEventsTracksList(score.elements, overrideTimeSig, overrideTempo, overrideDynamic, usePadSoundFont);

  // Now try a simple metronome track
  if (nBarsMetronome != null && nBarsMetronome > 0) { // cheap cheap cheap
    var metronomeNote = Note();
    metronomeNote.duration = NoteDuration(); // this is silly
    metronomeNote.duration.firstNumber = 4;
    metronomeNote.duration.secondNumber = 1;
    metronomeNote.velocity = 127;
    var metronomeTrack = midi.createMidiEventsMetronomeTrack(nBarsMetronome, overrideTempo, metronomeNote);
    midiTracks.add(metronomeTrack);
  }


  // Add the header and tracks list into a MidiFile, and write it
  var midiFile = MidiFile(midiTracks, midiHeader);
  var midiWriterCopy = MidiWriter();

  const outMidiFilesPath = 'midi'; // fix later.  This shouldn't be here.  It's below

  var midiFileOutFile = File(argResults[outMidiFilesPath]);
  midiWriterCopy.writeMidiToFile(midiFile, midiFileOutFile); // will crash here
  print('Done writing midifile ${midiFileOutFile.path}');
}



// expect either '104' (quarter note assumed) or '8:3=104'
Tempo parseTempo(String noteTempoString) {
  var tempo = Tempo();
  // var parts = tempoString.split(r'[:=]');
  var noteTempoParts = noteTempoString.split('=');
  if (noteTempoParts.length == 1) {
    tempo.bpm = int.parse(noteTempoParts[0]);
    tempo.noteDuration.firstNumber = 4;
    tempo.noteDuration.secondNumber = 1;
  }
  else if (noteTempoParts.length == 2) {
    var noteParts = noteTempoParts[0].split(':');
    tempo.noteDuration.firstNumber = int.parse(noteParts[0]);
    tempo.noteDuration.secondNumber = int.parse(noteParts[1]);
    tempo.bpm = int.parse(noteTempoParts[1]); // wrong of course
  }
  else {
    print('Failed to parse tempo correctly: -->$noteTempoString<--');
  }
  return tempo;
}

// ArgResults createArgParser(List<String> arguments, Tempo overrideTempo, int nBarsMetronome, Dynamic overrideDynamic, TimeSig overrideTimeSig, Dynamic defaultDynamic, Tempo defaultTempo, TimeSig defaultTimeSig) {
// ArgResults createArgParser(List<String> arguments, Dynamic defaultDynamic, Tempo defaultTempo, TimeSig defaultTimeSig) {
ArgResults parseCommandLineArgs(List<String> arguments) {
  var now = DateTime.now();
  ArgResults argResults;
  // If no midi file given, but 1 input file given, name it same with .midi
  var timeStampedMidiOutCurDirName =
      'Tune${now.year}${now.month}${now.day}${now.hour}${now.minute}.mid';

  final parser = ArgParser()
    ..addMultiOption(inFilesList,
        abbr: 'i',
        help:
        'List as many input SnareLang input files/pieces you want, separated by commas, without spaces.',
        valueHelp: 'path1,path2,...')
    ..addOption(commandLineLogLevel,
        hide: true,
        abbr: 'l',
        allowed: ['ALL', 'FINEST', 'FINER', 'FINE', 'CONFIG', 'INFO', 'WARNING', 'SEVERE', 'SHOUT', 'OFF'],
        defaultsTo: 'OFF',
        help:
        'Set the log level.  This is a hidden optionl',
        valueHelp: '-l ALL')
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
        //defaultsTo: '4/4', // do this???  Maybe, don't wanna take time now to fine out
        help:
        'initial/default time signature, like 3/4 or 4/4 or 9/8, etc',
        valueHelp: 'bpmValue')
    ..addOption(commandLineMetronome, // of questionable utillity
        abbr: 'm',
        help:
        'string indicating metronome tempo and number of bars.  This is an experiment',
        valueHelp: 'nBars')
  // render buzzes without pulses, make them continuous, and therefore looped by the sound font
  // pipers might like that, but not snares, because we want to know how to play buzz strokes correctly.
  // This means need to have two different buzz numbers, and this flag will choose the correct one
    ..addFlag(commandLineContinuousSustainedLoopedBuzzes,
        negatable: false,
        help:
        'if you want looped rolls choose this so that when slowed down it will still sound like a continuous roll which is good for pipers, but not snares')
    ..addFlag(commandLineUsePadSoundFont,
        negatable: false,
        help:
        'if you want the midi file to be a practice pad sound, specify this flag')
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
  try {
    argResults = parser.parse(arguments);
  }
  catch (exception) {
    print('Usage:\n${parser.usage}');
    print('${exception}  Exiting...');
    exitCode = 3; // "Process finished with exit code 3"
    //return;
    exit(exitCode);
  }

  if (argResults.arguments.isEmpty) {
    print('No arguments provided.  Aborting ...');
    print('Usage:\n${parser.usage}');
    print(
        'Example: <thisProg> -p Tunes/BadgeOfScotland.snl,Tunes/RowanTree.snl,Tunes/ScotlandTheBrave.snl --midi midifiles/BadgeSet.mid');
    exitCode = 2; // does anything?
    //return;
    exit(exitCode);
  }
  if (argResults.rest.isNotEmpty) {
    print('Ignoring command line arguments: -->${argResults.rest}<-- and aborting ...');
    print('Usage:\n${parser.usage}');
    print(
        'Example: <thisProg> -p Tunes/BadgeOfScotland.snl,Tunes/RowanTree.snl,Tunes/ScotlandTheBrave.snl --midi midifiles/BadgeSet.mid');
    exitCode = 2; // does anything?
    // return;
    exit(exitCode);
  }

  if (argResults[help]) {
    print('Usage:\n${parser.usage}');
    //return;
    exitCode = 0;
    exit(exitCode);
  }

  if (argResults[commandLineLogLevel] != null) {
    switch (argResults[commandLineLogLevel]) {
      case 'ALL':
        Logger.root.level = Level.ALL;
        break;
      case 'FINEST':
        Logger.root.level = Level.FINEST;
        break;
      case 'FINER':
        Logger.root.level = Level.FINER;
        break;
      case 'FINE':
        Logger.root.level = Level.FINE;
        break;
      case 'CONFIG':
        Logger.root.level = Level.CONFIG;
        break;
      case 'INFO':
        Logger.root.level = Level.INFO;
        break;
      case 'WARNING':
        Logger.root.level = Level.WARNING;
        break;
      case 'SEVERE':
        Logger.root.level = Level.SEVERE;
        break;
      case 'SHOUT':
        Logger.root.level = Level.SHOUT;
        break;
      case 'OFF':
        Logger.root.level = Level.OFF;
        break;
      default:
        Logger.root.level = Level.OFF;
    }
  }
  return argResults;
}