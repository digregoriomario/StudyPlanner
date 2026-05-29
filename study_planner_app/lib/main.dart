import 'package:flutter/material.dart';

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
    store = StudyStore();
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyPlanner',

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppStyle.ink),
        scaffoldBackgroundColor: AppStyle.background,
        textTheme: Typography.blackCupertino.apply(bodyColor: AppStyle.ink, displayColor: AppStyle.ink),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppStyle.ink,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, AppStyle.buttonHeight),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyle.buttonRadius)),
          ),
        ),
      ),

      home: StoreScope(notifier: store, child: const ShellScreen()),
    );
  }
}

class StoreScope extends InheritedNotifier<StudyStore> {
  const StoreScope({super.key, required super.notifier, required super.child});

  static StudyStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StoreScope>();
    return scope!.notifier!;
  }
}

class Course {
  final String name;
  final String teacher;
  final int cfu;
  final String status;

  Course(this.name, this.teacher, this.cfu, this.status);
}

class ExamItem {
  final String title;
  final String course;
  final DateTime date;
  final String priority;
  final String status;

  ExamItem(this.title, this.course, this.date, this.priority, this.status);
}

class StudySession {
  final String title;
  final String course;
  final DateTime date;
  final int minutes;
  bool completed;

  StudySession(this.title, this.course, this.date, this.minutes, this.completed);
}

class TaskGoal {
  final String title;
  final String course;
  final String priority;
  bool completed;

  TaskGoal(this.title, this.course, this.priority, this.completed);
}

class StudyStore extends ChangeNotifier {
  final List<Course> courses = [
    Course('Programmazione Mobile', 'Prof. Rossi', 9, 'In corso'),
    Course('Basi di Dati', 'Prof.ssa Bianchi', 6, 'Da ripassare'),
    Course('Ingegneria del Software', 'Prof. Verdi', 9, 'Da iniziare'),
  ];

  final List<ExamItem> exams = [ExamItem('Esame Mobile', 'Programmazione Mobile', DateTime.now().add(const Duration(days: 18)), 'Alta', 'Futuro'), ExamItem('Consegna progetto', 'Ingegneria del Software', DateTime.now().add(const Duration(days: 7)), 'Alta', 'Futuro'), ExamItem('Database', 'Basi di Dati', DateTime.now().add(const Duration(days: 34)), 'Media', 'Futuro')];

  final List<StudySession> sessions = [StudySession('Studio widget Flutter', 'Programmazione Mobile', DateTime.now(), 90, false), StudySession('Esercizi SQL', 'Basi di Dati', DateTime.now().add(const Duration(days: 1)), 120, false), StudySession('Ripasso UML', 'Ingegneria del Software', DateTime.now().add(const Duration(days: 2)), 60, false)];

  final List<TaskGoal> tasks = [TaskGoal('Completare mockup', 'Programmazione Mobile', 'Alta', false), TaskGoal('Ripassare normalizzazione', 'Basi di Dati', 'Media', false), TaskGoal('Preparare schema UML', 'Ingegneria del Software', 'Alta', false)];

  void addCourse(String name) {
    courses.add(Course(name, 'Docente da definire', 6, 'Da iniziare'));
    notifyListeners();
  }

  void addExam(String title) {
    exams.add(ExamItem(title, courses.first.name, DateTime.now().add(const Duration(days: 14)), 'Media', 'Futuro'));
    notifyListeners();
  }

  void addSession(String title) {
    sessions.add(StudySession(title, courses.first.name, DateTime.now(), 60, false));
    notifyListeners();
  }

  void addTask(String title) {
    tasks.add(TaskGoal(title, courses.first.name, 'Media', false));
    notifyListeners();
  }

  void toggleSession(StudySession session) {
    session.completed = !session.completed;
    notifyListeners();
  }

  void toggleTask(TaskGoal task) {
    task.completed = !task.completed;
    notifyListeners();
  }

