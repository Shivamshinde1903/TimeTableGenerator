// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Timetable _$TimetableFromJson(Map<String, dynamic> json) {
  List<List<TimetableEntry>> timetable = [];
  for (var i = 0; i < json['timetable'].length; i++) {
    timetable.add([]);
    for (var j = 0; j < json['timetable'][i].length; j++) {
      timetable[i].add(TimetableEntry.fromJSON(json['timetable'][i][j]));
    }
  }

  return Timetable.withTimetable(json['days'], json['timeSlots'], timetable);
}

Map<String, dynamic> _$TimetableToJson(Timetable instance) => <String, dynamic>{
      'days': instance.days,
      'timeSlots': instance.timeSlots,
      'timetable': instance._timetable
          .map((e) => e
              .map((e) => TimetableEntry(
                      professor: e!.professor,
                      subject: e.subject,
                      classNumber: e.classNumber)
                  .toJSON())
              .toList())
          .toList()
    };

TimetableEntry _$TimetableEntryFromJson(Map<String, dynamic> json) =>
    TimetableEntry(
      professor: json['professor'] as String,
      subject: json['subject'] as String,
      classNumber: json['classNumber'] as int,
    );

Map<String, dynamic> _$TimetableEntryToJson(TimetableEntry instance) =>
    <String, dynamic>{
      'professor': instance.professor,
      'subject': instance.subject,
      'classNumber': instance.classNumber,
    };
