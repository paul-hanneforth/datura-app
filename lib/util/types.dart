import 'package:datura/util/date.dart';

enum Review {
  good,
  ok,
  bad,
  unset
}
extension ReviewToString on Review {
  String get name {
    if(this == Review.good) return "GOOD";
    if(this == Review.ok) return "OK";
    if(this == Review.bad) return "BAD";
    if(this == Review.unset) return "UNSET";
    return "UNSET";
  }
  String get serialized {
    if(this == Review.good) return "good";
    if(this == Review.ok) return "ok";
    if(this == Review.bad) return "bad";
    if(this == Review.unset) return "unset";
    
    return "unset";
  }
}
Review deserializeReview(String serialized) {
  if(serialized == "good") return Review.good;
  if(serialized == "ok") return Review.ok;
  if(serialized == "bad") return Review.bad;
  if(serialized == "unset") return Review.unset;

  return Review.unset;
}

enum WeightUnit {
  kilogram
}
extension WeightUnitToString on WeightUnit {
  String get name {
    if(this == WeightUnit.kilogram) return "kg";

    return "kg";
  }
  String get serialized {
    if(this == WeightUnit.kilogram) return "kg";

    return "kg";
  }
}

WeightUnit deserializeWeightUnit(String serializedWeightUnit) {
  if(serializedWeightUnit == "kg") {
    return WeightUnit.kilogram;
  }

  return WeightUnit.kilogram;
}

class WeightEntry {
  final num weight;
  final BetterDateTime date;
  final WeightUnit weightUnit;
  final Review? review;

  const WeightEntry({
    required this.weight,
    required this.date,
    this.weightUnit = WeightUnit.kilogram,
    this.review
  });

  WeightEntry copyWith({
    weight,
    date,
    weightUnit,
    review
  }) {
    return WeightEntry(
      weight: weight ?? this.weight,
      date: date ?? this.date,
      weightUnit: weightUnit ?? this.weightUnit,
      review: review ?? this.review
    );
  }

  isTheSame(WeightEntry other) => weight == other.weight && date == other.date && weightUnit == other.weightUnit;

}

class IndexedWeightEntry extends WeightEntry {

  final String id;

  IndexedWeightEntry({ 
    required this.id,
    required weight,
    required date,
    review,
    weightUnit
  }) : super(weight: weight, date: date, weightUnit: weightUnit, review: review);
  IndexedWeightEntry.from({
    required weightEntry,
    required this.id
  }) : super(weight: weightEntry.weight, date: weightEntry.date, weightUnit: weightEntry.weightUnit, review: weightEntry.review);

  static IndexedWeightEntry fromMap(Map<String, dynamic> map) {
    return IndexedWeightEntry(
      id: map["id"], 
      weight: map["weight"], 
      date: BetterDateTime.deserialize(map["date"]),
      weightUnit: deserializeWeightUnit(map["weightUnit"]),
      review: map["review"] != null ? deserializeReview(map["review"]) : Review.unset
    );
  }
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "weight": weight,
      "date": date.serialize(),
      "weightUnit": weightUnit.serialized,
      "review": review != null ? review!.serialized : Review.unset.serialized
    };
  }

  @override
  IndexedWeightEntry copyWith({
    weight,
    date,
    weightUnit,
    review,
    id
  }) {
    return IndexedWeightEntry(
      weight: weight ?? this.weight,
      date: date ?? this.date,
      weightUnit: weightUnit ?? this.weightUnit,
      review: review ?? this.review,
      id: id ?? this.id
    );
  }

  @override
  String toString() {
    String weightUnit = this.weightUnit.toString();
    return 'IndexedWeightEntry{id: $id, weight: $weight, weightUnit: $weightUnit, date: $date}';
  }

}