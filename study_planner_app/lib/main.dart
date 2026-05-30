
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const StudyPlannerApp());
}

class StudyPlannerApp extends StatefulWidget {
  const StudyPlannerApp({super.key});

  @override
  State<StudyPlannerApp> createState() => _StudyPlannerAppState();
}

class _StudyPlannerAppState extends State<StudyPlannerApp> {
  late final StudyStore store;

  @override
  void initState() {
    super.initState();
    store = StudyStore()..load();
  }

  @override
  Widget build(BuildContext context) {
    final foruiTheme = const <TargetPlatform>{
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.fuchsia,
    }.contains(defaultTargetPlatform)
        ? FThemes.neutral.light.touch
        : FThemes.neutral.light.desktop;

    final baseTextTheme = Typography.blackCupertino.apply(
      bodyColor: AppStyle.ink,
      displayColor: AppStyle.ink,
    );

    final materialTheme = foruiTheme.toApproximateMaterialTheme().copyWith(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppStyle.ink,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppStyle.background,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: baseTextTheme.copyWith(
            displayLarge: baseTextTheme.displayLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1.2),
            displayMedium: baseTextTheme.displayMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1.0),
            headlineLarge: baseTextTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.8),
            headlineMedium: baseTextTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.7),
            headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.4),
            titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.25),
            titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            bodyLarge: baseTextTheme.bodyLarge?.copyWith(height: 1.45),
            bodyMedium: baseTextTheme.bodyMedium?.copyWith(height: 1.42),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: AppStyle.background,
            foregroundColor: AppStyle.ink,
            centerTitle: false,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppStyle.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            hintStyle: const TextStyle(color: AppStyle.muted, fontWeight: FontWeight.w600),
            labelStyle: const TextStyle(color: AppStyle.subtle, fontWeight: FontWeight.w700),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppStyle.line)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppStyle.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppStyle.ink, width: 1.4),
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            elevation: 0,
            height: 74,
            backgroundColor: AppStyle.surface,
            indicatorColor: AppStyle.ink,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            labelTextStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return IconThemeData(color: selected ? Colors.white : AppStyle.subtle, size: 22);
            }),
          ),
          chipTheme: const ChipThemeData(
            backgroundColor: AppStyle.surfaceAlt,
            side: BorderSide(color: AppStyle.line),
            shape: StadiumBorder(),
            labelStyle: TextStyle(fontWeight: FontWeight.w800, color: AppStyle.ink),
          ),
          dropdownMenuTheme: DropdownMenuThemeData(
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppStyle.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: AppStyle.line)),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, AppStyle.buttonHeight),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              backgroundColor: AppStyle.ink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyle.buttonRadius)),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, AppStyle.buttonHeight),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              foregroundColor: AppStyle.ink,
              side: const BorderSide(color: AppStyle.lineStrong),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyle.buttonRadius)),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, AppStyle.buttonHeight),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              foregroundColor: AppStyle.ink,
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyle.buttonRadius)),
            ),
          ),
          cardTheme: CardThemeData(
            color: AppStyle.surface,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26), side: const BorderSide(color: AppStyle.line)),
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: AppStyle.surface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            titleTextStyle: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: AppStyle.ink),
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: AppStyle.surface,
            surfaceTintColor: Colors.transparent,
          ),
        );

    return StudyScope(
      notifier: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'StudyPlanner',
        supportedLocales: FLocalizations.supportedLocales,
        localizationsDelegates: const [...FLocalizations.localizationsDelegates],
        theme: materialTheme,
        builder: (context, child) => FTheme(
          data: foruiTheme,
          child: FToaster(child: FTooltipGroup(child: child!)),
        ),
        home: const ShellScreen(),
      ),
    );
  }
}

class StudyScope extends InheritedNotifier<StudyStore> {
  const StudyScope({super.key, required super.notifier, required super.child});

  static StudyStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StudyScope>();
    assert(scope != null, 'StudyScope non trovato');
    return scope!.notifier!;
  }
}

class StudyStore extends ChangeNotifier {
  static const storageKey = 'study_planner_state_v1';

  List<Course> courses = [];
  List<ExamItem> exams = [];
  List<StudySession> sessions = [];
  List<TaskGoal> tasks = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null) {
      _seed();
      await save();
      notifyListeners();
      return;
    }
    final json = jsonDecode(raw) as Map<String, dynamic>;
    courses = (json['courses'] as List).map((e) => Course.fromJson(e)).toList();
    exams = (json['exams'] as List).map((e) => ExamItem.fromJson(e)).toList();
    sessions = (json['sessions'] as List).map((e) => StudySession.fromJson(e)).toList();
    tasks = (json['tasks'] as List).map((e) => TaskGoal.fromJson(e)).toList();
    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode({
      'courses': courses.map((e) => e.toJson()).toList(),
      'exams': exams.map((e) => e.toJson()).toList(),
      'sessions': sessions.map((e) => e.toJson()).toList(),
      'tasks': tasks.map((e) => e.toJson()).toList(),
    }));
  }

  void _seed() {
    final now = DateTime.now();
    courses = [
      Course(id: 'c1', name: 'Programmazione Mobile', teacher: 'Prof. Rossi', semester: 'II semestre', cfu: 9, status: CourseStatus.inProgress, desiredGrade: 28, notes: 'Flutter, navigazione, stato e persistenza.'),
      Course(id: 'c2', name: 'Basi di Dati', teacher: 'Prof.ssa Bianchi', semester: 'I semestre', cfu: 6, status: CourseStatus.review, desiredGrade: 27, notes: 'SQL, modellazione ER e normalizzazione.'),
      Course(id: 'c3', name: 'Ingegneria del Software', teacher: 'Prof. Verdi', semester: 'Annuale', cfu: 9, status: CourseStatus.toStart, desiredGrade: 30, notes: 'Analisi, UML, testing e pattern.'),
    ];
    exams = [
      ExamItem(id: 'e1', title: 'Esame Mobile', courseId: 'c1', date: now.add(const Duration(days: 18)), type: ExamType.exam, priority: Priority.high, status: ItemStatus.future, notes: 'Ripassare gestione stato e storage.'),
      ExamItem(id: 'e2', title: 'Consegna progetto DB', courseId: 'c2', date: now.add(const Duration(days: 7)), type: ExamType.deadline, priority: Priority.medium, status: ItemStatus.future, notes: 'Completare relazione e schema logico.'),
      ExamItem(id: 'e3', title: 'Parziale Software', courseId: 'c3', date: now.subtract(const Duration(days: 14)), type: ExamType.exam, priority: Priority.medium, status: ItemStatus.completed, result: 26, notes: 'Superato.'),
    ];
    sessions = [
      StudySession(id: 's1', title: 'Studio widget Flutter', courseId: 'c1', date: now, minutesPlanned: 90, minutesDone: 70, kind: StudyKind.study, completed: false),
      StudySession(id: 's2', title: 'Esercizi SQL', courseId: 'c2', date: now.add(const Duration(days: 1)), minutesPlanned: 120, minutesDone: 0, kind: StudyKind.exercise, completed: false),
      StudySession(id: 's3', title: 'Ripasso UML', courseId: 'c3', date: now.add(const Duration(days: 2)), minutesPlanned: 60, minutesDone: 0, kind: StudyKind.review, completed: false),
    ];
    tasks = [
      TaskGoal(id: 't1', title: 'Rifinire schermate principali', description: 'Organizzare il flusso tra dashboard, calendario e obiettivi.', courseId: 'c1', dueDate: now.add(const Duration(days: 3)), priority: Priority.high, status: ItemStatus.future, estimatedMinutes: 120, actualMinutes: 40),
      TaskGoal(id: 't2', title: 'Schema ER', description: 'Rifinire entità, relazioni e vincoli.', courseId: 'c2', dueDate: now.add(const Duration(days: 4)), priority: Priority.medium, status: ItemStatus.future, estimatedMinutes: 90, actualMinutes: 0),
      TaskGoal(id: 't3', title: 'Leggere capitolo testing', description: 'Annotare concetti chiave.', courseId: 'c3', dueDate: now.add(const Duration(days: 8)), priority: Priority.low, status: ItemStatus.completed, estimatedMinutes: 60, actualMinutes: 60),
    ];
  }

  String courseName(String? id) => courses.where((c) => c.id == id).map((c) => c.name).firstOrNull ?? 'Nessun corso';

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

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

