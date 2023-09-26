import 'dart:io';
import 'package:args/args.dart';
import 'package:logging/logging.dart';
import '../snarelang4.dart';

/// The idea is to define what a command line can have, and make it into a parser,
/// and then use the parser to parse the arguments which would set and store the
/// values for the fields related to the arguments, such that they could be
/// retrieved by doing a simple "get", so that references like
/// commandLing.tempoScalar would represent the value.
/// After the parser is created, and the commandline args have been processed,
/// the result of the parse is returned to the caller.  The result is what is
/// used to access the values.  The result get passed into methods, rather than
/// making it some kind of global.
class CommandLine {
  ArgParser argParser;
  ArgResults argResults;

  Tempo _tempo; // should create an object here, but without bpm?
  num _tempoScalar;
  int _nSnares;
  Track _track;
  Channel _channel;
  Dynamic _dynamic;
  TimeSig _timeSig;
  bool _loopBuzzes = false;
  bool _usePadSoundFont = false;
  List<String> _inputFilesList; // want list of Strings, or list of Files?
  String _outputMidiFile; // not a File?

  static final dynamicMapIndex = 'dynamic'; // -d
  static final helpMapIndex = 'help'; // -h
  static final logLevelMapIndex = 'log'; // -l
  static final loopBuzzesMapIndex = 'loopbuzzes'; // seems not to work.  Forget until fix soundFont for Roll
  static final inputFileListMapIndex = 'input'; // -i  --input
  static final outputMidiFilePathMapIndex = 'midiout'; // -o --output  --outmidi
  static final trackMapIndex = 'track'; // -s --track --stave --part --instrument
  static final channelMapIndex = 'channel'; // -c --channel --chan --program
  static final tempoMapIndex = 'tempo'; // -t, --tempo
  static final tempoScalarMapIndex = 'temposcalar'; // -S? --ts --temposcalar
  static final nSnaresMapIndex = 'nSnares'; // --ns --nsnares
  static final timeSigMapIndex = 'timesig'; // --timesig --sig
  static final usePadSoundFontMapIndex = 'usepad'; // --pad  Does this work?  Don't think so.

  List<String> get inputFilesList {
    return _inputFilesList;
  }
  String get outputMidiFile {
    return _outputMidiFile;
  }
  Tempo get tempo {
    return _tempo;
  }
  num get tempoScalar {
    return _tempoScalar;
  }
  int get nSnares {
    return _nSnares;
  }
  Track get track {
    return _track;
  }
  Channel get channel {
    return _channel;
  }
  Dynamic get dynamic {
    return _dynamic;
  }
  TimeSig get timeSig {
    return _timeSig;
  }
  bool get loopBuzzes {
    return _loopBuzzes;
  }
  bool get usePadSoundFont {
    return _usePadSoundFont;
  }

  // ArgResults get argResults { // I think this overwrites the built in thing
  //   return argResults;
  // }


  ArgResults parseCommandLineArgs(List<String> arguments) {
    var parser = CommandLine.createCommandLineParser();
    //
    // Now try parsing using that parser, and return the ArgResults object, but also do a little
    // checking on the return result, and set logging.
    //
    //ArgResults argResults;
    try {
      argResults = parser.parse(arguments);
    }
    catch (exception) {
      print('Usage:\n${parser.usage}');
      print('${exception}  Exiting...');
      exitCode = 42; // "Process finished with exit code 43"  What's the benefit?
      //return;
      exit(exitCode);
    }
    //argResults = argResults; // new

    if (argResults.arguments.isEmpty) {
      print('No arguments provided.  Aborting ...');
      print('Usage:\n${parser.usage}');
      print(
          'Example: <thisProg> -p Tunes/BadgeOfScotlandDrums.snl,Tunes/RowanTree.snl,Tunes/ScotlandTheBraveSnare.snl --midi midifiles/BadgeSet.mid');
      exitCode = 2; // does anything?
      //return;
      exit(exitCode);
    }
    if (argResults.rest.isNotEmpty) {
      print('Command line arguments error: -->${argResults.rest}<-- Aborting ...');
      print('Usage:\n${parser.usage}');
      print(
          'Example: <thisProg> -p Tunes/BadgeOfScotlandDrums.snl,Tunes/RowanTree.snl,Tunes/ScotlandTheBraveSnare.snl --midi midifiles/BadgeSet.mid');
      exitCode = 2; // does anything?
      // return;
      exit(exitCode);
    }

    if (argResults[helpMapIndex]) {
      print('Usage:\n${parser.usage}');
      //return;
      exitCode = 0;
      exit(exitCode);
    }
    //print('track thing: ${argResults['track']}'); // this prints out whatever is the default value in the parser creator

    // Set the log level.  Guess this is special and should do it first.
    if (argResults[logLevelMapIndex] != null) {
      switch (argResults[logLevelMapIndex]) {
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
          Logger.root.level = Level.INFO;
      }
    }

    storeTheResultValues(); // Track constructor not yet called until get into this method

    return argResults;
  }

