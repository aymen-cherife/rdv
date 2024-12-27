import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/appointment_provider.dart';
import 'add_appointment_screen.dart';
import 'appointment_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RDV'),
        actions: [
          IconButton(
            icon: Icon(Icons.cloud),
            onPressed: () {
              Navigator.pushNamed(context, '/weather');
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, appointmentProvider, child) {
          if (appointmentProvider.appointments.isEmpty) {
            return Center(
              child: Text(
                'Aucun rendez-vous disponible',
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
                    SnackBar(content: Text('Rendez-vous supprimé')),
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
                    'Date et Heure: ${appointment.dateTime}',
                    style: TextStyle(fontSize: 16),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAppointmentScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
