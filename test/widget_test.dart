import 'package:flutter_test/flutter_test.dart';
import 'package:snap_note_ai/main.dart';

void main() {
  testWidgets('SnapNoteApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SnapNoteApp());
  });
}