String id() => DateTime.now().microsecondsSinceEpoch.toString();
String dateLabel(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
String shortDateLabel(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
String weekdayLabel(DateTime d) => const ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'][d.weekday - 1];
String minutesLabel(int minutes) => '${minutes ~/ 60}h ${minutes % 60}min';
String timeLabel(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
String monthLabel(DateTime d) {
  const months = ['Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno', 'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'];
  return '${months[d.month - 1]} ${d.year}';
}
DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime monthOnly(DateTime d) => DateTime(d.year, d.month);
bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
bool sameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;
int daysUntil(DateTime d) => dayOnly(d).difference(dayOnly(DateTime.now())).inDays;
List<DateTime> calendarDaysForMonth(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  final last = DateTime(month.year, month.month + 1, 0);
  final start = first.subtract(Duration(days: first.weekday - 1));
  final end = last.add(Duration(days: 7 - last.weekday));
  return List.generate(end.difference(start).inDays + 1, (index) => DateTime(start.year, start.month, start.day + index));
}

class AutomaticStudySuggestion {
  final String title;
  final String courseName;
  final String reason;
  final int recommendedMinutes;
  final int daysLeft;
  final Priority priority;
  final DateTime examDate;

  const AutomaticStudySuggestion({
    required this.title,
    required this.courseName,
    required this.reason,
    required this.recommendedMinutes,
    required this.daysLeft,
    required this.priority,
    required this.examDate,
  });
}

List<AutomaticStudySuggestion> buildAutomaticSuggestions({
  required StudyStore store,
  required List<ExamItem> upcomingExams,
}) {
  final suggestions = <AutomaticStudySuggestion>[];
  final relevantExams = upcomingExams.where((exam) {
    final days = daysUntil(exam.date);
    return days >= 0 && days <= 30;
  }).toList()
    ..sort((a, b) {
      final priority = _priorityRank(b.priority).compareTo(_priorityRank(a.priority));
      if (priority != 0) return priority;
      return a.date.compareTo(b.date);
    });

  for (final exam in relevantExams) {
    final days = daysUntil(exam.date);
    final courseName = store.courseName(exam.courseId);
    final plannedBeforeExam = store.sessions.where((session) {
      return session.courseId == exam.courseId &&
          !session.completed &&
          !dayOnly(session.date).isAfter(dayOnly(exam.date));
    }).fold<int>(0, (sum, session) => sum + session.minutesPlanned);
    final openTasksBeforeExam = store.tasks.where((task) {
      return task.courseId == exam.courseId &&
          task.status != ItemStatus.completed &&
          !dayOnly(task.dueDate).isAfter(dayOnly(exam.date));
    }).length;

    final minimumTarget = exam.priority == Priority.high || days <= 7
        ? 120
        : days <= 14
            ? 90
            : 60;
    final gap = minimumTarget - plannedBeforeExam;
    final recommendedMinutes = gap > 0 ? gap.clamp(45, 180).toInt() : (openTasksBeforeExam > 0 ? 45 : 0);

    if (recommendedMinutes == 0 && days > 7) continue;

    final title = days <= 3
        ? 'Ripasso immediato'
        : days <= 7 || exam.priority == Priority.high
            ? 'Sessione prioritaria'
            : 'Piano di avvicinamento';
    final dayText = days == 0 ? 'oggi' : 'tra $days giorni';
    final taskText = openTasksBeforeExam == 1 ? '1 obiettivo aperto' : '$openTasksBeforeExam obiettivi aperti';

    suggestions.add(AutomaticStudySuggestion(
      title: title,
      courseName: courseName,
      reason: '${exam.title} $dayText: ${minutesLabel(plannedBeforeExam)} pianificati, $taskText.',
      recommendedMinutes: recommendedMinutes == 0 ? 45 : recommendedMinutes,
      daysLeft: days,
      priority: days <= 3 ? Priority.high : exam.priority,
      examDate: exam.date,
    ));
  }

  return suggestions.take(6).toList();
}

int _priorityRank(Priority priority) => switch (priority) {
      Priority.high => 3,
      Priority.medium => 2,
      Priority.low => 1,
    };

Color priorityColor(Priority priority) => switch (priority) {
      Priority.high => const Color(0xFFEF4444),
      Priority.medium => const Color(0xFFF59E0B),
      Priority.low => const Color(0xFF10B981),
    };

Color statusColor(Enum status) => switch (status) {
      CourseStatus.toStart => const Color(0xFF64748B),
      CourseStatus.inProgress => const Color(0xFF5B5FEF),
      CourseStatus.review => const Color(0xFFF59E0B),
      CourseStatus.completed => const Color(0xFF14B8A6),
      CourseStatus.passed => const Color(0xFF10B981),
      ItemStatus.future => const Color(0xFF3B82F6),
      ItemStatus.completed => const Color(0xFF10B981),
      ItemStatus.cancelled => const Color(0xFF94A3B8),
      _ => const Color(0xFF64748B),
    };

Color courseAccent(String id) {
  const colors = [
    Color(0xFF5B5FEF),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
    Color(0xFF10B981),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
  ];
  final index = id.codeUnits.fold<int>(0, (sum, value) => sum + value) % colors.length;
  return colors[index];
}

enum CourseStatus { toStart, inProgress, review, completed, passed }
enum ExamType { exam, deadline, project, other }
enum Priority { low, medium, high }
enum ItemStatus { future, completed, cancelled }
enum StudyKind { study, review, exercise, reading, project }

extension Labels on Enum {
  String get label => switch (this) {
        CourseStatus.toStart => 'Da iniziare',
        CourseStatus.inProgress => 'In corso',
        CourseStatus.review => 'Da ripassare',
        CourseStatus.completed => 'Completato',
        CourseStatus.passed => 'Superato',
        ExamType.exam => 'Esame',
        ExamType.deadline => 'Scadenza',
        ExamType.project => 'Progetto',
        ExamType.other => 'Altro',
        Priority.low => 'Bassa',
        Priority.medium => 'Media',
        Priority.high => 'Alta',
        ItemStatus.future => 'Futuro',
        ItemStatus.completed => 'Completato',
        ItemStatus.cancelled => 'Annullato',
        StudyKind.study => 'Studio',
        StudyKind.review => 'Ripasso',
        StudyKind.exercise => 'Esercitazioni',
        StudyKind.reading => 'Lettura',
        StudyKind.project => 'Progetto',
        _ => name,
      };
}

T enumByName<T extends Enum>(List<T> values, String name, T fallback) => values.where((e) => e.name == name).firstOrNull ?? fallback;

class Course {
  final String id;
  final String name;
  final String teacher;
  final String semester;
  final int cfu;
  final CourseStatus status;
  final int? desiredGrade;
  final int? finalGrade;
  final String notes;

  Course({required this.id, required this.name, required this.teacher, required this.semester, required this.cfu, required this.status, this.desiredGrade, this.finalGrade, required this.notes});

  Course copyWith({String? name, String? teacher, String? semester, int? cfu, CourseStatus? status, int? desiredGrade, int? finalGrade, String? notes}) => Course(
        id: id,
        name: name ?? this.name,
        teacher: teacher ?? this.teacher,
        semester: semester ?? this.semester,
        cfu: cfu ?? this.cfu,
        status: status ?? this.status,
        desiredGrade: desiredGrade ?? this.desiredGrade,
        finalGrade: finalGrade ?? this.finalGrade,
        notes: notes ?? this.notes,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'teacher': teacher, 'semester': semester, 'cfu': cfu, 'status': status.name, 'desiredGrade': desiredGrade, 'finalGrade': finalGrade, 'notes': notes};
  factory Course.fromJson(Map<String, dynamic> json) => Course(id: json['id'], name: json['name'], teacher: json['teacher'], semester: json['semester'], cfu: json['cfu'], status: enumByName(CourseStatus.values, json['status'], CourseStatus.toStart), desiredGrade: json['desiredGrade'], finalGrade: json['finalGrade'], notes: json['notes']);
}

class ExamItem {
  final String id;
  final String title;
  final String courseId;
  final DateTime date;
  final ExamType type;
  final Priority priority;
  final ItemStatus status;
  final String notes;
  final int? result;

  ExamItem({required this.id, required this.title, required this.courseId, required this.date, required this.type, required this.priority, required this.status, required this.notes, this.result});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'courseId': courseId, 'date': date.toIso8601String(), 'type': type.name, 'priority': priority.name, 'status': status.name, 'notes': notes, 'result': result};
  factory ExamItem.fromJson(Map<String, dynamic> json) => ExamItem(id: json['id'], title: json['title'], courseId: json['courseId'], date: DateTime.parse(json['date']), type: enumByName(ExamType.values, json['type'], ExamType.exam), priority: enumByName(Priority.values, json['priority'], Priority.medium), status: enumByName(ItemStatus.values, json['status'], ItemStatus.future), notes: json['notes'], result: json['result']);
}

class StudySession {
  final String id;
  final String title;
  final String courseId;
  final DateTime date;
  final int minutesPlanned;
  final int minutesDone;
  final StudyKind kind;
  final bool completed;

  StudySession({required this.id, required this.title, required this.courseId, required this.date, required this.minutesPlanned, required this.minutesDone, required this.kind, required this.completed});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'courseId': courseId, 'date': date.toIso8601String(), 'minutesPlanned': minutesPlanned, 'minutesDone': minutesDone, 'kind': kind.name, 'completed': completed};
  factory StudySession.fromJson(Map<String, dynamic> json) => StudySession(id: json['id'], title: json['title'], courseId: json['courseId'], date: DateTime.parse(json['date']), minutesPlanned: json['minutesPlanned'], minutesDone: json['minutesDone'], kind: enumByName(StudyKind.values, json['kind'], StudyKind.study), completed: json['completed']);
}

class TaskGoal {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final DateTime dueDate;
  final Priority priority;
  final ItemStatus status;
  final int estimatedMinutes;
  final int actualMinutes;

  TaskGoal({required this.id, required this.title, required this.description, required this.courseId, required this.dueDate, required this.priority, required this.status, required this.estimatedMinutes, required this.actualMinutes});
  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'description': description, 'courseId': courseId, 'dueDate': dueDate.toIso8601String(), 'priority': priority.name, 'status': status.name, 'estimatedMinutes': estimatedMinutes, 'actualMinutes': actualMinutes};
  factory TaskGoal.fromJson(Map<String, dynamic> json) => TaskGoal(id: json['id'], title: json['title'], description: json['description'], courseId: json['courseId'], dueDate: DateTime.parse(json['dueDate']), priority: enumByName(Priority.values, json['priority'], Priority.medium), status: enumByName(ItemStatus.values, json['status'], ItemStatus.future), estimatedMinutes: json['estimatedMinutes'], actualMinutes: json['actualMinutes']);
}


class AppStyle {
  static const Color background = Color(0xFFF6F5F1);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF8F7F3);
  static const Color ink = Color(0xFF111111);
  static const Color muted = Color(0xFF8A8A8A);
  static const Color subtle = Color(0xFF5F6368);
  static const Color line = Color(0xFFE8E4DA);
  static const Color lineStrong = Color(0xFFD8D2C4);
  static const Color darkSurface = Color(0xFF151515);
  static const Color darkSurfaceSoft = Color(0xFF242424);
  static const Color warm = Color(0xFFEDE7D8);
  static const double maxPageWidth = 1240;
  static const double sidebarWidth = 292;
  static const double buttonHeight = 48;
  static const double buttonRadius = 16;

  static BoxShadow get softShadow => BoxShadow(
        color: Colors.black.withOpacity(.045),
        blurRadius: 28,
        offset: const Offset(0, 14),
      );

  static BoxShadow get liftShadow => BoxShadow(
        color: Colors.black.withOpacity(.075),
        blurRadius: 34,
        offset: const Offset(0, 18),
      );
}

