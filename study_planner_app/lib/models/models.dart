part of '../main.dart';

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

T enumByName<T extends Enum>(List<T> values, String name, T fallback) =>
    values.where((e) => e.name == name).firstOrNull ?? fallback;

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

  Course(
      {required this.id,
      required this.name,
      required this.teacher,
      required this.semester,
      required this.cfu,
      required this.status,
      this.desiredGrade,
      this.finalGrade,
      required this.notes});

  Course copyWith(
          {String? name,
          String? teacher,
          String? semester,
          int? cfu,
          CourseStatus? status,
          int? desiredGrade,
          int? finalGrade,
          String? notes}) =>
      Course(
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'teacher': teacher,
        'semester': semester,
        'cfu': cfu,
        'status': status.name,
        'desiredGrade': desiredGrade,
        'finalGrade': finalGrade,
        'notes': notes
      };
  factory Course.fromJson(Map<String, dynamic> json) => Course(
      id: json['id'],
      name: json['name'],
      teacher: json['teacher'],
      semester: json['semester'],
      cfu: json['cfu'],
      status:
          enumByName(CourseStatus.values, json['status'], CourseStatus.toStart),
      desiredGrade: json['desiredGrade'],
      finalGrade: json['finalGrade'],
      notes: json['notes']);
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

  ExamItem(
      {required this.id,
      required this.title,
      required this.courseId,
      required this.date,
      required this.type,
      required this.priority,
      required this.status,
      required this.notes,
      this.result});
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'courseId': courseId,
        'date': date.toIso8601String(),
        'type': type.name,
        'priority': priority.name,
        'status': status.name,
        'notes': notes,
        'result': result
      };
  factory ExamItem.fromJson(Map<String, dynamic> json) => ExamItem(
      id: json['id'],
      title: json['title'],
      courseId: json['courseId'],
      date: DateTime.parse(json['date']),
      type: enumByName(ExamType.values, json['type'], ExamType.exam),
      priority: enumByName(Priority.values, json['priority'], Priority.medium),
      status: enumByName(ItemStatus.values, json['status'], ItemStatus.future),
      notes: json['notes'],
      result: json['result']);
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

  StudySession(
      {required this.id,
      required this.title,
      required this.courseId,
      required this.date,
      required this.minutesPlanned,
      required this.minutesDone,
      required this.kind,
      required this.completed});
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'courseId': courseId,
        'date': date.toIso8601String(),
        'minutesPlanned': minutesPlanned,
        'minutesDone': minutesDone,
        'kind': kind.name,
        'completed': completed
      };
  factory StudySession.fromJson(Map<String, dynamic> json) => StudySession(
      id: json['id'],
      title: json['title'],
      courseId: json['courseId'],
      date: DateTime.parse(json['date']),
      minutesPlanned: json['minutesPlanned'],
      minutesDone: json['minutesDone'],
      kind: enumByName(StudyKind.values, json['kind'], StudyKind.study),
      completed: json['completed']);
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

  TaskGoal(
      {required this.id,
      required this.title,
      required this.description,
      required this.courseId,
      required this.dueDate,
      required this.priority,
      required this.status,
      required this.estimatedMinutes,
      required this.actualMinutes});
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'courseId': courseId,
        'dueDate': dueDate.toIso8601String(),
        'priority': priority.name,
        'status': status.name,
        'estimatedMinutes': estimatedMinutes,
        'actualMinutes': actualMinutes
      };
  factory TaskGoal.fromJson(Map<String, dynamic> json) => TaskGoal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      courseId: json['courseId'],
      dueDate: DateTime.parse(json['dueDate']),
      priority: enumByName(Priority.values, json['priority'], Priority.medium),
      status: enumByName(ItemStatus.values, json['status'], ItemStatus.future),
      estimatedMinutes: json['estimatedMinutes'],
      actualMinutes: json['actualMinutes']);
}
