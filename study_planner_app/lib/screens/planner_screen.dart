part of '../main.dart';

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
    final plannedMinutes = monthEntries
        .where((e) => e.type == CalendarFilter.study)
        .fold<int>(0, (sum, e) => sum + e.minutes);
    final completedStudy = store.sessions
        .where((s) => sameMonth(s.date, visibleMonth) && s.completed)
        .length;
    final upcomingCritical = store.exams
        .where((e) =>
            sameMonth(e.date, visibleMonth) &&
            e.status == ItemStatus.future &&
            e.priority == Priority.high)
        .length;

    return PageFrame(
      title: 'Calendario',
      subtitle:
          'Pianifica sessioni, esami e obiettivi direttamente sui giorni del mese.',
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
          onPreviousMonth: () => setState(() => visibleMonth =
              DateTime(visibleMonth.year, visibleMonth.month - 1)),
          onNextMonth: () => setState(() => visibleMonth =
              DateTime(visibleMonth.year, visibleMonth.month + 1)),
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
    for (final session in store.sessions
        .where((s) => !s.date.isBefore(start) && s.date.isBefore(end))) {
      result.add(CalendarEntry.fromSession(session, store));
    }
    for (final exam in store.exams
        .where((e) => !e.date.isBefore(start) && e.date.isBefore(end))) {
      result.add(CalendarEntry.fromExam(exam, store));
    }
    for (final task in store.tasks
        .where((t) => !t.dueDate.isBefore(start) && t.dueDate.isBefore(end))) {
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
    return _applyFilter(result)
      ..sort((a, b) {
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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Crea elemento per ${dateLabel(date)}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              _CreateOption(
                icon: Icons.auto_stories_rounded,
                color: const Color(0xFF5B5FEF),
                title: 'Sessione di studio',
                subtitle:
                    'Studio, ripasso, esercizi o lettura con durata pianificata.',
                onTap: () {
                  Navigator.pop(sheetContext);
                  showDialog(
                      context: context,
                      builder: (_) => SessionDialog(initialDate: date));
                },
              ),
              _CreateOption(
                icon: Icons.school_rounded,
                color: const Color(0xFFF59E0B),
                title: 'Esame o scadenza',
                subtitle:
                    'Appello, consegna, progetto o altra data importante.',
                onTap: () {
                  Navigator.pop(sheetContext);
                  showDialog(
                      context: context,
                      builder: (_) => ExamDialog(initialDate: date));
                },
              ),
              _CreateOption(
                icon: Icons.task_alt_rounded,
                color: const Color(0xFF10B981),
                title: 'Obiettivo',
                subtitle:
                    'Obiettivo collegato a un corso con priorità e tempo stimato.',
                onTap: () {
                  Navigator.pop(sheetContext);
                  showDialog(
                      context: context,
                      builder: (_) => TaskDialog(initialDate: date));
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

  CalendarEntry(
      {required this.id,
      required this.title,
      required this.subtitle,
      required this.date,
      required this.type,
      required this.icon,
      required this.color,
      this.minutes = 0,
      this.completed = false,
      this.onToggle,
      this.onEdit,
      this.onDelete});

  factory CalendarEntry.fromSession(StudySession session, StudyStore store) =>
      CalendarEntry(
        id: session.id,
        title: session.title,
        subtitle:
            '${store.courseName(session.courseId)} • ${session.kind.label} • ${timeLabel(session.date)} • ${minutesLabel(session.minutesPlanned)}',
        date: session.date,
        type: CalendarFilter.study,
        icon: Icons.auto_stories_rounded,
        color: courseAccent(session.courseId),
        minutes: session.minutesPlanned,
        completed: session.completed,
      );

  factory CalendarEntry.fromExam(ExamItem exam, StudyStore store) =>
      CalendarEntry(
        id: exam.id,
        title: exam.title,
        subtitle:
            '${store.courseName(exam.courseId)} • ${exam.type.label} • priorità ${exam.priority.label.toLowerCase()}',
        date: exam.date,
        type: CalendarFilter.exams,
        icon: exam.type == ExamType.deadline
            ? Icons.assignment_rounded
            : Icons.school_rounded,
        color: priorityColor(exam.priority),
        completed: exam.status == ItemStatus.completed,
      );

  factory CalendarEntry.fromTask(TaskGoal task, StudyStore store) =>
      CalendarEntry(
        id: task.id,
        title: task.title,
        subtitle:
            '${store.courseName(task.courseId)} • entro ${dateLabel(task.dueDate)} • stimato ${minutesLabel(task.estimatedMinutes)}',
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

  const _CalendarMonthCard(
      {required this.visibleMonth,
      required this.selectedDate,
      required this.filter,
      required this.onFilterChanged,
      required this.onPreviousMonth,
      required this.onNextMonth,
      required this.onSelectDate,
      required this.entriesForDay});

  @override
  Widget build(BuildContext context) {
    final days = calendarDaysForMonth(visibleMonth);
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const _SoftIcon(
                icon: Icons.calendar_month_rounded, color: Color(0xFF5B5FEF)),
            const SizedBox(width: 12),
            Expanded(
                child: Text(monthLabel(visibleMonth),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900))),
            AppIconButton(
                onPressed: onPreviousMonth,
                icon: Icons.chevron_left_rounded,
                tooltip: 'Mese precedente'),
            AppIconButton(
                onPressed: onNextMonth,
                icon: Icons.chevron_right_rounded,
                tooltip: 'Mese successivo'),
          ]),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<CalendarFilter>(
              selected: {filter},
              showSelectedIcon: false,
              onSelectionChanged: (values) => onFilterChanged(values.first),
              segments: CalendarFilter.values
                  .map((e) => ButtonSegment(
                      value: e,
                      icon: Icon(e.icon, size: 18),
                      label: Text(e.label)))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          const Row(children: [
            _WeekdayHeader('Lun'),
            _WeekdayHeader('Mar'),
            _WeekdayHeader('Mer'),
            _WeekdayHeader('Gio'),
            _WeekdayHeader('Ven'),
            _WeekdayHeader('Sab'),
            _WeekdayHeader('Dom'),
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
                mainAxisExtent: veryCompact
                    ? 72
                    : compact
                        ? 78
                        : 108,
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
    return Expanded(
        child: Center(
            child: Text(text,
                style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w900,
                    fontSize: 12))));
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

  const _CalendarDayCell(
      {required this.date,
      required this.currentMonth,
      required this.selected,
      required this.today,
      required this.compact,
      required this.entries,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final study = entries.where((e) => e.type == CalendarFilter.study).length;
    final exams = entries.where((e) => e.type == CalendarFilter.exams).length;
    final tasks = entries.where((e) => e.type == CalendarFilter.tasks).length;
    final plannedMinutes = entries
        .where((e) => e.type == CalendarFilter.study)
        .fold<int>(0, (sum, e) => sum + e.minutes);

    return InkWell(
      borderRadius: BorderRadius.circular(compact ? 14 : 20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.all(compact ? 5 : 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF5B5FEF)
              : currentMonth
                  ? const Color(0xFFF8FAFC)
                  : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(compact ? 14 : 20),
          border: Border.all(
              color: selected
                  ? const Color(0xFF5B5FEF)
                  : today
                      ? const Color(0xFF06B6D4)
                      : const Color(0xFFE4EAF3),
              width: today || selected ? 1.6 : 1),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: const Color(0xFF5B5FEF).withValues(alpha: .28),
                      blurRadius: 16,
                      offset: const Offset(0, 10))
                ]
              : null,
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
                        color: today && !selected
                            ? const Color(0xFFE0F2FE)
                            : selected
                                ? Colors.white.withValues(alpha: .18)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: selected
                              ? Colors.white
                              : currentMonth
                                  ? const Color(0xFF111827)
                                  : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                  if (entries.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 1,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white.withValues(alpha: .18)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${entries.length}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF2563EB),
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
                          if (study > 0)
                            _TinyDot(
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF5B5FEF),
                                count: 1),
                          if (study > 0 && (exams > 0 || tasks > 0))
                            const SizedBox(width: 3),
                          if (exams > 0)
                            _TinyDot(
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFFF59E0B),
                                count: 1),
                          if (exams > 0 && tasks > 0) const SizedBox(width: 3),
                          if (tasks > 0)
                            _TinyDot(
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF10B981),
                                count: 1),
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
                      decoration: BoxDecoration(
                          color: today && !selected
                              ? const Color(0xFFE0F2FE)
                              : selected
                                  ? Colors.white.withValues(alpha: .18)
                                  : Colors.transparent,
                          shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text('${date.day}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: selected
                                  ? Colors.white
                                  : currentMonth
                                      ? const Color(0xFF111827)
                                      : const Color(0xFF94A3B8))),
                    ),
                    const Spacer(),
                    if (entries.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                            color: selected
                                ? Colors.white.withValues(alpha: .18)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(999)),
                        child: Text('${entries.length}',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF2563EB))),
                      ),
                  ]),
                  const Spacer(),
                  if (plannedMinutes > 0)
                    Text(minutesLabel(plannedMinutes),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11,
                            color: selected
                                ? Colors.white70
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.w800)),
                  const SizedBox(height: 5),
                  Wrap(spacing: 4, runSpacing: 4, children: [
                    if (study > 0)
                      _TinyDot(
                          color:
                              selected ? Colors.white : const Color(0xFF5B5FEF),
                          count: study),
                    if (exams > 0)
                      _TinyDot(
                          color:
                              selected ? Colors.white : const Color(0xFFF59E0B),
                          count: exams),
                    if (tasks > 0)
                      _TinyDot(
                          color:
                              selected ? Colors.white : const Color(0xFF10B981),
                          count: tasks),
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
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return const Wrap(spacing: 10, runSpacing: 8, children: [
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
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(text,
          style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w800,
              fontSize: 12)),
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

  const _DayAgendaPanel(
      {required this.selectedDate,
      required this.entries,
      required this.monthLabel,
      required this.plannedMinutesInMonth,
      required this.completedStudyInMonth,
      required this.highPriorityExamsInMonth,
      required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final store = StudyScope.of(context);
    final selectedPlanned = entries
        .where((e) => e.type == CalendarFilter.study)
        .fold<int>(0, (sum, e) => sum + e.minutes);
    return Column(
      children: [
        AppCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const _SoftIcon(
                  icon: Icons.view_agenda_rounded, color: Color(0xFF06B6D4)),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(
                      sameDay(selectedDate, DateTime.now())
                          ? 'Agenda di oggi'
                          : 'Agenda ${dateLabel(selectedDate)}',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900))),
              AppIconButton(
                  onPressed: onCreate,
                  icon: Icons.add_circle_rounded,
                  tooltip: 'Aggiungi elemento'),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _Pill(
                  text: '${entries.length} elementi',
                  color: const Color(0xFF5B5FEF)),
              _Pill(
                  text: minutesLabel(selectedPlanned),
                  color: const Color(0xFF06B6D4)),
              if (entries.any((e) => !e.completed))
                const _Pill(text: 'Da completare', color: Color(0xFFF59E0B)),
            ]),
            const SizedBox(height: 14),
            if (entries.isEmpty)
              _EmptyAgenda(onCreate: onCreate)
            else
              ...entries.map((entry) {
                final session = entry.type == CalendarFilter.study
                    ? store.sessions.where((s) => s.id == entry.id).firstOrNull
                    : null;
                final exam = entry.type == CalendarFilter.exams
                    ? store.exams.where((e) => e.id == entry.id).firstOrNull
                    : null;
                final task = entry.type == CalendarFilter.tasks
                    ? store.tasks.where((t) => t.id == entry.id).firstOrNull
                    : null;
                return _AgendaItemCard(
                  entry: entry,
                  onToggle: () {
                    if (session != null) {
                      store.upsertSession(StudySession(
                          id: session.id,
                          title: session.title,
                          courseId: session.courseId,
                          date: session.date,
                          minutesPlanned: session.minutesPlanned,
                          minutesDone: session.completed
                              ? session.minutesDone
                              : session.minutesPlanned,
                          kind: session.kind,
                          completed: !session.completed));
                    } else if (task != null) {
                      final completed = task.status == ItemStatus.completed;
                      store.upsertTask(TaskGoal(
                          id: task.id,
                          title: task.title,
                          description: task.description,
                          courseId: task.courseId,
                          dueDate: task.dueDate,
                          priority: task.priority,
                          status: completed
                              ? ItemStatus.future
                              : ItemStatus.completed,
                          estimatedMinutes: task.estimatedMinutes,
                          actualMinutes: completed
                              ? task.actualMinutes
                              : task.estimatedMinutes));
                    } else if (exam != null) {
                      final completed = exam.status == ItemStatus.completed;
                      store.upsertExam(ExamItem(
                          id: exam.id,
                          title: exam.title,
                          courseId: exam.courseId,
                          date: exam.date,
                          type: exam.type,
                          priority: exam.priority,
                          status: completed
                              ? ItemStatus.future
                              : ItemStatus.completed,
                          notes: exam.notes,
                          result: exam.result));
                    }
                  },
                  onEdit: () {
                    if (session != null) {
                      showDialog(
                          context: context,
                          builder: (_) => SessionDialog(item: session));
                    }
                    if (exam != null) {
                      showDialog(
                          context: context,
                          builder: (_) => ExamDialog(item: exam));
                    }
                    if (task != null) {
                      showDialog(
                          context: context,
                          builder: (_) => TaskDialog(item: task));
                    }
                  },
                  onDelete: () async {
                    final confirmed = await confirmDestructiveAction(
                      context,
                      title: 'Eliminare l\'elemento?',
                      message:
                          'L\'elemento "${entry.title}" verrà rimosso dal calendario.',
                    );
                    if (!confirmed) return;
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
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const _SoftIcon(
                  icon: Icons.insights_rounded, color: Color(0xFF8B5CF6)),
              const SizedBox(width: 12),
              Expanded(
                  child: Text('Sintesi $monthLabel',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900)))
            ]),
            const SizedBox(height: 14),
            _MiniMetric(
                label: 'Ore pianificate',
                value: minutesLabel(plannedMinutesInMonth),
                icon: Icons.schedule_rounded),
            _MiniMetric(
                label: 'Sessioni completate',
                value: '$completedStudyInMonth',
                icon: Icons.check_circle_rounded),
            _MiniMetric(
                label: 'Esami ad alta priorità',
                value: '$highPriorityExamsInMonth',
                icon: Icons.priority_high_rounded),
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

  const _AgendaItemCard(
      {required this.entry,
      required this.onToggle,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: entry.color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: entry.color.withValues(alpha: .18))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: entry.color.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(entry.icon, color: entry.color)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: Text(entry.title,
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        decoration: entry.completed
                            ? TextDecoration.lineThrough
                            : null))),
            _Pill(text: entry.type.label, color: entry.color),
          ]),
          const SizedBox(height: 5),
          Text(entry.subtitle,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                  height: 1.25)),
          const SizedBox(height: 8),
          Wrap(spacing: 4, children: [
            TextButton.icon(
                onPressed: onToggle,
                icon: Icon(
                    entry.completed ? Icons.undo_rounded : Icons.done_rounded,
                    size: 18),
                label: Text(entry.completed ? 'Riapri' : 'Completa')),
            TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Modifica')),
            TextButton.icon(
                onPressed: onDelete,
                style: TextButton.styleFrom(foregroundColor: AppStyle.danger),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Elimina')),
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
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE4EAF3))),
      child: Column(children: [
        Icon(Icons.event_busy_rounded,
            size: 46, color: const Color(0xFF64748B).withValues(alpha: .75)),
        const SizedBox(height: 8),
        const Text('Nessun elemento in questa data',
            style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text(
            'Aggiungi una sessione, un esame o un obiettivo direttamente dal calendario.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        AppButton(
            onPressed: onCreate,
            icon: Icons.add_rounded,
            child: const Text('Aggiungi elemento')),
      ]),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MiniMetric(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, size: 19, color: const Color(0xFF5B5FEF))),
        const SizedBox(width: 10),
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: Color(0xFF64748B), fontWeight: FontWeight.w800))),
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

  const _CreateOption(
      {required this.icon,
      required this.color,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: color.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: color.withValues(alpha: .16))),
          child: Row(children: [
            Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(18)),
                child: Icon(icon, color: color)),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600)),
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
  final String? initialCourseId;
  final String? initialTitle;
  final int? initialMinutes;
  const SessionDialog(
      {super.key,
      this.item,
      this.initialDate,
      this.initialCourseId,
      this.initialTitle,
      this.initialMinutes});

  @override
  State<SessionDialog> createState() => _SessionDialogState();
}

