// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'notification_page.dart';
import 'sync_updates_page.dart';
import 'timetable.dart';
import 'FreeVenuePage.dart';
import 'lecturers_page.dart';

class VenuePage extends StatefulWidget {
  const VenuePage({Key? key}) : super(key: key);

  @override
  _VenuePageState createState() => _VenuePageState();
}

class _VenuePageState extends State<VenuePage> {
  List<String> venues = [];
  String selectedVenue = '';
  List<Map<String, String>> timetableData = [];

  @override
  void initState() {
    super.initState();
    // Fetch venues on initialization
    fetchVenues();
  }

  Future<void> fetchVenues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('timetableData');

    if (jsonData != null) {
      List<dynamic> decodedData = jsonDecode(jsonData);
      List<Map<String, String>> storedTimetableData =
          List<Map<String, String>>.from(
        decodedData.map((dynamic item) => Map<String, String>.from(item)),
      );

      // Get unique list of venues
      Set<String?> uniqueVenues = storedTimetableData
          .map((entry) => entry['venue'])
          .where((venue) => venue != null && venue.isNotEmpty)
          .toSet();

      setState(() {
        venues = List<String>.from(uniqueVenues);
      });
    } else {
      print('No data stored.');
    }
  }

  Future<void> viewVenueTimetable(String venue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('timetableData');

    if (jsonData != null) {
      List<dynamic> decodedData = jsonDecode(jsonData);
      List<Map<String, String>> storedTimetableData =
          List<Map<String, String>>.from(
        decodedData.map((dynamic item) => Map<String, String>.from(item)),
      );

      // Filter data based on selected venue
      List<Map<String, String>> filteredData = storedTimetableData
          .where((entry) => entry['venue'] == venue)
          .toList();

      setState(() {
        selectedVenue = venue;
        timetableData = filteredData;
      });

      // Navigate to the new page to display venue details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VenueDetailsPage(
            selectedVenue: selectedVenue,
            timetableData: timetableData,
          ),
        ),
      );
    } else {
      print('No data stored.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venue Page'),
      ),
      backgroundColor: Colors.teal,
      drawer: Drawer(
        child: Container(
          color: Colors.teal, // Set background color to teal
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getSemesterText(),
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.white),
                title: const Text(
                  'Timetable',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TimetablePage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text(
                  'Lecturer',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LecturerPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.white),
                title: const Text(
                  'Venue',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications, color: Colors.white),
                title: const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.sync, color: Colors.white),
                title: const Text(
                  'Sync Updates',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SyncUpdatesPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '',
              style: TextStyle(fontSize: 35, color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FreeVenuePage()),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white, // Text color of the button
                padding: const EdgeInsets.all(16.0), // Adjust padding as needed
              ),
              child: const Text(
                'Free Venue',
                style: TextStyle(
                  fontSize: 28, // Adjust the font size as needed
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: venues.length,
                itemBuilder: (context, index) {
                  final venue = venues[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        viewVenueTimetable(venue);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: Text(
                        venue,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getSemesterText() {
    DateTime now = DateTime.now();
    int month = now.month;

    if (month >= 11 || (month >= 1 && month <= 2)) {
      return 'Semester 1';
    } else if (month >= 3 && month <= 7) {
      return 'Semester 2';
    } else {
      return 'Timetable';
    }
  }
}

class VenueDetailsPage extends StatelessWidget {
  final String selectedVenue;
  final List<Map<String, String>> timetableData;

  const VenueDetailsPage({
    Key? key,
    required this.selectedVenue,
    required this.timetableData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details for $selectedVenue'),
      ),
      backgroundColor: Colors.teal,
      drawer: Drawer(
        child: Container(
          color: Colors.teal, // Set background color to teal
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getSemesterText(),
                        style: const TextStyle(
                          fontSize: 25,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.white),
                title: const Text(
                  'Timetable',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TimetablePage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text(
                  'Lecturer',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LecturerPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.white),
                title: const Text(
                  'Venue',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VenuePage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications, color: Colors.white),
                title: const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.sync, color: Colors.white),
                title: const Text(
                  'Sync Updates',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SyncUpdatesPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Selected Venue: ${selectedVenue.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Display timetable details
              if (timetableData.isNotEmpty)
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: timetableData.length,
                  itemBuilder: (context, index) {
                    final entry = timetableData[index];
                    final previousDay =
                        index > 0 ? timetableData[index - 1]['day'] : null;
                    final currentDay = entry['day'];

                    // Check if the day has changed
                    final dayChanged = currentDay != previousDay;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (dayChanged)
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 5),
                            child: Text(
                              currentDay ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Card(
                          child: ListTile(
                            title: Text(
                              entry['subject'] ?? '',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Course: ${entry['course']}   Time: ${entry['time_start']} - ${entry['time_end']},   Venue: ${entry['venue']},  Lecturer: ${entry['teacher']}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  String getSemesterText() {
    DateTime now = DateTime.now();
    int month = now.month;

    if (month >= 11 || (month >= 1 && month <= 2)) {
      return 'Semester 1';
    } else if (month >= 3 && month <= 7) {
      return 'Semester 2';
    } else {
      return 'Timetable';
    }
  }
}
