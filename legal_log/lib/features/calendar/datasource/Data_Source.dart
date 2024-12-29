import 'package:legal_log/features/calendar/model/calendercase.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CaseDataSource extends CalendarDataSource {
  CaseDataSource(List<Calendercase> cases) {
    appointments = cases.map((c) {
      return Appointment(
        startTime:
            c.startTime, // Use a real `startTime` field from `Calendercase`
        endTime: DateTime.now().add(Duration(hours: 1)), // Adjust as necessary
        subject: c.caseNo, // Use any property to display as the event title
        notes: 'Client: ${c.ourClient}, Court: ${c.court}, Judge: ${c.judge}',
      );
    }).toList();
  }
}
