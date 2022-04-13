import 'package:datura/pages/page2.dart';
import 'package:datura/util/date.dart';
import 'package:datura/util/firebase.dart' as firebase;
import 'package:datura/util/mode.dart';
import 'package:datura/util/models.dart';
import 'package:datura/util/review_engine.dart';
import 'package:datura/util/store.dart';
import 'package:datura/util/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show kDebugMode;


void setupModelDatabaseListeners(WeightEntriesModel model, Database db) {

  model.addOnUpdateListener((weightEntryModel) async {
    if(dbActiveReset) return;

    await updateWeightEntry(db, weightEntryModel.value.id, weightEntryModel.value);

    reviewAllWeightEntries();
  });
  model.addOnAddListener((weightEntryModel) async {
    if(dbActiveReset) return;

    await insertWeightEntry(db, weightEntryModel.value);

    reviewAllWeightEntries();
  });
  model.addOnRemoveListener((weightEntryModel) async {
    if(dbActiveReset) return;

    await removeWeightEntry(db, weightEntryModel.value);

    reviewAllWeightEntries();
  });

}
Future<void> reviewWeightEntries(ReviewEngine engine, model) async {

  for(WeightEntryModel weightEntryModel in model.value) {
    final Review review = engine.review(weightEntryModel.value);

    if(weightEntryModel.value.review != review) {
      print("set review to ${review.name} ${weightEntryModel.value}");
      weightEntryModel.setReview(review);
    }
  }

}

Mode mode = Mode.production;
String get databasePath => mode == Mode.development ? "dev.db" : "prod.db"; 

bool dbActiveReset = false;
Future<Database> dbFuture = openStoreDatabase(databasePath);
WeightEntriesModel weightEntriesModel = WeightEntriesModel();
ReviewEngine reviewEngine = ReviewEngine(weightEntries: []);

Future<void> setMode(Mode newMode) async {
  mode = newMode;
  
  await restartDB();

  runApp(const MyApp());
}
Future<void> restartDB() async {
  // notify other components that the database is being stopped
  dbActiveReset = true;

  (await dbFuture).close();
  dbFuture = openStoreDatabase(databasePath);
  await loadWeightEntriesIntoModel();

  // notify other components that the database can be used again
  dbActiveReset = false;
}
Future<void> resetData() async {
  // notify other components that the database is being reset
  dbActiveReset = true;

  await wipeStoreDatabase(databasePath);

  weightEntriesModel = WeightEntriesModel();

  // restart database
  dbFuture = openStoreDatabase(databasePath);

  setupModelDatabaseListeners(weightEntriesModel, await dbFuture);

  // notify other components that the database can be used again
  dbActiveReset = false;

  runApp(MyApp());
}

Future<void> reviewAllWeightEntries() async {
  print("Reviewing all weight entries ...");

  final List<WeightEntryModel> list = weightEntriesModel.value;
  reviewEngine = ReviewEngine(weightEntries: list.map((weightEntryModel) => weightEntryModel.value).toList());
  
  reviewWeightEntries(reviewEngine, weightEntriesModel);

}

Future<void> loadWeightEntriesIntoModel() async {
  // clear all previous weightEntries
  final int length = weightEntriesModel.value.length;
  for(int i = 0; i < length; i ++) {
    weightEntriesModel.removeWeightEntry(weightEntriesModel.value[0]);
  }

  List<IndexedWeightEntry> weightEntries = await retrieveWeightEntries(await dbFuture);
  print("loaded ${weightEntries.length} weightEntries");

  for(final weightEntry in weightEntries) {
    weightEntriesModel.addWeightEntry(weightEntry);
  }

  await reviewAllWeightEntries();
}

void setup() async {

  await loadWeightEntriesIntoModel();

  setupModelDatabaseListeners(weightEntriesModel, await dbFuture);
  
}

Future<void> setupFirebase() async {

  await firebase.initialize();

  await firebase.setupCrashlytics();

  if(kDebugMode) {
    print("DEBUG MODE!!!");
  }

}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupFirebase();

  setup();

  //Setting SysemUIOverlay
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: true,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark)
  );
      
  //Setting SystmeUIMode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top]);

  runApp(const MyApp());
}

class AppState extends InheritedWidget {

  const AppState({
    Key? key,
    required this.model,
    required this.mode,
    required Widget child,
  }) : super(key: key, child: child);

  final WeightEntriesModel model;
  final Mode mode;

  static AppState of(BuildContext context) {
    final AppState? result = context.dependOnInheritedWidgetOfExactType<AppState>();
    assert(result != null, 'No AppState found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppState old) {
    print("AppState was modified! The Descendants will be notified!");
    return true;
  }

} 

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    return AppState(
      model: weightEntriesModel,
      mode: mode,
      child: MaterialApp(
        title: 'Datura',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MainPage()
      ),
    );
  }
}