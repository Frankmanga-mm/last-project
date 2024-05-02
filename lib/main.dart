// ignore_for_file: unused_import, prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'timetable.dart';
import 'store_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timetable App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: constraints.maxHeight * 0.1),
                      Icon(
                        Icons.school,
                        size: constraints.maxWidth * 0.6,
                        color: Colors.white,
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Welcome to Ratiba Yangu app',
                        style: TextStyle(
                          fontSize: constraints.maxWidth * 0.07,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.05),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TimetablePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        child: SizedBox(
                          width: constraints.maxWidth * 0.8,
                          child: Center(
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: constraints.maxWidth * 0.07,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: constraints.maxHeight * 0.1),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'App developed by frank manga',
                          style: TextStyle(
                            fontSize: constraints.maxWidth * 0.03,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
//store offline used shared prefferences