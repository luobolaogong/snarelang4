// import '../snarelang4.dart';
// /// I think the idea here is to be able to insert the keywords '/track pipes' or
// /// '/track tenor', ... and that track continues on as the only track being written
// /// to, until either the end of the score, or there's another /track designation.
// /// So, it's 'track <name>'
// enum TrackId {
//   met,
//   pipes,
//   pipesharmony,
//   chanter
// }
//
// class Track {
//   // Why not initialize?
//   TrackId id; // the default should be pipes.  How do you do that?
//   // Maybe this will be expanded to include more than just TrackId, otherwise just an enum
//   //int channel;  // not sure how this works yet or the range of values possible, probably 0-15.  Default 0
//   // and not a class will do, right?  I mean, why doesn't Dynamic do it this way?
//
//   Track() {
//     id = TrackId.pipes; // new 11/11/20  Why now?
//   }
//   @override
//   String toString() {
//     return 'Track: id: $id';
//   }
// }
//
//
// TrackId trackStringToId(String trackString) {
//   TrackId trackId;
//   switch (trackString) {
//     case 'met':
//     case 'metronome':
//       trackId = TrackId.met;
//       break;
//     case 'pipes':
//       trackId = TrackId.pipes;
//       break;
//     case 'pipesharmony':
//       trackId = TrackId.pipesharmony;
//       break;
//     case 'chanter':
//       trackId = TrackId.chanter;
//       break;
//     default:
//       log.severe('Bad track identifier: $trackString');
//       trackId = TrackId.pipes;
//       break;
//   }
//   return trackId;
// }
//
// String trackIdToString(TrackId id) {
//   switch (id) {
//     case TrackId.met:
//       return 'met';
//     case TrackId.pipes:
//       return 'pipes';
//     case TrackId.pipesharmony:
//       return 'pipesharmony';
//     case TrackId.chanter:
//       return 'chanter';
//     default:
//       log.severe('Bad track id: $id');
//       return null;
//
//   }
// }
