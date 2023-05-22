import 'dart:isolate';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ui3/pages/database.dart';

class TimeTable extends StatefulWidget {
  TimeTable({super.key, required this.isHOD});

  final user = FirebaseAuth.instance.currentUser!;
  final bool isHOD;
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

  List<String> selectedSubjects = List.empty(growable: true);

  TextEditingController subjectController = TextEditingController();
  List professors = [];
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
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.isHOD
        ? fetchData().then((teachers) => {
              setState(() {
                professors = teachers;
              }),
              for (int i = 0; i < teachers.length; i++)
                {
                  if (teachers[i]['selectedSubjects'] != null ||
                      teachers[i]['selectedSubjects'] != [])
                    {
                      print(teachers[i]['selectedSubjects']),
                      for (int j = 0;
                          j < teachers[i]['selectedSubjects'].length;
                          j++)
                        {
                          selectedSubjects
                              .add(teachers[i]['selectedSubjects'][j]),
                        }
                    }
                }
            })
        : null;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.isHOD);
    return Scaffold(
      bottomSheet: widget.isHOD
          ? Container(
              width: double.infinity,
              child: TextButton(
                child: const Text('Add Subjects'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          'Add Subjects',
                        ),
                        content: TextField(
                          controller: subjectController,
                        ),
                        actions: [
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  subjects.add(subjectController.text);
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Add Suject')),
                          TextButton(
                              onPressed: () {}, child: const Text('Cancel'))
                        ],
                      );
                    },
                  );
                },
              ))
          : null,
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: widget.user.photoURL != null
                    ? CircleAvatar(
                        backgroundImage: widget.user.photoURL != null
                            ? NetworkImage(widget.user.photoURL!)
                            : null)
                    : Text(
                        "Welcome \n${widget.user.email}",
                        style: const TextStyle(fontSize: 18),
                      )),
            const ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
            ),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
            const ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Timetable Generation App'),
        elevation: 1,
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                !widget.isHOD
                    ? 'Select Subjects to teach (${selectedSubjects.length}/3)'
                    : 'Professors Registered',
                style: TextStyle(fontSize: 18),
              ),
            ),
            if (!widget.isHOD)
              ...subjects.map(
                (subject) => CheckboxListTile(
                  title: Text(subject),
                  value: selectedSubjects.contains(subject),
                  onChanged: selectedSubjects.length < 3
                      ? (value) => onSubjectSelected(value!, subject)
                      : null,
                ),
              ),
            if (widget.isHOD)
              FutureBuilder(
                future: fetchData(),
                builder: (context, professors) {
                  if (professors.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: professors.data?.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(professors.data?[index]['fullName']),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ElevatedButton(
              onPressed: widget.isHOD
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimetableGenerationPage(
                              isHOD: true,
                              selectedSubjects: selectedSubjects,
                              professors: professors),
                        ),
                      );
                    }
                  : () {
                      updateData({'selectedSubjects': selectedSubjects},
                          widget.user.uid);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TimetableGenerationPage(
                                  isHOD: false,
                                  professors: [],
                                  selectedSubjects: selectedSubjects)));
                    },
              child:
                  Text(widget.isHOD ? 'Generate Timetable' : 'Save Subjects'),
            ),
          ],
        ),
      ),
    );
  }
}

class TimetableGenerationPage extends StatefulWidget {
  const TimetableGenerationPage(
      {super.key,
      required this.selectedSubjects,
      required this.isHOD,
      required this.professors});

  final List<String> selectedSubjects;
  final bool isHOD;
  final List professors;

  @override
  State<TimetableGenerationPage> createState() =>
      _TimetableGenerationPageState();
}

class _TimetableGenerationPageState extends State<TimetableGenerationPage> {
  Map<String, dynamic> professorTimetables = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.isHOD);
    print(widget.selectedSubjects);
    print(widget.professors);
    setState(() {
      professorTimetables = widget.isHOD
          ? generateTimetable(
              selectedSubjects: widget.selectedSubjects,
              days: 5,
              timeSlots: 6,
              classCount: 4,
              professors: widget.professors)
          : {};
    });
  }

  //Get this data from firestore
  bool isTimeTableGenerated = true;
  Timetable table = Timetable(days: 5, timeSlots: 6);
  String prof = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Timetables'),
      ),
      body: widget.isHOD
          ? ListView.builder(
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
            )
          : isTimeTableGenerated
              ? TimetableScreen(professor: prof, timetable: table)
              : Center(
                  child: Text(
                      'Please wait while the time table is generated by HOD'),
                ),
    );
  }
}

class TimetableScreen extends StatelessWidget {
  final String professor;
  final Timetable timetable;

  TimetableScreen(
      {super.key, required this.professor, required this.timetable});

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
                      trailing: Text(timetable
                              .getEntry(dayIndex, timeSlotIndex)
                              ?.subject ??
                          'Free'),
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

Map<String, Timetable> generateTimetable(
    {required List<String> selectedSubjects,
    required int days,
    required int timeSlots,
    required int classCount,
    required List professors}) {
  Map<String, Timetable> professorTimetables = {};

  print(professors.length);
  for (int i = 0; i <= professors.length - 1; i++) {
    print(i);
    professorTimetables[professors[i]['fullName']] =
        Timetable(days: days, timeSlots: timeSlots);
  }

  Random random = Random();
  for (int professor = 1; professor < professors.length; professor++) {
    for (int classIndex = 1; classIndex <= classCount; classIndex++) {
      for (int dayIndex = 1; dayIndex < days; dayIndex++) {
        for (int timeSlotIndex = 0;
            timeSlotIndex < timeSlots;
            timeSlotIndex++) {
          String subject = professors[professor]['selectedSubjects'][
              random.nextInt(professors[professor]['selectedSubjects'].length)];
          professorTimetables[professors[professor]['fullName']]!.setEntry(
              dayIndex,
              timeSlotIndex,
              TimetableEntry(
                  professor: professors[professor]['fullName'],
                  subject: subject,
                  classNumber: classIndex));
        }
      }
    }
  }

  /*
    List professorTimetable = [
      {
        name:
        fcmToken:
        subjects: [a,b,c]
        timetable: {}
      }
    ]
*/

  //Save these time tables into the professor model

  // Update this into user moel synchrounously
  for (int i = 0; i <= professors.length - 1; i++) {
    Future.delayed(
        const Duration(seconds: 1),
        () => updateData(
            {'timetabe': professorTimetables[professors[i]['fullName']]},
            professors[i]['uid']));
  }

  updateData({'timetabe': professorTimetables[professors[0]['fullName']]},
      professors[0]['uid']);

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
