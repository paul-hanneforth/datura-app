import 'package:datura/util/date.dart';
import 'package:datura/util/rand.dart';
import 'package:datura/util/store.dart';
import 'package:datura/util/types.dart';
import 'package:flutter/material.dart';

class WeightEntryModel extends ValueNotifier<IndexedWeightEntry> {

  WeightEntryModel(value) : super(value);
  
  setReview(Review updatedReview) {
    print("Updating Review from ${value.review} to ${updatedReview}!");
    value = value.copyWith(review: updatedReview);
  }
  update(WeightEntry updatedEntry) {
    value = value.copyWith(review: updatedEntry.review, weight: updatedEntry.weight, date: updatedEntry.date, weightUnit: updatedEntry.weightUnit);
  }

  @override
  notifyListeners() {
    super.notifyListeners();
  }

}

class WeightEntriesModel extends ValueNotifier<List<WeightEntryModel>> {

  WeightEntriesModel() : super([]);

  List<void Function(WeightEntryModel)> onRemoveListeners = [];
  List<void Function(WeightEntryModel)> onAddListeners = [];
  List<void Function(WeightEntryModel)> onUpdateListeners = [];

  void addOnRemoveListener(void Function(WeightEntryModel weightEntryModel) listener) => onRemoveListeners.add(listener);
  void addOnAddListener(void Function(WeightEntryModel weightEntryModel) listener) => onAddListeners.add(listener);
  void addOnUpdateListener(void Function(WeightEntryModel weightEntryModel) listener) => onUpdateListeners.add(listener);

  void removeOnRemoveListener(void Function(WeightEntryModel weightEntryModel) listener) => onRemoveListeners.remove(listener);
  void removeOnAddListener(void Function(WeightEntryModel weightEntryModel) listener) => onAddListeners.remove(listener);
  void removeOnUpdateListener(void Function(WeightEntryModel ) listener) => onUpdateListeners.remove(listener);

  @override
  void notifyListeners() {
    super.notifyListeners();

    print("WeightEntriesModel.notifyListeners()");
  }

  void addWeightEntry(IndexedWeightEntry indexedWeightEntry) {
    final WeightEntryModel weightEntryModel = WeightEntryModel(indexedWeightEntry);

    for(final listener in onUpdateListeners) {
      weightEntryModel.addListener((() => listener(weightEntryModel)));
    }
    weightEntryModel.addListener(() => notifyListeners());

    value.add(weightEntryModel);

    print("notifying ${onAddListeners.length} onAddListeners");

    for(final listener in onAddListeners) {
      listener(weightEntryModel);
    }

    super.notifyListeners();
  }
  void addUnindexedWeightEntry(WeightEntry entry) {
    final id = Rand.randomId();

    addWeightEntry(IndexedWeightEntry.from(weightEntry: entry, id: id));
  }
  void removeWeightEntry(WeightEntryModel entry) {
    value.removeWhere((model) => model == entry);

    for(final listener in onRemoveListeners) {
      listener(entry);
    }

    print("notifying ${onAddListeners.length} onRemoveListeners");

    super.notifyListeners();
  }

  WeightEntriesModelShadow shadow(DateTimeRange timeRange) {

    final WeightEntriesModelShadow newModel = WeightEntriesModelShadow(shader: this, timeRange: timeRange);

    // fill Model with WeightEntries from that period
    for(final weightEntryModel in value) {
      if(timeRange.start.isBefore(weightEntryModel.value.date) && timeRange.end.isAfter(weightEntryModel.value.date)) {
        newModel.addWeightEntryModel(weightEntryModel);
      }
    }

    // setup listeners
    addOnAddListener(newModel.shaderOnAddListener);
    addOnRemoveListener(newModel.shaderOnRemoveListener);

    return newModel;

  }

}
class WeightEntriesModelShadow extends ValueNotifier<List<WeightEntryModel>> {

  WeightEntriesModelShadow({
    this.shader,
    this.timeRange
  }) : super([]);

  final WeightEntriesModel? shader;
  DateTimeRange? timeRange;

  bool _mounted = true;
  bool get mounted => _mounted;

  void addWeightEntryModel(WeightEntryModel weightEntryModel) {
    int index = 0;
    for(final addedWeightEntryModel in value) {
      if(addedWeightEntryModel.value.date.isBefore(weightEntryModel.value.date)) {
        index++;
      }
    }    

    value.insert(index, weightEntryModel);

    weightEntryModel.addListener(() => notifyListeners());

    notifyListeners();
  }
  void removeWeightEntryModel(WeightEntryModel weightEntryModel) {
    value.remove(weightEntryModel);

    notifyListeners();
  }

  void shaderOnAddListener(WeightEntryModel weightEntryModel) {
    if(timeRange == null) return;

    if(timeRange!.start.isBefore(weightEntryModel.value.date) && timeRange!.end.isAfter(weightEntryModel.value.date)) {
      addWeightEntryModel(weightEntryModel);
    }
  }
  void shaderOnRemoveListener(WeightEntryModel weightEntryModel) {
    if(timeRange == null) return;

    if(timeRange!.start.isBefore(weightEntryModel.value.date) && timeRange!.end.isAfter(weightEntryModel.value.date)) {
      removeWeightEntryModel(weightEntryModel);
    }
  }

  void disposeListeners() {
    if(shader != null) {
      shader!.removeOnAddListener(shaderOnAddListener);
      shader!.removeOnRemoveListener(shaderOnRemoveListener);
    }
  }

  @override
  void removeListener(void Function() listener) {
    super.removeListener(listener);

    if(!hasListeners && mounted) {
      print("This WeightEntriesModelShadow doesn't seem to have any listeners anymore. It will be automatically disposed.");
      dispose();
    }
  }

  @override
  void dispose() {
    print("WeightEntriesModelShadow.dispose()");
    if(!mounted) return;

    // super.dispose();
    disposeListeners();

    _mounted = false;
  }

}