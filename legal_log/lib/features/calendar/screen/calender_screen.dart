import 'package:flutter/material.dart';
import 'package:legal_log/features/calendar/datasource/Data_Source.dart';
import 'package:legal_log/features/calendar/model/calendercase.dart';
import 'package:legal_log/features/calendar/services/calendercasefirebaseservices.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Future<List<Calendercase>> casesFuture;

  @override
  void initState() {
    super.initState();
    casesFuture = Calendercasefirebaseservices().fetchCasesForToday()
        as Future<List<Calendercase>>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Case Calendar')),
      body: FutureBuilder<List<Calendercase>>(
        future: casesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return SfCalendar(
              view: CalendarView.week,
              dataSource: CaseDataSource(snapshot.data!),
            );
          } else {
            return Center(child: Text('No cases found.'));
          }
        },
      ),
    );
  }
}
