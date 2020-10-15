import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_midi/dart_midi.dart';
import 'package:logging/logging.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snarelang4/snarelang4.dart';

/// Rename this project to RhythmAnalyst.  This isn't just about a language, and
/// not just about snare drumming.
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
/// Just learned something: Rosegarden (linux only) is a pretty good midi player.  It can loop and load a
/// sound font.  The tricky thing was that I needed to have QSynth up and working in order to hear the
/// result, and maybe I needed to tell it too about the sound font.  Probably only need to do it on qsynth.
/// Shouldn't need both.  Like VLC doesn't need qsynth.
///
const commandLineTempoScale = 'tempo'; // change to commandLineTempoIndexName
const commandLineStaff = 'staff';
const commandLineDynamic = 'dynamic';
const commandLineTimeSig = 'time';
const inFilesList = 'input';
const outMidiFilesPath = 'midi';
const commandLineLogLevel = 'loglevel';
const help = 'help';
const commandLineContinuousSustainedLoopedBuzzes = 'loopbuzzes'; // seems not to work.  Forget until fix soundFont for Roll
const commandLineUsePadSoundFont = 'pad';


// This is way too long.  Fix.
void main(List<String> arguments) {
  print('Staring snl ...');
  var usePadSoundFont = false;
  var loopBuzzes = false; // this is not working currently with "roll" R
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
  defaultTempo.noteDuration.firstNumber = 4; // put this in the constructor for NoteDuration??????????????????????????????
  defaultTempo.noteDuration.secondNumber = 1; // Seems things work if I initialize here rather than in NoteDuration.  Dunno why.

  var defaultStaff = Staff(); // helpful?
  defaultStaff.id = StaffId.snare;

  defaultTempo.bpm = 84;
  var defaultTimeSig = TimeSig();
  defaultTimeSig.numerator = 4;
  defaultTimeSig.denominator = 4;

//  Tempo overrideTempo; // deliberately null.  Perhaps change name to commandLineTempo, and change other to commandLineTempoIndexName
  num tempoScalar;
  TimeSig overrideTimeSig; // deliberately null
  Dynamic overrideDynamic; // deliberately null.  Right?
  Staff overrideStaff; // need?
  int nBarsMetronome;
  //
  // Parse the command line arguments
  //
  final argResults = parseCommandLineArgs(arguments);

  if (argResults[commandLineTempoScale] != null) { // should perhaps be a scaling factor.  default maybe at 84 if not specified in score
    // tempoScale = parseTempo(argResults[commandLineTempoScale]); // expect either '104' (quarter note assumed) or '8:3=104'
    tempoScalar = num.parse(argResults[commandLineTempoScale]);
    // overrideTempo = parseTempo(argResults[commandLineTempoScale]); // expect either '104' (quarter note assumed) or '8:3=104'
    print('defaultTempo.bpm is ${defaultTempo.bpm}');
    Tempo.scaleThis(defaultTempo, tempoScalar);
  }

  if (argResults[commandLineStaff] != null) {
    overrideStaff = parseStaff(argResults[commandLineStaff]);
  }
  if (argResults[commandLineDynamic] != null) { // this should be a scaling factor.  The default should be mf  but we may want to scale all dynamics by some value/scalar
    String dynamicString = argResults[commandLineDynamic];
    overrideDynamic = stringToDynamic(dynamicString); // dislike global functions/methods.  Does this update the param??????????????
  }
  if (argResults[commandLineTimeSig] != null) { // this is strange.  Prob should remove.  Should be specified in score.  Default should be 4/4 or 2/4.
    String sig = argResults[commandLineTimeSig]; // expecting num/denom
    List sigParts = sig.split('/');
    overrideTimeSig = TimeSig();
    overrideTimeSig.numerator = int.parse(sigParts[0]);
    overrideTimeSig.denominator = int.parse(sigParts[1]);
  }
  // if (argResults[commandLineMetronome] != null) { // this is for the metronome track, right?  Experimental
  //   nBarsMetronome = int.parse(argResults[commandLineMetronome]);
  // }

  if (argResults[commandLineContinuousSustainedLoopedBuzzes]) { // how valuable is this?
    print('Hmmmm, got this flag for looping buzzes');
    loopBuzzes = true; // where does this get tied in?  Doesn't seem to work
  }
  //var something = argResults[commandLineUsePadSoundFont];
  if (argResults[commandLineUsePadSoundFont]) {  // of questionable value.  Pad is an instrument now.  Specify it, rather than override.
    print('Want to use pad, eh?');
    usePadSoundFont = true;
  }

  overrideDynamic ??= defaultDynamic; // check check check check check.  And does this update the param coming in?
//  overrideTempo ??= defaultTempo; // scan score first?
  overrideStaff ??= defaultStaff;
  overrideTimeSig ??= defaultTimeSig; // scan score first?

  List<String> piecesOfMusic = [...argResults[inFilesList]]; // can't change to var.  Why?

  // var score = doThePhases(piecesOfMusic, overrideDynamic, overrideTimeSig, overrideTempo);
  //
  // There are different phases that the transformation takes.
  // To make this method shorter, I separated out those phases from this method.
  // Rename this later, and restructure it.
  var score = doThePhases(piecesOfMusic);




  // This sets up "override" values, before calling addMidiEventsToTracks, but not sure why.
  var firstTimeSigInScore = score.scanForFirstTimeSig();
  var firstTempoInScore = score.scanForFirstTempo();
  // One or the other or both those objects may be null, if not specified in the file.  But if either are specified, then we should use them to create the first
  // track's time sig and/or tempo
  if (firstTimeSigInScore != null) {
    overrideTimeSig = firstTimeSigInScore;
  }
  // if (firstTempoInScore != null) {
  //   overrideTempo = firstTempoInScore;
  // }

  // Watch out, this is pretty much duplicate code in another place, and it's probably wrong here, 'cause slightly different
  // High chance this is faulty code in this area.

  // Tempo.fillInTempoDuration(overrideTempo, overrideTimeSig);

  overrideTimeSig ??= defaultTimeSig;
  // overrideTempo ??= defaultTempo;
  overrideDynamic ??= defaultDynamic;
  overrideStaff ??= defaultStaff;


  // Now do some Midi stuff

  // Create Midi header
  var midi = Midi(); // I guess "midi" is already defined elsewhere
  // var midiHeaderOut = MidiHeader(ticksPerBeat: ticksPerBeat, format: 1, numTracks:2); // puts this in header with prop "ppq"  What would 2 do?

  var midiHeader =  midi.createMidiHeader(); // 840 ticks per beat seems good

  // Create Midi tracks.
  var midiTracks = <List<MidiEvent>>[];

  // What?  We really don't need to do this?  Makes no difference?
  // var timingTrackZero = midi.createTimingTrackZero(score.elements, overrideTimeSig, overrideTempo);
  // midiTracks.add(timingTrackZero);

  // We do want to add the events to the tracks before sending the tracks to the MidiFile/Writer,
  // but what happened to the processing phases before that?
  //
  midi.addMidiEventsToTracks(midiTracks, score.elements, tempoScalar, overrideTimeSig, usePadSoundFont, loopBuzzes, overrideStaff);
  // midi.addMidiEventsToTracks(midiTracks, score.elements, overrideTimeSig, usePadSoundFont, loopBuzzes, overrideStaff);


  // Add the header and tracks list into a MidiFile, and write it
  var midiFile = MidiFile(midiTracks, midiHeader);
  var midiWriterCopy = MidiWriter();

  const outMidiFilesPath = 'midi'; // fix later.  This shouldn't be here.  It's below

  var midiFileOutFile = File(argResults[outMidiFilesPath]);
  midiWriterCopy.writeMidiToFile(midiFile, midiFileOutFile); // will crash here
  print('Done writing midifile ${midiFileOutFile.path}');
}


