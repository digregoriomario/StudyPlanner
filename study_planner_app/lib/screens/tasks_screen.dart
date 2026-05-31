part of '../main.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  Priority? priority;
  ItemStatus? status;
  String query = '';

  @override
  Widget build(BuildContext context) {
    final store = StudyScope.of(context);
    final list = store.tasks.where((e) {
      final matchesPriority = priority == null || e.priority == priority;
      final matchesStatus = status == null || e.status == status;
      final text = '${e.title} ${e.description} ${store.courseName(e.courseId)}'
          .toLowerCase();
      final matchesQuery = text.contains(query.toLowerCase());
      return matchesPriority && matchesStatus && matchesQuery;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final completed =
        store.tasks.where((t) => t.status == ItemStatus.completed).length;
    final progress = store.tasks.isEmpty ? 0.0 : completed / store.tasks.length;

    return PageFrame(
      title: 'Obiettivi',
      subtitle:
          'Organizza attività, priorità, tempi stimati e avanzamento dei corsi.',
      actions: [
        AppButton(
            onPressed: () => showDialog(
                context: context, builder: (_) => const TaskDialog()),
            icon: Icons.add,
            child: const Text('Nuovo'))
      ],
      child: Column(children: [
        AppCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const _SoftIcon(
                  icon: Icons.flag_rounded, color: Color(0xFF10B981)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Progresso obiettivi',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('$completed completati su ${store.tasks.length}',
                        style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700)),
                  ])),
              Text('${(progress * 100).round()}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF10B981))),
            ]),
            const SizedBox(height: 14),
            ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE2E8F0),
                    color: const Color(0xFF10B981))),
          ]),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final search = TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Cerca task, corso o descrizione'),
            onChanged: (value) => setState(() => query = value),
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
          if (compact) {
            return Column(children: [
              search,
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: priorityField),
                const SizedBox(width: 10),
                Expanded(child: statusField)
              ])
            ]);
          }
          return Row(children: [
            Expanded(child: search),
            const SizedBox(width: 10),
            SizedBox(width: 190, child: priorityField),
            const SizedBox(width: 10),
            SizedBox(width: 190, child: statusField)
          ]);
        }),
        const SizedBox(height: 12),
        Expanded(
            child: list.isEmpty
                ? const AppCard(
                    child: Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.inbox_rounded,
                        size: 54, color: Color(0xFF94A3B8)),
                    SizedBox(height: 10),
                    Text('Nessun obiettivo trovato',
                        style: TextStyle(fontWeight: FontWeight.w900))
                  ])))
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final t = list[index];
                      final color = priorityColor(t.priority);
                      return AppCard(
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: t.status == ItemStatus.completed,
                                onChanged: (value) => store.upsertTask(TaskGoal(
                                    id: t.id,
                                    title: t.title,
                                    description: t.description,
                                    courseId: t.courseId,
                                    dueDate: t.dueDate,
                                    priority: t.priority,
                                    status: value == true
                                        ? ItemStatus.completed
                                        : ItemStatus.future,
                                    estimatedMinutes: t.estimatedMinutes,
                                    actualMinutes: value == true
                                        ? t.estimatedMinutes
                                        : t.actualMinutes)),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              child: Text(t.title,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          decoration: t
                                                                      .status ==
                                                                  ItemStatus
                                                                      .completed
                                                              ? TextDecoration
                                                                  .lineThrough
                                                              : null))),
                                          _Pill(
                                              text: t.priority.label,
                                              color: color),
                                        ]),
                                    const SizedBox(height: 5),
                                    Text(
                                        '${store.courseName(t.courseId)} • entro ${dateLabel(t.dueDate)}',
                                        style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 6),
                                    Text(
                                        t.description.isEmpty
                                            ? 'Nessuna descrizione.'
                                            : t.description,
                                        style: const TextStyle(
                                            color: Color(0xFF475569),
                                            height: 1.3)),
                                    const SizedBox(height: 10),
                                    Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          _Pill(
                                              text:
                                                  'Stimato ${minutesLabel(t.estimatedMinutes)}',
                                              color: const Color(0xFF5B5FEF)),
                                          _Pill(
                                              text:
                                                  'Effettivo ${minutesLabel(t.actualMinutes)}',
                                              color: const Color(0xFF06B6D4)),
                                          _Pill(
                                              text: t.status.label,
                                              color: statusColor(t.status)),
                                          AppIconButton(
                                              onPressed: () => showDialog(
                                                  context: context,
                                                  builder: (_) =>
                                                      TaskDialog(item: t)),
                                              icon: Icons.edit_rounded,
                                              tooltip: 'Modifica'),
                                          AppIconButton(
                                            onPressed: () async {
                                              final confirmed =
                                                  await confirmDestructiveAction(
                                                context,
                                                title:
                                                    'Eliminare l\'obiettivo?',
                                                message:
                                                    'L\'obiettivo "${t.title}" verrà rimosso definitivamente.',
                                              );
                                              if (confirmed) {
                                                store.deleteTask(t.id);
                                              }
                                            },
                                            icon: Icons.delete_outline_rounded,
                                            tooltip: 'Elimina',
                                          ),
                                        ]),
                                  ])),
                            ]),
                      );
                    })),
      ]),
    );
  }
}

