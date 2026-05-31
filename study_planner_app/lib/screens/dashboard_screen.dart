part of '../main.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final store = StudyScope.of(context);
    final planned = store.sessions.fold<int>(0, (a, b) => a + b.minutesPlanned);
    final done = store.sessions.fold<int>(0, (a, b) => a + b.minutesDone);
    final completedTasks =
        store.tasks.where((e) => e.status == ItemStatus.completed).length;
    final openTasks =
        store.tasks.where((e) => e.status != ItemStatus.completed).length;
    final completedExams =
        store.exams.where((e) => e.status == ItemStatus.completed).length;
    final activeCourses = store.courses
        .where((e) =>
            e.status == CourseStatus.inProgress ||
            e.status == CourseStatus.review)
        .length;
    final upcoming = [
      ...store.exams
          .where((e) => e.status == ItemStatus.future && daysUntil(e.date) >= 0)
    ]..sort((a, b) => a.date.compareTo(b.date));
    final nextExam = upcoming.firstOrNull;
    final nextDays = nextExam == null ? null : daysUntil(nextExam.date);
    final progress =
        planned == 0 ? 0.0 : (done / planned).clamp(0.0, 1.0).toDouble();
    final taskProgress = store.tasks.isEmpty
        ? 0.0
        : (completedTasks / store.tasks.length).clamp(0.0, 1.0).toDouble();
    final automaticSuggestions =
        buildAutomaticSuggestions(store: store, upcomingExams: upcoming);

    return PageFrame(
      title: 'Home',
      subtitle:
          'Riepilogo essenziale di corsi, scadenze, studio svolto e obiettivi.',
      child: ListView(
        children: [
          _DashboardStatsGrid(
            children: [
              StatCard(
                  label: 'Corsi totali',
                  value: '${store.courses.length}',
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFF5B5FEF),
                  onTap: () => onNavigate(1)),
              StatCard(
                  label: 'Corsi attivi',
                  value: '$activeCourses',
                  icon: Icons.local_library_rounded,
                  color: const Color(0xFF8B5CF6),
                  onTap: () => onNavigate(1)),
              StatCard(
                  label: 'Esami futuri',
                  value: '${upcoming.length}',
                  icon: Icons.event_rounded,
                  color: const Color(0xFF06B6D4),
                  onTap: () => onNavigate(2)),
              StatCard(
                  label: 'Esami completati',
                  value: '$completedExams',
                  icon: Icons.verified_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: () => onNavigate(2)),
              StatCard(
                  label: 'Studio svolto',
                  value: minutesLabel(done),
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFF10B981),
                  onTap: () => onNavigate(3)),
              StatCard(
                  label: 'Studio pianificato',
                  value: minutesLabel(planned),
                  icon: Icons.schedule_rounded,
                  color: const Color(0xFF14B8A6),
                  onTap: () => onNavigate(3)),
              StatCard(
                  label: 'Prossima scadenza',
                  value: nextExam == null
                      ? '—'
                      : (nextDays == 0 ? 'Oggi' : '${nextDays}g'),
                  icon: Icons.event_note_rounded,
                  color: const Color(0xFFF97316),
                  onTap: () => onNavigate(3)),
              StatCard(
                  label: 'Obiettivi aperti',
                  value: '$openTasks',
                  icon: Icons.checklist_rounded,
                  color: const Color(0xFFF59E0B),
                  onTap: () => onNavigate(4)),
            ],
          ),
          const SizedBox(height: 12),
          _AutomaticSuggestionsSummaryCard(
              count: automaticSuggestions.length,
              onTap: () => _showAutomaticSuggestionsSheet(
                  context, automaticSuggestions, () => onNavigate(3))),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final left = Column(
              children: [
                _ProgressCard(
                    title: 'Avanzamento studio',
                    subtitle:
                        '${minutesLabel(done)} svolti su ${minutesLabel(planned)} pianificati',
                    value: progress,
                    icon: Icons.auto_graph_rounded,
                    color: const Color(0xFF5B5FEF)),
                const SizedBox(height: 16),
                _ProgressCard(
                    title: 'Obiettivi completati',
                    subtitle:
                        '$completedTasks attività completate su ${store.tasks.length}',
                    value: taskProgress,
                    icon: Icons.flag_rounded,
                    color: const Color(0xFF10B981)),
                const SizedBox(height: 16),
                _StudyDistribution(
                    courses: store.courses, sessions: store.sessions),
              ],
            );
            final right = Column(
              children: [
                _UpcomingPanel(upcoming: upcoming, store: store),
              ],
            );
            if (!wide) {
              return Column(
                  children: [left, const SizedBox(height: 16), right]);
            }
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 6, child: left),
              const SizedBox(width: 16),
              Expanded(flex: 5, child: right)
            ]);
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
      final columns = constraints.maxWidth >= 1100
          ? 4
          : constraints.maxWidth >= 720
              ? 3
              : constraints.maxWidth >= 380
                  ? 2
                  : 1;
      final narrow = columns <= 2;
      final cardHeight = narrow ? 132.0 : 156.0;
      final tileWidth =
          (constraints.maxWidth - (spacing * (columns - 1))) / columns;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: tileWidth / cardHeight,
        children: children,
      );
    });
  }
}

