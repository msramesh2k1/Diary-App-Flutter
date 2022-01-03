import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/phoneclass.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedDay = _focusedDay;
    });
  }

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    LoginController loginController = Provider.of<LoginController>(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        title: const Text(
          "My Diary ",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.blueGrey[100]!.withOpacity(0.5),
      ),
      body: Container(
        child: Column(
          children: [
            const SizedBox(
              height: 0,
            ),
            Container(
              color: Colors.blue[100]!.withOpacity(0.1),
              height: 400,
              child: TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: DateTime.now(),
                // lastDay: kLastDay,
                // focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  // Use `selectedDayPredicate` to determine which day is currently selected.
                  // If this returns true, then `day` will be marked as selected.

                  // Using `isSameDay` is recommended to disregard
                  // the time-part of compared DateTime objects.
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    // Call `setState()` when updating the selected day
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    // Call `setState()` when updating calendar format
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  // No need to call `setState()` here
                  _focusedDay = focusedDay;
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Container(
                  child: Center(
                    child: Text(_selectedDay
                        .toString()
                        .replaceAll("00:00:00.000Z", "")),
                  ),
                  height: 40,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue[100]!.withOpacity(0.1),
                  ),
                ),
                const Spacer(),
                CircleAvatar(
                  child: const Icon(Icons.add),
                  backgroundColor: Colors.blue[100]!.withOpacity(0.5),
                ),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: Container(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .doc(
                        loginController
                            .setusermodel(FirebaseAuth.instance.currentUser)!
                            .uid
                            .toString(),
                      )
                      .collection("diary")
                      .where("id",
                          isEqualTo: _selectedDay
                              .toString()
                              .replaceAll(" 00:00:00.000Z", ""))
                      .snapshots(),
                  builder: (context, snapshot) {
                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  snapshot.data!.docs[index]['info'],
                                  style: const TextStyle(fontSize: 20),
                                  
                                ),
                              ),
                              height: 200,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blue.shade100.withOpacity(0.4)),
                            ),
                          );
                        });
                  },
                ),
                color: Colors.blue[100]!.withOpacity(0.2),
              ),
            )
          ],
        ),
      ),
    );
  }
}