class Responsive {
  static bool mobile(BuildContext context) => MediaQuery.of(context).size.width < 620;
  static bool tablet(BuildContext context) => MediaQuery.of(context).size.width < 980;
}

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(onNavigate: (value) => setState(() => selected = value)),
      const CoursesScreen(),
      const ExamsScreen(),
      const PlannerScreen(),
      const TasksScreen(),
      const PomodoroScreen(),
    ];
    final items = const [
      _NavItem(Icons.dashboard_outlined, Icons.dashboard, 'Home'),
      _NavItem(Icons.menu_book_outlined, Icons.menu_book, 'Corsi'),
      _NavItem(Icons.event_outlined, Icons.event, 'Esami'),
      _NavItem(Icons.calendar_month_outlined, Icons.calendar_month, 'Calendario'),
      _NavItem(Icons.task_alt_outlined, Icons.task_alt, 'Obiettivi'),
      _NavItem(Icons.timer_outlined, Icons.timer, 'Pomodoro'),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 920) {
        return Scaffold(
          body: Row(
            children: [
              _Sidebar(
                selected: selected,
                items: items,
                onSelected: (value) => setState(() => selected = value),
              ),
              Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 260), child: pages[selected])),
            ],
          ),
        );
      }
      return Scaffold(
        body: AnimatedSwitcher(duration: const Duration(milliseconds: 220), child: pages[selected]),
        bottomNavigationBar: NavigationBar(
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: selected,
          destinations: items.map((e) => NavigationDestination(icon: Icon(e.icon), selectedIcon: Icon(e.selectedIcon), label: e.label)).toList(),
          onDestinationSelected: (value) => setState(() => selected = value),
        ),
      );
    });
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItem(this.icon, this.selectedIcon, this.label);
}

class _Sidebar extends StatelessWidget {
  final int selected;
  final List<_NavItem> items;
  final ValueChanged<int> onSelected;

  const _Sidebar({required this.selected, required this.items, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppStyle.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppStyle.surface,
        border: Border(right: BorderSide(color: AppStyle.line)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppStyle.darkSurfaceSoft, AppStyle.darkSurface],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [AppStyle.liftShadow],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.auto_stories_rounded, color: AppStyle.ink),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('StudyPlanner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -.3)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('NAVIGAZIONE', style: TextStyle(color: AppStyle.muted, fontWeight: FontWeight.w900, letterSpacing: 1.3, fontSize: 11)),
              ),
              const SizedBox(height: 12),
              ...List.generate(items.length, (index) {
                final item = items[index];
                final active = selected == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => onSelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: active ? AppStyle.ink : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: active ? AppStyle.ink : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: active ? Colors.white.withOpacity(.12) : AppStyle.surfaceAlt,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(active ? item.selectedIcon : item.icon, color: active ? Colors.white : AppStyle.subtle, size: 19),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.label,
                              style: TextStyle(fontWeight: FontWeight.w900, color: active ? Colors.white : AppStyle.ink),
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: active ? 1 : 0,
                            duration: const Duration(milliseconds: 150),
                            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class PageFrame extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;

  const PageFrame({super.key, required this.title, required this.subtitle, required this.child, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.mobile(context);
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppStyle.background),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppStyle.maxPageWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(compact ? 14 : 28, compact ? 14 : 26, compact ? 14 : 28, compact ? 8 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PageHeader(title: title, subtitle: subtitle, actions: actions),
                  SizedBox(height: compact ? 14 : 22),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;

  const _PageHeader({required this.title, required this.subtitle, required this.actions});

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.mobile(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: (compact ? Theme.of(context).textTheme.headlineMedium : Theme.of(context).textTheme.displaySmall)?.copyWith(
            color: AppStyle.ink,
            fontWeight: FontWeight.w900,
            letterSpacing: compact ? -0.8 : -1.2,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          maxLines: compact ? 3 : 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppStyle.subtle, fontWeight: FontWeight.w600, height: 1.35),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 18 : 24),
      decoration: BoxDecoration(
        color: AppStyle.surface,
        borderRadius: BorderRadius.circular(compact ? 26 : 32),
        border: Border.all(color: AppStyle.line),
        boxShadow: [AppStyle.softShadow],
      ),
      child: compact
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [content, if (actions.isNotEmpty) ...[const SizedBox(height: 16), Wrap(spacing: 10, runSpacing: 10, children: actions)]])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: content),
                if (actions.isNotEmpty) ...[
                  const SizedBox(width: 18),
                  Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.end, children: actions),
                ],
              ],
            ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }
}

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final store = StudyScope.of(context);
    final planned = store.sessions.fold<int>(0, (a, b) => a + b.minutesPlanned);
    final done = store.sessions.fold<int>(0, (a, b) => a + b.minutesDone);
    final completedTasks = store.tasks.where((e) => e.status == ItemStatus.completed).length;
    final openTasks = store.tasks.where((e) => e.status != ItemStatus.completed).length;
    final completedExams = store.exams.where((e) => e.status == ItemStatus.completed).length;
    final activeCourses = store.courses.where((e) => e.status == CourseStatus.inProgress || e.status == CourseStatus.review).length;
    final upcoming = [...store.exams.where((e) => e.status == ItemStatus.future && daysUntil(e.date) >= 0)]..sort((a, b) => a.date.compareTo(b.date));
    final nextExam = upcoming.firstOrNull;
    final nextDays = nextExam == null ? null : daysUntil(nextExam.date);
    final progress = planned == 0 ? 0.0 : (done / planned).clamp(0.0, 1.0).toDouble();
    final taskProgress = store.tasks.isEmpty ? 0.0 : (completedTasks / store.tasks.length).clamp(0.0, 1.0).toDouble();
    final automaticSuggestions = buildAutomaticSuggestions(store: store, upcomingExams: upcoming);

    return PageFrame(
      title: 'Home',
      subtitle: 'Riepilogo essenziale di corsi, scadenze, studio svolto e obiettivi.',
      child: ListView(
        children: [
          _DashboardStatsGrid(
            children: [
              StatCard(label: 'Corsi totali', value: '${store.courses.length}', icon: Icons.menu_book_rounded, color: const Color(0xFF5B5FEF), onTap: () => onNavigate(1)),
              StatCard(label: 'Corsi attivi', value: '$activeCourses', icon: Icons.local_library_rounded, color: const Color(0xFF8B5CF6), onTap: () => onNavigate(1)),
              StatCard(label: 'Esami futuri', value: '${upcoming.length}', icon: Icons.event_rounded, color: const Color(0xFF06B6D4), onTap: () => onNavigate(2)),
              StatCard(label: 'Prossima scadenza', value: nextExam == null ? '—' : (nextDays == 0 ? 'Oggi' : '${nextDays}g'), icon: Icons.event_note_rounded, color: const Color(0xFFF97316), onTap: () => onNavigate(3)),
              StatCard(label: 'Studio svolto', value: minutesLabel(done), icon: Icons.trending_up_rounded, color: const Color(0xFF10B981), onTap: () => onNavigate(3)),
              StatCard(label: 'Studio pianificato', value: minutesLabel(planned), icon: Icons.schedule_rounded, color: const Color(0xFF14B8A6), onTap: () => onNavigate(3)),
              StatCard(label: 'Obiettivi aperti', value: '$openTasks', icon: Icons.checklist_rounded, color: const Color(0xFFF59E0B), onTap: () => onNavigate(4)),
              StatCard(label: 'Esami completati', value: '$completedExams', icon: Icons.verified_rounded, color: const Color(0xFF3B82F6), onTap: () => onNavigate(2)),
              StatCard(label: 'Suggerimenti automatici', value: '${automaticSuggestions.length}', icon: Icons.tips_and_updates_rounded, color: AppStyle.ink, helper: 'Da esami imminenti', onTap: () => _showAutomaticSuggestionsSheet(context, automaticSuggestions, () => onNavigate(3))),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final left = Column(
              children: [
                _ProgressCard(title: 'Avanzamento studio', subtitle: '${minutesLabel(done)} svolti su ${minutesLabel(planned)} pianificati', value: progress, icon: Icons.auto_graph_rounded, color: const Color(0xFF5B5FEF)),
                const SizedBox(height: 16),
                _ProgressCard(title: 'Obiettivi completati', subtitle: '$completedTasks attività completate su ${store.tasks.length}', value: taskProgress, icon: Icons.flag_rounded, color: const Color(0xFF10B981)),
                const SizedBox(height: 16),
                _StudyDistribution(courses: store.courses, sessions: store.sessions),
              ],
            );
            final right = Column(
              children: [
                _UpcomingPanel(upcoming: upcoming, store: store),
              ],
            );
            if (!wide) return Column(children: [left, const SizedBox(height: 16), right]);
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 6, child: left), const SizedBox(width: 16), Expanded(flex: 5, child: right)]);
          }),
        ],
      ),
    );
  }
}

class _DashboardStatsGrid extends StatelessWidget {
  final List<Widget> children;

