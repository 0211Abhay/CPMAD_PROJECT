import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CaseNotesView extends StatelessWidget {
  final String caseId;

  const CaseNotesView({Key? key, required this.caseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Case Notes'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('case') // Reference to 'case' collection
            .doc(caseId) // Case ID
            .collection('case_note') // Subcollection for notes
            .orderBy('timestamp', descending: true) // Order by timestamp
            .snapshots(), // Stream to get real-time updates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notes available'));
          }

          // Group notes by the same date
          final groupedNotes = _groupNotesByDate(snapshot.data!.docs);

          return ListView.builder(
            itemCount: groupedNotes.length,
            itemBuilder: (context, index) {
              final date = groupedNotes.keys.toList()[index];
              final notes = groupedNotes[date]!;

              return Card(
  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  elevation: 4, // Add shadow to the card
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bold Date
        Center(
          child: Text(
            _formatDate(date),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const Divider(
          thickness: 2, // Increase thickness for better visibility
          color: Colors.black54, // Adjust color to have reduced opacity
        ),
        ...notes.map((note) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            title: Text(note['note']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditNoteDialog(context, note['id'], note['note']),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteNote(note['id']),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    ),
  ),
);

            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNoteDialog(context, caseId),
        child: const Icon(Icons.add),
        tooltip: 'Add Note',
      ),
    );
  }

  // Group the notes by the date (ignoring time)
  Map<DateTime, List<Map<String, dynamic>>> _groupNotesByDate(List<QueryDocumentSnapshot> docs) {
    final Map<DateTime, List<Map<String, dynamic>>> groupedNotes = {};

    for (var doc in docs) {
      final timestamp = doc['timestamp'];
      if (timestamp != null) {
        final date = (timestamp as Timestamp).toDate(); // Safely cast Timestamp
        final dateOnly = DateTime(date.year, date.month, date.day); // Group by date (ignore time)

        if (!groupedNotes.containsKey(dateOnly)) {
          groupedNotes[dateOnly] = [];
        }

        groupedNotes[dateOnly]!.add({
          'id': doc.id,
          'note': doc['note'],
        });
      }
    }

    return groupedNotes;
  }

  // Format the date for display
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  // Method to show the Add Note dialog
  void _showAddNoteDialog(BuildContext context, String caseId) {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Note'),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter note here...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final note = noteController.text.trim();
                if (note.isNotEmpty) {
                  try {
                    // Add the note to Firestore
                    await FirebaseFirestore.instance
                        .collection('case') // Reference to 'case' collection
                        .doc(caseId) // Case ID
                        .collection('case_note') // Subcollection for notes
                        .add({
                          'note': note, // Store the note
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                    Navigator.of(context).pop(); // Close the dialog
                    // Show success message
                    Get.snackbar(
                      'Success',
                      'Note added successfully',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } catch (e) {
                    // Show error message
                    Get.snackbar(
                      'Error',
                      'Failed to add note: ${e.toString()}',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Method to show the Edit Note dialog
  void _showEditNoteDialog(BuildContext context, String noteId, String currentNote) {
    final TextEditingController noteController = TextEditingController(text: currentNote);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Edit note here...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final note = noteController.text.trim();
                if (note.isNotEmpty) {
                  try {
                    // Update the note in Firestore
                    await FirebaseFirestore.instance
                        .collection('case')
                        .doc(caseId)
                        .collection('case_note')
                        .doc(noteId) // Reference to the specific note
                        .update({
                          'note': note, // Update the note content
                          'timestamp': FieldValue.serverTimestamp(), // Optional: Update timestamp
                        });

                    Navigator.of(context).pop(); // Close the dialog
                    // Show success message
                    Get.snackbar(
                      'Success',
                      'Note updated successfully',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } catch (e) {
                    // Show error message
                    Get.snackbar(
                      'Error',
                      'Failed to update note: ${e.toString()}',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Method to delete a note
  void _deleteNote(String noteId) async {
    try {
      // Delete the note from Firestore
      await FirebaseFirestore.instance
          .collection('case')
          .doc(caseId)
          .collection('case_note')
          .doc(noteId) // Reference to the specific note
          .delete();

      // Show success message
      Get.snackbar(
        'Success',
        'Note deleted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to delete note: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
