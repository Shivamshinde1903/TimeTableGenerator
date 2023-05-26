import 'dart:convert';

import 'package:flutter/scheduler.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timetable.g.dart';

@JsonSerializable(explicitToJson: true)
class Timetable {
  final List<List<TimetableEntry?>> _timetable;
  final int days;
  final int timeSlots;

  Timetable({required this.days, required this.timeSlots})
      : _timetable = List.generate(
          days,
          (_) => List<TimetableEntry?>.filled(timeSlots, null),
        );

  Timetable.withTimetable(this.days, this.timeSlots,this._timetable);

  TimetableEntry? getEntry(int day, int timeSlot) => _timetable[day][timeSlot];

  get timetable => _timetable;
  Map toJSON() => _$TimetableToJson(this);

  factory Timetable.fromJSON(json) => _$TimetableFromJson(json);

  void setEntry(int day, int timeSlot, TimetableEntry entry) {
    _timetable[day][timeSlot] = entry;
  }
}

class TimetableEntry {
  final String professor;
  final String subject;
  final int classNumber;

  Map toJSON() => _$TimetableEntryToJson(this);

  factory TimetableEntry.fromJSON(json) => _$TimetableEntryFromJson(json);

  TimetableEntry(
      {required this.professor,
      required this.subject,
      required this.classNumber});
}
