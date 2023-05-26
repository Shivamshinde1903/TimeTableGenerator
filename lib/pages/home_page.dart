import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ui3/pages/database.dart';
import 'dart:io';

import 'package:pdf/widgets.dart' as pw;
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
    Navigator.pop(context);
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

    if (!widget.isHOD) {
      var doc =
          FirebaseFirestore.instance.collection("users").doc(widget.user.uid);
      doc.get().then((value) {
        print(value.data()!['selectedSubjects']);
        setState(() {
          selectedSubjects = value.data()!['selectedSubjects'] != null
              ? value.data()!['selectedSubjects'].cast<String>()
              : [];
        });
      });
    }
    exportAsPDF();
  }

  Future exportAsPDF() async {
    final pdf = pw.Document();
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text('Hello World!'),
        ),
      ),
    );

    final file =
        await File(appDocDirectory.path + '/' + 'welcome.pdf').create();
    file.writeAsBytes(await pdf.save()).then((value) => {
          print('Saved as PDF + $value'),
          Share.shareFiles([appDocDirectory.path + '/' + 'welcome.pdf'],
              text: 'Great picture')
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: !widget.isHOD
          ? FloatingActionButton(
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
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'))
                      ],
                    );
                  },
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomSheet: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue.shade300),
            foregroundColor: MaterialStateProperty.all(Colors.white),
            minimumSize: MaterialStateProperty.all(Size(double.maxFinite, 50)),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            )))),
        onPressed: widget.isHOD
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimetableGenerationPage(
                        isHOD: true,
                        selectedSubjects: [...selectedSubjects, "Free"],
                        professors: professors),
                  ),
                );
              }
            : () {
                var doc = FirebaseFirestore.instance
                    .collection("users")
                    .doc(widget.user.uid);
                doc.update({
                  'selectedSubjects': selectedSubjects.contains("Free")
                      ? selectedSubjects
                      : [...selectedSubjects, "Free"]
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TimetableGenerationPage(
                            isHOD: false,
                            professors: professors,
                            selectedSubjects: [...selectedSubjects, "Free"])));
              },
        child: Text(
          widget.isHOD
              ? 'Generate Timetable'
              : selectedSubjects.isNotEmpty
                  ? 'View Timetable'
                  : 'Save Subjects',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(fontSize: 18, color: Colors.white),
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
              padding: const EdgeInsets.all(8.0),
              child: Text(
                !widget.isHOD
                    ? 'Select Subjects to teach (${selectedSubjects.length == 4 ? 3 : selectedSubjects.length}/3)'
                    : 'Professors Registered',
                style: const TextStyle(fontSize: 18),
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
                        List<String> selectedSubjects = professors.data?[index]
                                ['selectedSubjects']
                            .cast<String>();
                        return ListTile(
                          title: Text(professors.data?[index]['fullName']),
                          trailing: DropdownButton<String>(
                            underline: const SizedBox(),
                            isExpanded: false,
                            items: selectedSubjects
                                .sublist(0, 3)
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                enabled: false,
                                child:
                                    Container(width: 150, child: Text(value)),
                              );
                            }).toList(),
                            onChanged: (_) {},
                          ),
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



