import 'dart:math';

import 'package:ui3/pages/model/timetable.dart';

Map toMap(Timetable? professorTimetable) {
  return {
    'timetable': professorTimetable!.timetable.map((e) => {
          'timetable': e
              .map((e) => {
                    'professor': e!.professor,
                    'subject': e.subject,
                    'classNumber': e.classNumber,
                  })
              .toList(),
          // 'timetable': e.toJSON()
          // 'timetable': e.map((TimetableEntry e) => TimetableEntry(
          //         professor: e.professor,
          //         subject: e.subject,
          //         classNumber: e.classNumber)
          //     .toJSON())
        }),
  };
}

int randomIntAccordingTopriority() {
  Random random = Random();
  List<int> numbers = [0, 1, 2, 3];
  List<double> probabilities = [0.3, 0.2, 0.1, 0.5];
  double randomNumber = random.nextDouble();
  double cumulativeProbability = 0.0;

  for (int i = 0; i < probabilities.length; i++) {
    cumulativeProbability += probabilities[i];
    if (randomNumber < cumulativeProbability) {
      return numbers[i];
    }
  }

  // If the loop finishes without returning a number, fallback to the last number
  return numbers.last;
}
