import 'dart:io';
import 'dart:math';
import 'package:args/args.dart';
import 'package:dart_midi/dart_midi.dart';
import 'package:logging/logging.dart';
//import 'package:petitparser/petitparser.dart';
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
// num velocityRamp(int ctr) { // ramp is bad name
//   // return 2.3 * pow(ctr, 2) + 5;
//   // return  16 * (4.0 * sin(((pi / 2) * ctr - 6.3)/4.0) + 4.0);
//   return  20 * (3.0 * sin(((pi / 2) * ctr - 6.3)/4.0) + 3.0);
// }
void main(List<String> arguments) {
  // print('Here are the dynamics that will be used:');
  // print('Parabolic1');
  // for (var ctr = 0; ctr < 9; ctr++) {
  //   // print('${ctr} : ${velocityRamp(ctr)}');
  //   print('${ctr+1} : ${(1.7 * ctr * ctr + 5).round()}');
  // }
  // for (var dynamic in Dynamic.values) {
  //   // print('${ctr} : ${velocityRamp(ctr)}');
  //   print('${dynamic} : ${(1.7 * dynamic.index * dynamic.index + 5).round()}');
  // }
  // print('Parabolic2');
  // for (var ctr = 1; ctr < 9; ctr++) {
  //   // print('${ctr} : ${velocityRamp(ctr)}');
  //   print('${ctr} : ${(10 * 0.19 * ctr * ctr).round()}');
  // }
  // for (var dynamic in Dynamic.values) {
  //   // print('${ctr} : ${velocityRamp(ctr)}');
  //   print('${dynamic} : ${(10 * 0.19 * (dynamic.index + 1) * (dynamic.index + 1)).round()}');
  // }
  // print('Sinusoidal:');
  // for (var ctr = 0; ctr < 9; ctr++) {
  //   print('${ctr} : ${(20 * (3.0 * sin(((pi / 2) * ctr - 6.3)/4.0) + 3.0)).round()}');
  // }
  // for (var dynamic in Dynamic.values) {
  //   print('${dynamic} : ${(20 * (3.0 * sin(((pi / 2) * (dynamic.index+1) - 6.3)/4.0) + 3.0)).round()}');
  // }
  // print('Linear:');
  // for (var ctr = 0; ctr < 9; ctr++) {
  //   print('${ctr} : ${(20 * (3.0 * sin(((pi / 2) * ctr - 6.3)/4.0) + 3.0)).round()}');
  // }
  // for (var dynamic in Dynamic.values) {
  //   print('${dynamic} : ${(20 * (3.0 * sin(((pi / 2) * (dynamic.index+1) - 6.3)/4.0) + 3.0)).round()}');
  // }




  print('Staring snl ...');
  // var usePadSoundFont = false;
  // var loopBuzzes = false; // this is not working currently with "roll" R
  //
  // Set up logging.  Does this somehow apply to all files?
  //
  // Logger.root.level = Level.ALL; // get this from the command line, as a secret setting
  Logger.root.level = Level.INFO; // get this from the command line, as a secret setting
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  final log = Logger('MyParser');

  //
  // Parse the command line arguments
  //
  var commandLine = CommandLine();
  var argResults = commandLine.parseCommandLineArgs(arguments);

  log.fine('Files to be processed: ${commandLine.inputFilesList}');

  var score = doThePhases(commandLine.inputFilesList, commandLine); // Maybe use tempoScalar to handle gracenote calculations

  // Create Midi header
  var midi = Midi(); // I guess "midi" is already defined elsewhere
  // var midiHeaderOut = MidiHeader(ticksPerBeat: ticksPerBeat, format: 1, numTracks:2); // puts this in header with prop "ppq"  What would 2 do?

  var midiHeader =  midi.createMidiHeader(); // 840 ticks per beat seems good

  // Create Midi tracks.
  var midiTracks = <List<MidiEvent>>[];

  // // What?  We really don't need to do this?  Makes no difference?
  // var timingTrackZero = midi.createTimingTrackZero(score.elements, commandLine);
  // midiTracks.add(timingTrackZero);

  // We do want to add the events to the tracks before sending the tracks to the MidiFile/Writer,
  // but what happened to the processing phases before that?
  //
  midi.addMidiEventsToTracks(midiTracks, score.elements, commandLine);

  // Add the header and tracks list into a MidiFile, and write it
  var midiFile = MidiFile(midiTracks, midiHeader);
  var midiWriterCopy = MidiWriter();

  var midiFileOutFile = File(commandLine.outputMidiFile);
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

Score doThePhases(List<String> piecesOfMusic, CommandLine commandLine) {
  log.fine('In doThePhases, and tempo coming in from commandLine tempo is ${commandLine.tempo} and dynamic is ${commandLine.dynamic}');
  //
  // Phase 1: load and parse the score, returning the Score, which contains a list of all elements, as PetitParser parses and creates them.
  // There is no processing of the elements put into the list.
  //
  var result = Score.loadAndParse(piecesOfMusic, commandLine);

  if (result.isFailure) {
    log.severe('Failed to parse the scores. Message: ${result.message}');
    var rowCol = result.toPositionString().split(':');
    log.severe('Check line ${rowCol[0]}, character ${rowCol[1]}');
    log.severe('Should be around this character: ${result.buffer[result.position]}');
    exit(42);
  }
  // Since parsing succeeded, we should have the Score element in the result value
  Score score = result.value;

  //
  // Phase 2:
  // Apply shorthands to the list, meaning fill in the blanks that are in the raw list, including Dynamics.
  // And this would include replacing default dynamics (/dd) with the default dynamic value set on commandline or whatever the default is.
  score.applyShorthands(commandLine);
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

  // What if there's no /tempo given in a file and no -t value specified on command line?  We still need
  // to put a tempoEvent in the midi output
  log.finer('doThePhases(), adding  a few elements at the start, like timesig and tempo, before adjusting for grace notes.');
  log.finest('doThePhases(), tempo to use for adding a couple events at the start, is ${commandLine.tempo} which WILL NOT be scaled next.');

  // Maybe should keep trackof initial timeSig and tempo, from command line or first in the file.  Really, it should be at the head of the file
  // to know how to do notes.  and every time you hit a /tempo mark, use the latest /timesig value, not the one from the command line.
  // Tempo.fillInTempoDuration(commandLine.tempo, commandLine.timeSig); // just a test.  There's no guarantee commandLine.timeSig or tempo will have values that represent what's in the file

  score.correctTripletTempos(commandLine);
  // maybe don't need to do the following two lines if correct tempos above, but probably do
  score.elements.insert(0, commandLine.tempo); // yes in this order     I dislike writing a tempo and timeSig if another pair are coming right after it.
  score.elements.insert(0, commandLine.timeSig);
  log.finer('Added elements ${commandLine.timeSig}, ${commandLine.tempo} to head of list of elements.');

// Actually should have a separate phase that only adjusts all Tempo elements by the scalar.  Then do the grace notes.
  if (commandLine.tempoScalar != 1.0) { // new 11/25/2020
    score.scaleTempos(commandLine);
  }


  // Phase 5:
  // Do grace notes
  score.adjustForGraceNotes(commandLine); // maybe do this similar to how applyShorthands is done

  return score;
}


// expect either '104' (quarter note assumed) or '8:3=104'
// Probably won't use this in the future
Tempo parseTempo(String noteTempoString) {
  var tempo = Tempo();
  // var parts = tempoString.split(r'[:=]');
  var noteTempoParts = noteTempoString.split('=');
  if (noteTempoParts.length == 1) {
    tempo.bpm = int.parse(noteTempoParts[0]);
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
  print("parseTempo is returning tempo: $tempo");
  return tempo;
}
