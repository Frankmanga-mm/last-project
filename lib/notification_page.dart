// ignore_for_file: use_build_context_synchronously, avoid_print, deprecated_member_use, library_private_types_in_public_api, prefer_collection_literals

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lecturers_page.dart';
import 'timetable.dart';
import 'venue_page.dart';
import 'sync_updates_page.dart';
import 'store_page.dart'; // Assuming there's a StorePage class
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Map<String, bool> bellSelection = {};
  String selectedCourse = '';
  String selectedLevel = '';

  bool _viewTimetableButtonClicked = false;
  List<String> courses = [];
  List<String> levels = [];
  List<Map<String, String>> timetableData = [];

  late Future<void> levelsFuture;
  late Future<void> timetableFuture;

  // Define a set to store selected subjects
  Set<String> selectedSubjects = Set<String>();

  @override
  void initState() {
    super.initState();
    // Fetch courses on initialization
    fetchCourses();
    // Initialize levelsFuture to fetch levels
    levelsFuture = fetchLevels();
    timetableFuture = fetchDataAndCompare();
    // Load selected subjects
    loadSelectedSubjects();
  }

// Add these functions to your _NotificationPageState class
// Add these functions to your _NotificationPageState class
  Future<void> saveSelectedSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> selectedSubjectsList =
        selectedSubjects.toList(); // Convert set to list
    prefs.setStringList('selectedSubjects', selectedSubjectsList);
  }

  Future<void> loadSelectedSubjects() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? selectedSubjectsList =
        prefs.getStringList('selectedSubjects');
    if (selectedSubjectsList != null) {
      setState(() {
        selectedSubjects = selectedSubjectsList.toSet();
      });
    }
  }

  Future<List<Map<String, String>>> fetchOnlineTimetableData() async {
    const url = 'http://www.expectextra.co.tz/ratiba/alltimetable.php';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the response as a List<Map<String, String>>
        final List<dynamic> rawData = jsonDecode(response.body);
        final List<Map<String, String>> timetableData = rawData
            .map((dynamic item) =>
                Map<String, String>.from(item as Map<String, dynamic>))
            .toList();

        return timetableData;
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (error) {
      throw Exception('Failed to fetch online data: $error');
    }
  }

  bool areTimetablesEqual(List<Map<String, String>> timetable1,
      List<Map<String, String>> timetable2) {
    // Compare the length of the timetables
    if (timetable1.length != timetable2.length) {
      return false;
    }

    // Iterate through each entry and compare
    for (int i = 0; i < timetable1.length; i++) {
      Map<String, String> entry1 = timetable1[i];
      Map<String, String> entry2 = timetable2[i];

      // Compare individual fields
      if (entry1['course'] != entry2['course'] ||
          entry1['level'] != entry2['level'] ||
          entry1['day'] != entry2['day'] ||
          entry1['subject'] != entry2['subject'] ||
          entry1['venue'] != entry2['venue'] ||
          entry1['time_start'] != entry2['time_start'] ||
          entry1['time_end'] != entry2['time_end'] ||
          entry1['teacher'] != entry2['teacher']) {
        return false;
      }
    }

    // Timetables are equal
    return true;
  }

  Future<bool> showDataMismatchAlert() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Data Mismatch',
                style: TextStyle(fontSize: 20),
              ),
              content: const Text(
                'There have been changes made to the timetable. Please update the timetable.',
                style: TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // Close the alert dialog with result true
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if user dismissed the dialog by clicking outside
  }

  Future<void> updateLocalStorage(List<Map<String, String>> updatedData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(updatedData);
    prefs.setString('timetableData', jsonData);
  }

  Future<void> fetchDataAndCompare() async {
    try {
      // Fetch data from the online source
      List<Map<String, String>> onlineTimetableData =
          await fetchOnlineTimetableData();

      // Fetch data from local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jsonData = prefs.getString('timetableData');

      if (jsonData != null) {
        List<dynamic> decodedData = jsonDecode(jsonData);
        List<Map<String, String>> storedTimetableData =
            List<Map<String, String>>.from(
          decodedData.map((dynamic item) => Map<String, String>.from(item)),
        );

        // Compare data
        if (!areTimetablesEqual(onlineTimetableData, storedTimetableData)) {
          // Data mismatch, show alert and update local storage
          bool shouldUpdate = await showDataMismatchAlert();
          if (shouldUpdate) {
            await updateLocalStorage(onlineTimetableData);
            setState(() {
              timetableData = onlineTimetableData;
            });
          }
        } else {
          // Data is equal, no need to update
          print('Timetable data is up-to-date.');
          setState(() {
            timetableData = storedTimetableData;
          });
        }
      } else {
        // No local data, update local storage with fetched online data
        await updateLocalStorage(onlineTimetableData);
        setState(() {
          timetableData = onlineTimetableData;
        });
      }
    } catch (e) {
      // Failed to fetch online data or other error
      print('Exception: $e');
      viewTimetable(); // Fallback to offline data
    }
  }

  Future<void> fetchCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('timetableData');

    if (jsonData != null) {
      List<dynamic> decodedData = jsonDecode(jsonData);
      List<Map<String, String>> storedTimetableData =
          List<Map<String, String>>.from(
        decodedData.map((dynamic item) => Map<String, String>.from(item)),
      );

      // Get unique list of courses
      Set<String?> uniqueCourses = storedTimetableData
          .map((entry) => entry['course'])
          .where((course) => course != null && course.isNotEmpty)
          .toSet();

      setState(() {
        courses = List<String>.from(uniqueCourses);
      });
    } else {
      print('No data stored.');
    }
  }

  Future<void> fetchLevels() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('timetableData');

    if (jsonData != null) {
      List<dynamic> decodedData = jsonDecode(jsonData);
      List<Map<String, String>> storedTimetableData =
          List<Map<String, String>>.from(
        decodedData.map((dynamic item) => Map<String, String>.from(item)),
      );

      // Get unique list of levels
      Set<String?> uniqueLevels = storedTimetableData
          .map((entry) => entry['level'])
          .where((level) => level != null && level.isNotEmpty)
          .toSet();

      setState(() {
        levels = List<String>.from(uniqueLevels);
      });
    } else {
      print('No data stored.');
    }
  }

  Future<void> viewTimetable() async {
    // Check if course and level are selected
    if (selectedCourse.isEmpty || selectedLevel.isEmpty) {
      // Handle case where course or level is not selected
      return;
    }
    // Fetch data from local storage for selected course and level
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('timetableData');

    if (jsonData != null) {
      List<dynamic> decodedData = jsonDecode(jsonData);
      List<Map<String, String>> storedTimetableData =
          List<Map<String, String>>.from(
        decodedData.map((dynamic item) => Map<String, String>.from(item)),
      );

      // Filter data based on selected course and level
      List<Map<String, String>> filteredData = storedTimetableData
          .where((entry) =>
              entry['course'] == selectedCourse &&
              entry['level'] == selectedLevel)
          .toList();

      if (filteredData.isEmpty) {
        // Display an error message if no timetable is found
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Timetable Not Found',
                style:
                    TextStyle(fontSize: 40), // Adjust the font size as needed
              ),
              content: const Text(
                'We are sorry, the timetable for the selected level and course has not been recorded yet.',
                style:
                    TextStyle(fontSize: 28), // Adjust the font size as needed
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                        fontSize: 30), // Adjust the font size as needed
                  ),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          timetableData = filteredData;
        });
        print(timetableData);
      }
    } else {
      print('No data stored.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
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
                    'View Timetable',
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
                  }),
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
                    'Notification',
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  }),
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
                      builder: (context) => const SyncUpdatesPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.save, color: Colors.white),
                title: const Text(
                  'Save data offline',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StorePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<void>(
        future: timetableFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Still waiting for the future to complete
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // Error occurred during fetching or comparison
            print('Error: ${snapshot.error}');
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            // Data has been fetched and compared, display the timetable
            print('Timetable data has been fetched and compared.');
            if (selectedCourse.isNotEmpty &&
                selectedLevel.isNotEmpty &&
                _viewTimetableButtonClicked) {
              // Display the timetable
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal, Colors.teal],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Select Course:',
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Column(
                          children: courses.map((course) {
                            return Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedCourse = course;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: selectedCourse == course
                                        ? Colors.green
                                        : Colors.white,
                                  ),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Center(
                                        child: Text(
                                          course,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Select Level:',
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Column(
                          children: levels.map((level) {
                            return Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedLevel = level;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: selectedLevel == level
                                        ? Colors.green
                                        : Colors.white,
                                  ),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Center(
                                        child: Text(
                                          level,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await viewTimetable();
                            setState(() {
                              _viewTimetableButtonClicked = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'View Timetable',
                                  style: TextStyle(
                                    fontSize: 50.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (timetableData.isNotEmpty)
                          Expanded(
                            child: ListView.builder(
                              itemCount: timetableData.length,
                              itemBuilder: (context, index) {
                                final entry = timetableData[index];
                                final subject = entry['subject'] ?? '';
                                //  final isBellSelected =
                                //               bellSelection[entry['subject'] ?? ''] ?? false;

                                final previousDay = index > 0
                                    ? timetableData[index - 1]['day']
                                    : null;
                                final currentDay = entry['day'];

                                final dayChanged = currentDay != previousDay;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (dayChanged)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 10, bottom: 5),
                                        child: Text(
                                          currentDay ?? '',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    Card(
                                      child: ListTile(
                                        title: Text(
                                          entry['subject'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Course: ${entry['course']}   Time: ${entry['time_start']} - ${entry['time_end']},   Venue: ${entry['venue']},  Lecturer: ${entry['teacher']}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                          ),
                                        ),
                                        // Add the bell icon for notifications
                                        // Add the bell icon for notifications
                                        trailing: GestureDetector(
                                          onTap: () {
                                            // Toggle the selected status for the subject
                                            setState(() {
                                              if (selectedSubjects
                                                  .contains(subject)) {
                                                selectedSubjects
                                                    .remove(subject);
                                              } else {
                                                selectedSubjects.add(subject);
                                              }
                                            });
                                            // Add your logic to show notifications here
                                            showNotification(entry);
                                          },
                                          child: Icon(
                                            Icons.notifications,
                                            color: selectedSubjects
                                                    .contains(subject)
                                                ? Colors
                                                    .teal // Bell is selected
                                                : Colors
                                                    .grey, // Bell is not selected
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              // Display courses, levels, and "View Timetable" button
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal, Colors.teal],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Select Course:',
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Column(
                          children: courses.map((course) {
                            return Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedCourse = course;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: selectedCourse == course
                                        ? Colors.green
                                        : Colors.white,
                                  ),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Center(
                                        child: Text(
                                          course,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Select Level:',
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Column(
                          children: levels.map((level) {
                            return Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedLevel = level;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: selectedLevel == level
                                        ? Colors.green
                                        : Colors.white,
                                  ),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Center(
                                        child: Text(
                                          level,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            );
                          }).toList(),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await viewTimetable();
                            setState(() {
                              _viewTimetableButtonClicked = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'View Timetable',
                                  style: TextStyle(
                                    fontSize: 50.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          } else {
            // Handle other states if necessary
            return Center(
              child: Text('Unexpected state: ${snapshot.connectionState}'),
            );
          }
        },
      ),
    );
  }
}

Future<void> showNotification(Map<String, String> entry) async {
  // Initialize the plugin
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    // Add your channel ID
    'your_channel_name', // Add your channel name
    'your_channel_description', // Add your channel description
    importance: Importance.max,
    priority: Priority.high,
    icon: 'mipmap/atc_logo',
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  // Create a notification
  await flutterLocalNotificationsPlugin.show(
    0,
    'Upcoming Class',
    'You have a class: ${entry['subject']} at ${entry['time_start']}',
    platformChannelSpecifics,
    payload: 'item x',
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
