import 'package:habit_crudx/utils/date_time.dart';
import 'package:hive/hive.dart';

final _myBox = Hive.box("Habit_Database");

class HabitDatabase {
  List todayHabitList = [];
  Map<DateTime, int> heatMapDataSet = {};

  // Create initial data
  void createDefaultData() {
    todayHabitList = [
      ['Morning run', false],
      ['Read', true],
      ['Study', false]
    ];

    _myBox.put("START_DATE", todayDateFormatted());
  }

  // Load data
  void loadData() {
    if (_myBox.get(todayDateFormatted()) == null) {
      todayHabitList = _myBox.get("CURRENT_HABIT_LIST");

      for (int i = 0; i < todayHabitList.length; i++) {
        todayHabitList[i][1] = false;
      }
    } else {
      todayHabitList = _myBox.get(todayDateFormatted());
    }
  }

  // Update data
  void updateDatabase() {
    _myBox.put(todayDateFormatted(), todayHabitList);

    _myBox.put("CURRENT_HABIT_LIST", todayHabitList);

    calculateHabitPorcentage();
    loadHeatMap();
  }

  void calculateHabitPorcentage() {
    int countCompleted = 0;
    for (int i = 0; i < todayHabitList.length; i++) {
      if (todayHabitList[i][1] == true) countCompleted++;
    }

    String percent = todayHabitList.isEmpty
        ? '0.0'
        : (countCompleted / todayHabitList.length).toStringAsFixed(1);
    _myBox.put("PERCENTAGE_SUMMARY_${todayDateFormatted()}", percent);
  }

  void loadHeatMap() {
    DateTime startDate = createDateTimeObject(_myBox.get("START_DATE"));

    int daysInBetween = DateTime.now().difference(startDate).inDays;

    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd = convertDateTimeToString(
        startDate.add(
          Duration(days: i),
        ),
      );

      double strength =
          double.parse(_myBox.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0");

      int year = startDate.add(Duration(days: i)).year;

      int month = startDate.add(Duration(days: i)).month;

      int day = startDate.add(Duration(days: i)).day;

      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strength).toInt(),
      };

      heatMapDataSet.addEntries(percentForEachDay.entries);
    }
  }
}
