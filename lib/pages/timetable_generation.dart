import 'package:flutter/material.dart';
import 'package:ui3/pages/generate_timetable.dart';
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTimeTable();
  }

  Future getTimeTable() async {
    professorTimetables =
        // widget.isHOD
        //     ?
        await generateTimetable(
            selectedSubjects: widget.selectedSubjects,
            days: 5,
            timeSlots: 6,
            classCount: 4,
            professors: widget.professors);
    // : {};

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
                  professor: prof, timetable: table, isHOD: widget.isHOD)
              : Center(
                  child: Text(
                      'Please wait while the time table is generated by HOD'),
                ),
    );
  }
}