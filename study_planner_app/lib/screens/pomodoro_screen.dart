part of '../main.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const workSeconds = 25 * 60;
  static const pauseSeconds = 5 * 60;
  int remaining = workSeconds;
  int studiedSeconds = 0;
  bool running = false;
  bool pause = false;
  String? selectedCourseId;
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
          if (!pause) {
            studiedSeconds += 1;
          }
          pause = !pause;
          remaining = pause ? pauseSeconds : workSeconds;
        });
      } else {
        setState(() {
          if (!pause) {
            studiedSeconds += 1;
          }
          remaining--;
        });
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

  Future<void> recordStudy(StudyStore store) async {
    if (selectedCourseId == null) {
      showAppMessage(
          context, 'Seleziona un corso prima di registrare il Pomodoro.');
      return;
    }
    final minutes = (studiedSeconds / 60).ceil();
    if (minutes <= 0) {
      showAppMessage(
          context, 'Avvia il timer prima di registrare una sessione.');
      return;
    }
    await store.upsertSession(StudySession(
      id: id(),
      title: 'Pomodoro - ${store.courseName(selectedCourseId)}',
      courseId: selectedCourseId!,
      date: DateTime.now().subtract(Duration(minutes: minutes)),
      minutesPlanned: minutes,
      minutesDone: minutes,
      kind: StudyKind.study,
      completed: true,
    ));
    if (!mounted) {
      return;
    }
    setState(() => studiedSeconds = 0);
    showAppMessage(
        context, 'Sessione Pomodoro registrata: ${minutesLabel(minutes)}.');
  }

  @override
  Widget build(BuildContext context) {
    final store = StudyScope.of(context);
    if (selectedCourseId == null ||
        !store.courses.any((course) => course.id == selectedCourseId)) {
      selectedCourseId = store.courses.firstOrNull?.id;
    }
    final compact = Responsive.mobile(context);
    final totalSeconds = pause ? pauseSeconds : workSeconds;
    final progress = totalSeconds == 0
        ? 0.0
        : (1 - remaining / totalSeconds).clamp(0.0, 1.0).toDouble();
    final mm = (remaining ~/ 60).toString().padLeft(2, '0');
    final ss = (remaining % 60).toString().padLeft(2, '0');
    final timerSize = compact ? 214.0 : 250.0;
    final timerFont = compact ? 52.0 : 66.0;
    final studiedMinutes = (studiedSeconds / 60).ceil();

    return PageFrame(
      title: 'Pomodoro 🍅',
      subtitle: 'Timer 25/5 per alternare studio concentrato e pause brevi.',
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: AppCard(
                padding: EdgeInsets.all(compact ? 18 : 24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedCourseId,
                    decoration:
                        const InputDecoration(labelText: 'Corso collegato'),
                    items: store.courses
                        .map((course) => DropdownMenuItem(
                            value: course.id, child: Text(course.name)))
                        .toList(),
                    onChanged: running
                        ? null
                        : (value) => setState(() => selectedCourseId = value),
                  ),
                  SizedBox(height: compact ? 18 : 22),
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
                            valueColor: AlwaysStoppedAnimation<Color>(pause
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF5B5FEF)),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$mm:$ss',
                                style: TextStyle(
                                    fontSize: timerFont,
                                    height: .95,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0,
                                    color: AppStyle.ink)),
                            const SizedBox(height: 10),
                            Text(
                              running
                                  ? 'Timer in corso'
                                  : 'Pronto per iniziare',
                              style: const TextStyle(
                                  color: AppStyle.subtle,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: compact ? 18 : 22),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      AppButton(
                          onPressed: toggle,
                          icon: running
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          child: Text(running ? 'Pausa' : 'Avvia')),
                      OutlinedButton.icon(
                          onPressed: reset,
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text('Reset')),
                      OutlinedButton.icon(
                        onPressed: studiedMinutes > 0
                            ? () => recordStudy(store)
                            : null,
                        icon: const Icon(Icons.add_task_rounded),
                        label: Text(studiedMinutes > 0
                            ? 'Registra ${minutesLabel(studiedMinutes)}'
                            : 'Registra'),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ),
        );
      }),
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
    return Chip(
        label: Text(priority.label),
        side: BorderSide(color: color.withValues(alpha: .35)),
        backgroundColor: color.withValues(alpha: .08));
  }
}