// What are the phases?
// 1.  Parse the score text, creating a List of raw score elements; no note dynamics, velocities, or ticks.
// 2.  Apply shorthands so that each note has full note property values including dynamic, and no "." notes,
//     and notes should have no velocities or ticks.  (or maybe they do have dynamics)
// 3.  Scan the elements list for dynamicRamp markers and set dynamics/velocities,
// 4.  Scan the elements list for tempoRamp markers,
// 5.  Go through the elements and adjust timings due to notes with grace notes.  Keep track of current tempo?  What if other tracks change tempo?
//     Probably should work on trackZero and move all tempos to it somehow and go off of it.

// Score doThePhases(List<String> piecesOfMusic, Dynamic overrideDynamic, TimeSig overrideTimeSig, Tempo overrideTempo) {
Score doThePhases(List<String> piecesOfMusic) {
  //
  // Phase 1: load and parse the score, returning the Score, which contains a list of all elements, as PetitParser parses and creates them
  //
  var result = Score.loadAndParse(piecesOfMusic); // hey, this probably parsed at least one tempo and one timesig
  // Result result = Score.load(piecesOfMusic);

  if (result.isFailure) {
    log.severe('Failed to parse the scores. Message: ${result.message}');
    var rowCol = result.toPositionString().split(':');
    log.severe('Check line ${rowCol[0]}, character ${rowCol[1]}');
    log.severe('Should be around this character: ${result.buffer[result.position]}');
//    log.info('^'.padLeft(result.position));
    // return;
    exit(42);
  }
  // Since parsing succeeded, we should have the Score element in the result value
  Score score = result.value;


  // Do we want to fix Tempo elements to make sure Duration FirstNumber and secondNumber are not null?
  // And that's based on the timesig.
  log.finer('Making sure ll timesigs have duration values');
  var defaultInitialTimeSig = TimeSig();
  defaultInitialTimeSig.numerator = 4;
  defaultInitialTimeSig.denominator = 4;
  var defaultInitialTempo = Tempo();
  defaultInitialTempo.noteDuration.firstNumber = 4;
  defaultInitialTempo.noteDuration.secondNumber = 1;
  defaultInitialTempo.bpm = 84; // check this.  Should be a default set elsewhere, perhaps when Tempo is instantiated.
  score.fixIncompleteTempos(score.elements, defaultInitialTimeSig, defaultInitialTempo);



  // Kinda strange to have this here.  Just to handle shorthand phase?  For noteType?
  // At this point we have a list of elements that comprise the score, but haven't kept track of the first
  // timesig or tempo if they were in there.  So for now create defaults for these:
  var defaultFirstNoteProperties = Note();
  defaultFirstNoteProperties.duration.firstNumber = 4;
  defaultFirstNoteProperties.duration.secondNumber = 1;
  defaultFirstNoteProperties.noteType = NoteType.tapLeft; // ???
  // defaultFirstNoteProperties.dynamic = overrideDynamic; // new    make sure has a dynamic.  If not specified, use default.
  defaultFirstNoteProperties.dynamic = Dynamic.f; // Not sure how important this is, or if it's wrong.  Wrong value?  Should have global values somewhere for these defaults;


  // Phase 2:
  // Apply shorthands to the list, meaning fill in the blanks that are in the raw list, including Dynamics.
  //
  score.applyShorthands(defaultFirstNoteProperties);
  for (var element in score.elements) {
    log.finer('After shorthand phase: $element');
  }

  // Phase 3:
  // Apply dynamics and dynamic ramps
  //
  score.applyDynamics();

  // Phase 4:
  // Apply tempo ramps
  // later

  // Phase 5:
  // Do grace notes
  score.adjustForGraceNotes(); // maybe do this similar to how applyShorthands is done

  return score;
}