class _SessionDialogState extends State<SessionDialog> {
  final title = TextEditingController();
  final minutes = TextEditingController();
  final actualMinutes = TextEditingController();
  DateTime date = DateTime.now();
  StudyKind kind = StudyKind.study;
  bool completed = false;
  String? courseId;

  @override
  void initState() {
    super.initState();
    title.text = widget.item?.title ?? widget.initialTitle ?? '';
    minutes.text =
        '${widget.item?.minutesPlanned ?? widget.initialMinutes ?? 60}';
    actualMinutes.text = '${widget.item?.minutesDone ?? 0}';
    final base = widget.item?.date ?? widget.initialDate ?? DateTime.now();
    final now = DateTime.now();
    date = DateTime(base.year, base.month, base.day,
        widget.item?.date.hour ?? now.hour, widget.item?.date.minute ?? 0);
    kind = widget.item?.kind ?? StudyKind.study;
    completed = widget.item?.completed ?? false;
    courseId = widget.item?.courseId ?? widget.initialCourseId;
  }

  @override
  void dispose() {
    title.dispose();
    minutes.dispose();
    actualMinutes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StudyScope.of(context);
    courseId ??= store.courses.firstOrNull?.id;
    return AlertDialog(
      title: Text(widget.item == null
          ? 'Nuova sessione di studio'
          : 'Modifica sessione'),
      content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
            controller: title,
            decoration: const InputDecoration(labelText: 'Titolo')),
        const SizedBox(height: 10),
        DropdownButtonFormField(
            initialValue: courseId,
            decoration: const InputDecoration(labelText: 'Corso'),
            items: store.courses
                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                .toList(),
            onChanged: (value) => setState(() => courseId = value)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: Text('Data: ${dateLabel(date)}',
                  style: const TextStyle(fontWeight: FontWeight.w700))),
          TextButton(
              onPressed: () async {
                final picked =
                    await showAppDatePicker(context, initialDate: date);
                if (picked != null) {
                  setState(() => date = DateTime(picked.year, picked.month,
                      picked.day, date.hour, date.minute));
                }
              },
              child: const Text('Scegli')),
        ]),
        Row(children: [
          Expanded(
              child: Text('Ora inizio: ${timeLabel(date)}',
                  style: const TextStyle(fontWeight: FontWeight.w700))),
          TextButton(
              onPressed: () async {
                final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(date));
                if (picked != null) {
                  setState(() => date = DateTime(date.year, date.month,
                      date.day, picked.hour, picked.minute));
                }
              },
              child: const Text('Scegli')),
        ]),
        TextField(
            controller: minutes,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Minuti pianificati')),
        const SizedBox(height: 10),
        TextField(
            controller: actualMinutes,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Minuti svolti')),
        const SizedBox(height: 10),
        DropdownButtonFormField(
            initialValue: kind,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: StudyKind.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                .toList(),
            onChanged: (value) => setState(() => kind = value!)),
        const SizedBox(height: 10),
        SwitchListTile(
          value: completed,
          contentPadding: EdgeInsets.zero,
          title: const Text('Sessione completata',
              style: TextStyle(fontWeight: FontWeight.w800)),
          onChanged: (value) => setState(() {
            completed = value;
            if (value && (int.tryParse(actualMinutes.text) ?? 0) == 0) {
              actualMinutes.text = minutes.text;
            }
          }),
        ),
      ])),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla')),
        AppButton(
            onPressed: () {
              final trimmedTitle = title.text.trim();
              final planned = int.tryParse(minutes.text.trim());
              final done = int.tryParse(actualMinutes.text.trim());
              if (trimmedTitle.isEmpty) {
                showAppMessage(context, 'Inserisci il titolo della sessione.');
                return;
              }
              if (courseId == null) {
                showAppMessage(
                    context, 'Crea o seleziona un corso prima di salvare.');
                return;
              }
              if (planned == null || planned <= 0) {
                showAppMessage(context, 'Inserisci minuti pianificati validi.');
                return;
              }
              if (done == null || done < 0) {
                showAppMessage(context, 'Inserisci minuti svolti validi.');
                return;
              }
              store.upsertSession(StudySession(
                id: widget.item?.id ?? id(),
                title: trimmedTitle,
                courseId: courseId!,
                date: date,
                minutesPlanned: planned,
                minutesDone: done,
                kind: kind,
                completed: completed,
              ));
              Navigator.pop(context);
            },
            child: const Text('Salva')),
      ],
    );
  }
}
