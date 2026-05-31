import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app/study_planner_app.dart';
part 'data/study_store.dart';
part 'models/models.dart';
part 'screens/courses_screen.dart';
part 'screens/dashboard_screen.dart';
part 'screens/exams_screen.dart';
part 'screens/planner_screen.dart';
part 'screens/pomodoro_screen.dart';
part 'screens/shell_screen.dart';
part 'screens/tasks_screen.dart';
part 'theme/app_style.dart';
part 'utils/app_utils.dart';
part 'widgets/shared_widgets.dart';

void main() {
  runApp(const StudyPlannerApp());
}