// expect either '104' (quarter note assumed) or '8:3=104'
// Probably won't use this in the future
// Tempo parseTempo(String noteTempoString) {
//   var tempo = Tempo();
//   // var parts = tempoString.split(r'[:=]');
//   var noteTempoParts = noteTempoString.split('=');
//   if (noteTempoParts.length == 1) {
//     tempo.bpm = int.parse(noteTempoParts[0]);
//     tempo.noteDuration.firstNumber = 4;
//     tempo.noteDuration.secondNumber = 1;
//   }
//   else if (noteTempoParts.length == 2) {
//     var noteParts = noteTempoParts[0].split(':');
//     tempo.noteDuration.firstNumber = int.parse(noteParts[0]);
//     tempo.noteDuration.secondNumber = int.parse(noteParts[1]);
//     tempo.bpm = int.parse(noteTempoParts[1]); // wrong of course
//   }
//   else {
//     print('Failed to parse tempo correctly: -->$noteTempoString<--');
//   }
//   return tempo;
// }

Staff parseStaff(String staffString) {
  var staff = Staff();
  staff.id = staffStringToId(staffString);
  return staff;
}

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
    ..addOption(commandLineStaff, // prob should also allow --stave and --track
        allowed: ['snare', 'snareUnison', 'tenor', 'bass', 'metronome', 'met', 'pipes'],
        defaultsTo: 'snare',
        help:
        'Set the first staff name.  Defaults to snare',
        valueHelp: '--staff bass')
    ..addOption(commandLineTempoScale,
        abbr: 't',
        help:
        // 'tempo override in bpm, assuming quarter note is a beat',
        'tempo scalar percentage',
        valueHelp: '-t -10')
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
    // ..addOption(commandLineMetronome, // of questionable utillity
    //     abbr: 'm',
    //     help:
    //     'string indicating metronome tempo and number of bars.  This is an experiment',
    //     valueHelp: 'nBars')
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
        'Example: <thisProg> -p Tunes/BadgeOfScotland.snl,Tunes/RowanTree.snl,Tunes/ScotlandTheBraveSnare.snl --midi midifiles/BadgeSet.mid');
    exitCode = 2; // does anything?
    //return;
    exit(exitCode);
  }
  if (argResults.rest.isNotEmpty) {
    print('Ignoring command line arguments: -->${argResults.rest}<-- and aborting ...');
    print('Usage:\n${parser.usage}');
    print(
        'Example: <thisProg> -p Tunes/BadgeOfScotland.snl,Tunes/RowanTree.snl,Tunes/ScotlandTheBraveSnare.snl --midi midifiles/BadgeSet.mid');
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