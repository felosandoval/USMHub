import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import '../models/meeting.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Meeting> meetings = [];

  // Lista de archivos .ics que deseas cargar
  final List<String> icsFiles = [
    'assets/calendars/2024-10.ics',
    'assets/calendars/2024-11.ics',
    'assets/calendars/2024-12.ics',
    // Agrega más archivos según sea necesario
  ];

  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    _loadIcsFiles(); // Cargar los eventos de los archivos .ics
  }

  Future<void> _loadIcsFiles() async {
  List<Meeting> loadedMeetings = [];
  for (String icsFile in icsFiles) {
    // Cargar cada archivo .ics desde los assets
    final icsString = await rootBundle.loadString(icsFile);
    final icalendar = ICalendar.fromString(icsString);
    // Extraer los eventos (VEVENT) del archivo ICS
    final events = icalendar.data.where((component) => component['type'] == 'VEVENT');
    for (var event in events) {
      final startDate = event['dtstart']?.dt;
      final endDate = event['dtend']?.dt;
      final summary = event['summary'] ?? 'Sin título';
      // Extraer la categoría del evento
      String category = 'Default';
      if (event['categories'] != null) {
        var categories = event['categories'];
        if (categories is List) {
          category = categories[0];
        } else if (categories is String) {
          category = categories;
        }
      }
      if (startDate != null) {
        DateTime eventStartDate = DateTime.parse(startDate.toString());
        DateTime eventEndDate = (endDate != null) 
          ? DateTime.parse(endDate.toString()).subtract(Duration(days: 1))
          : eventStartDate;
        // Obtener el color basado en la categoría
        Color eventColor = _getColorForCategory(category);
        // Crear un evento Meeting para Syncfusion con el color específico
        loadedMeetings.add(Meeting(summary, eventStartDate, eventEndDate, eventColor, false));
      }
    }
  }
  setState(() {
    meetings = loadedMeetings;
  });
}


  // Función para obtener el color basado en la categoría
  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'estudiantes':
        return Colors.orange;
      case 'profesores':
        return Colors.red;
      case 'jefes de carrera':
        return Colors.green;
      case 'ceremonias':
        return Colors.blue;
      case 'comunidad usm':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario USM'),
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
                  'Simbología:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(5), // Ajusta el radio para hacer el borde más o menos redondeado
                            ),
                          ),

                          SizedBox(width: 8),
                          Text('Estudiantes'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(5), // Ajusta el radio para hacer el borde más o menos redondeado
                            ),
                          ),

                          SizedBox(width: 8),
                          Text('Profesores'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(5), // Ajusta el radio para hacer el borde más o menos redondeado
                            ),
                          ),

                          SizedBox(width: 8),
                          Text('Jefes de Carrera'),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(5), // Ajusta el radio para hacer el borde más o menos redondeado
                            ),
                          ),

                          SizedBox(width: 8),
                          Text('Ceremonias'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(5), // Ajusta el radio para hacer el borde más o menos redondeado
                            ),
                          ),

                          SizedBox(width: 8),
                          Text('Comunidad'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5), // Ajusta el radio para hacer el borde más o menos redondeado
                            ),
                          ),

                          SizedBox(width: 8),
                          Text('Otros'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SfCalendar(
              view: CalendarView.month, // Vista de mes
              allowedViews: [
                CalendarView.month,
                CalendarView.week,
                CalendarView.day,
                CalendarView.schedule,
              ],
              dataSource: MeetingDataSource(meetings),
              monthViewSettings: MonthViewSettings(
                showAgenda: true, // Mostrar agenda de eventos debajo del calendario.
                agendaItemHeight: 50,
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
                                  children: [
                                    TextSpan(
                                      text: "Desde: ",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // En negrita y color negro
                                    ),
                                    TextSpan(
                                      text: formatDateTime(meeting.from),
                                      style: TextStyle(color: Colors.black), // Estilo normal y color negro
                                    ),
                                  ],
                                ),
                              ),

                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Hasta: ",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // En negrita y color negro
                                    ),
                                    TextSpan(
                                      text: formatDateTime(meeting.to),
                                      style: TextStyle(color: Colors.black), // Estilo normal y color negro
                                    ),
                                  ],
                                ),
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
            ),
          ),
        ],
      ),
    );
  }

}