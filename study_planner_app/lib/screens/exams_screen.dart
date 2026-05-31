part of '../main.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  ItemStatus? status;
  Priority? priority;
  String query = '';

  @override
  Widget build(BuildContext context) {
    final store = StudyScope.of(context);
    final list = store.exams.where((e) {
      final text =
          '${e.title} ${e.notes} ${store.courseName(e.courseId)}'.toLowerCase();
      return (status == null || e.status == status) &&
          (priority == null || e.priority == priority) &&
          text.contains(query.toLowerCase());
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return PageFrame(
      title: 'Esami e scadenze',
      subtitle: 'Appelli, consegne, priorità, stato e risultati.',
      actions: [
        AppButton(
            onPressed: () => showDialog(
                context: context, builder: (_) => const ExamDialog()),
            icon: Icons.add,
            child: const Text('Nuovo'))
      ],
      child: Column(children: [
        LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final search = TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Cerca esame, corso o note'),
            onChanged: (value) => setState(() => query = value),
          );
          final statusField = DropdownButtonFormField<ItemStatus?>(
            initialValue: status,
            decoration: const InputDecoration(labelText: 'Stato'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tutti')),
              ...ItemStatus.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
            ],
            onChanged: (value) => setState(() => status = value),
          );
          final priorityField = DropdownButtonFormField<Priority?>(
            initialValue: priority,
            decoration: const InputDecoration(labelText: 'Priorità'),
            items: [
              const DropdownMenuItem(value: null, child: Text('Tutte')),
              ...Priority.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
            ],
            onChanged: (value) => setState(() => priority = value),
          );
          if (compact) {
            return Column(children: [
              search,
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: statusField),
                const SizedBox(width: 10),
                Expanded(child: priorityField)
              ]),
            ]);
          }
          return Row(children: [
            Expanded(child: search),
            const SizedBox(width: 10),
            SizedBox(width: 190, child: statusField),
            const SizedBox(width: 10),
            SizedBox(width: 190, child: priorityField),
          ]);
        }),
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
                onEdit: () => showDialog(
                    context: context, builder: (_) => ExamDialog(item: e)),
                onDelete: () async {
                  final confirmed = await confirmDestructiveAction(
                    context,
                    title: 'Eliminare la scadenza?',
                    message:
                        'L\'elemento "${e.title}" verrà rimosso definitivamente.',
                  );
                  if (confirmed) store.deleteExam(e.id);
                },
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

  const ExamCard(
      {super.key,
      required this.exam,
      required this.courseName,
      required this.onEdit,
      required this.onDelete});

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
              gradient: LinearGradient(colors: [
                color.withValues(alpha: .18),
                color.withValues(alpha: .08)
              ]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
                exam.type == ExamType.deadline
                    ? Icons.assignment_rounded
                    : Icons.school_rounded,
                color: color,
                size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                      child: Text(exam.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900))),
                  _Pill(
                      text: days < 0 ? 'Passata' : '$days giorni',
                      color: color),
                ]),
                const SizedBox(height: 6),
                Text(
                    '$courseName • ${exam.type.label} • ${dateLabel(exam.date)}',
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text(exam.notes.isEmpty ? 'Nessuna nota inserita.' : exam.notes,
                    style: const TextStyle(
                        color: Color(0xFF475569), height: 1.35)),
                const SizedBox(height: 12),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      PriorityChip(exam.priority),
                      _Pill(
                          text: exam.status.label,
                          color: statusColor(exam.status)),
                      AppIconButton(
                          onPressed: onEdit,
                          icon: Icons.edit_rounded,
                          tooltip: 'Modifica'),
                      AppIconButton(
                          onPressed: onDelete,
                          icon: Icons.delete_outline_rounded,
                          tooltip: 'Elimina'),
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
  DateTime? date;
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
    date = widget.item?.date ?? widget.initialDate;
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
    final size = MediaQuery.sizeOf(context);
    final dialogWidth = (size.width - 48).clamp(280.0, 520.0);
    final dialogHeight = (size.height * .56).clamp(260.0, 460.0);
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      title: Text(widget.item == null
          ? 'Nuovo esame/scadenza'
          : 'Modifica esame/scadenza'),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Titolo')),
            const SizedBox(height: 10),
            DropdownButtonFormField(
                initialValue: courseId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Corso'),
                items: store.courses
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (value) => setState(() => courseId = value)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: Text(
                      date == null
                          ? 'Data: nessuna data selezionata'
                          : 'Data: ${dateLabel(date!)}',
                      style: const TextStyle(fontWeight: FontWeight.w700))),
              TextButton(
                  onPressed: () async {
                    final currentDate = date ?? dayOnly(DateTime.now());
                    final picked = await showAppDatePicker(context,
                        initialDate: currentDate);
                    if (picked != null) {
                      setState(() => date =
                          DateTime(picked.year, picked.month, picked.day));
                    }
                  },
                  child: const Text('Scegli')),
            ]),
            DropdownButtonFormField(
                initialValue: type,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Tipologia'),
                items: ExamType.values
                    .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.label)))
                    .toList(),
                onChanged: (value) => setState(() => type = value!)),
            const SizedBox(height: 10),
            DropdownButtonFormField(
                initialValue: priority,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Priorità'),
                items: Priority.values
                    .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.label)))
                    .toList(),
                onChanged: (value) => setState(() => priority = value!)),
            const SizedBox(height: 10),
            DropdownButtonFormField(
                initialValue: status,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Stato'),
                items: ItemStatus.values
                    .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.label)))
                    .toList(),
                onChanged: (value) => setState(() => status = value!)),
            if (status == ItemStatus.completed) ...[
              const SizedBox(height: 10),
              TextField(
                  controller: result,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Voto/risultato')),
            ],
            const SizedBox(height: 10),
            TextField(
                controller: notes,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Note')),
          ]),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla')),
        AppButton(
            onPressed: () {
              final trimmedTitle = title.text.trim();
              final parsedResult = optionalInt(result.text);
              if (trimmedTitle.isEmpty) {
                showAppMessage(context,
                    'Inserisci il titolo dell\'esame o della scadenza.');
                return;
              }
              if (courseId == null) {
                showAppMessage(
                    context, 'Crea o seleziona un corso prima di salvare.');
                return;
              }
              if (date == null) {
                showAppMessage(
                    context, 'Scegli la data dell\'esame o della scadenza.');
                return;
              }
              if (result.text.trim().isNotEmpty && parsedResult == null) {
                showAppMessage(
                    context, 'Inserisci un risultato numerico valido.');
                return;
              }
              store.upsertExam(ExamItem(
                id: widget.item?.id ?? id(),
                title: trimmedTitle,
                courseId: courseId!,
                date: date!,
                type: type,
                priority: priority,
                status: status,
                notes: notes.text.trim(),
                result: status == ItemStatus.completed ? parsedResult : null,
              ));
              Navigator.pop(context);
            },
            child: const Text('Salva')),
      ],
    );
  }
}