  const _DashboardStatsGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const spacing = 12.0;
      final narrow = constraints.maxWidth < 520;
      final cardHeight = narrow ? 116.0 : 148.0;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: (constraints.maxWidth - (spacing * 2)) / 3 / cardHeight,
        children: children.take(9).toList(),
      );
    });
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final IconData icon;
  final Color color;

  const _ProgressCard({required this.title, required this.subtitle, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          _SoftIcon(icon: icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900))), Text('${(value * 100).round()}%', style: TextStyle(color: color, fontWeight: FontWeight.w900))]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(value: value, minHeight: 10, backgroundColor: color.withOpacity(.12), color: color),
                ),
                const SizedBox(height: 8),
                Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyDistribution extends StatelessWidget {
  final List<Course> courses;
  final List<StudySession> sessions;

  const _StudyDistribution({required this.courses, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final values = courses.map((course) {
      final minutes = sessions.where((session) => session.courseId == course.id).fold<int>(0, (sum, session) => sum + session.minutesPlanned);
      return MapEntry(course, minutes);
    }).where((entry) => entry.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxMinutes = values.isEmpty ? 1 : values.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const _SoftIcon(icon: Icons.donut_large_rounded, color: Color(0xFF8B5CF6)), const SizedBox(width: 12), Text('Distribuzione studio', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))]),
          const SizedBox(height: 16),
          if (values.isEmpty) const Text('Pianifica una sessione per vedere la distribuzione per corso.'),
          ...values.map((entry) {
            final color = courseAccent(entry.key.id);
            final value = entry.value / maxMinutes;
            return Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Expanded(child: Text(entry.key.name, style: const TextStyle(fontWeight: FontWeight.w800))), Text(minutesLabel(entry.value), style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF64748B)))]),
                  const SizedBox(height: 7),
                  ClipRRect(borderRadius: BorderRadius.circular(999), child: LinearProgressIndicator(value: value, minHeight: 9, backgroundColor: color.withOpacity(.12), color: color)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _UpcomingPanel extends StatelessWidget {
  final List<ExamItem> upcoming;
  final StudyStore store;

  const _UpcomingPanel({required this.upcoming, required this.store});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const _SoftIcon(icon: Icons.event_available_rounded, color: Color(0xFF06B6D4)), const SizedBox(width: 12), Expanded(child: Text('Scadenze imminenti', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)))]),
          const SizedBox(height: 12),
          if (upcoming.isEmpty) const Text('Nessuna scadenza futura.'),
          ...upcoming.take(5).map((e) {
            final days = daysUntil(e.date);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE4EAF3))),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(color: priorityColor(e.priority).withOpacity(.12), borderRadius: BorderRadius.circular(18)),
                      child: Icon(e.type == ExamType.deadline ? Icons.assignment_rounded : Icons.school_rounded, color: priorityColor(e.priority)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 3),
                        Text('${store.courseName(e.courseId)} • ${dateLabel(e.date)}', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      ]),
                    ),
                    _Pill(text: days < 0 ? 'Passata' : '${days}g', color: priorityColor(e.priority)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? helper;
  final VoidCallback? onTap;

  const StatCard({super.key, required this.label, required this.value, required this.icon, this.color = AppStyle.ink, this.helper, this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 132;
      final padding = compact ? const EdgeInsets.all(10) : const EdgeInsets.all(18);
      final iconSize = compact ? 32.0 : 46.0;
      final iconRadius = compact ? 12.0 : 16.0;
      final arrowSize = compact ? 26.0 : 34.0;
      final valueStyle = compact
          ? Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.5)
          : Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -.7);
      final labelStyle = TextStyle(
        color: AppStyle.subtle,
        fontWeight: FontWeight.w800,
        fontSize: compact ? 11 : 14,
        height: 1.05,
      );

      final card = AppCard(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: color.withOpacity(.10),
                  borderRadius: BorderRadius.circular(iconRadius),
                  border: Border.all(color: color.withOpacity(.12)),
                ),
                child: Icon(icon, color: color, size: compact ? 17 : 22),
              ),
              const Spacer(),
              Container(
                width: arrowSize,
                height: arrowSize,
                decoration: BoxDecoration(
                  color: color.withOpacity(onTap == null ? .05 : .10),
                  borderRadius: BorderRadius.circular(compact ? 10 : 14),
                  border: Border.all(color: color.withOpacity(onTap == null ? .10 : .20)),
                ),
                child: Icon(Icons.north_east_rounded, size: compact ? 14 : 17, color: color.withOpacity(onTap == null ? .28 : .88)),
              ),
            ]),
            const Spacer(),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: valueStyle),
            const SizedBox(height: 4),
            Text(label, maxLines: compact ? 2 : 1, overflow: TextOverflow.ellipsis, style: labelStyle),
            if (helper != null) ...[
              const SizedBox(height: 2),
              Text(
                helper!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppStyle.muted, fontWeight: FontWeight.w700, fontSize: compact ? 9 : 11, height: 1.05),
              ),
            ],
          ],
        ),
      );

      if (onTap == null) return card;

      return Semantics(
        button: true,
        label: label,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: card,
          ),
        ),
      );
    });
  }
}

void _showAutomaticSuggestionsSheet(BuildContext context, List<AutomaticStudySuggestion> suggestions, VoidCallback openCalendar) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(18, 4, 18, 18 + MediaQuery.of(sheetContext).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Suggerimenti automatici', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text(
              'La statistica viene calcolata dagli esami e dalle scadenze nei prossimi 30 giorni, confrontando priorità, giorni rimanenti, sessioni già pianificate e obiettivi aperti.',
              style: TextStyle(color: AppStyle.subtle, fontWeight: FontWeight.w600, height: 1.35),
            ),
            const SizedBox(height: 14),
            if (suggestions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppStyle.surfaceAlt, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppStyle.line)),
                child: const Text('Nessun suggerimento necessario: le attività risultano già ben pianificate rispetto alle scadenze imminenti.', style: TextStyle(fontWeight: FontWeight.w700, height: 1.35)),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) => _AutomaticSuggestionTile(suggestion: suggestions[index]),
                ),
              ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  openCalendar();
                },
                icon: Icons.calendar_month_rounded,
                child: const Text('Apri calendario'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _AutomaticSuggestionTile extends StatelessWidget {
  final AutomaticStudySuggestion suggestion;

  const _AutomaticSuggestionTile({required this.suggestion});

  @override
  Widget build(BuildContext context) {
    final color = priorityColor(suggestion.priority);
    final days = suggestion.daysLeft == 0 ? 'oggi' : '${suggestion.daysLeft}g';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppStyle.surfaceAlt, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppStyle.line)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.tips_and_updates_rounded, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(suggestion.title, style: const TextStyle(fontWeight: FontWeight.w900))),
                    _Pill(text: days, color: color),
                  ],
                ),
                const SizedBox(height: 4),
                Text(suggestion.courseName, style: const TextStyle(fontWeight: FontWeight.w800, color: AppStyle.ink)),
                const SizedBox(height: 4),
                Text(suggestion.reason, style: const TextStyle(color: AppStyle.subtle, fontWeight: FontWeight.w600, height: 1.3)),
                const SizedBox(height: 8),
                Text('Attività suggerita: ${minutesLabel(suggestion.recommendedMinutes)}', style: TextStyle(color: color, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SoftIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(.12)),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;

  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.18)),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: -.1)),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppStyle.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppStyle.line),
        boxShadow: [AppStyle.softShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: FCard.raw(
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;

  const AppButton({super.key, required this.onPressed, required this.child, this.icon});

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      minimumSize: const Size(0, AppStyle.buttonHeight),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyle.buttonRadius)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
    );

    if (icon == null) {
      return FilledButton(onPressed: onPressed, style: style, child: child);
    }

    return FilledButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon, size: 18),
      label: child,
    );
  }
}

class AppIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;

  const AppIconButton({super.key, required this.onPressed, required this.icon, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: AppStyle.buttonHeight,
      height: AppStyle.buttonHeight,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyle.buttonRadius)),
        ),
        child: Icon(icon, size: 19),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String query = '';
  CourseStatus? status;

  @override
  Widget build(BuildContext context) {
    final store = StudyScope.of(context);
    final filtered = store.courses.where((c) => c.name.toLowerCase().contains(query.toLowerCase()) && (status == null || c.status == status)).toList();
    return PageFrame(
      title: 'Corsi',
      subtitle: 'Gestione insegnamenti, CFU, docente, stato e voti.',
      actions: [AppButton(onPressed: () => _openForm(context), icon: Icons.add, child: const Text('Nuovo'))],
      child: Column(children: [
        LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final search = TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Cerca per nome'),
            onChanged: (value) => setState(() => query = value),
          );
          final dropdown = DropdownButtonFormField<CourseStatus?>(
            value: status,
            decoration: const InputDecoration(labelText: 'Stato'),
            items: [const DropdownMenuItem(value: null, child: Text('Tutti')), ...CourseStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label)))],
            onChanged: (value) => setState(() => status = value),
          );
          if (compact) return Column(children: [search, const SizedBox(height: 10), dropdown]);
          return Row(children: [Expanded(child: search), const SizedBox(width: 12), SizedBox(width: 220, child: dropdown)]);
        }),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final c = filtered[index];
              return CourseCard(
                course: c,
                onEdit: () => _openForm(context, c),
                onDelete: () => store.deleteCourse(c.id),
              );
            },
          ),
        ),
      ]),
    );
  }

  void _openForm(BuildContext context, [Course? course]) {
    showDialog(context: context, builder: (_) => CourseDialog(course: course));
  }
}


class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CourseCard({super.key, required this.course, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = courseAccent(course.id);
    return AppCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 8, decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.horizontal(left: Radius.circular(28)))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SoftIcon(icon: Icons.menu_book_rounded, color: color),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(course.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 4),
                            Text('${course.teacher} • ${course.semester}', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                          ]),
                        ),
                        _Pill(text: course.status.label, color: statusColor(course.status)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(course.notes.isEmpty ? 'Nessuna nota inserita.' : course.notes, style: const TextStyle(color: Color(0xFF475569), height: 1.35)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _Pill(text: '${course.cfu} CFU', color: color),
                        if (course.desiredGrade != null) _Pill(text: 'Obiettivo ${course.desiredGrade}', color: const Color(0xFF8B5CF6)),
                        if (course.finalGrade != null) _Pill(text: 'Voto ${course.finalGrade}', color: const Color(0xFF10B981)),
                        AppIconButton(onPressed: onEdit, icon: Icons.edit_rounded, tooltip: 'Modifica'),
                        AppIconButton(onPressed: onDelete, icon: Icons.delete_outline_rounded, tooltip: 'Elimina'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseDialog extends StatefulWidget {
  final Course? course;
  const CourseDialog({super.key, this.course});

  @override
  State<CourseDialog> createState() => _CourseDialogState();
}

class _CourseDialogState extends State<CourseDialog> {
  final name = TextEditingController();
  final teacher = TextEditingController();
  final semester = TextEditingController();
  final cfu = TextEditingController();
  final notes = TextEditingController();
  CourseStatus status = CourseStatus.toStart;

  @override
  void initState() {
    super.initState();
    name.text = widget.course?.name ?? '';
    teacher.text = widget.course?.teacher ?? '';
    semester.text = widget.course?.semester ?? '';
    cfu.text = '${widget.course?.cfu ?? 6}';
    notes.text = widget.course?.notes ?? '';
    status = widget.course?.status ?? CourseStatus.toStart;
  }

  @override
  Widget build(BuildContext context) {
    final store = StudyScope.of(context);
    return AlertDialog(
      title: Text(widget.course == null ? 'Nuovo corso' : 'Modifica corso'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome corso')),
          const SizedBox(height: 10),
          TextField(controller: teacher, decoration: const InputDecoration(labelText: 'Docente')),
          const SizedBox(height: 10),
          TextField(controller: semester, decoration: const InputDecoration(labelText: 'Semestre')),
          const SizedBox(height: 10),
          TextField(controller: cfu, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'CFU')),
          const SizedBox(height: 10),
          DropdownButtonFormField(value: status, decoration: const InputDecoration(labelText: 'Stato'), items: CourseStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(), onChanged: (value) => status = value!),
          const SizedBox(height: 10),
          TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Note')),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
        AppButton(onPressed: () {
          final item = Course(id: widget.course?.id ?? id(), name: name.text.trim(), teacher: teacher.text.trim(), semester: semester.text.trim(), cfu: int.tryParse(cfu.text) ?? 6, status: status, notes: notes.text.trim());
          store.upsertCourse(item);
          Navigator.pop(context);
        }, child: const Text('Salva')),
      ],
    );
  }
}

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  ItemStatus? status;

  @override
  Widget build(BuildContext context) {
    final store = StudyScope.of(context);
    final list = store.exams.where((e) => status == null || e.status == status).toList()..sort((a, b) => a.date.compareTo(b.date));
    return PageFrame(
      title: 'Esami e scadenze',
      subtitle: 'Appelli, consegne, priorità, stato e risultati.',
      actions: [AppButton(onPressed: () => showDialog(context: context, builder: (_) => ExamDialog()), icon: Icons.add, child: const Text('Nuovo'))],
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: Responsive.mobile(context) ? double.infinity : 230,
            child: DropdownButtonFormField<ItemStatus?>(
              value: status,
              decoration: const InputDecoration(labelText: 'Stato'),
              items: [const DropdownMenuItem(value: null, child: Text('Tutti')), ...ItemStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label)))],
              onChanged: (value) => setState(() => status = value),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final e = list[index];
              return ExamCard(
                exam: e,
                courseName: store.courseName(e.courseId),
                onEdit: () => showDialog(context: context, builder: (_) => ExamDialog(item: e)),
                onDelete: () => store.deleteExam(e.id),
              );
            },
          ),
        ),
      ]),
    );
  }
}


