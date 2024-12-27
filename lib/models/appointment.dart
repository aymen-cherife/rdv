class Appointment {
  final String id;
  final String title;
  final DateTime dateTime;
  final bool reminder24h;
  final bool reminder1h;

  Appointment({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.reminder24h,
    required this.reminder1h,
  });
}