class TaskDialog extends StatefulWidget {
  final TaskGoal? item;
  final DateTime? initialDate;
  const TaskDialog({super.key, this.item, this.initialDate});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final title = TextEditingController();
  final description = TextEditingController();
  final estimate = TextEditingController(text: '60');
  final actual = TextEditingController(text: '0');
  DateTime dueDate = DateTime.now().add(const Duration(days: 5));
  Priority priority = Priority.medium;
  ItemStatus status = ItemStatus.future;
  String? courseId;

  @override
  void initState() {
    super.initState();
    title.text = widget.item?.title ?? '';
    description.text = widget.item?.description ?? '';
    estimate.text = '${widget.item?.estimatedMinutes ?? 60}';
    actual.text = '${widget.item?.actualMinutes ?? 0}';
    dueDate = widget.item?.dueDate ??
        widget.initialDate ??
        DateTime.now().add(const Duration(days: 5));
    priority = widget.item?.priority ?? Priority.medium;
    status = widget.item?.status ?? ItemStatus.future;
    courseId = widget.item?.courseId;
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    estimate.dispose();
    actual.dispose();
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
          ? 'Nuova attività/obiettivo'
          : 'Modifica attività/obiettivo'),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Titolo')),
            const SizedBox(height: 10),
            TextField(
                controller: description,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Descrizione')),
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
                  child: Text('Scadenza: ${dateLabel(dueDate)}',
                      style: const TextStyle(fontWeight: FontWeight.w700))),
              TextButton(
                  onPressed: () async {
                    final picked =
                        await showAppDatePicker(context, initialDate: dueDate);
                    if (picked != null) {
                      setState(() => dueDate = picked);
                    }
                  },
                  child: const Text('Scegli'))
            ]),
            TextField(
                controller: estimate,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Tempo stimato in minuti')),
            const SizedBox(height: 10),
            TextField(
                controller: actual,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Tempo effettivo in minuti')),
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
              final estimated = int.tryParse(estimate.text.trim());
              final done = int.tryParse(actual.text.trim());
              if (trimmedTitle.isEmpty) {
                showAppMessage(context, 'Inserisci il titolo dell\'obiettivo.');
                return;
              }
              if (courseId == null) {
                showAppMessage(
                    context, 'Crea o seleziona un corso prima di salvare.');
                return;
              }
              if (estimated == null || estimated <= 0) {
                showAppMessage(context, 'Inserisci un tempo stimato valido.');
                return;
              }
              if (done == null || done < 0) {
                showAppMessage(context, 'Inserisci un tempo effettivo valido.');
                return;
              }
              store.upsertTask(TaskGoal(
                  id: widget.item?.id ?? id(),
                  title: trimmedTitle,
                  description: description.text.trim(),
                  courseId: courseId!,
                  dueDate: dueDate,
                  priority: priority,
                  status: status,
                  estimatedMinutes: estimated,
                  actualMinutes: done));
              Navigator.pop(context);
            },
            child: const Text('Salva')),
      ],
    );
  }
}
