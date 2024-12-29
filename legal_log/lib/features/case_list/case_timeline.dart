import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

class CaseNotesTimeline extends StatelessWidget {
  final String caseId;

  const CaseNotesTimeline({Key? key, required this.caseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('case')
          .doc(caseId)
          .collection('case_note')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final notes = snapshot.data!.docs;

        if (notes.isEmpty) {
          return const Center(child: Text('No notes available'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index].data() as Map<String, dynamic>;
            final timestamp = note['timestamp'] as Timestamp;
            final noteText = note['note'] as String;
            final date = timestamp.toDate();

            return TimelineTile(
              alignment: TimelineAlign.manual,
              lineXY: 0.2,
              isFirst: index == 0,
              isLast: index == notes.length - 1,
              indicatorStyle: IndicatorStyle(
                width: 20,
                color: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              beforeLineStyle: LineStyle(
                color: Theme.of(context).primaryColor,
              ),
              endChild: Container(
                constraints: const BoxConstraints(
                  minHeight: 120,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      noteText,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              startChild: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  DateFormat('MMM dd, yyyy\nhh:mm a').format(date),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
