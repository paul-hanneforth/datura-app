import 'package:datura/util/types.dart';

List<int> gradientDescentMinima(List<double> gradient) {
  if(gradient.isEmpty) return [];

  double last = gradient.first;
  List<int> minima = [];

  for(int i = 1; i < gradient.length; i ++) {
    if(gradient[i] < last) {
        minima.add(i);
    }
    last = gradient[i];
  }

  return minima;

}
List<double> averageOut(List<double> list, [int n = 1]) {

  List<double> averageList = [];

  for(int i = n; i < list.length; i = i + (2 * n + 1)) {
      final sliced = n != 0 ? list.sublist(i - n, (i + n) + 1) : [list[i]];
      final average = sliced.reduce((a, b) => a + b) / (2 * n + 1);
      for(int t = 0; t < (2 * n + 1); t++) {
          averageList.add(average);
      }
  }

  return averageList;

}

class ReviewEngine {

  ReviewEngine({
    required this.weightEntries
  });

  final List<IndexedWeightEntry> weightEntries;
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
  List<List<IndexedWeightEntry>> segmentWeightEntries() {

    List<double> weightsAveraged = averageOut(weightEntries.map((entry) => entry.weight.toDouble()).toList(), 5);
    List<int> segmentIndexes = gradientDescentMinima(weightsAveraged);
    List<List<IndexedWeightEntry>> list = [];

    for(int i = 0; i < segmentIndexes.length; i ++) {
      if(i == 0) {
        list.add(weightEntries.sublist(0, segmentIndexes[i]));
      } else {
        list.add(weightEntries.sublist(segmentIndexes[i - 1], segmentIndexes[i]));
      }
    }

    return list;

  }

}