class ExamCard extends StatelessWidget {
  final ExamItem exam;
  final String courseName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExamCard({super.key, required this.exam, required this.courseName, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = priorityColor(exam.priority);
    final days = daysUntil(exam.date);
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withOpacity(.18), color.withOpacity(.08)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(exam.type == ExamType.deadline ? Icons.assignment_rounded : Icons.school_rounded, color: color, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Text(exam.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
                  _Pill(text: days < 0 ? 'Passata' : '${days} giorni', color: color),
                ]),
                const SizedBox(height: 6),
                Text('$courseName • ${exam.type.label} • ${dateLabel(exam.date)}', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text(exam.notes.isEmpty ? 'Nessuna nota inserita.' : exam.notes, style: const TextStyle(color: Color(0xFF475569), height: 1.35)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  PriorityChip(exam.priority),
                  _Pill(text: exam.status.label, color: statusColor(exam.status)),
                  AppIconButton(onPressed: onEdit, icon: Icons.edit_rounded, tooltip: 'Modifica'),
                  AppIconButton(onPressed: onDelete, icon: Icons.delete_outline_rounded, tooltip: 'Elimina'),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExamDialog extends StatefulWidget {
  final ExamItem? item;
  final DateTime? initialDate;
  const ExamDialog({super.key, this.item, this.initialDate});

  @override
  State<ExamDialog> createState() => _ExamDialogState();
}

class _ExamDialogState extends State<ExamDialog> {
  final title = TextEditingController();
  final notes = TextEditingController();
  final result = TextEditingController();
  late DateTime date;
  ExamType type = ExamType.exam;
  Priority priority = Priority.medium;
  ItemStatus status = ItemStatus.future;
  String? courseId;

  @override
  void initState() {
    super.initState();
    title.text = widget.item?.title ?? '';
    notes.text = widget.item?.notes ?? '';
    result.text = widget.item?.result?.toString() ?? '';
    date = widget.item?.date ?? widget.initialDate ?? DateTime.now().add(const Duration(days: 7));
    type = widget.item?.type ?? ExamType.exam;
    priority = widget.item?.priority ?? Priority.medium;
    status = widget.item?.status ?? ItemStatus.future;
    courseId = widget.item?.courseId;
  }

  @override
  void dispose() {
    title.dispose();
    notes.dispose();
    result.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StudyScope.of(context);
    courseId ??= store.courses.firstOrNull?.id;
    return AlertDialog(
      title: Text(widget.item == null ? 'Nuovo esame/scadenza' : 'Modifica esame/scadenza'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Titolo')),
        const SizedBox(height: 10),
        DropdownButtonFormField(value: courseId, decoration: const InputDecoration(labelText: 'Corso'), items: store.courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(), onChanged: (value) => courseId = value),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Text('Data: ${dateLabel(date)}', style: const TextStyle(fontWeight: FontWeight.w700))),
          TextButton(onPressed: () async {
            final picked = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2035), initialDate: date);
            if (picked != null) setState(() => date = DateTime(picked.year, picked.month, picked.day, date.hour, date.minute));
          }, child: const Text('Scegli')),
        ]),
        DropdownButtonFormField(value: type, decoration: const InputDecoration(labelText: 'Tipologia'), items: ExamType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(), onChanged: (value) => setState(() => type = value!)),
        const SizedBox(height: 10),
        DropdownButtonFormField(value: priority, decoration: const InputDecoration(labelText: 'Priorità'), items: Priority.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(), onChanged: (value) => setState(() => priority = value!)),
        const SizedBox(height: 10),
        DropdownButtonFormField(value: status, decoration: const InputDecoration(labelText: 'Stato'), items: ItemStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(), onChanged: (value) => setState(() => status = value!)),
        if (status == ItemStatus.completed) ...[
          const SizedBox(height: 10),
          TextField(controller: result, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Voto/risultato')),
        ],
        const SizedBox(height: 10),
        TextField(controller: notes, maxLines: 3, decoration: const InputDecoration(labelText: 'Note')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
        AppButton(onPressed: () {
          if (courseId == null || title.text.trim().isEmpty) return;
          store.upsertExam(ExamItem(
            id: widget.item?.id ?? id(),
            title: title.text.trim(),
            courseId: courseId!,
            date: date,
            type: type,
            priority: priority,
            status: status,
            notes: notes.text.trim(),
            result: int.tryParse(result.text),
          ));
          Navigator.pop(context);
        }, child: const Text('Salva')),
      ],
    );
  }
}

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

enum CalendarFilter { all, study, exams, tasks }

extension CalendarFilterLabel on CalendarFilter {
  String get label => switch (this) {
        CalendarFilter.all => 'Tutto',
        CalendarFilter.study => 'Studio',
        CalendarFilter.exams => 'Esami',
        CalendarFilter.tasks => 'Obiettivi',
      };

  IconData get icon => switch (this) {
        CalendarFilter.all => Icons.calendar_month_rounded,
        CalendarFilter.study => Icons.auto_stories_rounded,
        CalendarFilter.exams => Icons.school_rounded,
        CalendarFilter.tasks => Icons.task_alt_rounded,
      };
}

class _PlannerScreenState extends State<PlannerScreen> {
  DateTime visibleMonth = monthOnly(DateTime.now());
  DateTime selectedDate = dayOnly(DateTime.now());
  CalendarFilter filter = CalendarFilter.all;

  @override
  Widget build(BuildContext context) {
    final store = StudyScope.of(context);
    final selectedEntries = _entriesForDay(store, selectedDate);
    final monthEntries = _entriesForMonth(store, visibleMonth);
    final plannedMinutes = monthEntries.where((e) => e.type == CalendarFilter.study).fold<int>(0, (sum, e) => sum + e.minutes);
    final completedStudy = store.sessions.where((s) => sameMonth(s.date, visibleMonth) && s.completed).length;
    final upcomingCritical = store.exams.where((e) => sameMonth(e.date, visibleMonth) && e.status == ItemStatus.future && e.priority == Priority.high).length;

    return PageFrame(
      title: 'Calendario',
      subtitle: 'Pianifica sessioni, esami e obiettivi direttamente sui giorni del mese.',
      actions: [
        OutlinedButton.icon(
          onPressed: _goToday,
          icon: const Icon(Icons.today_rounded),
          label: const Text('Oggi'),
        ),
        AppButton(
          onPressed: () => _showCreateMenu(context, selectedDate),
          icon: Icons.add_rounded,
          child: const Text('Aggiungi'),
        ),
      ],
      child: LayoutBuilder(builder: (context, constraints) {
        final calendar = _CalendarMonthCard(
          visibleMonth: visibleMonth,
          selectedDate: selectedDate,
          filter: filter,
          onFilterChanged: (value) => setState(() => filter = value),
          onPreviousMonth: () => setState(() => visibleMonth = DateTime(visibleMonth.year, visibleMonth.month - 1)),
          onNextMonth: () => setState(() => visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + 1)),
          onSelectDate: (date) => setState(() {
            selectedDate = dayOnly(date);
            visibleMonth = monthOnly(date);
          }),
          entriesForDay: (date) => _entriesForDay(store, date),
        );

        final agenda = _DayAgendaPanel(
          selectedDate: selectedDate,
          entries: selectedEntries,
          monthLabel: monthLabel(visibleMonth),
          plannedMinutesInMonth: plannedMinutes,
          completedStudyInMonth: completedStudy,
          highPriorityExamsInMonth: upcomingCritical,
          onCreate: () => _showCreateMenu(context, selectedDate),
        );

        if (constraints.maxWidth >= 980) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: calendar),
                const SizedBox(width: 18),
                Expanded(flex: 4, child: agenda),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [calendar, const SizedBox(height: 16), agenda],
        );
      }),
    );
  }

  void _goToday() {
    final today = dayOnly(DateTime.now());
    setState(() {
      selectedDate = today;
      visibleMonth = monthOnly(today);
    });
  }

  List<CalendarEntry> _entriesForMonth(StudyStore store, DateTime month) {
    final result = <CalendarEntry>[];
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    for (final session in store.sessions.where((s) => !s.date.isBefore(start) && s.date.isBefore(end))) {
      result.add(CalendarEntry.fromSession(session, store));
    }
    for (final exam in store.exams.where((e) => !e.date.isBefore(start) && e.date.isBefore(end))) {
      result.add(CalendarEntry.fromExam(exam, store));
    }
    for (final task in store.tasks.where((t) => !t.dueDate.isBefore(start) && t.dueDate.isBefore(end))) {
      result.add(CalendarEntry.fromTask(task, store));
    }
    return _applyFilter(result)..sort((a, b) => a.date.compareTo(b.date));
  }

  List<CalendarEntry> _entriesForDay(StudyStore store, DateTime day) {
    final result = <CalendarEntry>[];
    for (final session in store.sessions.where((s) => sameDay(s.date, day))) {
      result.add(CalendarEntry.fromSession(session, store));
    }
    for (final exam in store.exams.where((e) => sameDay(e.date, day))) {
      result.add(CalendarEntry.fromExam(exam, store));
    }
    for (final task in store.tasks.where((t) => sameDay(t.dueDate, day))) {
      result.add(CalendarEntry.fromTask(task, store));
    }
    return _applyFilter(result)..sort((a, b) {
      final typeOrder = a.type.index.compareTo(b.type.index);
      if (typeOrder != 0) return typeOrder;
      return a.date.compareTo(b.date);
    });
  }

  List<CalendarEntry> _applyFilter(List<CalendarEntry> entries) {
    if (filter == CalendarFilter.all) return entries;
    return entries.where((e) => e.type == filter).toList();
  }

  Future<void> _showCreateMenu(BuildContext context, DateTime date) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Crea elemento per ${dateLabel(date)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              _CreateOption(
                icon: Icons.auto_stories_rounded,
                color: const Color(0xFF5B5FEF),
                title: 'Sessione di studio',
                subtitle: 'Studio, ripasso, esercizi o lettura con durata pianificata.',
                onTap: () {
                  Navigator.pop(sheetContext);
                  showDialog(context: context, builder: (_) => SessionDialog(initialDate: date));
                },
              ),
              _CreateOption(
                icon: Icons.school_rounded,
                color: const Color(0xFFF59E0B),
                title: 'Esame o scadenza',
                subtitle: 'Appello, consegna, progetto o altra data importante.',
                onTap: () {
                  Navigator.pop(sheetContext);
                  showDialog(context: context, builder: (_) => ExamDialog(initialDate: date));
                },
              ),
              _CreateOption(
                icon: Icons.task_alt_rounded,
                color: const Color(0xFF10B981),
                title: 'Obiettivo',
                subtitle: 'Obiettivo collegato a un corso con priorità e tempo stimato.',
                onTap: () {
                  Navigator.pop(sheetContext);
                  showDialog(context: context, builder: (_) => TaskDialog(initialDate: date));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CalendarEntry {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final CalendarFilter type;
  final IconData icon;
  final Color color;
  final int minutes;
  final bool completed;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  CalendarEntry({required this.id, required this.title, required this.subtitle, required this.date, required this.type, required this.icon, required this.color, this.minutes = 0, this.completed = false, this.onToggle, this.onEdit, this.onDelete});

  factory CalendarEntry.fromSession(StudySession session, StudyStore store) => CalendarEntry(
        id: session.id,
        title: session.title,
        subtitle: '${store.courseName(session.courseId)} • ${session.kind.label} • ${timeLabel(session.date)} • ${minutesLabel(session.minutesPlanned)}',
        date: session.date,
        type: CalendarFilter.study,
        icon: Icons.auto_stories_rounded,
        color: courseAccent(session.courseId),
        minutes: session.minutesPlanned,
        completed: session.completed,
      );

  factory CalendarEntry.fromExam(ExamItem exam, StudyStore store) => CalendarEntry(
        id: exam.id,
        title: exam.title,
        subtitle: '${store.courseName(exam.courseId)} • ${exam.type.label} • priorità ${exam.priority.label.toLowerCase()}',
        date: exam.date,
        type: CalendarFilter.exams,
        icon: exam.type == ExamType.deadline ? Icons.assignment_rounded : Icons.school_rounded,
        color: priorityColor(exam.priority),
        completed: exam.status == ItemStatus.completed,
      );

  factory CalendarEntry.fromTask(TaskGoal task, StudyStore store) => CalendarEntry(
        id: task.id,
        title: task.title,
        subtitle: '${store.courseName(task.courseId)} • entro ${dateLabel(task.dueDate)} • stimato ${minutesLabel(task.estimatedMinutes)}',
        date: task.dueDate,
        type: CalendarFilter.tasks,
        icon: Icons.task_alt_rounded,
        color: priorityColor(task.priority),
        minutes: task.estimatedMinutes,
        completed: task.status == ItemStatus.completed,
      );
}

class _CalendarMonthCard extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime selectedDate;
  final CalendarFilter filter;
  final ValueChanged<CalendarFilter> onFilterChanged;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDate;
  final List<CalendarEntry> Function(DateTime date) entriesForDay;

  const _CalendarMonthCard({required this.visibleMonth, required this.selectedDate, required this.filter, required this.onFilterChanged, required this.onPreviousMonth, required this.onNextMonth, required this.onSelectDate, required this.entriesForDay});

  @override
  Widget build(BuildContext context) {
    final days = calendarDaysForMonth(visibleMonth);
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _SoftIcon(icon: Icons.calendar_month_rounded, color: const Color(0xFF5B5FEF)),
            const SizedBox(width: 12),
            Expanded(child: Text(monthLabel(visibleMonth), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900))),
            AppIconButton(onPressed: onPreviousMonth, icon: Icons.chevron_left_rounded, tooltip: 'Mese precedente'),
            AppIconButton(onPressed: onNextMonth, icon: Icons.chevron_right_rounded, tooltip: 'Mese successivo'),
          ]),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<CalendarFilter>(
              selected: {filter},
              showSelectedIcon: false,
              onSelectionChanged: (values) => onFilterChanged(values.first),
              segments: CalendarFilter.values.map((e) => ButtonSegment(value: e, icon: Icon(e.icon, size: 18), label: Text(e.label))).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: const [
            _WeekdayHeader('Lun'), _WeekdayHeader('Mar'), _WeekdayHeader('Mer'), _WeekdayHeader('Gio'), _WeekdayHeader('Ven'), _WeekdayHeader('Sab'), _WeekdayHeader('Dom'),
          ]),
          const SizedBox(height: 6),
          LayoutBuilder(builder: (context, constraints) {
            final compact = constraints.maxWidth < 680;
            final veryCompact = constraints.maxWidth < 390;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: days.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisExtent: veryCompact ? 72 : compact ? 78 : 108,
                crossAxisSpacing: compact ? 4 : 8,
                mainAxisSpacing: compact ? 4 : 8,
              ),
              itemBuilder: (context, index) {
                final day = days[index];
                final entries = entriesForDay(day);
                return _CalendarDayCell(
                  date: day,
                  currentMonth: sameMonth(day, visibleMonth),
                  selected: sameDay(day, selectedDate),
                  today: sameDay(day, DateTime.now()),
                  entries: entries,
                  compact: compact,
                  onTap: () => onSelectDate(day),
                );
              },
            );
          }),
          const SizedBox(height: 12),
          const _CalendarLegend(),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  final String text;
  const _WeekdayHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Center(child: Text(text, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w900, fontSize: 12))));
  }
}

