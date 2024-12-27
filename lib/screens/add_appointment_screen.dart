import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/appointment.dart';
import '../providers/appointment_provider.dart';
import '../main.dart';

class AddAppointmentScreen extends StatefulWidget {
  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _reminder24h = false;
  bool _reminder1h = false;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

  void scheduleNotification(
      DateTime scheduledDate, String title, String body, int id) async {
    final tz.TZDateTime tzScheduledDate =
        tz.TZDateTime.from(scheduledDate, tz.local);

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un Rendez-vous'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Titre'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Date : ${_selectedDate.toLocal()}'.split(' ')[0],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Text('Sélectionner Date'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Heure : ${_selectedTime.format(context)}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (picked != null && picked != _selectedTime) {
                      setState(() {
                        _selectedTime = picked;
                      });
                    }
                  },
                  child: Text('Sélectionner Heure'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _reminder24h,
                  onChanged: (bool? value) {
                    setState(() {
                      _reminder24h = value ?? false;
                    });
                  },
                ),
                Text('Rappel 24 heures avant'),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _reminder1h,
                  onChanged: (bool? value) {
                    setState(() {
                      _reminder1h = value ?? false;
                    });
                  },
                ),
                Text('Rappel 1 heure avant'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Le titre ne peut pas être vide'),
                    ),
                  );
                  return;
                }
                if (_selectedDate.isBefore(DateTime.now())) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('La date doit être au présent ou futur'),
                    ),
                  );
                  return;
                }
                final newAppointment = Appointment(
                  id: Uuid().v4(),
                  title: _titleController.text,
                  dateTime: DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  ),
                  reminder24h: _reminder24h,
                  reminder1h: _reminder1h,
                );

                if (_reminder24h) {
                  scheduleNotification(
                    newAppointment.dateTime.subtract(Duration(hours: 24)),
                    'Rappel de RDV',
                    'Votre rendez-vous "${newAppointment.title}" est dans 24 heures.',
                    newAppointment.id.hashCode,
                  );
                }
                if (_reminder1h) {
                  scheduleNotification(
                    newAppointment.dateTime.subtract(Duration(hours: 1)),
                    'Rappel de RDV',
                    'Votre rendez-vous "${newAppointment.title}" est dans 1 heure.',
                    newAppointment.id.hashCode + 1,
                  );
                }

                Provider.of<AppointmentProvider>(context, listen: false)
                    .addAppointment(newAppointment);
                Navigator.pop(context);
              },
              child: Text('Ajouter le Rendez-vous'),
            ),
          ],
        ),
      ),
    );
  }
}
