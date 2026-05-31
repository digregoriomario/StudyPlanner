# StudyPlanner

StudyPlanner e un'app Flutter per organizzare corsi universitari, esami, scadenze, sessioni di studio, obiettivi e cicli Pomodoro in un unico ambiente.

## Funzionalita principali

- Dashboard con corsi attivi, esami futuri, obiettivi aperti, ore pianificate e ore svolte.
- Gestione completa dei corsi con docente, semestre selezionabile, CFU, stato, note, voto obiettivo e voto finale.
- Gestione di esami e scadenze con corso collegato, data, tipologia, priorita, stato, note e risultato.
- Calendario mensile con filtri per sessioni di studio, esami e obiettivi.
- Agenda giornaliera con completamento, modifica ed eliminazione rapida degli elementi.
- Obiettivi con ricerca, filtri per priorita/stato e tempi stimati/effettivi.
- Suggerimenti automatici sulle scadenze dei prossimi 21 giorni, con creazione rapida della sessione consigliata.
- Pomodoro collegato ai corsi, ciclo fisso 25/5 e registrazione automatica del tempo svolto come sessione completata.
- Persistenza locale tramite JSON e `shared_preferences`, con avvio iniziale senza dati precompilati.
- Layout responsive con sidebar su schermi larghi e bottom navigation su mobile.

## Migliorie UX integrate

- Conferma prima delle eliminazioni distruttive.
- Validazioni visibili nei form principali.
- Griglia dashboard adattiva su mobile, tablet e desktop.
- Form corso allineato al modello dati, inclusi voto obiettivo e voto finale.
- Form sessione con minuti pianificati, minuti svolti e stato completato.
- Filtri avanzati nella sezione esami per testo, stato e priorita.
- Pulizia automatica del vecchio dataset demo salvato nelle versioni precedenti.

## Architettura

Il progetto usa una struttura leggera adatta alla consegna didattica:

- `StudyStore`: stato globale basato su `ChangeNotifier`.
- `StudyScope`: accesso allo stato tramite `InheritedNotifier`.
- Modelli dati: `Course`, `ExamItem`, `StudySession`, `TaskGoal`.
- Persistenza: serializzazione JSON salvata in `shared_preferences`.
- `lib/main.dart`: bootstrap dell'app e collegamento dei file Dart.
- `lib/app/`: configurazione dell'app e scope globale.
- `lib/data/`: store e gestione della persistenza.
- `lib/models/`: enum e modelli dati.
- `lib/screens/`: schermate e dialog collegati alle sezioni principali.
- `lib/theme/`: costanti grafiche e regole responsive.
- `lib/utils/`: funzioni di supporto per date, validazioni, messaggi e suggerimenti.
- `lib/widgets/`: componenti UI riutilizzabili.

La divisione e realizzata con part file Dart per mantenere il refactor semplice e senza cambiare il comportamento dell'app.

## Requisiti

- Flutter SDK 3.x.
- Dart SDK incluso in Flutter.
- Un emulatore Android/iOS, un dispositivo fisico oppure Chrome per la versione web.

## Avvio

```bash
flutter pub get
flutter run
```

Per avviare su browser:

```bash
flutter run -d chrome
```

## Verifica

```bash
dart format lib test
flutter analyze
flutter test
```