class _CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool currentMonth;
  final bool selected;
  final bool today;
  final bool compact;
  final List<CalendarEntry> entries;
  final VoidCallback onTap;

  const _CalendarDayCell({required this.date, required this.currentMonth, required this.selected, required this.today, required this.compact, required this.entries, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final study = entries.where((e) => e.type == CalendarFilter.study).length;
    final exams = entries.where((e) => e.type == CalendarFilter.exams).length;
    final tasks = entries.where((e) => e.type == CalendarFilter.tasks).length;
    final plannedMinutes = entries.where((e) => e.type == CalendarFilter.study).fold<int>(0, (sum, e) => sum + e.minutes);

    return InkWell(
      borderRadius: BorderRadius.circular(compact ? 14 : 20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(compact ? 5 : 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF5B5FEF) : currentMonth ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(compact ? 14 : 20),
          border: Border.all(color: selected ? const Color(0xFF5B5FEF) : today ? const Color(0xFF06B6D4) : const Color(0xFFE4EAF3), width: today || selected ? 1.6 : 1),
          boxShadow: selected ? [BoxShadow(color: const Color(0xFF5B5FEF).withOpacity(.28), blurRadius: 16, offset: const Offset(0, 10))] : null,
        ),
        child: compact
            ? Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: today && !selected ? const Color(0xFFE0F2FE) : selected ? Colors.white.withOpacity(.18) : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: selected ? Colors.white : currentMonth ? const Color(0xFF111827) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                  if (entries.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: selected ? Colors.white.withOpacity(.18) : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${entries.length}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: selected ? Colors.white : const Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (study > 0) _TinyDot(color: selected ? Colors.white : const Color(0xFF5B5FEF), count: 1),
                          if (study > 0 && (exams > 0 || tasks > 0)) const SizedBox(width: 3),
                          if (exams > 0) _TinyDot(color: selected ? Colors.white : const Color(0xFFF59E0B), count: 1),
                          if (exams > 0 && tasks > 0) const SizedBox(width: 3),
                          if (tasks > 0) _TinyDot(color: selected ? Colors.white : const Color(0xFF10B981), count: 1),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(color: today && !selected ? const Color(0xFFE0F2FE) : selected ? Colors.white.withOpacity(.18) : Colors.transparent, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text('${date.day}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: selected ? Colors.white : currentMonth ? const Color(0xFF111827) : const Color(0xFF94A3B8))),
                    ),
                    const Spacer(),
                    if (entries.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: selected ? Colors.white.withOpacity(.18) : const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(999)),
                        child: Text('${entries.length}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: selected ? Colors.white : const Color(0xFF2563EB))),
                      ),
                  ]),
                  const Spacer(),
                  if (plannedMinutes > 0)
                    Text(minutesLabel(plannedMinutes), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: selected ? Colors.white70 : const Color(0xFF64748B), fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Wrap(spacing: 4, runSpacing: 4, children: [
                    if (study > 0) _TinyDot(color: selected ? Colors.white : const Color(0xFF5B5FEF), count: study),
                    if (exams > 0) _TinyDot(color: selected ? Colors.white : const Color(0xFFF59E0B), count: exams),
                    if (tasks > 0) _TinyDot(color: selected ? Colors.white : const Color(0xFF10B981), count: tasks),
                  ]),
                ],
              ),
      ),
    );
  }
}

class _TinyDot extends StatelessWidget {
  final Color color;
  final int count;
  const _TinyDot({required this.color, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      width: count > 1 ? 18 : 8,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 10, runSpacing: 8, children: const [
      _LegendItem(color: Color(0xFF5B5FEF), text: 'Sessioni studio'),
      _LegendItem(color: Color(0xFFF59E0B), text: 'Esami/scadenze'),
      _LegendItem(color: Color(0xFF10B981), text: 'Obiettivi'),
    ]);
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800, fontSize: 12)),
    ]);
  }
}

