// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, avoid_print, unused_import, duplicate_import, use_build_context_synchronously, unnecessary_import
import 'package:Atctimetable/lecturers_page.dart';
import 'package:Atctimetable/notification_page.dart';
import 'package:Atctimetable/store_page.dart';
import 'package:Atctimetable/sync_updates_page.dart';
import 'package:Atctimetable/venue_page.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:Atctimetable/store_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({Key? key}) : super(key: key);

  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  String selectedCourse = '';
  String selectedLevel = '';

  bool _viewTimetableButtonClicked = false;
  List<String> courses = [];
  List<String> levels = [];
  List<Map<String, String>> timetableData = [];

  late Future<void> levelsFuture;
  late Future<void> timetableFuture;
  @override
  void initState() {
    super.initState();
    // Fetch courses on initialization
    fetchCourses();
    // Initialize levelsFuture to fetch levels
    levelsFuture = fetchLevels();

    // Initialize timetableFuture to check for updates when the page loads
    timetableFuture = fetchDataAndCompare();
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

//online fetching
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

  ///  comaparing  ofline and  online retrived
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

//update local stored data
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

  Future<void> showAlert() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Timetable Update'),
          content: const Text(
              'There have been changes to the timetable. Please update the timetable.'),
          actions: [
            TextButton(
              onPressed: () {
                // Navigate to another page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const StorePage()),
                );
              },
              child: const Text('Update Timetable'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
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
                  'View Timetable',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
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
                  'Notification',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationPage(),
                    ),
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

      //scroll view........//
      body: SingleChildScrollView(
        child: FutureBuilder<void>(
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
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color>((states) {
                                        if (states
                                            .contains(MaterialState.pressed)) {
                                          return Colors
                                              .green; // Change color when pressed
                                        }
                                        return selectedCourse == course
                                            ? Colors.green
                                            : Colors.white;
                                      }),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        const RoundedRectangleBorder(
                                          borderRadius: BorderRadius
                                              .zero, // Set borderRadius to zero
                                        ),
                                      ),
                                    ),
                                    child: SizedBox(
                                      width: double
                                          .infinity, // Make the button adopt to any screen width
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Center(
                                          child: Text(
                                            course,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                                      // takes space according to screen size
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
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
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: timetableData.length,
                              itemBuilder: (context, index) {
                                final entry = timetableData[index];
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
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color>((states) {
                                        if (states
                                            .contains(MaterialState.pressed)) {
                                          return Colors
                                              .green; // Change color when pressed
                                        }
                                        return selectedCourse == course
                                            ? Colors.green
                                            : Colors.white;
                                      }),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius
                                              .zero, // Set borderRadius to zero
                                        ),
                                      ),
                                    ),
                                    child: SizedBox(
                                      width: double
                                          .infinity, // Make the button adopt to any screen width
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Center(
                                          child: Text(
                                            course,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color>((states) {
                                        if (states
                                            .contains(MaterialState.pressed)) {
                                          return Colors
                                              .green; // Change color when pressed
                                        }
                                        return selectedLevel == level
                                            ? Colors.green
                                            : Colors.white;
                                      }),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius
                                              .zero, // Set borderRadius to zero
                                        ),
                                      ),
                                    ),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Center(
                                          child: Text(
                                            level,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                              print("Else Block clicked..");
                              setState(() {
                                _viewTimetableButtonClicked = true;
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors
                                      .green; // Change color when pressed
                                }
                                return Colors.white;
                              }),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                const RoundedRectangleBorder(
                                  borderRadius: BorderRadius
                                      .zero, // Set borderRadius to zero
                                ),
                              ),
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
      ),
    );
  }
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
