import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import '../models/meeting.dart';


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
          DateTime eventEndDate = (endDate != null) ? DateTime.parse(endDate.toString()) : eventStartDate;

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
        return Colors.blue;
      case 'profesores':
        return Colors.green;
      case 'jefes de carrera':
        return Colors.orange;
      case 'ceremonias':
        return Colors.red;
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
        title: Text('Calendario de Eventos'),
      ),
      body: SfCalendar(
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
        ),
        onViewChanged: (ViewChangedDetails details) {
          print("Vista actual cambiada: ${details.visibleDates}");
        },
      ),
    );
  }
}