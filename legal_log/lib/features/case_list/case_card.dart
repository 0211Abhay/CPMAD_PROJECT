import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:legal_log/features/case_add/model/case.dart';
import 'package:legal_log/features/case_list/case_details.dart';

class CaseCard extends StatefulWidget {
  final Case legalCase;
  final double width;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const CaseCard({
    super.key,
    required this.legalCase,
    required this.width,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  _CaseCardState createState() => _CaseCardState();
}

class _CaseCardState extends State<CaseCard> {
  DateTime? selectedDateTime;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _selectDateTime(BuildContext context) async {
    // Select Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // Select Time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        DateTime newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Update Firestore
        await _updateCaseHistory(newDateTime);
        setState(() {
          selectedDateTime = newDateTime;
        });
      }
    }
  }

  
      // Fetch the most recent next_date for this case
    Future<void> _updateCaseHistory(DateTime newDateTime) async {
  try {
    DateTime previousDate = widget.legalCase.dateOfFiling;

    // Fetch the most recent case history entry, if it exists
    QuerySnapshot snapshot = await _firestore
        .collection('case_history')
        .where('case_id', isEqualTo: widget.legalCase.docId)
        .orderBy('next_date', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Use the current 'next_date' as the new 'previous_date'
      previousDate = (snapshot.docs.first['next_date'] as Timestamp).toDate();
    }

    // Add a new case history entry
    await _firestore.collection('case_history').add({
      'advocate_id': widget.legalCase.advocate_id,
      'case_id': widget.legalCase.docId,
      'case_no': widget.legalCase.caseNo,
      'previous_date': previousDate,
      'next_date': newDateTime,
    });

    print("Case history updated successfully.");
  } catch (e) {
    print("Error updating case history: $e");
  }
}



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => CaseDetailScreen(),
          arguments: widget.legalCase, // Pass the case data to the details screen
        );
      },
      child: Container(
        width: widget.width,
        child: Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 6.0, // More prominent elevation
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Case Number
                Row(
                  children: [
                    const Icon(
                      Icons.bookmark_border,
                      color: Colors.black87,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Case No: ${widget.legalCase.caseNo ?? "N/A"}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const Divider(thickness: 1.0, height: 20.0), // Divider below Case No

                // Case Details
                _buildDetail("File No", widget.legalCase.fileNo, Icons.document_scanner),
                _buildDetail("Applicant", widget.legalCase.applicantName, Icons.person),
                _buildDetail("Opponent", widget.legalCase.opponentName, Icons.person_outline),
                _buildDetail("Court", widget.legalCase.court, Icons.gavel),
                _buildDetail("Stage", widget.legalCase.stage, Icons.timeline),
                _buildDetail("Date of Filing",
                    widget.legalCase.dateOfFiling.toString(), Icons.calendar_today),

                const SizedBox(height: 8),

                // DateTime Picker Button
                ElevatedButton.icon(
                  onPressed: () => _selectDateTime(context),
                  icon: const Icon(Icons.date_range),
                  label: const Text("Select Date & Time"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.black87,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? "N/A",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}



// class CaseCard extends StatelessWidget {
//   final Case legalCase;
//   final double width;
//   final VoidCallback onUpdate;
//   final VoidCallback onDelete;

//   const CaseCard({
//     super.key,
//     required this.legalCase,
//     required this.width,
//     required this.onUpdate,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Get.to(
//           () => CaseDetailScreen(),
//           arguments: legalCase, // Pass the case data to the details screen
//         );
//       },
//       child: Container(
//         width: width,
//         child: Card(
//           margin: const EdgeInsets.all(8.0),
//           elevation: 4.0,
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Text(
//                   "Case No: ${legalCase.caseNo ?? "N/A"}",
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 Text("File No: ${legalCase.fileNo ?? "N/A"}"),
//                 Text("Applicant: ${legalCase.applicantName ?? "N/A"}"),
//                 Text("Opponent: ${legalCase.opponentName ?? "N/A"}"),
//                 Text("Court: ${legalCase.court ?? "N/A"}"),
//                 Text("Stage: ${legalCase.stage ?? "N/A"}"),
//                 const SizedBox(height: 8),
//                 Text(
//                   "Date of Filing: ${legalCase.dateOfFiling.toLocal().toString().split(' ')[0]}",
//                   style: const TextStyle(color: Colors.grey),
//                 ),
//                 const SizedBox(height: 8),
//                 Text("Note: ${legalCase.note ?? "N/A"}"),
//                 const SizedBox(height: 16),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CaseCard extends StatelessWidget {
//   final Case legalCase;
//   final double width;
//   final VoidCallback onUpdate;
//   final VoidCallback onDelete;

//   const CaseCard({
//     super.key,
//     required this.legalCase,
//     required this.width,
//     required this.onUpdate,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Get.to(
//           () => CaseDetailScreen(),
//           arguments: legalCase, // Pass the case data to the details screen
//         );
//       },
//       child: Container(
//         width: width,
//         child: Card(
//           margin: const EdgeInsets.all(8.0),
//           elevation: 6.0, // More prominent elevation
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.0), // Rounded corners
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Case Number
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.bookmark_border,
//                       color: Colors.black87,
//                       size: 18,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Case No: ${legalCase.caseNo ?? "N/A"}",
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const Divider(thickness: 1.0, height: 20.0), // Divider below Case No

//                 // Case Details
//                 _buildDetail("File No", legalCase.fileNo, Icons.document_scanner),
//                 _buildDetail("Applicant", legalCase.applicantName, Icons.person),
//                 _buildDetail("Opponent", legalCase.opponentName, Icons.person_outline),
//                 _buildDetail("Court", legalCase.court, Icons.gavel),
//                 _buildDetail("Stage", legalCase.stage, Icons.timeline),

//                 const SizedBox(height: 8),

//                 // Filing Date
//                 Row(
                  
//                   children: [
//                     Icon(
//                       Icons.calendar_today,
//                       color: Colors.grey,
//                       size: 18,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Date of Filing:",
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const SizedBox(width:4),
//                     Text(
//                       legalCase.dateOfFiling.toLocal().toString().split(' ')[0],
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 8),

//                 // Note Section
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.note_alt_outlined,
//                       color: Colors.black87,
//                       size: 18,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       "Note:",
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   legalCase.note ?? "N/A",
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.black54,
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Action Buttons
//                 // You can add action buttons here if needed (e.g. Update, Delete)
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetail(String label, String? value, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         children: [
//           Icon(
//             icon,
//             color: Colors.black87,
//             size: 18,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             "$label: ",
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: Colors.black87,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value ?? "N/A",
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Colors.black54,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



