import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/appointment.dart';

class AppointmentProvider with ChangeNotifier {
  List<Appointment> _appointments = [];

  List<Appointment> get appointments => _appointments;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AppointmentProvider() {
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      _firestore
          .collection('appointments')
          .where('userId', isEqualTo: uid)
          .snapshots()
          .listen((snapshot) {
        _appointments = snapshot.docs
            .map((doc) => Appointment(
                  id: doc.id,
                  title: doc['title'],
                  dateTime: (doc['dateTime'] as Timestamp).toDate(),
                  reminder24h: doc['reminder24h'],
                  reminder1h: doc['reminder1h'],
                ))
            .toList();
        notifyListeners();
      });
    }
  }

  void addAppointment(Appointment appointment) async {
    User? user = _auth.currentUser;
    if (user != null) {
      String uid = user.uid;
      var docRef = await _firestore.collection('appointments').add({
        'userId': uid,
        'title': appointment.title,
        'dateTime': appointment.dateTime,
        'reminder24h': appointment.reminder24h,
        'reminder1h': appointment.reminder1h,
      });
      // Create a new appointment instance with the assigned ID
      Appointment newAppointment = Appointment(
        id: docRef.id,
        title: appointment.title,
        dateTime: appointment.dateTime,
        reminder24h: appointment.reminder24h,
        reminder1h: appointment.reminder1h,
      );
      _scheduleNotification(newAppointment);
      _fetchAppointments();
    }
  }

  void removeAppointment(String id) async {
    await _firestore.collection('appointments').doc(id).delete();
    _flutterLocalNotificationsPlugin.cancel(id.hashCode);
    _fetchAppointments();
  }

  void _scheduleNotification(Appointment appointment) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'appointment_channel',
      'Appointments',
      channelDescription: 'Channel for appointment reminders',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    if (appointment.reminder24h) {
      final dateTime24hBefore =
          appointment.dateTime.subtract(Duration(days: 1));
      _flutterLocalNotificationsPlugin.zonedSchedule(
        appointment.id.hashCode + 1,
        'Reminder: ${appointment.title}',
        'Your appointment is in 24 hours',
        tz.TZDateTime.from(dateTime24hBefore, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    if (appointment.reminder1h) {
      final dateTime1hBefore =
          appointment.dateTime.subtract(Duration(hours: 1));
      _flutterLocalNotificationsPlugin.zonedSchedule(
        appointment.id.hashCode + 2,
        'Reminder: ${appointment.title}',
        'Your appointment is in 1 hour',
        tz.TZDateTime.from(dateTime1hBefore, tz.local),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
