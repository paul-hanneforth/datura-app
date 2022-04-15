import 'package:datura/util/date.dart';
import 'package:datura/util/rand.dart';
import 'package:datura/util/types.dart';
import 'package:sdcl/health_data/health_data.dart' as sdcl;
import 'package:sdcl/health_data/weight.dart' as sdcl;
import 'package:sdcl/identifiables.dart' as sdcl;
import 'package:sdcl/sdcl.dart' as sdcl;

class Faker {

  static WeightEntry todayWeight() {
    final num weight = Rand.randomNumberBetween(50, 70);

    return WeightEntry(weight: weight, date: BetterDateTime());
  }

  static WeightEntry weight() {
    final num weight = Rand.randomNumberBetween(50, 70);

    final int daysSkipped = Rand.randomNumberBetween(-30, 30);
    final int hoursSkipped = Rand.randomNumberBetween(-24, 24);
    final int minutesSkipped = Rand.randomNumberBetween(-60, 60);
    final int secondsSkipped = Rand.randomNumberBetween(-60, 60);
    final BetterDateTime date = BetterDateTime().add(Duration(days: daysSkipped, hours: hoursSkipped, minutes: minutesSkipped, seconds: secondsSkipped));

    return WeightEntry(weight: weight, date: date, review: review());
  }

  static Review review() {
    int rand = Rand.randomNumberBetween(0, 3);
    Review review = rand == 2 ? Review.good : (rand == 1 ? Review.ok : Review.bad);
    return review;
  }

  static sdcl.Block block() {
    final String randomString = Rand.getRandomString(10);

    return sdcl.Block(
      healthData: sdcl.HealthData(
        weightList: [
          sdcl.Weight(
            weight: Rand.randomNumberBetween(50, 70),
            date: BetterDateTime(),
            weightUnit: sdcl.WeightUnit.kilogram,
          )
        ]
      ),
      identifiables: [
        sdcl.Identifiable(value: randomString)
      ]
    );
  }
  
}