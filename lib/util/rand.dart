import 'dart:math';

import 'package:datura/util/date.dart';

class Rand {

  static const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  static String getRandomString(int length) {
    final Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  static int randomNumberBetween(min, max) {
    final _random = Random();
    return min + _random.nextInt(max - min);
  }

  static String randomId() => getRandomString(10);

  static BetterDateTime randomDate(int dayRangeStart, int dayRangeEnd) {
    final BetterDateTime current = BetterDateTime();
    final int day = randomNumberBetween(dayRangeStart, dayRangeEnd);

    final int subtract = current.day - day;

    return subtract.isNegative ? current.add(Duration(days: subtract.abs())) : current.subtract(Duration(days: subtract));
  }

}