import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_planner_exam_tracker/main.dart';

void main() {
  test('StudyStore starts empty without demo data', () async {
    SharedPreferences.setMockInitialValues({});
    final store = StudyStore();

    await store.load();

    expect(store.courses, isEmpty);
    expect(store.exams, isEmpty);
    expect(store.sessions, isEmpty);
    expect(store.tasks, isEmpty);
  });

  test('StudyStore removes legacy demo data from storage', () async {
    final legacySnapshot = {
      'courses': [
        {
          'id': 'c1',
          'name': 'Programmazione Mobile',
          'teacher': 'Prof. Rossi',
          'semester': 'II semestre',
          'cfu': 9,
          'status': 'inProgress',
          'desiredGrade': 28,
          'finalGrade': null,
          'notes': 'Flutter, navigazione, stato e persistenza.'
        }
      ],
      'exams': [
        {
          'id': 'e1',
          'title': 'Esame Mobile',
          'courseId': 'c1',
          'date': DateTime(2026, 6, 15).toIso8601String(),
          'type': 'exam',
          'priority': 'high',
          'status': 'future',
          'notes': 'Ripassare gestione stato e storage.',
          'result': null
        }
      ],
      'sessions': [
        {
          'id': 's1',
          'title': 'Studio widget Flutter',
          'courseId': 'c1',
          'date': DateTime(2026, 6, 1).toIso8601String(),
          'minutesPlanned': 90,
          'minutesDone': 70,
          'kind': 'study',
          'completed': false
        }
      ],
      'tasks': [
        {
          'id': 't1',
          'title': 'Rifinire schermate principali',
          'description':
              'Organizzare il flusso tra dashboard, calendario e obiettivi.',
          'courseId': 'c1',
          'dueDate': DateTime(2026, 6, 4).toIso8601String(),
          'priority': 'high',
          'status': 'future',
          'estimatedMinutes': 120,
          'actualMinutes': 40
        }
      ],
    };
    SharedPreferences.setMockInitialValues(
        {StudyStore.storageKey: jsonEncode(legacySnapshot)});
    final store = StudyStore();

    await store.load();

    expect(store.courses, isEmpty);
    expect(store.exams, isEmpty);
    expect(store.sessions, isEmpty);
    expect(store.tasks, isEmpty);

    final prefs = await SharedPreferences.getInstance();
    final stored = jsonDecode(prefs.getString(StudyStore.storageKey)!)
        as Map<String, dynamic>;
    expect(stored['courses'], isEmpty);
    expect(stored['exams'], isEmpty);
    expect(stored['sessions'], isEmpty);
    expect(stored['tasks'], isEmpty);
  });

  testWidgets('StudyPlanner app loads', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const StudyPlannerApp());
    await tester.pump();
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('Desktop sidebar shows StudyPlanner logo and title',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const StudyPlannerApp());
    await tester.pumpAndSettle();

    expect(find.text('StudyPlanner'), findsOneWidget);
    expect(
        find.image(
            const AssetImage('assets/branding/studyplanner_logo_1024.png')),
        findsOneWidget);
  });

  testWidgets('Exam dialog starts without a guessed date', (tester) async {
    final store = StudyStore()
      ..courses = [
        Course(
            id: 'mobile',
            name: 'Mobile Programming',
            teacher: '',
            semester: '',
            cfu: 9,
            status: CourseStatus.inProgress,
            notes: '')
      ];

    await tester.pumpWidget(StudyScope(
      notifier: store,
      child: MaterialApp(
        home: Builder(builder: (context) {
          return Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                  context: context, builder: (_) => const ExamDialog()),
              child: const Text('Apri esame'),
            ),
          );
        }),
      ),
    ));
    await tester.tap(find.text('Apri esame'));
    await tester.pumpAndSettle();

    expect(find.text('Data: nessuna data selezionata'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Esame Mobile');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(store.exams, isEmpty);
    expect(find.text('Controlla i dati'), findsOneWidget);
    expect(find.text('Scegli la data dell\'esame o della scadenza.'),
        findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Exam dialog fits on compact screens without overflow',
      (tester) async {
    final flutterErrors = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = flutterErrors.add;
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      FlutterError.onError = previousOnError;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final store = StudyStore()
      ..courses = [
        Course(
            id: 'mobile',
            name: 'Mobile Programming con nome corso abbastanza lungo',
            teacher: '',
            semester: '1° semestre',
            cfu: 9,
            status: CourseStatus.inProgress,
            notes: '')
      ];

    await tester.pumpWidget(StudyScope(
      notifier: store,
      child: MaterialApp(
        home: Builder(builder: (context) {
          return Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                  context: context, builder: (_) => const ExamDialog()),
              child: const Text('Apri esame'),
            ),
          );
        }),
      ),
    ));
    await tester.tap(find.text('Apri esame'));
    await tester.pumpAndSettle();
    FlutterError.onError = previousOnError;

    expect(find.text('Nuovo esame/scadenza'), findsOneWidget);
    expect(find.text('Data: nessuna data selezionata'), findsOneWidget);
    expect(flutterErrors, isEmpty,
        reason: flutterErrors.map((error) => error.toString()).join('\n\n'));
  });

  testWidgets('Course dialog requires semester from a select', (tester) async {
    final store = StudyStore();

    await tester.pumpWidget(StudyScope(
      notifier: store,
      child: MaterialApp(
        home: Builder(builder: (context) {
          return Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                  context: context, builder: (_) => const CourseDialog()),
              child: const Text('Apri corso'),
            ),
          );
        }),
      ),
    ));
    await tester.tap(find.text('Apri corso'));
    await tester.pumpAndSettle();

    expect(find.text('Semestre'), findsOneWidget);
    expect(find.text('Voto obiettivo'), findsOneWidget);
    expect(find.text('Voto finale'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Mobile Programming');
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(store.courses, isEmpty);
    expect(find.text('Controlla i dati'), findsOneWidget);
    expect(find.text('Seleziona il semestre del corso.'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Task dialog fits on compact screens without overflow',
      (tester) async {
    final flutterErrors = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = flutterErrors.add;
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      FlutterError.onError = previousOnError;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final store = StudyStore()
      ..courses = [
        Course(
            id: 'mobile',
            name: 'Mobile Programming con nome corso abbastanza lungo',
            teacher: '',
            semester: '1° semestre',
            cfu: 9,
            status: CourseStatus.inProgress,
            notes: '')
      ];

    await tester.pumpWidget(StudyScope(
      notifier: store,
      child: MaterialApp(
        home: Builder(builder: (context) {
          return Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                  context: context, builder: (_) => const TaskDialog()),
              child: const Text('Apri obiettivo'),
            ),
          );
        }),
      ),
    ));
    await tester.tap(find.text('Apri obiettivo'));
    await tester.pumpAndSettle();
    FlutterError.onError = previousOnError;

    expect(find.text('Nuova attività/obiettivo'), findsOneWidget);
    expect(find.textContaining('Scadenza:'), findsOneWidget);
    expect(flutterErrors, isEmpty,
        reason: flutterErrors.map((error) => error.toString()).join('\n\n'));
  });

  testWidgets('Dashboard adapts on narrow screens without overflow',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final flutterErrors = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = flutterErrors.add;
    tester.view.physicalSize = const Size(360, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      FlutterError.onError = previousOnError;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const StudyPlannerApp());
    await tester.pump();
    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await tester.pump();
    FlutterError.onError = previousOnError;

    expect(find.text('Suggerimenti automatici'), findsWidgets);
    expect(flutterErrors, isEmpty,
        reason: flutterErrors.map((error) => error.toString()).join('\n\n'));
  });
}
