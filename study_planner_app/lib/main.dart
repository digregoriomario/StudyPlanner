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
  

  @override
  void initState() {
    super.initState();
    
  }

  @override
  void dispose() {
    
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

      home: const ShellScreen(),
    );
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
    
    return [
      _Section('Home', Icons.dashboard_outlined, Icons.dashboard, HomeScreen(onNavigate: _goTo)),
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
    

    return PageFrame(
      title: 'Home',
      subtitle: 'Struttura iniziale dell\'app con navigazione e schermata principale.',
      child: ListView(
        children: [
          const AppCard(child: Text('StudyPlanner organizza corsi, esami, sessioni e obiettivi in un unico spazio.')),
        ],
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
