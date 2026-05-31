# StudyPlanner

StudyPlanner e un'app Flutter per organizzare lo studio universitario: corsi, esami, scadenze, sessioni pianificate, obiettivi e timer Pomodoro.

Il codice dell'app si trova nella cartella `study_planner_app/`.

## Funzionalita principali

- Dashboard con riepilogo di corsi, esami, studio svolto, studio pianificato e obiettivi.
- Gestione dei corsi con semestre, CFU, stato, note, voto obiettivo e voto finale.
- Gestione di esami e scadenze collegate ai corsi.
- Calendario mensile con sessioni di studio, esami e obiettivi.
- Sezione obiettivi con filtri, priorita e tempi stimati/effettivi.
- Timer Pomodoro con ciclo 25/5 e registrazione del tempo svolto.
- Persistenza locale tramite `shared_preferences`.
- Interfaccia responsive per mobile e web.

## Piattaforme incluse

Il progetto mantiene solo le piattaforme utili alla consegna:

- Android
- iOS
- Web

Le cartelle desktop `linux/`, `macos/` e `windows/` sono state rimosse per tenere la repository piu leggera.

## Struttura

```text
StudyPlannerFinale/
├── README.md
└── study_planner_app/
    ├── android/
    ├── ios/
    ├── web/
    ├── assets/
    ├── lib/
    │   └── main.dart
    ├── test/
    ├── pubspec.yaml
    └── pubspec.lock
```

## Requisiti

- Flutter SDK 3.x
- Dart SDK incluso in Flutter
- Chrome per la versione web
- Android Studio/Xcode o un dispositivo/emulatore per le build mobile

## Avvio

```bash
cd study_planner_app
flutter pub get
flutter run
```

Per avviare la versione web:

```bash
cd study_planner_app
flutter run -d chrome
```

## Verifica

```bash
cd study_planner_app
dart analyze lib test
flutter test
```

## Note

La repository ignora file generati, cache, build locali, file IDE e documenti non necessari al progetto. I file importanti per compilare l'app restano versionati.
