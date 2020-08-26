import 'package:petitparser/petitparser.dart';
import '../snarelang4.dart';

///
/// Want to do comments using '//' to end of line
///


class Comment {
  String comment;
  String toString() {
    return 'Comment: $comment';
  }
}

///
/// commentParser
///
Parser commentParser = (
    // string('//').trim() & pattern('\n\r').neg().star().trim() & pattern('\n\r').trim().optional()
    string('//') & pattern('\n\r').neg().star() & pattern('\n\r').optional()
).flatten().trim().map((value) {
  log.finest('\nIn commentParser and value is -->$value<--');
  var comment = Comment();
  comment.comment = value.trim();
  log.finest('Leaving CommentParser returning -->$comment<--');
  return comment;
});

// Parser NEWLINE = pattern('\n\r');
//
// Parser HASHBANG = string('#!') & pattern('^\n\r').star() & NEWLINE.optional();
//
// Parser SINGLE_LINE_COMMENT = string('//') & NEWLINE.neg().star() & NEWLINE.optional();