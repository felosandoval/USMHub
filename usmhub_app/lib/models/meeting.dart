import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay, this.category);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
  String category;

  // Comparar dos objetos Meeting
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meeting &&
          runtimeType == other.runtimeType &&
          eventName == other.eventName &&
          from == other.from &&
          to == other.to &&
          category == other.category;

  @override
  int get hashCode =>
      eventName.hashCode ^ from.hashCode ^ to.hashCode ^ category.hashCode;

  // Métodos para JSON (si no los tenés ya):
  Map<String, dynamic> toJson() => {
        'eventName': eventName,
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
        'background': background.value,
        'isAllDay': isAllDay,
        'category': category,
      };

  factory Meeting.fromJson(Map<String, dynamic> json) => Meeting(
        json['eventName'],
        DateTime.parse(json['from']),
        DateTime.parse(json['to']),
        Color(json['background']),
        json['isAllDay'],
        json['category'],
      );
}

// Fuente de datos que enlaza los eventos al calendario
class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}
