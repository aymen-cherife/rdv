import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/appointment_provider.dart';
import 'appointment_detail_screen.dart';

class AppointmentListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              // You can add a refresh function here if needed.
            },
          ),
        ],
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, appointmentProvider, child) {
          if (appointmentProvider.appointments.isEmpty) {
            return Center(
              child: Text(
                'No appointments available',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            itemCount: appointmentProvider.appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointmentProvider.appointments[index];
              return Dismissible(
                key: Key(appointment.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  appointmentProvider.removeAppointment(appointment.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Appointment deleted')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                child: ListTile(
                  title: Text(appointment.title),
                  subtitle: Text(
                    'Date: ${appointment.dateTime.toLocal().toString().split(' ')[0]}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AppointmentDetailScreen(appointment: appointment),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
