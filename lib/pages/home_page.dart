import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ui3/pages/database.dart';

import 'timetable_generation.dart';

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
    super.initState();

    // widget.isHOD
    //     ?
    fetchData().then((teachers) => {
          setState(() {
            professors = teachers;
          }),
          for (int i = 0; i < teachers.length; i++)
            {
              if (teachers[i]['selectedSubjects'] != null ||
                  teachers[i]['selectedSubjects'] != [])
                {
                  for (int j = 0;
                      j < teachers[i]['selectedSubjects'].length;
                      j++)
                    {
                      selectedSubjects.add(teachers[i]['selectedSubjects'][j]),
                    }
                }
            }
        });
    // : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: !widget.isHOD
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
                      updateData({
                        'selectedSubjects': [...selectedSubjects, "Free"]
                      }, widget.user.uid);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TimetableGenerationPage(
                                  isHOD: true,
                                  professors: professors,
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
  // for (int i = 0; i <= professors.length - 1; i++) {
  //   Future.delayed(
  //       const Duration(seconds: 1),
  //       () => updateData(
  //           {'timetabe': professorTimetables[professors[i]['fullName']]},
  //           professors[i]['uid']));
  // }

  // professors.forEach((professor) async {
  //   Map mapSubject = toMap(professorTimetables[professor['fullName']]);
  //   print(mapSubject.toString());
  //   await updateData({'timetabe': mapSubject.toString()}, professor['uid'],
  //       isFiles: true);
  // });