  void storeTheResultValues() {
    if (argResults[CommandLine.inputFileListMapIndex] != null) { // not sure
      _inputFilesList = [...argResults[CommandLine.inputFileListMapIndex]];
    }

    if (argResults[CommandLine.outputMidiFilePathMapIndex] != null) {
      _outputMidiFile = argResults[CommandLine.outputMidiFilePathMapIndex];
      log.fine('output file: $_outputMidiFile');
    }

    // The defaultsTo values when creating the command line parser may mess this up.  Does it?
    if (argResults[CommandLine.tempoMapIndex] != null) {
      _tempo = parseTempo(argResults[CommandLine.tempoMapIndex]); // expect either '104' (quarter note assumed) or '8:3=104'
    }
    _tempo ??= Tempo(); // new 11/25/2020  Why wasn't this done before now?

    if (argResults[CommandLine.tempoScalarMapIndex] != null) {
      _tempoScalar = num.parse(argResults[CommandLine.tempoScalarMapIndex]);
    }

    if (argResults[CommandLine.nSnaresMapIndex] != null) {
      _nSnares = num.parse(argResults[CommandLine.nSnaresMapIndex]);
    }

    if (argResults[CommandLine.trackMapIndex] != null) {
      _track = parseTrack(argResults[CommandLine.trackMapIndex]);
    }
    if (argResults[CommandLine.dynamicMapIndex] != null) {
      String dynamicString = argResults[CommandLine.dynamicMapIndex];
      _dynamic = stringToDynamic(dynamicString);
      log.finest('storeTheResultValues(), just set _dynamic to $_dynamic because either something was set on command line, or it wasnt and we just have the default value, but in any case, its set.');
    }
    if (argResults[CommandLine.timeSigMapIndex] != null) {
      String sig = argResults[CommandLine.timeSigMapIndex]; // prob default, right?  Don't really want to do it so simply.  What if sig specified before any notes in score?
      List sigParts = sig.split('/');
      _timeSig = TimeSig();
      _timeSig.numerator = int.parse(sigParts[0]);
      _timeSig.denominator = int.parse(sigParts[1]);
      Tempo.fillInTempoDuration(_tempo, _timeSig); // _tempo shouldn't be null.  And why does this return num?
      // _tempo.noteDuration.firstNumber ??= NoteDuration.DefaultFirstNumber;
      // _tempo.noteDuration.secondNumber ??= NoteDuration.DefaultSecondNumber;
    }

    if (argResults[CommandLine.loopBuzzesMapIndex]) { // how valuable is this?
      _loopBuzzes = true; // where does this get tied in?  Doesn't seem to work
    }
    if (argResults[CommandLine.usePadSoundFontMapIndex]) {  // of questionable value.  Pad is an instrument now.  Specify it, rather than override.
      _usePadSoundFont = true;
    }

  }