class _DayAgendaPanel extends StatelessWidget {
  final DateTime selectedDate;
  final List<CalendarEntry> entries;
  final String monthLabel;
  final int plannedMinutesInMonth;
  final int completedStudyInMonth;
  final int highPriorityExamsInMonth;
  final VoidCallback onCreate;

  const _DayAgendaPanel({required this.selectedDate, required this.entries, required this.monthLabel, required this.plannedMinutesInMonth, required this.completedStudyInMonth, required this.highPriorityExamsInMonth, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final store = StudyScope.of(context);
    final selectedPlanned = entries.where((e) => e.type == CalendarFilter.study).fold<int>(0, (sum, e) => sum + e.minutes);
    return Column(
      children: [
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              _SoftIcon(icon: Icons.view_agenda_rounded, color: const Color(0xFF06B6D4)),
              const SizedBox(width: 12),
              Expanded(child: Text(sameDay(selectedDate, DateTime.now()) ? 'Agenda di oggi' : 'Agenda ${dateLabel(selectedDate)}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
              AppIconButton(onPressed: onCreate, icon: Icons.add_circle_rounded, tooltip: 'Aggiungi elemento'),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _Pill(text: '${entries.length} elementi', color: const Color(0xFF5B5FEF)),
              _Pill(text: minutesLabel(selectedPlanned), color: const Color(0xFF06B6D4)),
              if (entries.any((e) => !e.completed)) _Pill(text: 'Da completare', color: const Color(0xFFF59E0B)),
            ]),
            const SizedBox(height: 14),
            if (entries.isEmpty)
              _EmptyAgenda(onCreate: onCreate)
            else
              ...entries.map((entry) {
                final session = entry.type == CalendarFilter.study ? store.sessions.where((s) => s.id == entry.id).firstOrNull : null;
                final exam = entry.type == CalendarFilter.exams ? store.exams.where((e) => e.id == entry.id).firstOrNull : null;
                final task = entry.type == CalendarFilter.tasks ? store.tasks.where((t) => t.id == entry.id).firstOrNull : null;
                return _AgendaItemCard(
                  entry: entry,
                  onToggle: () {
                    if (session != null) {
                      store.upsertSession(StudySession(id: session.id, title: session.title, courseId: session.courseId, date: session.date, minutesPlanned: session.minutesPlanned, minutesDone: session.completed ? session.minutesDone : session.minutesPlanned, kind: session.kind, completed: !session.completed));
                    } else if (task != null) {
                      final completed = task.status == ItemStatus.completed;
                      store.upsertTask(TaskGoal(id: task.id, title: task.title, description: task.description, courseId: task.courseId, dueDate: task.dueDate, priority: task.priority, status: completed ? ItemStatus.future : ItemStatus.completed, estimatedMinutes: task.estimatedMinutes, actualMinutes: completed ? task.actualMinutes : task.estimatedMinutes));
                    } else if (exam != null) {
                      final completed = exam.status == ItemStatus.completed;
                      store.upsertExam(ExamItem(id: exam.id, title: exam.title, courseId: exam.courseId, date: exam.date, type: exam.type, priority: exam.priority, status: completed ? ItemStatus.future : ItemStatus.completed, notes: exam.notes, result: exam.result));
                    }
                  },
                  onEdit: () {
                    if (session != null) showDialog(context: context, builder: (_) => SessionDialog(item: session));
                    if (exam != null) showDialog(context: context, builder: (_) => ExamDialog(item: exam));
                    if (task != null) showDialog(context: context, builder: (_) => TaskDialog(item: task));
                  },
                  onDelete: () {
                    if (session != null) store.deleteSession(session.id);
                    if (exam != null) store.deleteExam(exam.id);
                    if (task != null) store.deleteTask(task.id);
                  },
                );
              }),
          ]),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const _SoftIcon(icon: Icons.insights_rounded, color: Color(0xFF8B5CF6)), const SizedBox(width: 12), Expanded(child: Text('Sintesi $monthLabel', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)))]),
            const SizedBox(height: 14),
            _MiniMetric(label: 'Ore pianificate', value: minutesLabel(plannedMinutesInMonth), icon: Icons.schedule_rounded),
            _MiniMetric(label: 'Sessioni completate', value: '$completedStudyInMonth', icon: Icons.check_circle_rounded),
            _MiniMetric(label: 'Esami ad alta priorità', value: '$highPriorityExamsInMonth', icon: Icons.priority_high_rounded),
          ]),
        ),
      ],
    );
  }
}

class _AgendaItemCard extends StatelessWidget {
  final CalendarEntry entry;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AgendaItemCard({required this.entry, required this.onToggle, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: entry.color.withOpacity(.08), borderRadius: BorderRadius.circular(22), border: Border.all(color: entry.color.withOpacity(.18))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: entry.color.withOpacity(.14), borderRadius: BorderRadius.circular(16)), child: Icon(entry.icon, color: entry.color)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(entry.title, style: TextStyle(fontWeight: FontWeight.w900, decoration: entry.completed ? TextDecoration.lineThrough : null))),
            _Pill(text: entry.type.label, color: entry.color),
          ]),
          const SizedBox(height: 5),
          Text(entry.subtitle, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700, height: 1.25)),
          const SizedBox(height: 8),
          Wrap(spacing: 4, children: [
            TextButton.icon(onPressed: onToggle, icon: Icon(entry.completed ? Icons.undo_rounded : Icons.done_rounded, size: 18), label: Text(entry.completed ? 'Riapri' : 'Completa')),
            TextButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_rounded, size: 18), label: const Text('Modifica')),
            TextButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded, size: 18), label: const Text('Elimina')),
          ]),
        ])),
      ]),
    );
  }
}

class _EmptyAgenda extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyAgenda({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFE4EAF3))),
      child: Column(children: [
        Icon(Icons.event_busy_rounded, size: 46, color: const Color(0xFF64748B).withOpacity(.75)),
        const SizedBox(height: 8),
        const Text('Nessun elemento in questa data', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text('Aggiungi una sessione, un esame o un obiettivo direttamente dal calendario.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        AppButton(onPressed: onCreate, icon: Icons.add_rounded, child: const Text('Aggiungi elemento')),
      ]),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MiniMetric({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14)), child: Icon(icon, size: 19, color: const Color(0xFF5B5FEF))),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ]),
    );
  }
}

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CreateOption({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: color.withOpacity(.08), borderRadius: BorderRadius.circular(22), border: Border.all(color: color.withOpacity(.16))),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(.13), borderRadius: BorderRadius.circular(18)), child: Icon(icon, color: color)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            ])),
            const Icon(Icons.chevron_right_rounded),
          ]),
        ),
      ),
    );
  }
}

class SessionDialog extends StatefulWidget {
  final StudySession? item;
  final DateTime? initialDate;
  const SessionDialog({super.key, this.item, this.initialDate});

  @override
  State<SessionDialog> createState() => _SessionDialogState();
}

class _SessionDialogState extends State<SessionDialog> {
  final title = TextEditingController();
  final minutes = TextEditingController();
  DateTime date = DateTime.now();
  StudyKind kind = StudyKind.study;
  String? courseId;

  @override
  void initState() {
    super.initState();
    title.text = widget.item?.title ?? '';
    minutes.text = '${widget.item?.minutesPlanned ?? 60}';
    final base = widget.item?.date ?? widget.initialDate ?? DateTime.now();
    final now = DateTime.now();
    date = DateTime(base.year, base.month, base.day, widget.item?.date.hour ?? now.hour, widget.item?.date.minute ?? 0);
    kind = widget.item?.kind ?? StudyKind.study;
    courseId = widget.item?.courseId;
  }

