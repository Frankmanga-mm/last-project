// ignore_for_file: avoid_print, library_private_types_in_public_api, unused_local_variable

import 'package:Atctimetable/timetable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  List<Map<String, dynamic>> timetableData = [];
  List<Map<String, dynamic>> venueData = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromPhp();
  }

  Future<void> fetchDataFromPhp() async {
    await fetchVenuesFromPhp();
    await fetchTimetableFromPhp();
  }

  Future<void> fetchTimetableFromPhp() async {
    final response = await http.get(Uri.parse('http://www.expectextra.co.tz/ratiba/alltimetable.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        timetableData = List<Map<String, dynamic>>.from(
          data.map((dynamic item) => Map<String, dynamic>.from(item)),
        );
      });

      // Store timetable data locally
      _storeTimetableDataLocally();
    } else {
      print('Failed to fetch timetable data from PHP: ${response.statusCode}');
    }
  }

  Future<void> fetchVenuesFromPhp() async {
    final response = await http.get(Uri.parse('http://www.expectextra.co.tz/ratiba/venues.php'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        venueData = List<Map<String, dynamic>>.from(
          data.map((dynamic item) => Map<String, dynamic>.from(item)),
        );
      });

      // Store venue data locally
      _storeVenueDataLocally();
    } else {
      print('Failed to fetch venue data from PHP: ${response.statusCode}');
    }
  }

  Future<void> _storeTimetableDataLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(timetableData);
    prefs.setString('timetableData', jsonData);
  }

  Future<void> _storeVenueDataLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(venueData);
    prefs.setString('venueData', jsonData);
  }

  

  Future<void> navigateToTimetablePage() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TimetablePage()),
    );
  }

  Future<void> retrieveStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('timetableData');

    if (jsonData != null) {
      List<dynamic> decodedData = jsonDecode(jsonData);
      List<Map<String, dynamic>> storedTimetableData =
          List<Map<String, dynamic>>.from(decodedData);

      // Print each entry in the stored data
      // for (var entry in storedTimetableData) {
      //   print('Course: ${entry['course']}');
      //   print('Level: ${entry['level']}');
      //   print('Day: ${entry['day']}');
      //   print('Subject: ${entry['subject']}');
      //   print('Venue: ${entry['venue']}');
      //   print('Teacher: ${entry['teacher']}');
      //   print('Time Start: ${entry['time_start']}');
      //   print('Time End: ${entry['time_end']}');
      //   print('----------------------');
      // }

      // Navigate to TimetablePage
      navigateToTimetablePage();
    } else {
      print('No data stored.');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title: const Text('Offline storage', style: TextStyle(fontSize: 24)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'This feature enables you to view timetable even with no internet connection',
              style: TextStyle(fontSize:50,color:Colors.white ),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () {
                // Retrieve and print stored data
                retrieveStoredData();
              },
              child: const Text('Save data offline by clicking here ', style: TextStyle(fontSize: 40)),
            ),
          ],
        ),
      ),
    );
  }
}
