part of '../main.dart';

extension FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

String id() => DateTime.now().microsecondsSinceEpoch.toString();
String dateLabel(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
String shortDateLabel(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
String weekdayLabel(DateTime d) =>
    const ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'][d.weekday - 1];
String minutesLabel(int minutes) => '${minutes ~/ 60}h ${minutes % 60}min';
String timeLabel(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
int? optionalInt(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return int.tryParse(trimmed);
}

int positiveIntOrFallback(String value, int fallback) {
  final parsed = int.tryParse(value.trim());
  if (parsed == null || parsed < 0) return fallback;
  return parsed;
}

void showAppMessage(BuildContext context, String message) {
  final route = ModalRoute.of(context);
  if (route is PopupRoute) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Controlla i dati'),
        content: Text(message),
        actions: [
          AppButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
}

Future<bool> confirmDestructiveAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Elimina',
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Annulla')),
            FilledButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(confirmLabel),
              style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626)),
            ),
          ],
        ),
      ) ??
      false;
}

Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  final first = firstDate ?? DateTime(2020);
  final last = lastDate ?? DateTime(2035);
  final safeInitial = initialDate.isBefore(first)
      ? first
      : initialDate.isAfter(last)
          ? last
          : initialDate;

  return showDatePicker(
    context: context,
    firstDate: first,
    lastDate: last,
    initialDate: safeInitial,
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    helpText: 'Seleziona data',
    cancelText: 'Annulla',
    confirmText: 'Conferma',
    builder: (pickerContext, child) {
      final base = Theme.of(pickerContext);
      return Theme(
        data: base.copyWith(
          colorScheme: base.colorScheme.copyWith(
            primary: AppStyle.primary,
            onPrimary: Colors.white,
            surface: AppStyle.surface,
            onSurface: AppStyle.ink,
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: AppStyle.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: const BorderSide(color: AppStyle.line)),
            headerBackgroundColor: AppStyle.primary,
            headerForegroundColor: Colors.white,
            headerHeadlineStyle: base.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 0),
            headerHelpStyle: base.textTheme.labelLarge?.copyWith(
                color: Colors.white.withValues(alpha: .86),
                fontWeight: FontWeight.w800),
            weekdayStyle: const TextStyle(
                color: AppStyle.subtle, fontWeight: FontWeight.w800),
            dayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return Colors.white;
              if (states.contains(WidgetState.disabled)) return AppStyle.muted;
              return AppStyle.ink;
            }),
            dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppStyle.primary;
              }
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused)) {
                return AppStyle.primarySoft;
              }
              return null;
            }),
            todayForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return Colors.white;
              return AppStyle.primary;
            }),
            todayBorder: const BorderSide(color: AppStyle.primary, width: 1.4),
            yearForegroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return Colors.white;
              return AppStyle.ink;
            }),
            yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppStyle.primary;
              }
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused)) {
                return AppStyle.primarySoft;
              }
              return null;
            }),
            cancelButtonStyle:
                TextButton.styleFrom(foregroundColor: AppStyle.subtle),
            confirmButtonStyle:
                TextButton.styleFrom(foregroundColor: AppStyle.primary),
          ),
        ),
        child: child!,
      );
    },
  );
}

String monthLabel(DateTime d) {
  const months = [
    'Gennaio',
    'Febbraio',
    'Marzo',
    'Aprile',
    'Maggio',
    'Giugno',
    'Luglio',
    'Agosto',
    'Settembre',
    'Ottobre',
    'Novembre',
    'Dicembre'
  ];
  return '${months[d.month - 1]} ${d.year}';
}

DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime monthOnly(DateTime d) => DateTime(d.year, d.month);
bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
bool sameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;
int daysUntil(DateTime d) =>
    dayOnly(d).difference(dayOnly(DateTime.now())).inDays;
DateTime suggestedStudyDate(DateTime examDate, int daysLeft) {
  final now = DateTime.now();
  final targetDay = daysLeft <= 1
      ? dayOnly(now)
      : daysLeft <= 3
          ? dayOnly(examDate).subtract(const Duration(days: 1))
          : dayOnly(now).add(const Duration(days: 1));
  return DateTime(targetDay.year, targetDay.month, targetDay.day, 9);
}

List<DateTime> calendarDaysForMonth(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  final last = DateTime(month.year, month.month + 1, 0);
  final start = first.subtract(Duration(days: first.weekday - 1));
  final end = last.add(Duration(days: 7 - last.weekday));
  return List.generate(end.difference(start).inDays + 1,
      (index) => DateTime(start.year, start.month, start.day + index));
}

class AutomaticStudySuggestion {
  final String title;
  final String examTitle;
  final String courseId;
  final String courseName;
  final String reason;
  final int recommendedMinutes;
  final int daysLeft;
  final Priority priority;
  final DateTime examDate;
  final DateTime suggestedDate;

  const AutomaticStudySuggestion({
    required this.title,
    required this.examTitle,
    required this.courseId,
    required this.courseName,
    required this.reason,
    required this.recommendedMinutes,
    required this.daysLeft,
    required this.priority,
    required this.examDate,
    required this.suggestedDate,
  });
}

const automaticSuggestionWindowDays = 21;

List<AutomaticStudySuggestion> buildAutomaticSuggestions({
  required StudyStore store,
  required List<ExamItem> upcomingExams,
}) {
  final suggestions = <AutomaticStudySuggestion>[];
  final relevantExams = upcomingExams.where((exam) {
    final days = daysUntil(exam.date);
    return days >= 0 && days <= automaticSuggestionWindowDays;
  }).toList()
    ..sort((a, b) {
      final priority =
          _priorityRank(b.priority).compareTo(_priorityRank(a.priority));
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
    final recommendedMinutes = gap > 0
        ? gap.clamp(45, 180).toInt()
        : (openTasksBeforeExam > 0 ? 45 : 0);

    if (recommendedMinutes == 0 && days > 7) continue;

    final title = days <= 3
        ? 'Ripasso immediato'
        : days <= 7 || exam.priority == Priority.high
            ? 'Sessione prioritaria'
            : 'Piano di avvicinamento';
    final dayText = days == 0 ? 'oggi' : 'tra $days giorni';
    final taskText = openTasksBeforeExam == 1
        ? '1 obiettivo aperto'
        : '$openTasksBeforeExam obiettivi aperti';

    suggestions.add(AutomaticStudySuggestion(
      title: title,
      examTitle: exam.title,
      courseId: exam.courseId,
      courseName: courseName,
      reason:
          '${exam.title} $dayText: ${minutesLabel(plannedBeforeExam)} pianificati, $taskText.',
      recommendedMinutes: recommendedMinutes == 0 ? 45 : recommendedMinutes,
      daysLeft: days,
      priority: days <= 3 ? Priority.high : exam.priority,
      examDate: exam.date,
      suggestedDate: suggestedStudyDate(exam.date, days),
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
  final index =
      id.codeUnits.fold<int>(0, (sum, value) => sum + value) % colors.length;
  return colors[index];
}
