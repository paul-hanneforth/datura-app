import 'package:datura/pages/page.dart';
import 'package:datura/util/date.dart';
import 'package:datura/util/firebase.dart' as firebase;
import 'package:datura/util/mode.dart';
import 'package:datura/util/models.dart';
import 'package:datura/util/review_engine.dart';
import 'package:datura/util/sdcl.dart';
import 'package:datura/util/store.dart';
import 'package:datura/util/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

Future<void> reviewWeightEntries(ReviewEngine engine, model) async {

  for(WeightEntryModel weightEntryModel in model.value) {
    final Review review = engine.review(weightEntryModel.value);

    if(weightEntryModel.value.review != review) {
      weightEntryModel.set(weightEntryModel.value.copyWith(review: review));
    }
  }

}

Future<void> setupFirebase() async {

  await firebase.initialize();

  await firebase.setupCrashlytics();

  await firebase.setupRemoteConfig();

  if(kDebugMode) {
    await firebase.disableFirebaseTracking();
  }

}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await setupFirebase();
  } catch(e) {
    debugPrint("Failed to setup firebase: $e");
  }

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
    required this.switchMode,
    required this.resetData,
    required Widget child,
  }) : super(key: key, child: child);

  final WeightEntriesModel model;
  final Mode mode;
  final Future<void> Function(Mode newMode) switchMode;
  final Future<void> Function() resetData;

  static AppState of(BuildContext context) {
    final AppState? result = context.dependOnInheritedWidgetOfExactType<AppState>();
    assert(result != null, 'No AppState found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppState oldWidget) {
    debugPrint("[main.dart] [AppState] AppState was modified! The Descendants will be notified!");
    return true;
  }

} 

class MyApp extends StatefulWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {

  Mode mode = kDebugMode ? Mode.development : Mode.production;
  WeightEntriesModel model = WeightEntriesModel();
  Database? db;

  @override
  void initState() {
    super.initState();

    asyncWrapper();
  }
  void asyncWrapper() async {

    // load DB
    db = await openStoreDatabase(databasePath(mode));

    List<IndexedWeightEntry> loadedWeightEntries = await retrieveWeightEntries(db!);
    
    // load weightEntries into model
    for(final weightEntry in loadedWeightEntries) {
      model.addWeightEntry(weightEntry);
    }

    /* List<WeightEntry> weightEntries = importData();
    for(final weightEntry in weightEntries) {
      model.addUnindexedWeightEntry(weightEntry);
    } */

    setupModelListeners(model, db!);

    final BetterDateTime? lastPushed = await lastPushedBlock();
    if(lastPushed == null || DateTime.now().difference(lastPushed).inSeconds > firebase.getSDCLUpdateInterval()) {
      pushBlockToFirebase(loadedWeightEntries);
    }

  }
  void setupModelListeners(WeightEntriesModel model, Database db) {

    model.addOnUpdateListener((weightEntryModel) async => await updateWeightEntry(db, weightEntryModel.value.id, weightEntryModel.value));
    model.addOnAddListener((weightEntryModel) async => await insertWeightEntry(db, weightEntryModel.value));
    model.addOnRemoveListener((weightEntryModel) async => await removeWeightEntry(db, weightEntryModel.value));

    model.addOnUpdateListener((weightEntryModel) => reviewAllWeightEntries());
    model.addOnAddListener((weightEntryModel) => reviewAllWeightEntries());
    model.addOnRemoveListener((weightEntryModel) => reviewAllWeightEntries());

  }
  void reviewAllWeightEntries() {

    final List<WeightEntryModel> list = model.value;
    ReviewEngine reviewEngine = ReviewEngine(weightEntries: list.map((weightEntryModel) => weightEntryModel.value).toList());
    reviewWeightEntries(reviewEngine, model);

  }
  Future<void> switchMode(Mode newMode) async {

    Database newDB = await openStoreDatabase(databasePath(newMode));
    WeightEntriesModel newModel = WeightEntriesModel();

    List<IndexedWeightEntry> loadedWeightEntries = await retrieveWeightEntries(newDB);
    
    // load weightEntries into model
    for(final weightEntry in loadedWeightEntries) {
      newModel.addWeightEntry(weightEntry);
    }

    setupModelListeners(newModel, newDB);

    reviewAllWeightEntries();

    setState(() {
      mode = newMode;
      db = newDB;
      model = newModel;
    });
  }
  Future<void> resetData() async {

    model.disposeAllListeners();

    if(db != null) await db!.close();

    await wipeStoreDatabase(databasePath(mode));

    Database newDB = await openStoreDatabase(databasePath(mode));
    WeightEntriesModel newModel = WeightEntriesModel();

    setupModelListeners(newModel, newDB);

    setState(() {
      db = newDB;
      model = newModel;
    });

  }

  @override
  Widget build(BuildContext context) {
    debugPrint("[main.dart] [MyApp] Rebuilding entire App!");
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    return AppState(
      model: model,
      mode: mode,
      switchMode: switchMode,
      resetData: resetData,
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