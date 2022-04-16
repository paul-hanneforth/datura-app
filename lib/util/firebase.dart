import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datura/util/types.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import "package:flutter/material.dart";
import 'package:sdcl/sdcl.dart' as sdcl;

Future<void> disableFirebaseTracking() async {

  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
  await FirebasePerformance.instance.setPerformanceCollectionEnabled(false);

}
Future<void> setupCrashlytics() async {

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

}
Future<void> logAddWeightEntryEvent(WeightEntry weightEntry) async {
  
  await FirebaseAnalytics.instance.logEvent(
    name: 'add_weight_entry',
    parameters: {
      "weight": weightEntry.weight,
      "weightUnit": weightEntry.weightUnit.name,
      "date": weightEntry.date.toIso8601String(),
    }
  );

}
Future<void> initialize() => Firebase.initializeApp();
Future<void> addBlock(sdcl.Block block) async {

  CollectionReference blocks = FirebaseFirestore.instance.collection("blocks");

  await blocks.add(block.toJSON());

}
Future<void> setupRemoteConfig() async {

  final remoteConfig = FirebaseRemoteConfig.instance;

  await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
  ));
  await remoteConfig.setDefaults(const {
    "review_strictness": 1,
  });
  await remoteConfig.fetchAndActivate();

}
double getReviewStrictness() {

  final remoteConfig = FirebaseRemoteConfig.instance;

  final double reviewStrictness = remoteConfig.getDouble("review_strictness");

  return reviewStrictness;

}