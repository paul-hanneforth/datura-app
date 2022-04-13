import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

Future<void> disableFirebaseProducts() async {

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);

}
Future<void> setupCrashlytics() async {
  // TODO
  // ? FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
}
Future<void> logAddWeightEntryEvent() async {

  await FirebaseAnalytics.instance.logEvent(name: 'add_weight_entry');

}
Future<void> initialize() => Firebase.initializeApp();