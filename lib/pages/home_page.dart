import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  // sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
          child: Text(
        "LOGGED IN AS: " + user.email!,
        style: TextStyle(fontSize: 20),
      )),
    );
  }
}

class TimeTable extends StatefulWidget {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  _TimeTableState createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  List<String> subjects = [
    'Internet of Things',
    'Artificial Intelligence',
    'Machine Learning',
    'Data Structures',
    'Operating Systems',
    'Database Management Systems',
    'Software Engineering',
    'Computer Networks',
    'Computer Graphics',
    'Discrete Mathematics',
  ];

  List<String> selectedSubjects = [];

  void onSubjectSelected(bool value, String subject) {
    setState(() {
      if (value) {
        selectedSubjects.add(subject);
      } else {
        selectedSubjects.remove(subject);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable Generation App'),
        elevation: 1,
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Choose subjects to teach:',
              style: TextStyle(fontSize: 18),
            ),
          ),
          ...subjects.map(
            (subject) => CheckboxListTile(
              title: Text(subject),
              value: selectedSubjects.contains(subject),
              onChanged: (value) => onSubjectSelected(value!, subject),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TimetableGenerationPage(
                      selectedSubjects: selectedSubjects),
                ),
              );
            },
            child: const Text('Generate Timetable'),
          ),
        ],
      ),
    );
  }
}

class TimetableGenerationPage extends StatelessWidget {
  final List<String> selectedSubjects;

  TimetableGenerationPage({required this.selectedSubjects});

  @override
  Widget build(BuildContext context) {
    final professorTimetables = generateTimetable(
      selectedSubjects: selectedSubjects,
      days: 5,
      timeSlots: 6,
      professorCount: 10,
      classCount: 12,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Timetables'),
      ),
      body: ListView.builder(
        itemCount: professorTimetables.length,
        itemBuilder: (context, index) {
          final professor = professorTimetables.keys.elementAt(index);
          final timetable = professorTimetables[professor]!;
          return ListTile(
            title: Text(professor),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TimetableScreen(
                      professor: professor, timetable: timetable),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TimetableScreen extends StatelessWidget {
  final String professor;
  final Timetable timetable;

  TimetableScreen({required this.professor, required this.timetable});

  List timeSlots = [
    '10:00am - 11:00am',
    '11:00am - 12:00pm',
    '12:00pm - 1:00pm',
    '1:00pm - 2:00pm',
    '2:00pm - 3:00pm',
    '3:00pm - 4:00pm',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timetable for $professor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ListView.builder(
          itemCount: timetable.days,
          itemBuilder: (context, dayIndex) {
            return ListTile(
              title: Text('Day ${dayIndex + 1}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int timeSlotIndex = 0;
                      timeSlotIndex < timetable.timeSlots;
                      ++timeSlotIndex)
                    ListTile(
                      title: Text(' ${timeSlots[timeSlotIndex]} '),
                      subtitle: Text(
                          'Room No. ${timetable.getEntry(dayIndex, timeSlotIndex)?.classNumber ?? '-'}'),
                      trailing: Text(
                          '${timetable.getEntry(dayIndex, timeSlotIndex)?.subject ?? 'Free'}'),
                    )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class Timetable {
  final List<List<TimetableEntry?>> _timetable;
  final int days;
  final int timeSlots;

  Timetable({required this.days, required this.timeSlots})
      : _timetable = List.generate(
          days,
          (_) => List<TimetableEntry?>.filled(timeSlots, null),
        );

  TimetableEntry? getEntry(int day, int timeSlot) => _timetable[day][timeSlot];

  void setEntry(int day, int timeSlot, TimetableEntry entry) {
    _timetable[day][timeSlot] = entry;
  }
}

Map<String, Timetable> generateTimetable({
  required List<String> selectedSubjects,
  required int days,
  required int timeSlots,
  required int professorCount,
  required int classCount,
}) {
  Map<String, Timetable> professorTimetables = {};
  for (int i = 1; i <= professorCount; i++) {
    professorTimetables['Professor $i'] =
        Timetable(days: days, timeSlots: timeSlots);
  }

  Random random = Random();
  for (int classIndex = 1; classIndex <= classCount; classIndex++) {
    for (int dayIndex = 0; dayIndex < days; dayIndex++) {
      for (int timeSlotIndex = 0; timeSlotIndex < timeSlots; timeSlotIndex++) {
        String subject =
            selectedSubjects[random.nextInt(selectedSubjects.length)];
        String professor = 'Professor ${random.nextInt(professorCount) + 1}';

        professorTimetables[professor]!.setEntry(
            dayIndex,
            timeSlotIndex,
            TimetableEntry(
                professor: professor,
                subject: subject,
                classNumber: classIndex));
      }
    }
  }

  return professorTimetables;
}

class TimetableEntry {
  final String professor;
  final String subject;
  final int classNumber;

  TimetableEntry(
      {required this.professor,
      required this.subject,
      required this.classNumber});
}
