part of '../main.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(onNavigate: (value) => setState(() => selected = value)),
      const CoursesScreen(),
      const ExamsScreen(),
      const PlannerScreen(),
      const TasksScreen(),
      const PomodoroScreen(),
    ];
    const items = [
      _NavItem(Icons.dashboard_outlined, Icons.dashboard, 'Home'),
      _NavItem(Icons.menu_book_outlined, Icons.menu_book, 'Corsi'),
      _NavItem(Icons.event_outlined, Icons.event, 'Esami'),
      _NavItem(
          Icons.calendar_month_outlined, Icons.calendar_month, 'Calendario'),
      _NavItem(Icons.task_alt_outlined, Icons.task_alt, 'Obiettivi'),
      _NavItem(Icons.timer_outlined, Icons.timer, 'Pomodoro'),
    ];

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 920) {
        return Scaffold(
          body: Row(
            children: [
              _Sidebar(
                selected: selected,
                items: items,
                onSelected: (value) => setState(() => selected = value),
              ),
              Expanded(
                  child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: pages[selected])),
            ],
          ),
        );
      }
      return Scaffold(
        body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: pages[selected]),
        bottomNavigationBar: NavigationBar(
          height: 70,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: selected,
          destinations: items
              .map((e) => NavigationDestination(
                  icon: Icon(e.icon),
                  selectedIcon: Icon(e.selectedIcon),
                  label: e.label))
              .toList(),
          onDestinationSelected: (value) => setState(() => selected = value),
        ),
      );
    });
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItem(this.icon, this.selectedIcon, this.label);
}

class _Sidebar extends StatelessWidget {
  final int selected;
  final List<_NavItem> items;
  final ValueChanged<int> onSelected;

  const _Sidebar(
      {required this.selected, required this.items, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppStyle.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppStyle.surface,
        border: Border(right: BorderSide(color: AppStyle.line)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppStyle.darkSurfaceSoft, AppStyle.darkSurface],
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [AppStyle.liftShadow],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: .10),
                              blurRadius: 12,
                              offset: const Offset(0, 5)),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                          'assets/branding/studyplanner_logo_1024.png',
                          fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('StudyPlanner',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              letterSpacing: 0)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('NAVIGAZIONE',
                    style: TextStyle(
                        color: AppStyle.muted,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                        fontSize: 11)),
              ),
              const SizedBox(height: 12),
              ...List.generate(items.length, (index) {
                final item = items[index];
                final active = selected == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => onSelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: active ? AppStyle.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color:
                                active ? AppStyle.primary : Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white.withValues(alpha: .12)
                                  : AppStyle.surfaceAlt,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(active ? item.selectedIcon : item.icon,
                                color: active ? Colors.white : AppStyle.subtle,
                                size: 19),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.label,
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: active ? Colors.white : AppStyle.ink),
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: active ? 1 : 0,
                            duration: const Duration(milliseconds: 150),
                            child: const Icon(Icons.arrow_forward_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class PageFrame extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget> actions;

  const PageFrame(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.child,
      this.actions = const []});

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.mobile(context);
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppStyle.background),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppStyle.maxPageWidth),
            child: Padding(
              padding: EdgeInsets.fromLTRB(compact ? 14 : 28, compact ? 14 : 26,
                  compact ? 14 : 28, compact ? 8 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PageHeader(
                      title: title, subtitle: subtitle, actions: actions),
                  SizedBox(height: compact ? 14 : 22),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;

  const _PageHeader(
      {required this.title, required this.subtitle, required this.actions});

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.mobile(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: (compact
                  ? Theme.of(context).textTheme.headlineMedium
                  : Theme.of(context).textTheme.displaySmall)
              ?.copyWith(
            color: AppStyle.ink,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          maxLines: compact ? 3 : 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppStyle.subtle,
              fontWeight: FontWeight.w600,
              height: 1.35),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 18 : 24),
      decoration: BoxDecoration(
        color: AppStyle.surface,
        borderRadius: BorderRadius.circular(compact ? 26 : 32),
        border: Border.all(color: AppStyle.line),
        boxShadow: [AppStyle.softShadow],
      ),
      child: compact
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              content,
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(spacing: 10, runSpacing: 10, children: actions)
              ]
            ])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: content),
                if (actions.isNotEmpty) ...[
                  const SizedBox(width: 18),
                  Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.end,
                      children: actions),
                ],
              ],
            ),
    );
  }
}
