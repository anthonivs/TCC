import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/event.dart';

class UnifiedCalendar extends StatefulWidget {
  final List<Event> events;
  final void Function(DateTime, List<Event>)? onDaySelected;

  const UnifiedCalendar({super.key, required this.events, this.onDaySelected});

  @override
  State<UnifiedCalendar> createState() => _UnifiedCalendarState();
}

class _UnifiedCalendarState extends State<UnifiedCalendar> {
  late Map<DateTime, List<Event>> _eventsByDate;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _eventsByDate = _groupEventsByDate(widget.events);
  }

  @override
  void didUpdateWidget(covariant UnifiedCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events != widget.events) {
      setState(() {
        _eventsByDate = _groupEventsByDate(widget.events);
      });
    }
  }

  Map<DateTime, List<Event>> _groupEventsByDate(List<Event> events) {
    final Map<DateTime, List<Event>> map = {};
    for (var event in events) {
      final eventDate = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      map.putIfAbsent(eventDate, () => []).add(event);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar<Event>(
      locale: 'pt_BR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: DateTime.now(),
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader:
          (day) => _eventsByDate[DateTime(day.year, day.month, day.day)] ?? [],
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
        });

        final selectedEvents =
            _eventsByDate[DateTime(
              selectedDay.year,
              selectedDay.month,
              selectedDay.day,
            )] ??
            [];
        if (widget.onDaySelected != null) {
          widget.onDaySelected!(selectedDay, selectedEvents);
        }
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
