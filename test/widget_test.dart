
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker/main.dart';

void main() {
  testWidgets('Time Tracker app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const TimeTrackerApp());

    expect(find.text('Time Tracker'), findsOneWidget);
  });
}