import 'dart:math';

import 'package:ui3/pages/model/timetable.dart';

Map toMap(Timetable? professorTimetable) {
  return {
    'timetable': professorTimetable!.timetable.map((e) => {
          e.map((e) => {
                'professor': e!.professor,
                'classNumber': e.classNumber,
                'subject': e.subject
              })
        }),
  };
}

int randomIntAccordingTopriority() {
  Random random = Random();
  int temp = random.nextInt(10);

  if (temp < 5) {
    return 0;
  }
  if (temp > 5 && temp < 8) {
    return 1;
  }
  return 2;
}
