part of '../main.dart';

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
    store = StudyStore()..load();
  }

  @override
  Widget build(BuildContext context) {
    final foruiTheme = const <TargetPlatform>{
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.fuchsia,
    }.contains(defaultTargetPlatform)
        ? FThemes.neutral.light.touch
        : FThemes.neutral.light.desktop;

    final baseTextTheme = Typography.blackCupertino.apply(
      bodyColor: AppStyle.ink,
      displayColor: AppStyle.ink,
    );

    final materialTheme = foruiTheme.toApproximateMaterialTheme().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppStyle.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppStyle.background,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: baseTextTheme.copyWith(
            displayLarge: baseTextTheme.displayLarge
                ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
            displayMedium: baseTextTheme.displayMedium
                ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
            headlineLarge: baseTextTheme.headlineLarge
                ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
            headlineMedium: baseTextTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
            headlineSmall: baseTextTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
            titleLarge: baseTextTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
            titleMedium: baseTextTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
            bodyLarge: baseTextTheme.bodyLarge?.copyWith(height: 1.45),
            bodyMedium: baseTextTheme.bodyMedium?.copyWith(height: 1.42),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: AppStyle.background,
            foregroundColor: AppStyle.ink,
            centerTitle: false,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppStyle.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            hintStyle: const TextStyle(
                color: AppStyle.muted, fontWeight: FontWeight.w600),
            labelStyle: const TextStyle(
                color: AppStyle.subtle, fontWeight: FontWeight.w700),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppStyle.line)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppStyle.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppStyle.primary, width: 1.4),
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            elevation: 0,
            height: 74,
            backgroundColor: AppStyle.surface,
            indicatorColor: AppStyle.primary,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return IconThemeData(
                  color: selected ? Colors.white : AppStyle.subtle, size: 22);
            }),
          ),
          chipTheme: const ChipThemeData(
            backgroundColor: AppStyle.surfaceAlt,
            side: BorderSide(color: AppStyle.line),
            shape: StadiumBorder(),
            labelStyle:
                TextStyle(fontWeight: FontWeight.w800, color: AppStyle.ink),
          ),
          dropdownMenuTheme: DropdownMenuThemeData(
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppStyle.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppStyle.line)),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, AppStyle.buttonHeight),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              backgroundColor: AppStyle.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppStyle.buttonRadius)),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, AppStyle.buttonHeight),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              foregroundColor: AppStyle.primary,
              side: const BorderSide(color: AppStyle.lineStrong),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppStyle.buttonRadius)),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              minimumSize: const Size(0, AppStyle.buttonHeight),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              foregroundColor: AppStyle.primary,
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppStyle.buttonRadius)),
            ),
          ),
          cardTheme: CardThemeData(
            color: AppStyle.surface,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
                side: const BorderSide(color: AppStyle.line)),
          ),
          dialogTheme: DialogThemeData(
            backgroundColor: AppStyle.surface,
            surfaceTintColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            titleTextStyle: baseTextTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w900, color: AppStyle.ink),
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: AppStyle.surface,
            surfaceTintColor: Colors.transparent,
          ),
        );

    return StudyScope(
      notifier: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'StudyPlanner',
        supportedLocales: FLocalizations.supportedLocales,
        localizationsDelegates: const [
          ...FLocalizations.localizationsDelegates
        ],
        theme: materialTheme,
        builder: (context, child) => FTheme(
          data: foruiTheme,
          child: FToaster(child: FTooltipGroup(child: child!)),
        ),
        home: const ShellScreen(),
      ),
    );
  }
}

class StudyScope extends InheritedNotifier<StudyStore> {
  const StudyScope({super.key, required super.notifier, required super.child});

  static StudyStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StudyScope>();
    assert(scope != null, 'StudyScope non trovato');
    return scope!.notifier!;
  }
}
