import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import '../models/meeting.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart'; // Ajusta el path según la estructura de tu proyecto
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<Meeting> meetings = [];
  List<Meeting> filteredMeetings = [];
  Set<String> scheduledEventIds = {};
  List<Meeting> userCreatedMeetings = [];

  final List<String> icsFiles = [
    // https://vra.usm.cl/eventos/mes/2025-01/?ical=1
    'assets/calendars/2024-10.ics',
    'assets/calendars/2024-11.ics',
    'assets/calendars/2024-12.ics',
    'assets/calendars/2025-01.ics',
  ];

  late CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    loadScheduledEventIds().then((_) {
      _loadIcsFiles(); // Carga los eventos después de recuperar los programados
  });
    loadUserCreatedMeetings();
  }

  Future<void> _loadIcsFiles() async {
    List<Meeting> loadedMeetings = [];
    for (String icsFile in icsFiles) {
      final icsString = await rootBundle.loadString(icsFile);
      final icalendar = ICalendar.fromString(icsString);
      final events = icalendar.data.where((component) => component['type'] == 'VEVENT');
      for (var event in events) {
        final startDate = event['dtstart']?.dt;
        final endDate = event['dtend']?.dt;
        final summary = event['summary'] ?? 'Sin título';
        String category = 'Default';
        if (event['categories'] != null) {
          var categories = event['categories'];
          if (categories is List) {
            category = categories.join(', ');
          } else if (categories is String) {
            category = categories;
          }
        }
        if (startDate != null) {
          DateTime eventStartDate = DateTime.parse(startDate.toString());
          DateTime eventEndDate = (endDate != null)
              ? DateTime.parse(endDate.toString()).subtract(Duration(days: 1))
              : eventStartDate;

          // Crear un identificador único para el evento
          String uniqueId = '${eventStartDate.toIso8601String()}_$summary';
          print('Generando ID único para el evento: $uniqueId');

          // Crear el evento siempre
          Color eventColor = _getColorForCategory(category.split(',')[0]);
          final meeting = Meeting(summary, eventStartDate, eventEndDate, eventColor, false, category);
          loadedMeetings.add(meeting);

          // Programar notificaciones solo para eventos futuros que no hayan sido programados
          if (eventStartDate.isAfter(DateTime.now()) && !scheduledEventIds.contains(uniqueId)) {
            await scheduleNotification(meeting);
            scheduledEventIds.add(uniqueId);
            print('Notificación programada evento: ${meeting.eventName}');
            
            await saveScheduledEventIds(); // Guardar los identificadores
          } else if (scheduledEventIds.contains(uniqueId)) {
            print('Notificación ya programada para el evento: ${meeting.eventName}');
          } else {
            print('Evento pasado (sin notificación): $summary en $eventStartDate');

          }
        }
      }
    }
    setState(() {
      meetings = [...loadedMeetings, ...userCreatedMeetings];
      filteredMeetings = meetings; // Mostrar todos los eventos inicialmente
    });
  }


  Future<void> scheduleNotification(Meeting meeting) async {
    final notificationId = meeting.hashCode; // ID único basado en el evento
    final eventDate = meeting.from.subtract(Duration(minutes: 15)); // 1 dias antes del evento
    print('Notificación programada para: $eventDate');

    // Verifica que el evento no sea en el pasado
    if (eventDate.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      meeting.eventName, // Título
      'El evento ${meeting.eventName} comienza a las ${formatDateTime(meeting.from)}.', // Cuerpo
      tz.TZDateTime.from(eventDate, tz.local), // Fecha con zona horaria
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id', // ID del canal
          'channel_name', // Nombre del canal
          channelDescription: 'Descripción del canal',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexact, // Agregar este parámetro
    );
  }

  Future<void> saveScheduledEventIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('scheduledEventIds', scheduledEventIds.toList());
    print('Identificadores guardados: $scheduledEventIds');
  }

  Future<void> loadScheduledEventIds() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList('scheduledEventIds') ?? [];
    scheduledEventIds = savedIds.toSet();
    print('Identificadores cargados: $scheduledEventIds');
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


  Future<void> saveUserCreatedMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    final meetingsJson = userCreatedMeetings.map((e) => e.toJson()).toList();
    await prefs.setString('userCreatedMeetings', jsonEncode(meetingsJson));
  }

  Future<void> loadUserCreatedMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    final meetingsJsonString = prefs.getString('userCreatedMeetings');
    if (meetingsJsonString != null) {
      final meetingsJson = jsonDecode(meetingsJsonString) as List;
      userCreatedMeetings = meetingsJson.map((json) => Meeting.fromJson(json)).toList();
    }
  }


  Future<void> _showAddEventDialog() async {
    final titleController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Crear Evento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Título'),
            ),
            ElevatedButton(
              onPressed: () async {
                startDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (startDate != null) {
                  startTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                }
              },
              child: Text('Fecha y hora de inicio'),
            ),
            ElevatedButton(
              onPressed: () async {
                endDate = await showDatePicker(
                  context: context,
                  initialDate: startDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (endDate != null) {
                  endTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                }
              },
              child: Text('Fecha y hora de fin'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  startDate != null &&
                  endDate != null &&
                  startTime != null &&
                  endTime != null) {
                // Combinar fecha y hora
                final startDateTime = DateTime(
                  startDate!.year,
                  startDate!.month,
                  startDate!.day,
                  startTime!.hour,
                  startTime!.minute,
                );
                final endDateTime = DateTime(
                  endDate!.year,
                  endDate!.month,
                  endDate!.day,
                  endTime!.hour,
                  endTime!.minute,
                );

                // Validación: Verificar que la hora de inicio sea anterior a la de fin
                if (startDateTime.isAfter(endDateTime) ||
                    startDateTime.isAtSameMomentAs(endDateTime)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('La hora de inicio debe ser anterior a la de fin.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return; // No permitir guardar el evento
                }

                final newEvent = Meeting(
                  titleController.text,
                  startDateTime,
                  endDateTime,
                  Colors.blue,
                  false,
                  'Creado por el usuario',
                );

                setState(() {
                  userCreatedMeetings.add(newEvent);
                  filteredMeetings.add(newEvent);
                });

                saveUserCreatedMeetings(); // Guardar en SharedPreferences

                handleEventNotification(event: newEvent);
                Navigator.of(context).pop();
              }
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _deleteUserCreatedEvent(Meeting meeting) async {
    setState(() {
      userCreatedMeetings.remove(meeting); // Eliminar de la lista local
      filteredMeetings.remove(meeting); // Eliminar de la lista visible en el calendario
    });

    await saveUserCreatedMeetings(); // Guardar cambios en SharedPreferences

    // Cancelar la notificación asociada al evento eliminado
    handleEventNotification(event: meeting, cancel: true);
  }

  Future<void> handleEventNotification({
      required Meeting event,
      bool cancel = false,
    }) async {
      final notificationId = event.hashCode;

      if (cancel) {
        await flutterLocalNotificationsPlugin.cancel(notificationId);
        print('Notificación cancelada para el evento: ${event.eventName}');
        return;
      }
      tz.setLocalLocation(tz.getLocation('America/Santiago'));
      // Calcular el momento de la notificación (2 minutos antes del evento)
      final scheduledDate = tz.TZDateTime.from(
        event.from.subtract(Duration(minutes: 2)),
        tz.local,
      );

      // Verificar que la fecha esté en el futuro
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        print('El evento ya pasó, no se programará notificación.');
        return;
      }

      print('Programando notificación para: $scheduledDate');

      // Programar la notificación
      await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        event.eventName, // Título
        'Tu evento "${event.eventName}" comenzará pronto a las ${DateFormat('HH:mm').format(event.from)}.',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'event_channel_id', // Asegurate de usar este ID en todos los lugares
            'Eventos creados', // Nombre del canal
            channelDescription: 'Notificaciones para eventos creados por el usuario',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      print('Notificación programada correctamente.');
    }
    
  //   Future<void> sendScheduledTestNotification() async {
  // // Inicializar zonas horarias
  //       tz.setLocalLocation(tz.getLocation('America/Santiago'));

  //       final now = tz.TZDateTime.now(tz.local); // Hora local
  //       final scheduledDate = now.add(Duration(minutes: 1)); // Programar para 1 minuto después

  //       print('Hora actual: $now');
  //       print('Programando notificación para: $scheduledDate');

  //       await flutterLocalNotificationsPlugin.zonedSchedule(
  //         0, // ID único
  //         'Notificación de prueba',
  //         'Esta es una notificación programada.',
  //         scheduledDate,
  //         const NotificationDetails(
  //           android: AndroidNotificationDetails(
  //             'event_channel_id',
  //             'Eventos creados',
  //             channelDescription: 'Notificaciones para eventos creados por el usuario',
  //             importance: Importance.max,
  //             priority: Priority.high,
  //           ),
  //         ),
  //         uiLocalNotificationDateInterpretation:
  //             UILocalNotificationDateInterpretation.absoluteTime,
  //         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Modo exacto
  //       );

  //       print('Notificación programada correctamente.');
  //     }

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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  Expanded(
                      child: ElevatedButton(
                      onPressed: () {
                          filterEvents('Estudiantes, Profesores, Ceremonias, Comunidad USM, Jefes de Carrera');
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.black,
                          
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                      child: Container(
                          constraints: BoxConstraints(minWidth: 150), // Ajustar el ancho mínimo
                          alignment: Alignment.center,
                          child: Text('Todos'),
                      ),
                      ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                      child: ElevatedButton(
                      onPressed: () {
                          filterEvents('estudiantes');
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 202, 158, 0),
                          foregroundColor: Colors.white, // Texto claro para fondo oscuro
                          
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                      child: Container(
                          constraints: BoxConstraints(minWidth: 150),
                          alignment: Alignment.center,
                          child: Text('Estudiantes'),
                      ),
                      ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                      child: ElevatedButton(
                      onPressed: () {
                          filterEvents('profesores');
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 210, 9, 29),
                          foregroundColor: Colors.white, // Texto claro para fondo oscuro
                          
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                      child: Container(
                          constraints: BoxConstraints(minWidth: 150),
                          alignment: Alignment.center,
                          child: Text('Profesores'),
                      ),
                      ),
                  ),
                  ],
              ),
              
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  Expanded(
                      child: ElevatedButton(
                      onPressed: () {
                          filterEvents('Ceremonias');
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 0, 94, 144),
                          foregroundColor: Colors.white, // Texto claro para fondo oscuro
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                      child: Container(
                          constraints: BoxConstraints(minWidth: 150),
                          alignment: Alignment.center,
                          child: Text('Ceremonias'),
                      ),
                      ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                      child: ElevatedButton(
                      onPressed: () {
                          filterEvents('Comunidad USM');
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 13, 14, 13),
                          foregroundColor: Colors.white, // Texto claro para fondo oscuro
                          
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                      child: Container(
                          constraints: BoxConstraints(minWidth: 150),
                          alignment: Alignment.center,
                          child: Text('Comunidad'),
                      ),
                      ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                      child: ElevatedButton(
                      onPressed: () {
                          filterEvents('Jefes de Carrera');
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 0, 117, 72),
                          foregroundColor: Colors.white, // Texto claro para fondo oscuro
                          
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                      child: Container(
                          constraints: BoxConstraints(minWidth: 150),
                          alignment: Alignment.center,
                          child: Text('Jefes Carrera'),
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

                    // Mostrar el cuadro de diálogo
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(meeting.eventName),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Desde: ${formatDateTime(meeting.from)}'),
                              Text('Hasta: ${formatDateTime(meeting.to)}'),
                              SizedBox(height: 8),
                              Text('Categorías: ${meeting.category}'),
                            ],
                          ),
                          actions: [
                            // Mostrar botón "Eliminar" solo si es un evento creado por el usuario
                            if (userCreatedMeetings.contains(meeting))
                              TextButton(
                                onPressed: () {
                                  _deleteUserCreatedEvent(meeting); // Llamar al método de eliminación
                                  Navigator.of(context).pop(); // Cerrar el diálogo
                                },
                                child: Text(
                                  'Eliminar',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('Cerrar'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
              
            )
            
          ),
        ],
        
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(),
        child: Icon(Icons.add),
        
),
    );
    
  }
}
