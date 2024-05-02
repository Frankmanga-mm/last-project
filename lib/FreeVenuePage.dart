// free_venue_page.dart

// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_print, library_private_types_in_public_api, file_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FreeVenuePage extends StatefulWidget {
  const FreeVenuePage({Key? key}) : super(key: key);

  @override
  _FreeVenuePageState createState() => _FreeVenuePageState();
}

class _FreeVenuePageState extends State<FreeVenuePage> {
  String selectedDay = 'Monday'; // Default day
  String startTime = '';
  String endTime = '';
  List<String> availableVenues = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Venue Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Select Day:',
              style: TextStyle(fontSize: 20),
            ),
            DropdownButton<String>(
              value: selectedDay,
              onChanged: (String? newValue) {
                setState(() {
                  selectedDay = newValue!;
                });
              },
              items: <String>['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter Starting Time',
              ),
              onChanged: (value) {
                startTime = value;
              },
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter End Time',
              ),
              onChanged: (value) {
                endTime = value;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                searchVenues();
              },
              child: const Text('Search Venue'),
            ),
            const SizedBox(height: 20),
            // Display available venues
            if (availableVenues.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Venues:',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  for (String venue in availableVenues)
                    Text(
                      venue,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.teal,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

 Future<void> searchVenues() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? jsonData = prefs.getString('timetableData');

  if (jsonData != null) {
    List<dynamic> decodedData = jsonDecode(jsonData);
    List<Map<String, String>> storedTimetableData =
        List<Map<String, String>>.from(
      decodedData.map((dynamic item) => Map<String, String>.from(item)),
    );

    // Filter data based on selected day and time range
    Set<String?> allVenues = storedTimetableData
        .map((entry) => entry['venue'])
        .where((venue) => venue != null && venue.isNotEmpty)
        .toSet();

    Set<String?> bookedVenues = storedTimetableData
        .where((entry) =>
            entry['day'] == selectedDay &&
            isTimeInRange(entry['time_start']!, startTime, endTime))
        .map((entry) => entry['venue'])
        .where((venue) => venue != null && venue.isNotEmpty)
        .toSet();

    setState(() {
      availableVenues = allVenues
          .difference(bookedVenues)
          .where((venue) => venue != null)
          .cast<String>()
          .toList();
    });

  } else {
    print('No data stored.');
  }
}

  bool isTimeInRange(String time, String startTime, String endTime) {
    DateTime entryTime = DateTime.parse('2022-01-01 ' + time);
    DateTime start = DateTime.parse('2022-01-01 ' + startTime);
    DateTime end = DateTime.parse('2022-01-01 ' + endTime);

    return entryTime.isAfter(start) && entryTime.isBefore(end);
  }
}
