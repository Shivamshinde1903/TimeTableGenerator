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

  get timetable => _timetable;

  void setEntry(int day, int timeSlot, TimetableEntry entry) {
    _timetable[day][timeSlot] = entry;
  }
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
