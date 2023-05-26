import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ui3/pages/generate_timetable.dart';
import 'package:ui3/pages/home_page.dart';
import 'package:ui3/pages/model/timetable.dart';
import 'package:ui3/pages/timtetable_screen.dart';

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
  Timetable professorTimetable = Timetable(days: 5, timeSlots: 6);
  @override
  void initState() {
    super.initState();
    widget.isHOD ? getTimeTable() : getProfessorTimetable();
  }

  Future getTimeTable() async {
    professorTimetables = await generateTimetable(
        selectedSubjects: widget.selectedSubjects,
        days: 5,
        timeSlots: 6,
        classCount: 4,
        professors: widget.professors);
    setState(() {});
  }

  getProfessorTimetable() {
    final user = FirebaseAuth.instance.currentUser!;
    var doc = FirebaseFirestore.instance.collection("users").doc(user.uid);
    doc.get().then((value) {
      setState(() {
        professorTimetable =
            Timetable.fromJSON(jsonDecode(value.data()!['timetable']));
      });
      print(professorTimetables);
    });

    setState(() {});
  }

  //Get this data from firestore
  bool isTimeTableGenerated = true;
  Timetable table = Timetable(days: 5, timeSlots: 6);
  String prof = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Timetable'),
      ),
      body: widget.isHOD
          ? ListView.builder(
              itemCount: professorTimetables.length,
              itemBuilder: (context, index) {
                final professor = professorTimetables.keys.elementAt(index);
                final timetable = professorTimetables[professor]!;
                return ListTile(
                  title: Text(professor),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimetableScreen(
                            isHOD: widget.isHOD,
                            professor: professor,
                            timetable: timetable),
                      ),
                    );
                  },
                );
              },
            )
          : isTimeTableGenerated
              ? TimetableScreen(
                  professor: prof, timetable: professorTimetable, isHOD: false)
              : const Center(
                  child: Text(
                      'Please wait while the time table is generated by HOD'),
                ),
    );
  }
}
