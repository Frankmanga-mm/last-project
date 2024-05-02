import 'package:flutter/material.dart';
import 'lecturers_page.dart';
import 'timetable.dart';
import 'venue_page.dart';
import 'notification_page.dart';

class SyncUpdatesPage extends StatelessWidget {
  const SyncUpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Updates Page'),
      ),
      drawer: buildDrawer(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: Text(
            'Details about Sync Updates Page',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.teal,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            buildDrawerTile(
              icon: Icons.table_chart,
              text: 'Timetable',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TimetablePage()),
                );
              },
            ),
            buildDrawerTile(
              icon: Icons.person,
              text: 'Lecturer',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LecturerPage()),
                );
              },
            ),
            buildDrawerTile(
              icon: Icons.place,
              text: 'Venue',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VenuePage()),
                );
              },
            ),
            buildDrawerTile(
              icon: Icons.notifications,
              text: 'Notification',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>  const NotificationPage()),
                );
              },
            ),
            buildDrawerTile(
              icon: Icons.sync,
              text: 'Sync Updates',
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  ListTile buildDrawerTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        text,
        style: const TextStyle(
          fontSize: 25,
          color: Colors.white,
        ),
      ),
      onTap: onTap,
    );
  }
}
