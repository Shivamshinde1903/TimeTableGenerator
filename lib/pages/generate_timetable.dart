import 'dart:math';

import 'package:ui3/pages/database.dart';
import 'package:ui3/pages/model/timetable.dart';
import 'package:ui3/pages/utils.dart';

Future<Map<String, Timetable>> generateTimetable(
    {required List<String> selectedSubjects,
    required int days,
    required int timeSlots,
    required int classCount,
    required List professors}) async {
  Map<String, Timetable> professorTimetables = {};
  for (int i = 0; i <= professors.length - 1; i++) {
    professorTimetables[professors[i]['fullName']] =
        Timetable(days: days, timeSlots: timeSlots);
  }
  Random random = Random();
  for (int professor = 0; professor < professors.length; professor++) {
    for (int dayIndex = 0; dayIndex < days; dayIndex++) {
      for (int timeSlotIndex = 0; timeSlotIndex < timeSlots; timeSlotIndex++) {
        String subject = professors[professor]['selectedSubjects']
            [randomIntAccordingTopriority()];
        int classIndex = random.nextInt(classCount);
        professorTimetables[professors[professor]['fullName']]!.setEntry(
            dayIndex,
            timeSlotIndex,
            TimetableEntry(
                professor: professors[professor]['fullName'],
                subject: subject,
                classNumber: classIndex + 1));
      }
    }
  }
    var futures = professors.map((professor) async {
    // Get the map of subjects for the professor.

    Map mapSubject = toMap(professorTimetables[professor['fullName']]);

    updateData({'timetabe': mapSubject.toString()}, professor['uid'],
        isFiles: true);
  });

  await Future.wait(futures);

  return professorTimetables;
}

  