class _AutomaticSuggestionsSummaryCard extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _AutomaticSuggestionsSummaryCard(
      {required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const color = AppStyle.primary;
    final card = AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          const _SoftIcon(icon: Icons.tips_and_updates_rounded, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Suggerimenti automatici',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('Da esami imminenti',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: color.withValues(alpha: .18)),
            ),
            child: Text('$count',
                style: const TextStyle(
                    color: color, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
          const SizedBox(width: 10),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: .20)),
            ),
            child: Icon(Icons.north_east_rounded,
                color: color.withValues(alpha: .88), size: 18),
          ),
        ],
      ),
    );

    return Semantics(
      button: true,
      label: 'Suggerimenti automatici',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: card,
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double value;
  final IconData icon;
  final Color color;

  const _ProgressCard(
      {required this.title,
      required this.subtitle,
      required this.value,
      required this.icon,
      required this.color});

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
                Row(children: [
                  Expanded(
                      child: Text(title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900))),
                  Text('${(value * 100).round()}%',
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.w900))
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                      value: value,
                      minHeight: 10,
                      backgroundColor: color.withValues(alpha: .12),
                      color: color),
                ),
                const SizedBox(height: 8),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
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
    final values = courses
        .map((course) {
          final minutes = sessions
              .where((session) => session.courseId == course.id)
              .fold<int>(0, (sum, session) => sum + session.minutesPlanned);
          return MapEntry(course, minutes);
        })
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxMinutes = values.isEmpty
        ? 1
        : values.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const _SoftIcon(
                icon: Icons.donut_large_rounded, color: Color(0xFF8B5CF6)),
            const SizedBox(width: 12),
            Expanded(
                child: Text('Distribuzione studio',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900)))
          ]),
          const SizedBox(height: 16),
          if (values.isEmpty)
            const Text(
                'Pianifica una sessione per vedere la distribuzione per corso.'),
          ...values.map((entry) {
            final color = courseAccent(entry.key.id);
            final value = entry.value / maxMinutes;
            return Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(entry.key.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800))),
                    Text(minutesLabel(entry.value),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B)))
                  ]),
                  const SizedBox(height: 7),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                          value: value,
                          minHeight: 9,
                          backgroundColor: color.withValues(alpha: .12),
                          color: color)),
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
          Row(children: [
            const _SoftIcon(
                icon: Icons.event_available_rounded, color: Color(0xFF06B6D4)),
            const SizedBox(width: 12),
            Expanded(
                child: Text('Scadenze imminenti',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900)))
          ]),
          const SizedBox(height: 12),
          if (upcoming.isEmpty) const Text('Nessuna scadenza futura.'),
          ...upcoming.take(5).map((e) {
            final days = daysUntil(e.date);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE4EAF3))),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                          color:
                              priorityColor(e.priority).withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(18)),
                      child: Icon(
                          e.type == ExamType.deadline
                              ? Icons.assignment_rounded
                              : Icons.school_rounded,
                          color: priorityColor(e.priority)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900)),
                            const SizedBox(height: 3),
                            Text(
                                '${store.courseName(e.courseId)} • ${dateLabel(e.date)}',
                                style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600)),
                          ]),
                    ),
                    _Pill(
                        text: days < 0 ? 'Passata' : '${days}g',
                        color: priorityColor(e.priority)),
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

  const StatCard(
      {super.key,
      required this.label,
      required this.value,
      required this.icon,
      this.color = AppStyle.ink,
      this.helper,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final compact = constraints.maxWidth < 132;
      final padding =
          compact ? const EdgeInsets.all(8) : const EdgeInsets.all(18);
      final iconSize = compact ? 30.0 : 46.0;
      final iconRadius = compact ? 12.0 : 16.0;
      final arrowSize = compact ? 24.0 : 34.0;
      final valueStyle = compact
          ? Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 0)
          : Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 0);
      final labelStyle = TextStyle(
        color: AppStyle.subtle,
        fontWeight: FontWeight.w800,
        fontSize: compact ? 10 : 14,
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
                  color: color.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(iconRadius),
                  border: Border.all(color: color.withValues(alpha: .12)),
                ),
                child: Icon(icon, color: color, size: compact ? 17 : 22),
              ),
              const Spacer(),
              Container(
                width: arrowSize,
                height: arrowSize,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: onTap == null ? .05 : .10),
                  borderRadius: BorderRadius.circular(compact ? 10 : 14),
                  border: Border.all(
                      color:
                          color.withValues(alpha: onTap == null ? .10 : .20)),
                ),
                child: Icon(Icons.north_east_rounded,
                    size: compact ? 14 : 17,
                    color: color.withValues(alpha: onTap == null ? .28 : .88)),
              ),
            ]),
            const Spacer(),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: valueStyle),
            const SizedBox(height: 4),
            Text(label,
                maxLines: compact ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: labelStyle),
            if (helper != null) ...[
              const SizedBox(height: 2),
              Text(
                helper!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppStyle.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 9 : 11,
                    height: 1.05),
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

void _showAutomaticSuggestionsSheet(BuildContext context,
    List<AutomaticStudySuggestion> suggestions, VoidCallback openCalendar) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            18, 4, 18, 18 + MediaQuery.of(sheetContext).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Suggerimenti automatici',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            const Text(
              'La statistica viene calcolata dagli esami e dalle scadenze nei prossimi 21 giorni, confrontando priorità, giorni rimanenti, sessioni già pianificate e obiettivi aperti.',
              style: TextStyle(
                  color: AppStyle.subtle,
                  fontWeight: FontWeight.w600,
                  height: 1.35),
            ),
            const SizedBox(height: 14),
            if (suggestions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppStyle.surfaceAlt,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppStyle.line)),
                child: const Text(
                    'Nessun suggerimento necessario: le attività risultano già ben pianificate rispetto alle scadenze imminenti.',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, height: 1.35)),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) => _AutomaticSuggestionTile(
                    suggestion: suggestions[index],
                    onCreate: () async {
                      final suggestion = suggestions[index];
                      final store = StudyScope.of(context);
                      await store.upsertSession(StudySession(
                        id: id(),
                        title: '${suggestion.title} - ${suggestion.examTitle}',
                        courseId: suggestion.courseId,
                        date: suggestion.suggestedDate,
                        minutesPlanned: suggestion.recommendedMinutes,
                        minutesDone: 0,
                        kind: StudyKind.review,
                        completed: false,
                      ));
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                      if (context.mounted) {
                        showAppMessage(context,
                            'Sessione consigliata creata per ${dateLabel(suggestion.suggestedDate)}.');
                        openCalendar();
                      }
                    },
                  ),
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
  final VoidCallback onCreate;

  const _AutomaticSuggestionTile(
      {required this.suggestion, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final color = priorityColor(suggestion.priority);
    final days = suggestion.daysLeft == 0 ? 'oggi' : '${suggestion.daysLeft}g';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppStyle.surfaceAlt,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppStyle.line)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.tips_and_updates_rounded, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(suggestion.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w900))),
                    _Pill(text: days, color: color),
                  ],
                ),
                const SizedBox(height: 4),
                Text(suggestion.courseName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: AppStyle.ink)),
                const SizedBox(height: 4),
                Text(suggestion.reason,
                    style: const TextStyle(
                        color: AppStyle.subtle,
                        fontWeight: FontWeight.w600,
                        height: 1.3)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _Pill(
                        text: minutesLabel(suggestion.recommendedMinutes),
                        color: color),
                    _Pill(
                        text: dateLabel(suggestion.suggestedDate),
                        color: const Color(0xFF06B6D4)),
                    TextButton.icon(
                      onPressed: onCreate,
                      icon: const Icon(Icons.add_task_rounded, size: 18),
                      label: const Text('Crea sessione'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
