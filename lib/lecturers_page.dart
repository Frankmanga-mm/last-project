// ignore_for_file: use_build_context_synchronously, avoid_print, unused_import, library_private_types_in_public_api

import 'package:Atctimetable/notification_page.dart';
import 'package:Atctimetable/sync_updates_page.dart';
import 'package:Atctimetable/timetable.dart';
import 'package:Atctimetable/venue_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LecturerPage extends StatefulWidget {
  const LecturerPage({Key? key}) : super(key: key);

  @override
  _LecturerPageState createState() => _LecturerPageState();
}

class _LecturerPageState extends State<LecturerPage> {
  List<String> teachers = [];
  String selectedTeacher = '';
  List<Map<String, String>> timetableData = [];

  @override
  void initState() {
    super.initState();
    // Fetch teachers on initialization
    fetchTeachers();
  }

  Future<void> fetchTeachers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('timetableData');

    if (jsonData != null) {
      List<dynamic> decodedData = jsonDecode(jsonData);
      List<Map<String, String>> storedTimetableData =
          List<Map<String, String>>.from(
        decodedData.map((dynamic item) => Map<String, String>.from(item)),
      );

      // Get unique list of teachers
      Set<String?> uniqueTeachers = storedTimetableData
          .map((entry) => entry['teacher'])
          .where((teacher) => teacher != null && teacher.isNotEmpty)
          .toSet();

      setState(() {
        teachers = List<String>.from(uniqueTeachers);
      });
    } else {
      print('No data stored.');
    }
  }

  Future<void> viewTeacherTimetable(String teacher) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('timetableData');

    if (jsonData != null) {
      List<dynamic> decodedData = jsonDecode(jsonData);
      List<Map<String, String>> storedTimetableData =
          List<Map<String, String>>.from(
        decodedData.map((dynamic item) => Map<String, String>.from(item)),
      );

      // Filter data based on selected teacher
      List<Map<String, String>> filteredData = storedTimetableData
          .where((entry) => entry['teacher'] == teacher)
          .toList();

      setState(() {
        selectedTeacher = teacher;
        timetableData = filteredData;
      });

      // Navigate to the new page to display teacher details
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeacherDetailsPage(
            selectedTeacher: selectedTeacher,
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
        title: const Text('Lecturers Page'),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.teal,
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
                  Navigator.pop(context); // Close the drawer
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
                    MaterialPageRoute(
                        builder: (context) =>  const NotificationPage()),
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
      body: SingleChildScrollView(
        child: Container(
          color: Colors.teal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: MediaQuery.of(context).size.height - 100, // Adjust height as needed
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = teachers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            viewTeacherTimetable(teacher);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: null,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: Text(
                            teacher,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.teal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
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

class TeacherDetailsPage extends StatelessWidget {
  final String selectedTeacher;
  final List<Map<String, String>> timetableData;

  const TeacherDetailsPage({
    Key? key,
    required this.selectedTeacher,
    required this.timetableData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details for $selectedTeacher'),
      ),
       backgroundColor: Colors.teal, 
      drawer: Drawer(
        child: Container(
          color: Colors.teal,
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
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.teal],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              color: Colors.teal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Selected Teacher: ${selectedTeacher.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (timetableData.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: timetableData.length,
                      itemBuilder: (context, index) {
                        final entry = timetableData[index];
                        final previousDay =
                            index > 0 ? timetableData[index - 1]['day'] : null;
                        final currentDay = entry['day'];

                        final dayChanged = currentDay != previousDay;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (dayChanged)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 5),
                                child: Text(
                                  currentDay ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            Card(
                              child: ListTile(
                                title: Text(
                                  entry['subject'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Course: ${entry['course']}   Time: ${entry['time_start']} - ${entry['time_end']},   Venue: ${entry['venue']},  Lecturer: ${entry['teacher']}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 22,
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
