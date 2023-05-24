import 'package:flutter/material.dart';
import 'package:ui3/pages/model/timetable.dart';

class TimetableScreen extends StatelessWidget {
  final String professor;
  final Timetable timetable;
  final bool isHOD;

  TimetableScreen(
      {super.key,
      required this.professor,
      required this.timetable,
      required this.isHOD});

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
      appBar: isHOD
          ? AppBar(
              title: Text('Timetable for $professor'),
            )
          : AppBar(),
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