  @override
  void dispose() {
    title.dispose();
    minutes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StudyScope.of(context);
    courseId ??= store.courses.firstOrNull?.id;
    return AlertDialog(
      title: Text(widget.item == null ? 'Nuova sessione di studio' : 'Modifica sessione'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Titolo')),
        const SizedBox(height: 10),
        DropdownButtonFormField(value: courseId, decoration: const InputDecoration(labelText: 'Corso'), items: store.courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(), onChanged: (value) => setState(() => courseId = value)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: Text('Data: ${dateLabel(date)}', style: const TextStyle(fontWeight: FontWeight.w700))),
          TextButton(onPressed: () async {
            final picked = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2035), initialDate: date);
            if (picked != null) setState(() => date = DateTime(picked.year, picked.month, picked.day, date.hour, date.minute));
          }, child: const Text('Scegli')),
        ]),
        Row(children: [
          Expanded(child: Text('Ora inizio: ${timeLabel(date)}', style: const TextStyle(fontWeight: FontWeight.w700))),
          TextButton(onPressed: () async {
            final picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(date));
            if (picked != null) setState(() => date = DateTime(date.year, date.month, date.day, picked.hour, picked.minute));
          }, child: const Text('Scegli')),
        ]),
        TextField(controller: minutes, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Minuti pianificati')),
        const SizedBox(height: 10),
        DropdownButtonFormField(value: kind, decoration: const InputDecoration(labelText: 'Tipo'), items: StudyKind.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(), onChanged: (value) => setState(() => kind = value!)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
        AppButton(onPressed: () {
          if (courseId == null || title.text.trim().isEmpty) return;
          store.upsertSession(StudySession(
            id: widget.item?.id ?? id(),
            title: title.text.trim(),
            courseId: courseId!,
            date: date,
            minutesPlanned: int.tryParse(minutes.text) ?? 60,
            minutesDone: widget.item?.minutesDone ?? 0,
            kind: kind,
            completed: widget.item?.completed ?? false,
          ));
          Navigator.pop(context);
        }, child: const Text('Salva')),
      ],
    );
  }
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  Priority? priority;
  ItemStatus? status;
  String query = '';

  @override
  Widget build(BuildContext context) {
    final store = StudyScope.of(context);
    final list = store.tasks.where((e) {
      final matchesPriority = priority == null || e.priority == priority;
      final matchesStatus = status == null || e.status == status;
      final text = '${e.title} ${e.description} ${store.courseName(e.courseId)}'.toLowerCase();
      final matchesQuery = text.contains(query.toLowerCase());
      return matchesPriority && matchesStatus && matchesQuery;
    }).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final completed = store.tasks.where((t) => t.status == ItemStatus.completed).length;
    final progress = store.tasks.isEmpty ? 0.0 : completed / store.tasks.length;

    return PageFrame(
      title: 'Obiettivi',
      subtitle: 'Organizza attività, priorità, tempi stimati e avanzamento dei corsi.',
      actions: [AppButton(onPressed: () => showDialog(context: context, builder: (_) => const TaskDialog()), icon: Icons.add, child: const Text('Nuovo'))],
      child: Column(children: [
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const _SoftIcon(icon: Icons.flag_rounded, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Progresso obiettivi', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('$completed completati su ${store.tasks.length}', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
              ])),
              Text('${(progress * 100).round()}%', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF10B981))),
            ]),
            const SizedBox(height: 14),
            ClipRRect(borderRadius: BorderRadius.circular(999), child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: const Color(0xFFE2E8F0), color: const Color(0xFF10B981))),
          ]),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final search = TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Cerca task, corso o descrizione'),
            onChanged: (value) => setState(() => query = value),
          );
          final priorityField = DropdownButtonFormField<Priority?>(
            value: priority,
            decoration: const InputDecoration(labelText: 'Priorità'),
            items: [const DropdownMenuItem(value: null, child: Text('Tutte')), ...Priority.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label)))],
            onChanged: (value) => setState(() => priority = value),
          );
          final statusField = DropdownButtonFormField<ItemStatus?>(
            value: status,
            decoration: const InputDecoration(labelText: 'Stato'),
            items: [const DropdownMenuItem(value: null, child: Text('Tutti')), ...ItemStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label)))],
            onChanged: (value) => setState(() => status = value),
          );
          if (compact) {
            return Column(children: [search, const SizedBox(height: 10), Row(children: [Expanded(child: priorityField), const SizedBox(width: 10), Expanded(child: statusField)])]);
          }
          return Row(children: [Expanded(child: search), const SizedBox(width: 10), SizedBox(width: 190, child: priorityField), const SizedBox(width: 10), SizedBox(width: 190, child: statusField)]);
        }),
        const SizedBox(height: 12),
        Expanded(child: list.isEmpty
            ? AppCard(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.inbox_rounded, size: 54, color: Color(0xFF94A3B8)), SizedBox(height: 10), Text('Nessun obiettivo trovato', style: TextStyle(fontWeight: FontWeight.w900))])))
            : ListView.separated(itemCount: list.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (context, index) {
                final t = list[index];
                final color = priorityColor(t.priority);
                return AppCard(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Checkbox(
                      value: t.status == ItemStatus.completed,
                      onChanged: (value) => store.upsertTask(TaskGoal(id: t.id, title: t.title, description: t.description, courseId: t.courseId, dueDate: t.dueDate, priority: t.priority, status: value == true ? ItemStatus.completed : ItemStatus.future, estimatedMinutes: t.estimatedMinutes, actualMinutes: value == true ? t.estimatedMinutes : t.actualMinutes)),
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(child: Text(t.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, decoration: t.status == ItemStatus.completed ? TextDecoration.lineThrough : null))),
                        _Pill(text: t.priority.label, color: color),
                      ]),
                      const SizedBox(height: 5),
                      Text('${store.courseName(t.courseId)} • entro ${dateLabel(t.dueDate)}', style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(t.description.isEmpty ? 'Nessuna descrizione.' : t.description, style: const TextStyle(color: Color(0xFF475569), height: 1.3)),
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                        _Pill(text: 'Stimato ${minutesLabel(t.estimatedMinutes)}', color: const Color(0xFF5B5FEF)),
                        _Pill(text: 'Effettivo ${minutesLabel(t.actualMinutes)}', color: const Color(0xFF06B6D4)),
                        _Pill(text: t.status.label, color: statusColor(t.status)),
                        AppIconButton(onPressed: () => showDialog(context: context, builder: (_) => TaskDialog(item: t)), icon: Icons.edit_rounded, tooltip: 'Modifica'),
                        AppIconButton(onPressed: () => store.deleteTask(t.id), icon: Icons.delete_outline_rounded, tooltip: 'Elimina'),
                      ]),
                    ])),
                  ]),
                );
              })),
      ]),
    );
  }
}

class TaskDialog extends StatefulWidget {
  final TaskGoal? item;
  final DateTime? initialDate;
  const TaskDialog({super.key, this.item, this.initialDate});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final title = TextEditingController();
  final description = TextEditingController();
  final estimate = TextEditingController(text: '60');
  final actual = TextEditingController(text: '0');
  DateTime dueDate = DateTime.now().add(const Duration(days: 5));
  Priority priority = Priority.medium;
  ItemStatus status = ItemStatus.future;
  String? courseId;

  @override
  void initState() {
    super.initState();
    title.text = widget.item?.title ?? '';
    description.text = widget.item?.description ?? '';
    estimate.text = '${widget.item?.estimatedMinutes ?? 60}';
    actual.text = '${widget.item?.actualMinutes ?? 0}';
    dueDate = widget.item?.dueDate ?? widget.initialDate ?? DateTime.now().add(const Duration(days: 5));
    priority = widget.item?.priority ?? Priority.medium;
    status = widget.item?.status ?? ItemStatus.future;
    courseId = widget.item?.courseId;
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    estimate.dispose();
    actual.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StudyScope.of(context);
    courseId ??= store.courses.firstOrNull?.id;
    return AlertDialog(
      title: Text(widget.item == null ? 'Nuova attività/obiettivo' : 'Modifica attività/obiettivo'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Titolo')),
        const SizedBox(height: 10),
        TextField(controller: description, maxLines: 2, decoration: const InputDecoration(labelText: 'Descrizione')),
        const SizedBox(height: 10),
        DropdownButtonFormField(value: courseId, decoration: const InputDecoration(labelText: 'Corso'), items: store.courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(), onChanged: (value) => setState(() => courseId = value)),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: Text('Scadenza: ${dateLabel(dueDate)}', style: const TextStyle(fontWeight: FontWeight.w700))), TextButton(onPressed: () async { final picked = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2035), initialDate: dueDate); if (picked != null) setState(() => dueDate = picked); }, child: const Text('Scegli'))]),
        TextField(controller: estimate, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tempo stimato in minuti')),
        const SizedBox(height: 10),
        TextField(controller: actual, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tempo effettivo in minuti')),
        const SizedBox(height: 10),
        DropdownButtonFormField(value: priority, decoration: const InputDecoration(labelText: 'Priorità'), items: Priority.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(), onChanged: (value) => setState(() => priority = value!)),
        const SizedBox(height: 10),
        DropdownButtonFormField(value: status, decoration: const InputDecoration(labelText: 'Stato'), items: ItemStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(e.label))).toList(), onChanged: (value) => setState(() => status = value!)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
        AppButton(onPressed: () {
          if (courseId == null || title.text.trim().isEmpty) return;
          store.upsertTask(TaskGoal(id: widget.item?.id ?? id(), title: title.text.trim(), description: description.text.trim(), courseId: courseId!, dueDate: dueDate, priority: priority, status: status, estimatedMinutes: int.tryParse(estimate.text) ?? 60, actualMinutes: int.tryParse(actual.text) ?? 0));
          Navigator.pop(context);
        }, child: const Text('Salva')),
      ],
    );
  }
}

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const workSeconds = 25 * 60;
  static const pauseSeconds = 5 * 60;
  int remaining = workSeconds;
  bool running = false;
  bool pause = false;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void toggle() {
    if (running) {
      timer?.cancel();
      setState(() => running = false);
      return;
    }
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remaining <= 1) {
        setState(() {
          pause = !pause;
          remaining = pause ? pauseSeconds : workSeconds;
        });
      } else {
        setState(() => remaining--);
      }
    });
    setState(() => running = true);
  }

  void reset() {
    timer?.cancel();
    setState(() {
      running = false;
      pause = false;
      remaining = workSeconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.mobile(context);
    final totalSeconds = pause ? pauseSeconds : workSeconds;
    final progress = totalSeconds == 0 ? 0.0 : (1 - remaining / totalSeconds).clamp(0.0, 1.0).toDouble();
    final mm = (remaining ~/ 60).toString().padLeft(2, '0');
    final ss = (remaining % 60).toString().padLeft(2, '0');
    final timerSize = compact ? 268.0 : 360.0;
    final timerFont = compact ? 64.0 : 96.0;

    return PageFrame(
      title: 'Pomodoro',
      subtitle: 'Timer per alternare studio concentrato e pause brevi.',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: AppCard(
            padding: EdgeInsets.all(compact ? 24 : 38),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: (pause ? const Color(0xFFF59E0B) : const Color(0xFF5B5FEF)).withOpacity(.09),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: (pause ? const Color(0xFFF59E0B) : const Color(0xFF5B5FEF)).withOpacity(.18)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(pause ? '☕' : '🍅', style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      pause ? 'Pausa breve' : 'Studio concentrato',
                      style: TextStyle(color: pause ? const Color(0xFFF59E0B) : const Color(0xFF5B5FEF), fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              SizedBox(height: compact ? 22 : 30),
              SizedBox(
                width: timerSize,
                height: timerSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: timerSize,
                      height: timerSize,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: compact ? 12 : 16,
                        strokeCap: StrokeCap.round,
                        backgroundColor: AppStyle.surfaceAlt,
                        valueColor: AlwaysStoppedAnimation<Color>(pause ? const Color(0xFFF59E0B) : const Color(0xFF5B5FEF)),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$mm:$ss', style: TextStyle(fontSize: timerFont, height: .95, fontWeight: FontWeight.w900, letterSpacing: compact ? -2.0 : -4.0, color: AppStyle.ink)),
                        const SizedBox(height: 10),
                        Text(
                          running ? 'Timer in corso' : 'Pronto per iniziare',
                          style: const TextStyle(color: AppStyle.subtle, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: compact ? 24 : 34),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  AppButton(onPressed: toggle, icon: running ? Icons.pause_rounded : Icons.play_arrow_rounded, child: Text(running ? 'Pausa' : 'Avvia')),
                  OutlinedButton.icon(onPressed: reset, icon: const Icon(Icons.restart_alt_rounded), label: const Text('Reset')),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class PriorityChip extends StatelessWidget {
  final Priority priority;
  const PriorityChip(this.priority, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      Priority.high => Colors.red,
      Priority.medium => Colors.orange,
      Priority.low => Colors.green,
    };
    return Chip(label: Text(priority.label), side: BorderSide(color: color.withOpacity(.35)), backgroundColor: color.withOpacity(.08));
  }
}
