import 'package:datura/util/types.dart';

class ReviewEngine {

  ReviewEngine({
    required this.weightEntries
  });

  final List<WeightEntry> weightEntries;
  final double buffer = 1.25;
  num get averageWeight => weightEntries.fold<num>(0, (acc, entry) => acc + entry.weight.toDouble()) / weightEntries.length;

  Review review(WeightEntry entry) {
    if(weightEntries.isEmpty) {
      return Review.good;
    }

    if(entry.weight <= averageWeight + buffer && entry.weight >= averageWeight - buffer) {
      return Review.ok;
    } else if(entry.weight < averageWeight) {
      return Review.good;
    } else if(entry.weight > averageWeight) {
      return Review.bad;
    }

    return Review.unset;
  }

}