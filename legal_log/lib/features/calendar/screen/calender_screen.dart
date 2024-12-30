// import 'package:flutter/material.dart';
// import 'package:legal_log/features/calendar/datasources/Data_Souce.dart';
// import 'package:legal_log/features/calendar/model/calendercase.dart';
// import 'package:legal_log/features/calendar/services/calenderfirebaseservices.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';
// import 'package:table_calendar/table_calendar.dart';

// class CalendarScreen extends StatefulWidget {
//   const CalendarScreen({super.key});

//   @override
//   State<CalendarScreen> createState() => _CalenderScreenState();
// }

// class _CalenderScreenState extends State<CalendarScreen> {
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   List<Map<String, dynamic>> _cases = [];
//   final CalendarCaseFirebaseServices _caseService =
//       CalendarCaseFirebaseServices();

//   @override
//   void initState() {
//     super.initState();
//     // Fetch cases for today when the screen is initialized
//     _fetchCasesForToday(DateTime.now());
//   }

//   Future<void> _fetchCasesForToday(DateTime date) async {
//     List<Map<String, dynamic>> cases =
//         await _caseService.fetchCasesForToday(date);
//     setState(() {
//       _cases = cases;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TableCalendar(
//               firstDay: DateTime.utc(2010, 10, 16),
//               lastDay: DateTime.utc(2030, 3, 14),
//               focusedDay: _focusedDay,
//               calendarFormat: _calendarFormat,
//               selectedDayPredicate: (day) {
//                 return isSameDay(_selectedDay, day);
//               },
//               onDaySelected: (selectedDay, focusedDay) {
//                 setState(() {
//                   _selectedDay = selectedDay;
//                   _focusedDay = focusedDay;
//                 });
//                 // Fetch cases for the selected day
//                 _fetchCasesForToday(selectedDay);
//               },
//               onFormatChanged: (format) {
//                 setState(() {
//                   _calendarFormat = format;
//                 });
//               },
//             ),
//             const SizedBox(height: 20), // Space between calendar and case list
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _cases.length,
//                 itemBuilder: (context, index) {
//                   final caseItem = _cases[index];
//                   return ListTile(
//                     title: Text(caseItem['case_no'] ?? 'No Title'),
//                     subtitle: Text(caseItem['case_id']),
//                     onTap: () {
//                       print("DOc Id ${caseItem['docId']}");
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:legal_log/features/case_add/model/case.dart';
import 'package:legal_log/features/case_add/services/case_firebase_services.dart';
import 'package:legal_log/features/case_list/case_details.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _casesForSelectedDay = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _fetchCasesForDay(selectedDay); // Corrected method name
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
            ),
          ),
          Expanded(
            child: _casesForSelectedDay.isEmpty
                ? const Center(
                    child: Text("No cases for this day."),
                  )
                : ListView.builder(
                    itemCount: _casesForSelectedDay.length,
                    itemBuilder: (context, index) {
                      final caseData = _casesForSelectedDay[index];
                      return ListTile(
                        title: Text("Case No: ${caseData['case_no'] ?? 'N/A'}"),
                        subtitle: Text(
                            "Advocate ID: ${caseData['advocate_id'] ?? 'N/A'}"),
                        onTap: () async {
                          print("Case ID: ${caseData['case_id']}");
                          _fetchAndNavigateToCaseDetails(caseData['case_id']);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _fetchCasesForDay(DateTime selectedDay) async {
    DateTime startOfDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('case_history')
          .where('advocate_id',
              isEqualTo: GetStorage().read('user')['advocate_id'])
          .where('next_date', isGreaterThanOrEqualTo: startOfDay)
          .where('next_date', isLessThan: endOfDay)
          .get();

      setState(() {
        _casesForSelectedDay = querySnapshot.docs
            .map((doc) => {
                  "case_no": doc['case_no'] ?? 'N/A',
                  "advocate_id": doc['advocate_id'] ?? 'N/A',
                  "next_date": doc['next_date'],
                  "case_id": doc['case_id'],
                  "docId": doc.id,
                })
            .toList();
      });
    } catch (e) {
      print("Error fetching cases: $e");
      // Optionally show an error message to the user
      Get.snackbar("Error", "Failed to fetch cases. Please try again.");
    }
  }

  void _fetchAndNavigateToCaseDetails(String caseId) async {
    try {
      DocumentSnapshot caseDoc =
          await FirebaseFirestore.instance.collection('case').doc(caseId).get();

      if (caseDoc.exists) {
        Case caseData = Case.fromJson(caseDoc.data() as Map<String, dynamic>);
        caseData.docId = caseId;

        Get.to(
          () => CaseDetailScreen(),
          arguments: caseData,
        );
      } else {
        print("Case document not found.");
        Get.snackbar("Error", "Case not found.");
      }
    } catch (e) {
      print("Error fetching case details: $e");
      Get.snackbar("Error", "Failed to fetch case details. Please try again.");
    }
  }
}
