import 'package:datura/util/date.dart';
import 'package:datura/util/firebase.dart' as firebase;
import 'package:datura/util/id.dart';
import 'package:datura/util/types.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:sdcl/health_data/health_data.dart' as sdcl;
import 'package:sdcl/health_data/weight.dart' as sdcl;
import 'package:sdcl/identifiables.dart' as sdcl;
import 'package:sdcl/sdcl.dart' as sdcl;
import 'package:shared_preferences/shared_preferences.dart';

late Future<SharedPreferences> prefs = SharedPreferences.getInstance();

Future<BetterDateTime?> lastPushedBlock() async {
  final String? iso8601 = (await prefs).getString("lastPushedBlock");
  if(iso8601 == null) return null;
  return BetterDateTime.fromDateTime(DateTime.parse(iso8601));
}

Future<void> pushBlockToFirebase(List<IndexedWeightEntry> weightEntries) async {

  final String? deviceId = await getDeviceId();
  final sdcl.Identifiable userIdentifable = sdcl.Identifiable(value: deviceId);  
  final sdcl.Identifiable timestampIdentifiable = sdcl.Identifiable(value: BetterDateTime().toIso8601String());
  
  final sdcl.Block block = sdcl.Block(
    identifiables: kDebugMode == true ? [ 
      userIdentifable, 
      timestampIdentifiable,
      const sdcl.Identifiable(value: "debug"),
    ] : [
      userIdentifable, 
      timestampIdentifiable 
    ],
    healthData: sdcl.HealthData(
      weightList: weightEntries.map<sdcl.Weight>((e) {
        final sdcl.WeightUnit weightUnit = e.weightUnit == WeightUnit.kilogram ? sdcl.WeightUnit.kilogram : sdcl.WeightUnit.unset;

        return sdcl.Weight(
          date: e.date,
          weight: e.weight,
          weightUnit: weightUnit
        );
      }).toList()
    )
  );

  await firebase.addBlock(block);

  (await prefs).setString("lastPushedBlock", BetterDateTime().toIso8601String());

}