  int automaticSuggestionCount() {
    final urgentExams = exams.where((exam) => exam.date.difference(DateTime.now()).inDays <= 30 && exam.status == 'Futuro').length;
    final openTasks = tasks.where((task) => !task.completed).length;
    final plannedMinutes = sessions.fold<int>(0, (sum, session) => sum + session.minutes);
    var value = urgentExams;
    if (openTasks > 0) value++;
    if (plannedMinutes < 240 && urgentExams > 0) value++;
    return value;
  }
}

class AppStyle {
  static const Color background = Color(0xFFF6F5F1);
  static const Color surface = Colors.white;
  static const Color surfaceAlt = Color(0xFFF8F7F3);
  static const Color ink = Color(0xFF111111);
  static const Color muted = Color(0xFF6F6F6F);
  static const Color line = Color(0xFFE8E4DA);
  static const double buttonHeight = 46;
  static const double buttonRadius = 14;
}

class _Section {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;

  const _Section(this.label, this.icon, this.selectedIcon, this.page);
}

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int selected = 0;

  void _goTo(String label) {
    final index = sections.indexWhere((section) => section.label == label);
    if (index >= 0) setState(() => selected = index);
  }

  List<_Section> get sections {
    final store = StoreScope.of(context);
    return [
      _Section('Home', Icons.dashboard_outlined, Icons.dashboard, HomeScreen(onNavigate: _goTo)),
      _Section('Corsi', Icons.menu_book_outlined, Icons.menu_book, CoursesScreen(store: store)),
      _Section('Esami', Icons.event_outlined, Icons.event, ExamsScreen(store: store)),
      _Section('Calendario', Icons.calendar_month_outlined, Icons.calendar_month, PlannerScreen(store: store)),
      _Section('Obiettivi', Icons.task_alt_outlined, Icons.task_alt, TasksScreen(store: store)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = sections;
    const wide = false;
    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            Container(
              width: 280,
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(color: AppStyle.surface, border: Border(right: BorderSide(color: AppStyle.line))),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('StudyPlanner', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 24),
                    ...List.generate(items.length, (index) {
                      final active = selected == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: FilledButton.tonal(
                          onPressed: () => setState(() => selected = index),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, AppStyle.buttonHeight),
                            backgroundColor: active ? AppStyle.ink : AppStyle.surfaceAlt,
                            foregroundColor: active ? Colors.white : AppStyle.ink,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyle.buttonRadius)),
                          ),
                          child: Row(children: [Icon(active ? items[index].selectedIcon : items[index].icon), const SizedBox(width: 10), Text(items[index].label)]),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Expanded(child: items[selected].page),
          ],
        ),
      );
    }
    return Scaffold(
      body: items[selected].page,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (value) => setState(() => selected = value),
        destinations: items.map((section) => NavigationDestination(icon: Icon(section.icon), selectedIcon: Icon(section.selectedIcon), label: section.label)).toList(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final ValueChanged<String> onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);

    final cards = <Widget>[
      StatCard(label: 'Corsi totali', value: '${store.courses.length}', icon: Icons.menu_book_rounded, onTap: () => onNavigate('Corsi')),
      StatCard(label: 'Esami futuri', value: '${store.exams.length}', icon: Icons.event_rounded, onTap: () => onNavigate('Esami')),
      StatCard(label: 'Studio pianificato', value: minutesLabel(store.sessions.fold<int>(0, (sum, session) => sum + session.minutes)), icon: Icons.schedule_rounded, onTap: () => onNavigate('Calendario')),
      StatCard(label: 'Obiettivi aperti', value: '${store.tasks.where((task) => !task.completed).length}', icon: Icons.task_alt_rounded, onTap: () => onNavigate('Obiettivi')),
      StatCard(label: 'CFU inseriti', value: '${store.courses.fold<int>(0, (sum, course) => sum + course.cfu)}', icon: Icons.school_rounded, onTap: () => onNavigate('Corsi')),
    ];

    return PageFrame(
      title: 'Home',
      subtitle: 'Riepilogo dello studio, delle scadenze e degli obiettivi.',
      child: ListView(
        children: [
          
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: cards,
            ),

        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const StatCard({super.key, required this.label, required this.value, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon), const Spacer(), const Icon(Icons.arrow_forward_rounded, size: 18)]),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppStyle.muted, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class CoursesScreen extends StatefulWidget {
  final StudyStore store;

  const CoursesScreen({super.key, required this.store});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final data = widget.store.courses.where((course) => course.name.toLowerCase().contains(query.toLowerCase())).toList();
    return PageFrame(
      title: 'Corsi',
      subtitle: 'Elenco degli insegnamenti con stato, docente e CFU.',
      actions: [FilledButton.icon(onPressed: () => showTextDialog(context, 'Nuovo corso', widget.store.addCourse), icon: const Icon(Icons.add), label: const Text('Aggiungi'))],
      child: ListView(
        children: [
          TextField(decoration: const InputDecoration(labelText: 'Cerca corso'), onChanged: (value) => setState(() => query = value)), const SizedBox(height: 12),
          ...data.map((course) => AppCard(
            child: Row(
              children: [
                const Icon(Icons.menu_book_rounded),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(course.name, style: const TextStyle(fontWeight: FontWeight.w900)), Text('${course.teacher} • ${course.cfu} CFU • ${course.status}')])),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class ExamsScreen extends StatelessWidget {
  final StudyStore store;

  const ExamsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'Esami',
      subtitle: 'Appelli, consegne e scadenze ordinate per data.',
      actions: [FilledButton.icon(onPressed: () => showTextDialog(context, 'Nuovo esame', store.addExam), icon: const Icon(Icons.add), label: const Text('Aggiungi'))],
      child: ListView(
        children: store.exams.map((exam) => AppCard(
          child: Row(
            children: [
              const Icon(Icons.event_rounded),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(exam.title, style: const TextStyle(fontWeight: FontWeight.w900)), Text('${exam.course} • ${dateLabel(exam.date)} • ${exam.status}') ])),
              Text(exam.priority, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        )).toList(),
      ),
    );
  }
}

class PlannerScreen extends StatelessWidget {
  final StudyStore store;

  const PlannerScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'Calendario',
      subtitle: 'Sessioni pianificate e attività giornaliere.',
      actions: [FilledButton.icon(onPressed: () => showTextDialog(context, 'Nuova sessione', store.addSession), icon: const Icon(Icons.add), label: const Text('Aggiungi'))],
      child: ListView(
        children: [
          
          ...store.sessions.map((session) => AppCard(
            child: Row(
              children: [
                Checkbox(value: session.completed, onChanged: (value) => store.toggleSession(session)),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(session.title, style: const TextStyle(fontWeight: FontWeight.w900)), Text('${session.course} • ${dateLabel(session.date)} • ${minutesLabel(session.minutes)}') ])),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class TasksScreen extends StatelessWidget {
  final StudyStore store;

  const TasksScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'Obiettivi',
      subtitle: 'Attività e obiettivi di studio collegati ai corsi.',
      actions: [FilledButton.icon(onPressed: () => showTextDialog(context, 'Nuovo obiettivo', store.addTask), icon: const Icon(Icons.add), label: const Text('Aggiungi'))],
      child: ListView(
        children: store.tasks.map((task) => AppCard(
          child: Row(
            children: [
              Checkbox(value: task.completed, onChanged: (value) => store.toggleTask(task)),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(task.title, style: const TextStyle(fontWeight: FontWeight.w900)), Text('${task.course} • Priorità ${task.priority}') ])),
            ],
          ),
        )).toList(),
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: AppStyle.muted, fontWeight: FontWeight.w600))])),
                ...actions,
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;

  const AppCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStyle.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppStyle.line),
      ),
      child: child,
    );
  }
}

Future<void> showTextDialog(BuildContext context, String title, ValueChanged<String> onSubmit) async {
  final controller = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
        FilledButton(onPressed: () { if (controller.text.trim().isNotEmpty) onSubmit(controller.text.trim()); Navigator.pop(context); }, child: const Text('Salva')),
      ],
    ),
  );
}

String dateLabel(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String minutesLabel(int value) {
  final hours = value ~/ 60;
  final minutes = value % 60;
  if (hours == 0) return '${minutes}m';
  if (minutes == 0) return '${hours}h';
  return '${hours}h ${minutes}m';
}

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
