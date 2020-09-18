import 'package:snarelang4/snarelang4.dart';
import 'package:test/test.dart';
import 'package:petitparser/petitparser.dart'; // defines Result

void main() {
  group('A group of tests', ()
  {
    Score score;

    setUp(() {
      score = Score();
    });
    group('Test single Score elements', () {
      test('Comment test ', () {
        Result result = scoreParser.parse('// The entire line starting at first of line!');
        expect(result.value.elements.elementAt(0), '// The entire line starting at first of line!');
      });
      test('Dynamics test ppp', () {
        Result result = scoreParser.parse('/ppp');
        expect(result.value.elements.elementAt(0), Dynamic.ppp);
      });
      test('Dynamics test pp', () {
        Result result = scoreParser.parse('/pp');
        expect(result.value.elements.elementAt(0), Dynamic.pp);
      });
      test('Dynamics test p', () {
        Result result = scoreParser.parse('/p');
        expect(result.value.elements.elementAt(0), Dynamic.p);
      });
      test('Dynamics test mp', () {
        Result result = scoreParser.parse('/mp');
        expect(result.value.elements.elementAt(0), Dynamic.mp);
      });
      test('Dynamics test mf', () {
        Result result = scoreParser.parse('/mf');
        expect(result.value.elements.elementAt(0), Dynamic.mf);
      });
      test('Dynamics test f', () {
        Result result = scoreParser.parse('/f');
        var score = result.value;
        expect(score.elements.elementAt(0), Dynamic.f);
      });
      test('Dynamics test ff', () {
        Result result = scoreParser.parse('/ff');
        expect(result.value.elements.elementAt(0), Dynamic.ff);
      });
      test('Dynamics test fff', () {
        Result result = scoreParser.parse('/fff');
        expect(result.value.elements.elementAt(0), Dynamic.fff);
      });
      test('Dynamics test >', () {
        Result result = scoreParser.parse('/>');
        expect(result.value.elements.elementAt(0), DynamicRamp);
      });
      test('Dynamics test <', () {
        Result result = scoreParser.parse('/<');
        expect(result.value.elements.elementAt(0), DynamicRamp);
      });
      test('Dynamics test cresc', () {
        Result result = scoreParser.parse('/cresc');
        expect(result.value.elements.elementAt(0), DynamicRamp);
      });
      test('Dynamics test dim', () {
        Result result = scoreParser.parse('/dim');
        expect(result.value.elements.elementAt(0), DynamicRamp);
      });
      test('Dynamics test decresc', () {
        Result result = scoreParser.parse('/decresc');
        expect(result.value.elements.elementAt(0), DynamicRamp);
      });
      test('Set of score elements', () {
        Result result = scoreParser.parse('/time 2/4 /tempo 4=99 /mf 16 T >8 . . . /ff _Z 24f ^6d /dim . . . /p F . . /tempo 8:2=88 ');
        expect(result.isSuccess, isTrue);
      });

      test('Time signature', () {
        Result result = scoreParser.parse('/time 3/8');
        expect((result.value.elements
            .elementAt(0)
            .numerator + result.value.elements
            .elementAt(0)
            .denominator), 3 + 8);
      });

      test('Tempo', () {
        var result = scoreParser.parse('/tempo 4:9=1011');
        Tempo tempo = result.value.elements.elementAt(0);
        expect((tempo.noteDuration.firstNumber + tempo.noteDuration.secondNumber + tempo.bpm), 4 + 9 + 1011);
      });
    });
  });
}
