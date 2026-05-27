import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_planner_exam_tracker/main.dart';

void main() {
  testWidgets('StudyPlanner app loads', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const StudyPlannerApp());
    await tester.pump();
    expect(find.text('Home'), findsWidgets);
  });
}
