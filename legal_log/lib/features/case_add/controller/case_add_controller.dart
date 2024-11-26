import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:legal_log/features/case_add/model/case.dart';
import 'package:legal_log/features/case_add/services/case_firebase_services.dart';

/// Controller for managing case registration logic and form validation.
class CaseAddController extends GetxController {
  final formKey = GlobalKey<FormState>();
  // Observable variables for the form fields
  final fileNo = ''.obs;
  final caseNo = ''.obs;
  final applicantName = ''.obs;
  final otherApplicant = <String>[].obs; // List for other applicants
  final opponentName = ''.obs;
  final otherOpponent = <String>[].obs; // List for other opponents
  final ourClient = ''.obs;
  final area = ''.obs;
  final court = ''.obs;
  final judge = ''.obs;
  final ourAdvocates = <String>[].obs; // List for our advocates
  final opponentAdvocates = <String>[].obs; // List for opponent advocates
  final dateOfFiling = ''.obs;
  final stage = ''.obs;
  final note = ''.obs;

  // TextEditingControllers for each field
  late final TextEditingController fileNoController;
  late final TextEditingController caseNoController;
  late final TextEditingController applicantNameController;
  late final TextEditingController otherapplicantNameController;
  late final TextEditingController opponentNameController;
  late final TextEditingController otheropponentNameController;
  late final TextEditingController ourClientController;
  late final TextEditingController areaController;
  late final TextEditingController courtController;
  late final TextEditingController judgeController;
  late final TextEditingController ourAdvocatesController;
  late final TextEditingController opponentAdvocatesController;
  late final TextEditingController dateOfFilingController;
  late final TextEditingController stageController;
  late final TextEditingController noteController;

  @override
  void onInit() {
    super.onInit();

    // Initialize controllers and sync with observables
    fileNoController = TextEditingController(text: fileNo.value);
    caseNoController = TextEditingController(text: caseNo.value);
    applicantNameController = TextEditingController(text: applicantName.value);
    otherapplicantNameController = TextEditingController(
      text: otherApplicant.isNotEmpty ? otherApplicant.join(', ') : '',
    );
    opponentNameController = TextEditingController(text: opponentName.value);
    otheropponentNameController = TextEditingController(
      text: otherOpponent.isNotEmpty ? otherOpponent.join(', ') : '',
    );
    ourClientController = TextEditingController(text: ourClient.value);
    areaController = TextEditingController(text: area.value);
    courtController = TextEditingController(text: court.value);
    judgeController = TextEditingController(text: judge.value);
    ourAdvocatesController = TextEditingController(
      text: ourAdvocates.isNotEmpty ? ourAdvocates.join(', ') : '',
    );
    opponentAdvocatesController = TextEditingController(
      text: opponentAdvocates.isNotEmpty ? opponentAdvocates.join(', ') : '',
    );
    dateOfFilingController = TextEditingController(text: dateOfFiling.value);
    stageController = TextEditingController(text: stage.value);
    noteController = TextEditingController(text: note.value);

    // Add listeners to update Rx variables
    fileNoController.addListener(() => fileNo.value = fileNoController.text);
    caseNoController.addListener(() => caseNo.value = caseNoController.text);
    applicantNameController.addListener(() => applicantName.value = applicantNameController.text);
    opponentNameController.addListener(() => opponentName.value = opponentNameController.text);
    ourClientController.addListener(() => ourClient.value = ourClientController.text);
    areaController.addListener(() => area.value = areaController.text);
    courtController.addListener(() => court.value = courtController.text);
    judgeController.addListener(() => judge.value = judgeController.text);
    dateOfFilingController.addListener(() => dateOfFiling.value = dateOfFilingController.text);
    stageController.addListener(() => stage.value = stageController.text);
    noteController.addListener(() => note.value = noteController.text);

  }

  @override
  void onClose() {
    // Dispose controllers to avoid memory leaks
    fileNoController.dispose();
    caseNoController.dispose();
    applicantNameController.dispose();
    opponentNameController.dispose();
    ourClientController.dispose();
    areaController.dispose();
    courtController.dispose();
    judgeController.dispose();
    dateOfFilingController.dispose();
    stageController.dispose();
    noteController.dispose();
    super.onClose();
  }

  // Validation methods
  String? validateFileNo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "File No cannot be empty.";
    }
    return null;
  }

  String? validateCaseNo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Case No cannot be empty.";
    }
    return null;
  }

  String? validateApplicantName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Applicant Name cannot be empty.";
    }
    if (value.trim().length < 3) {
      return "Applicant Name must be at least 3 characters.";
    }
    return null;
  }

  String? validateOpponentName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Opponent Name cannot be empty.";
    }
    return null;
  }

  String? validateOurClient(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Our Client cannot be empty.";
    }
    return null;
  }

  String? validateJudge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Judge cannot be empty.";
    }
    return null;
  }

  String? validateOurAdvocates(String? values) {
    if (values == null || values.isEmpty) {
      return "At least one Our Advocate is required.";
    }
    return null;
  }

  String? validateOpponentAdvocates(String? values) {
    if (values == null || values.isEmpty) {
      return "At least one Opponent Advocate is required.";
    }
    return null;
  }

  String? validateDateOfFiling(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Date of Filing cannot be empty.";
    }
    try {
      // Attempt to parse the date in YYYY-MM-DD format
      DateTime.parse(value.trim());
    } catch (e) {
      return "Enter a valid date in YYYY-MM-DD format.";
    }
    return null;
  }

  String? validateStage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Stage cannot be empty.";
    }
    return null;
  }

  String? validateArea(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Area cannot be empty.";
    }
    return null;
  }

  String? validateCourt(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Court cannot be empty.";
    }
    return null;
  }

  String? validateNote(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Note cannot be empty.";
    }
    return null;
  }

  // (Other validation methods here, as already written in your code...)

List<String> validateAllFields() {
    List<String> errors = [];

    // List of validation functions
    final validations = [
      validateFileNo(fileNo.value),
      validateCaseNo(caseNo.value),
      validateApplicantName(applicantName.value),
      validateOpponentName(opponentName.value),
      validateOurClient(ourClient.value),
      validateDateOfFiling(dateOfFiling.value),
      validateStage(stage.value),
      validateArea(area.value),
      validateCourt(court.value),
      validateNote(note.value),
    ];

    // Iterate through the list of validation results and add any non-null errors
    for (var error in validations) {
      if (error != null) {
        errors.add(error);
      }
    }

    return errors;
  }


  // Registration Logic
  Future<void> registerCase() async {
    final errors = validateAllFields();

    if (errors.isEmpty) {
      try {
        final parsedDate = DateTime.parse(dateOfFiling.value.trim());
        final dateOnly =
            DateTime(parsedDate.year, parsedDate.month, parsedDate.day);

        final caseData = Case(
          fileNo: fileNo.value,
          caseNo: caseNo.value,
          applicantName: applicantName.value,
          otherApplicant: otherApplicant.toList(),
          opponentName: opponentName.value,
          otherOpponent: otherOpponent.toList(),
          ourClient: ourClient.value,
          area: area.value,
          court: court.value,
          judge: judge.value,
          ourAdvocates: ourAdvocates.toList(),
          opponentAdvocates: opponentAdvocates.toList(),
          dateOfFiling: dateOnly,
          stage: stage.value,
          note: note.value,
        );

        await CaseFirebaseServices().addCase(caseData);

        Get.snackbar(
          'Success',
          'Case Registered Successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (error) {
        Get.snackbar(
          'Error',
          'Failed to register case. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        errors.join("\n"),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