  static ArgParser createCommandLineParser() {
    var now = DateTime.now();
    // If no midi file given, but 1 input file given, name it same with .midi
    var timeStampedMidiOutCurDirName =
        'Tune${now.year}${now.month}${now.day}${now.hour}${now.minute}.mid';

    // Define/create the parser so you can use it later.
    var argParser = ArgParser()
      ..addMultiOption(CommandLine.inputFileListMapIndex,
          abbr: 'i',
          help:
          'List of input files/pieces, \nseparated by commas, without spaces.',
          valueHelp: 'path1,path2,...')

      ..addOption(CommandLine.outputMidiFilePathMapIndex,
          abbr: 'o',
          defaultsTo: timeStampedMidiOutCurDirName,
          help:
          'This is the output midi file name and path.  \neg: tunes/TheBrave.mid   Running now would generate "Tune<dateAndTime>.midi"',
          valueHelp: 'path')

      ..addOption(CommandLine.tempoMapIndex,
          abbr: 't',
          defaultsTo: '84', // is this smart?????????  Does it work?  Removing 11/25/2020, must account for nulls elsewhere prob
          help:
          'tempo if none specified in score (eg 64  or  8:3=84)',
          valueHelp: 'bpm or beatDuration=bpm')

      ..addOption(CommandLine.tempoScalarMapIndex,
          // abbr: 't',
          abbr: 'S', // change later.  One letter, right?  Can't use s
          // defaultsTo: '0', // string okay here?
          defaultsTo: '1.0', // string okay here?
          help:
          // 'tempo override in bpm, assuming quarter note is a beat',
          //'tempo scalar percentage.  eg: "-10" for 10% slower',
          'tempo scalar fraction.  eg: "0.90" for 10% slower',
          valueHelp: 'percent')

      ..addOption(CommandLine.nSnaresMapIndex,
          //abbr: 'ns', // change later.  One letter, right?  Can't use s
          defaultsTo: '5', // string okay here?
          help:
          'expected number of snares in a snare line, to help simulation',
          valueHelp: '1 - 9')

      ..addOption(CommandLine.dynamicMapIndex,
          abbr: 'd',
          defaultsTo: 'mf', // works???????   Hey, this is important
          allowed: ['ppp', 'pp', 'p', 'mp', 'mf', 'f', 'ff', 'fff'],
          help:
          'initial dynamic, using values like mf or f or ff, etc',
          valueHelp: 'name')

      ..addOption(CommandLine.logLevelMapIndex,
          hide: true,
          abbr: 'l',
          allowed: ['ALL', 'FINEST', 'FINER', 'FINE', 'CONFIG', 'INFO', 'WARNING', 'SEVERE', 'SHOUT', 'OFF'],
          //defaultsTo: 'OFF',
          defaultsTo: 'INFO',
          help:
          'Set the log level.  This is a hidden optionl',
          valueHelp: 'WARNING')

      ..addOption(CommandLine.trackMapIndex, // prob should also allow --stave and --track
          //allowed: ['snare', 'snare1', 'snare2', 'snare3', 'snare4', 'snare5', 'snare6', 'snare7', 'snare8', 'snare9' 'tenor', 'bass', 'metronome', 'met', 'pipes', 'tempo'], // tempo?  what about trackzero?  those hold events
          allowed: ['snare', 'tenor', 'bass', 'metronome', 'met', 'pipes', 'tempo'], // pad?  tempo?  what about trackzero?  those hold events
          defaultsTo: 'snare', // I think this is the reason we get a value!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1 without a constructor
          help:
          'Set the staff/stave/instrument/track name.',
          valueHelp: 'tenor')


      ..addOption(CommandLine.timeSigMapIndex, // of questionable utillity
          //abbr: 's',
          defaultsTo: '4/4', // works??????????????????????
          help:
          'initial/default time signature, like 3/4 or 4/4 or 9/8, etc',
          valueHelp: 'nBeats/notePerBeat')

    // ..addOption(CommandLine.commandLineMetronome, // of questionable utillity
    //     abbr: 'm',
    //     help:
    //     'string indicating metronome tempo and number of bars.  This is an experiment',
    //     valueHelp: 'nBars')
    // render buzzes without pulses, make them continuous, and therefore looped by the sound font
    // pipers might like that, but not snares, because we want to know how to play buzz strokes correctly.
    // This means need to have two different buzz numbers, and this flag will choose the correct one

      ..addFlag(CommandLine.loopBuzzesMapIndex,
          hide: true,
          negatable: false,
          defaultsTo: false, // right?  works?
          help:
          'if you want looped rolls choose this so that when slowed down it will still sound like a continuous roll which is good for pipers, but not snares')

      ..addFlag(CommandLine.usePadSoundFontMapIndex,
          hide: true,
          negatable: false,
          defaultsTo: false, // right? works?  Automatically defaults to false, right?
          help:
          'if you want the midi file to be a practice pad sound, specify this flag')

      ..addFlag(CommandLine.helpMapIndex,
          abbr: 'h',
          negatable: false,
          help:
          'help by showing usage then exiting');

    return argParser;
  }


  Tempo parseTempo(String noteTempoString) {
    //print('In parseTempo()');
    var tempo = Tempo();
    // var parts = tempoString.split(r'[:=]');
    var noteTempoParts = noteTempoString.split('=');
    if (noteTempoParts.length == 1) {
      tempo.bpm = int.parse(noteTempoParts[0]);
      //tempo.noteDuration.firstNumber = 4; // this is already done in Tempo constructor and possibly in command line parser defaultsTo
      //tempo.noteDuration.secondNumber = 1;
    }
    else if (noteTempoParts.length == 2) {
      var noteParts = noteTempoParts[0].split(':');
      tempo.noteDuration.firstNumber = int.parse(noteParts[0]);
      tempo.noteDuration.secondNumber = int.parse(noteParts[1]);
      tempo.bpm = int.parse(noteTempoParts[1]); // wrong of course
    }
    else {
      log.severe('Failed to parse tempo correctly: -->$noteTempoString<--');
    }
    //print('parseTempo is returning tempo: $tempo');  check to insure duration f and s are not null here????
    return tempo;
  }

  Track parseTrack(String trackString) {
    var track = Track();
    track.id = trackStringToId(trackString);
    return track;
  }


}
