import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:http/http.dart' as http;
import '../models/meeting.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Meeting> meetings = [];
  List<Meeting> filteredMeetings = [];
  final List<String> icsUrls = [
    'https://vra.usm.cl/eventos/mes/2024-10/?ical=1',
    'https://vra.usm.cl/eventos/mes/2024-11/?ical=1',
    'https://vra.usm.cl/eventos/mes/2024-12/?ical=1',
    'https://vra.usm.cl/eventos/mes/2025-01/?ical=1',
  ];
  late CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _loadIcsFiles(); // Cargar los eventos de los archivos .ics
  }

  Future<void> _loadIcsFiles() async {
    List<Meeting> loadedMeetings = [];
    List<Future<http.Response>> futures = [];

    // Crear una lista de futuros para todas las solicitudes HTTP
    for (String icsUrl in icsUrls) {
      futures.add(http.get(Uri.parse(icsUrl)));
    }

    // Esperar a que todas las solicitudes HTTP terminen
    List<http.Response> responses = await Future.wait(futures);

    for (var response in responses) {
      if (response.statusCode == 200) {
        final icalendar = ICalendar.fromString(response.body);
        final events = icalendar.data.where((component) => component['type'] == 'VEVENT');
        for (var event in events) {
          final startDate = event['dtstart']?.dt;
          final endDate = event['dtend']?.dt;
          final summary = event['summary'] ?? 'Sin título';
          String category = 'Default';
          if (event['categories'] != null) {
            var categories = event['categories'];
            if (categories is List) {
              category = categories.join(', '); // Guardar todas las categorías
            } else if (categories is String) {
              category = categories;
            }
          }
          if (startDate != null) {
            DateTime eventStartDate = DateTime.parse(startDate.toString());
            DateTime eventEndDate = (endDate != null)
                ? DateTime.parse(endDate.toString()).subtract(Duration(days: 1))
                : eventStartDate;
            Color eventColor = _getColorForCategory(category.split(',')[0]); // Usar la primera categoría para el color
            loadedMeetings.add(Meeting(summary, eventStartDate, eventEndDate, eventColor, false, category));
          }
        }
      }
    }

    setState(() {
      meetings = loadedMeetings;
      filteredMeetings = meetings; // Inicialmente, mostrar todos los eventos
    });
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'estudiantes':
        return Color(0xFFCA9E00);
      case 'profesores':
        return Color(0xFFD2091D);
      case 'jefes de carrera':
        return Color(0xFF007549);
      case 'ceremonias':
        return Color(0xFF005E90);
      case 'comunidad usm':
        return Color(0xFF0D0E0D);
      default:
        return Colors.grey.shade200;
    }
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  void filterEvents(String categories) {
    List<String> categoryList = categories.toLowerCase().split(',').map((category) => category.trim()).toList();
    setState(() {
      filteredMeetings = meetings.where((event) {
        List<String> eventCategories = event.category.toLowerCase().split(',').map((category) => category.trim()).toList();
        return categoryList.any((category) => eventCategories.contains(category));
      }).toList();
    });
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario USM'),
        actions: [
          IconButton(
            icon: Icon(Icons.view_day_rounded),
            onPressed: () {
              // Cambiar a la vista actual
              _calendarController.selectedDate = DateTime.now();
              _calendarController.displayDate = DateTime.now();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtros:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          filterEvents('Estudiantes, Profesores, Ceremonias, Comunidad USM, Jefes de Carrera');
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Todos'),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          filterEvents('estudiantes');
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 202, 158, 0),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Estudiantes'),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          filterEvents('profesores');
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 210, 9, 29),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Profesores'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),
                
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          filterEvents('Ceremonias');
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 0, 94, 144),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Ceremonias'),
                          ],
                        ),
                      ),
                    ),

                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          filterEvents('Comunidad USM');
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 13, 14, 13),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Comunidad'),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          filterEvents('Jefes de Carrera');
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 0, 117, 72),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Jefes de Carrera'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SfCalendar(
              controller: _calendarController,
              view: CalendarView.month,
              allowedViews: [
                //CalendarView.day,
                CalendarView.month,
                CalendarView.schedule,
                //CalendarView.timelineDay,
                CalendarView.timelineMonth,
                //CalendarView.timelineWeek,
                //CalendarView.week,
                //CalendarView.workWeek,
              ],
              dataSource: MeetingDataSource(filteredMeetings),
              monthViewSettings: MonthViewSettings(
                showAgenda: true,
                agendaItemHeight: 60,
              ),
              onTap: (CalendarTapDetails details) {
                if (details.targetElement == CalendarElement.appointment) {
                  if (details.appointments != null && details.appointments!.isNotEmpty) {
                    final Meeting meeting = details.appointments!.first;
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(meeting.eventName),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: formatDateTime(meeting.from) + ' - ' + formatDateTime(meeting.to),
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Categorías:',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              for (var category in meeting.category.split(','))
                                Text(
                                  '* ${category.trim()}',
                                  style: TextStyle(color: Colors.black),
                                ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cerrar'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
onViewChanged: (ViewChangedDetails details) {
                print("Vista actual cambiada: ${details.visibleDates}");
              },
            )

          ),
        ],
      ),
    );
  }
}
