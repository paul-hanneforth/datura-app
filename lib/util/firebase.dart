import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
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
Future<void> logAddWeightEntryEvent() async {

  await FirebaseAnalytics.instance.logEvent(name: 'add_weight_entry');

}
Future<void> initialize() => Firebase.initializeApp();

Future<void> addBlock(sdcl.Block block) async {

  CollectionReference blocks = FirebaseFirestore.instance.collection("blocks");

  await blocks.add(block.toJSON());

}