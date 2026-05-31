part of '../main.dart';

class StudyStore extends ChangeNotifier {
  static const storageKey = 'study_planner_state_v1';
  static const _legacyDemoCourseIds = {'c1', 'c2', 'c3'};
  static const _legacyDemoExamIds = {'e1', 'e2', 'e3'};
  static const _legacyDemoSessionIds = {'s1', 's2', 's3'};
  static const _legacyDemoTaskIds = {'t1', 't2', 't3'};

  List<Course> courses = [];
  List<ExamItem> exams = [];
  List<StudySession> sessions = [];
  List<TaskGoal> tasks = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null) {
      _resetToEmpty();
      await save();
      notifyListeners();
      return;
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      courses = (json['courses'] as List? ?? [])
          .map((e) => Course.fromJson(e))
          .toList();
      exams = (json['exams'] as List? ?? [])
          .map((e) => ExamItem.fromJson(e))
          .toList();
      sessions = (json['sessions'] as List? ?? [])
          .map((e) => StudySession.fromJson(e))
          .toList();
      tasks = (json['tasks'] as List? ?? [])
          .map((e) => TaskGoal.fromJson(e))
          .toList();
      if (_removeLegacyDemoData()) await save();
    } catch (_) {
      _resetToEmpty();
      await save();
    }
    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        storageKey,
        jsonEncode({
          'courses': courses.map((e) => e.toJson()).toList(),
          'exams': exams.map((e) => e.toJson()).toList(),
          'sessions': sessions.map((e) => e.toJson()).toList(),
          'tasks': tasks.map((e) => e.toJson()).toList(),
        }));
  }

  void _resetToEmpty() {
    courses = [];
    exams = [];
    sessions = [];
    tasks = [];
  }

  bool _removeLegacyDemoData() {
    final removedCourseIds = courses
        .where((course) => _legacyDemoCourseIds.contains(course.id))
        .map((course) => course.id)
        .toSet();
    final beforeCount =
        courses.length + exams.length + sessions.length + tasks.length;

    courses.removeWhere((course) => _legacyDemoCourseIds.contains(course.id));
    exams.removeWhere((exam) =>
        _legacyDemoExamIds.contains(exam.id) ||
        removedCourseIds.contains(exam.courseId));
    sessions.removeWhere((session) =>
        _legacyDemoSessionIds.contains(session.id) ||
        removedCourseIds.contains(session.courseId));
    tasks.removeWhere((task) =>
        _legacyDemoTaskIds.contains(task.id) ||
        removedCourseIds.contains(task.courseId));

    final afterCount =
        courses.length + exams.length + sessions.length + tasks.length;
    return beforeCount != afterCount;
  }

  String courseName(String? id) =>
      courses.where((c) => c.id == id).map((c) => c.name).firstOrNull ??
      'Nessun corso';

  Future<void> upsertCourse(Course course) async {
    final index = courses.indexWhere((e) => e.id == course.id);
    if (index >= 0) {
      courses[index] = course;
    } else {
      courses.add(course);
    }
    await save();
    notifyListeners();
  }

  Future<void> deleteCourse(String id) async {
    courses.removeWhere((e) => e.id == id);
    exams.removeWhere((e) => e.courseId == id);
    sessions.removeWhere((e) => e.courseId == id);
    tasks.removeWhere((e) => e.courseId == id);
    await save();
    notifyListeners();
  }

  Future<void> upsertExam(ExamItem item) async {
    final index = exams.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      exams[index] = item;
    } else {
      exams.add(item);
    }
    await save();
    notifyListeners();
  }

  Future<void> deleteExam(String id) async {
    exams.removeWhere((e) => e.id == id);
    await save();
    notifyListeners();
  }

  Future<void> upsertSession(StudySession item) async {
    final index = sessions.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      sessions[index] = item;
    } else {
      sessions.add(item);
    }
    await save();
    notifyListeners();
  }

  Future<void> deleteSession(String id) async {
    sessions.removeWhere((e) => e.id == id);
    await save();
    notifyListeners();
  }

  Future<void> upsertTask(TaskGoal item) async {
    final index = tasks.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      tasks[index] = item;
    } else {
      tasks.add(item);
    }
    await save();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    tasks.removeWhere((e) => e.id == id);
    await save();
    notifyListeners();
  }
}
