import 'package:flutter/material.dart';
import 'package:habit_crudx/components/monthly_summary.component.dart';
import 'package:habit_crudx/data/habit_database.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../components/fab.component.dart';
import '../components/habit_tile.component.dart';
import '../components/dialog_box.component.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HabitDatabase db = HabitDatabase();
  final _myBox = Hive.box("Habit_Database");

  @override
  void initState() {
    if (_myBox.get("CURRENT_HABIT_LIST") == null) {
      db.createDefaultData();
    } else {
      db.loadData();
    }

    db.updateDatabase();

    super.initState();
  }

  void checkBoxTapped(bool? value, int index) {
    setState(() {
      db.todayHabitList[index][1] = value;
    });
    db.updateDatabase();
  }

  final _newHabitController = TextEditingController();

  void saveNewHabit() {
    setState(() {
      db.todayHabitList.add([_newHabitController.text, false]);
    });
    _newHabitController.clear();

    db.updateDatabase();

    Navigator.pop(context);
  }

  void cancelHabit() {
    _newHabitController.clear();
    Navigator.pop(context);
  }

  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _newHabitController,
          onSave: saveNewHabit,
          onCancel: cancelHabit,
          hintText: 'New Habit',
        );
      },
    );
  }

  void openHabitSettings(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _newHabitController,
          onSave: () => _saveExistingHabit(index),
          onCancel: cancelHabit,
          hintText: db.todayHabitList[index][0],
        );
      },
    );
  }

  void _saveExistingHabit(int index) {
    setState(() {
      db.todayHabitList[index][0] = _newHabitController.text;
    });
    _newHabitController.clear();

    db.updateDatabase();

    Navigator.pop(context);
  }

  void deleteHabit(int index) {
    setState(() {
      db.todayHabitList.removeAt(index);
    });

    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        floatingActionButton:
            CustomFloatingActionButton(onPressed: createNewHabit),
        body: ListView(
          children: <Widget>[
            MonthlySummary(
                datasets: db.heatMapDataSet,
                startDate: _myBox.get("START_DATE")),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: db.todayHabitList.length,
              itemBuilder: (context, index) {
                return HabitTile(
                  habitName: db.todayHabitList[index][0],
                  habitCompleted: db.todayHabitList[index][1],
                  onChanged: (value) => checkBoxTapped(value, index),
                  settingsTapped: (context) => openHabitSettings(index),
                  deleteTapped: (context) => deleteHabit(index),
                );
              },
            ),
          ],
        ));
  }
}
