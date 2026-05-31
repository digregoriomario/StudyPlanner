part of '../main.dart';

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
    final filtered = store.courses
        .where((c) =>
            c.name.toLowerCase().contains(query.toLowerCase()) &&
            (status == null || c.status == status))
        .toList();
    return PageFrame(
      title: 'Corsi',
      subtitle: 'Gestione insegnamenti, CFU, docente, stato e voti.',
      actions: [
        AppButton(
            onPressed: () => _openForm(context),
            icon: Icons.add,
            child: const Text('Nuovo'))
      ],
      child: Column(children: [
        LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final search = TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Cerca per nome'),
            onChanged: (value) => setState(() => query = value),
          );
          final dropdown = DropdownButtonFormField<CourseStatus?>(
            initialValue: status,
            decoration: const InputDecoration(labelText: 'Stato'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tutti')),
              ...CourseStatus.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
            ],
            onChanged: (value) => setState(() => status = value),
          );
          if (compact) {
            return Column(
                children: [search, const SizedBox(height: 10), dropdown]);
          }
          return Row(children: [
            Expanded(child: search),
            const SizedBox(width: 12),
            SizedBox(width: 220, child: dropdown)
          ]);
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
                onDelete: () async {
                  final confirmed = await confirmDestructiveAction(
                    context,
                    title: 'Eliminare il corso?',
                    message:
                        'Verranno eliminati anche esami, sessioni e obiettivi collegati a "${c.name}".',
                  );
                  if (confirmed) store.deleteCourse(c.id);
                },
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

  const CourseCard(
      {super.key,
      required this.course,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = courseAccent(course.id);
    return AppCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
                width: 8,
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(28)))),
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
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(course.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.w900)),
                                const SizedBox(height: 4),
                                Text('${course.teacher} • ${course.semester}',
                                    style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w700)),
                              ]),
                        ),
                        _Pill(
                            text: course.status.label,
                            color: statusColor(course.status)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                        course.notes.isEmpty
                            ? 'Nessuna nota inserita.'
                            : course.notes,
                        style: const TextStyle(
                            color: Color(0xFF475569), height: 1.35)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _Pill(text: '${course.cfu} CFU', color: color),
                        if (course.desiredGrade != null)
                          _Pill(
                              text: 'Obiettivo ${course.desiredGrade}',
                              color: const Color(0xFF8B5CF6)),
                        if (course.finalGrade != null)
                          _Pill(
                              text: 'Voto ${course.finalGrade}',
                              color: const Color(0xFF10B981)),
                        AppIconButton(
                            onPressed: onEdit,
                            icon: Icons.edit_rounded,
                            tooltip: 'Modifica'),
                        AppIconButton(
                            onPressed: onDelete,
                            icon: Icons.delete_outline_rounded,
                            tooltip: 'Elimina'),
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
  static const _semesterOptions = ['1° semestre', '2° semestre'];

  final name = TextEditingController();
  final teacher = TextEditingController();
  final cfu = TextEditingController();
  final desiredGrade = TextEditingController();
  final finalGrade = TextEditingController();
  final notes = TextEditingController();
  String? semester;
  CourseStatus status = CourseStatus.toStart;

  static String? _semesterOptionFromText(String? value) {
    final normalized = value?.trim().toLowerCase();
    return switch (normalized) {
      '1' ||
      '1 semestre' ||
      '1° semestre' ||
      'i semestre' =>
        _semesterOptions.first,
      '2' ||
      '2 semestre' ||
      '2° semestre' ||
      'ii semestre' =>
        _semesterOptions.last,
      _ => null,
    };
  }

  @override
  void initState() {
    super.initState();
    name.text = widget.course?.name ?? '';
    teacher.text = widget.course?.teacher ?? '';
    semester = _semesterOptionFromText(widget.course?.semester);
    cfu.text = '${widget.course?.cfu ?? 6}';
    desiredGrade.text = widget.course?.desiredGrade?.toString() ?? '';
    finalGrade.text = widget.course?.finalGrade?.toString() ?? '';
    notes.text = widget.course?.notes ?? '';
    status = widget.course?.status ?? CourseStatus.toStart;
  }

  @override
  void dispose() {
    name.dispose();
    teacher.dispose();
    cfu.dispose();
    desiredGrade.dispose();
    finalGrade.dispose();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = StudyScope.of(context);
    return AlertDialog(
      title: Text(widget.course == null ? 'Nuovo corso' : 'Modifica corso'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Nome corso')),
          const SizedBox(height: 10),
          TextField(
              controller: teacher,
              decoration: const InputDecoration(labelText: 'Docente')),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
              initialValue: semester,
              decoration: const InputDecoration(
                  labelText: 'Semestre', hintText: 'Seleziona semestre'),
              items: _semesterOptions
                  .map((value) =>
                      DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => semester = value)),
          const SizedBox(height: 10),
          TextField(
              controller: cfu,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'CFU')),
          const SizedBox(height: 10),
          TextField(
              controller: desiredGrade,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Voto obiettivo', hintText: '18-30')),
          const SizedBox(height: 10),
          TextField(
              controller: finalGrade,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Voto finale', hintText: '18-30')),
          const SizedBox(height: 10),
          DropdownButtonFormField(
              initialValue: status,
              decoration: const InputDecoration(labelText: 'Stato'),
              items: CourseStatus.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
                  .toList(),
              onChanged: (value) => setState(() => status = value!)),
          const SizedBox(height: 10),
          TextField(
              controller: notes,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Note')),
        ]),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla')),
        AppButton(
            onPressed: () {
              final courseName = name.text.trim();
              final cfuValue = int.tryParse(cfu.text.trim());
              final desired = optionalInt(desiredGrade.text);
              final finalValue = optionalInt(finalGrade.text);
              if (courseName.isEmpty) {
                showAppMessage(context, 'Inserisci il nome del corso.');
                return;
              }
              if (cfuValue == null || cfuValue <= 0) {
                showAppMessage(context, 'Inserisci un numero di CFU valido.');
                return;
              }
              if (semester == null) {
                showAppMessage(context, 'Seleziona il semestre del corso.');
                return;
              }
              if ((desired != null && (desired < 18 || desired > 30)) ||
                  (finalValue != null &&
                      (finalValue < 18 || finalValue > 30))) {
                showAppMessage(
                    context, 'I voti devono essere compresi tra 18 e 30.');
                return;
              }
              final item = Course(
                id: widget.course?.id ?? id(),
                name: courseName,
                teacher: teacher.text.trim(),
                semester: semester!,
                cfu: cfuValue,
                status: status,
                desiredGrade: desired,
                finalGrade: finalValue,
                notes: notes.text.trim(),
              );
              store.upsertCourse(item);
              Navigator.pop(context);
            },
            child: const Text('Salva')),
      ],
    );
  }
}
