import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:legal_log/features/case_add/model/case.dart';
import 'package:legal_log/features/case_add/services/case_firebase_services.dart';

/// Controller for managing case registration logic and form validation.
class CaseEditController extends GetxController {
  final GetStorage storage = GetStorage();
  final formKey = GlobalKey<FormState>();

  // Document ID of the case being updated
  String? documentId;

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

  void setCaseData(Case legalCase, String? docId) {
    documentId = docId;
    fileNo.value = legalCase.fileNo;
    caseNo.value = legalCase.caseNo;
    applicantName.value = legalCase.applicantName;
    otherApplicant.value =
        legalCase.otherApplicant.map((e) => e ?? '').toList();
    opponentName.value = legalCase.opponentName;
    otherOpponent.value = legalCase.otherOpponent.map((e) => e ?? '').toList();
    ourClient.value = legalCase.ourClient;
    area.value = legalCase.area;
    court.value = legalCase.court;
    judge.value = legalCase.judge;

    fileNoController.text = legalCase.fileNo;
    caseNoController.text = legalCase.caseNo;
    applicantNameController.text = legalCase.applicantName;
    otherapplicantNameController.text = legalCase.otherApplicant.join(',');
    opponentNameController.text = legalCase.opponentName;
    otheropponentNameController.text = legalCase.otherOpponent.join(',');
    ourClientController.text = legalCase.ourClient;
    areaController.text = legalCase.area;
    courtController.text = legalCase.court;
    judgeController.text = legalCase.judge;
    ourAdvocatesController.text = legalCase.ourAdvocates.join(',');
    opponentAdvocatesController.text = legalCase.opponentAdvocates.join(',');
    dateOfFilingController.text =
        legalCase.dateOfFiling.toLocal().toString().split(' ')[0];
    stageController.text = legalCase.stage;
    noteController.text = legalCase.note!;
  }

  @override
  void onInit() {
    super.onInit();

    // Initialize userName from storage after object initialization

    // Initialize controllers and sync with observables
    fileNoController = TextEditingController();
    caseNoController = TextEditingController();
    applicantNameController = TextEditingController();
    otherapplicantNameController = TextEditingController();
    opponentNameController = TextEditingController();
    otheropponentNameController = TextEditingController();
    ourClientController = TextEditingController();
    areaController = TextEditingController();
    courtController = TextEditingController();
    judgeController = TextEditingController();
    ourAdvocatesController = TextEditingController();
    opponentAdvocatesController = TextEditingController();
    dateOfFilingController = TextEditingController();
    stageController = TextEditingController();
    noteController = TextEditingController();

    // Add listeners to update Rx variables
    fileNoController.addListener(() => fileNo.value = fileNoController.text);
    caseNoController.addListener(() => caseNo.value = caseNoController.text);
    applicantNameController
        .addListener(() => applicantName.value = applicantNameController.text);
    otherapplicantNameController.addListener(() =>
        otherApplicant.value = otherapplicantNameController.text.split(','));
    opponentNameController
        .addListener(() => opponentName.value = opponentNameController.text);
    otheropponentNameController.addListener(() =>
        otherOpponent.value = otheropponentNameController.text.split(','));
    ourClientController
        .addListener(() => ourClient.value = ourClientController.text);
    areaController.addListener(() => area.value = areaController.text);
    courtController.addListener(() => court.value = courtController.text);
    judgeController.addListener(() => judge.value = judgeController.text);
    ourAdvocatesController.addListener(
        () => ourAdvocates.value = ourAdvocatesController.text.split(','));
    opponentAdvocatesController.addListener(() =>
        opponentAdvocates.value = opponentAdvocatesController.text.split(','));
    dateOfFilingController
        .addListener(() => dateOfFiling.value = dateOfFilingController.text);
    stageController.addListener(() => stage.value = stageController.text);
    noteController.addListener(() => note.value = noteController.text);
  }

  void Clear_Controller() {
    fileNoController.clear();
    caseNoController.clear();
    applicantNameController.clear();
    otherapplicantNameController.clear();
    opponentNameController.clear();
    otheropponentNameController.clear();
    ourClientController.clear();
    areaController.clear();
    courtController.clear();
    judgeController.clear();
    ourAdvocatesController.clear();
    opponentAdvocatesController.clear();
    dateOfFilingController.clear();
    stageController.clear();
    noteController.clear();
  }

  @override
  void onClose() {
    // Dispose controllers to avoid memory leaks
    fileNoController.dispose();
    caseNoController.dispose();
    applicantNameController.dispose();
    otherapplicantNameController.dispose();
    opponentNameController.dispose();
    otheropponentNameController.dispose();
    ourClientController.dispose();
    areaController.dispose();
    courtController.dispose();
    judgeController.dispose();
    ourAdvocatesController.dispose();
    opponentAdvocatesController.dispose();
    dateOfFilingController.dispose();
    stageController.dispose();
    noteController.dispose();
    super.onClose();
  }

  // Validation methods
  String? validateFileNo(String? value) =>
      (value?.trim().isEmpty ?? true) ? "File No cannot be empty." : null;

  String? validateCaseNo(String? value) =>
      (value?.trim().isEmpty ?? true) ? "Case No cannot be empty." : null;

  String? validateApplicantName(String? value) {
    if (value == null || value.trim().isEmpty)
      return "Applicant Name cannot be empty.";
    if (value.trim().length < 3)
      return "Applicant Name must be at least 3 characters.";
    return null;
  }

  String? validateOurAdvocates(String? values) {
    if (values == null || values.isEmpty) {
      return "At least one Our Advocate is required.";
    }
    return null;
  }

  String? validateOpponentName(String? value) =>
      (value?.trim().isEmpty ?? true) ? "Opponent Name cannot be empty." : null;

  String? validateOurClient(String? value) =>
      (value?.trim().isEmpty ?? true) ? "Our Client cannot be empty." : null;

  String? validateJudge(String? value) =>
      (value?.trim().isEmpty ?? true) ? "Judge cannot be empty." : null;

  String? validateDateOfFiling(String? value) {
    if (value == null || value.trim().isEmpty)
      return "Date of Filing cannot be empty.";
    try {
      DateTime.parse(value.trim());
    } catch (_) {
      return "Enter a valid date in YYYY-MM-DD format.";
    }
    return null;
  }

  String? validateStage(String? value) =>
      (value?.trim().isEmpty ?? true) ? "Stage cannot be empty." : null;

  String? validateArea(String? value) =>
      (value?.trim().isEmpty ?? true) ? "Area cannot be empty." : null;

  String? validateCourt(String? value) =>
      (value?.trim().isEmpty ?? true) ? "Court cannot be empty." : null;

  String? validateNote(String? value) =>
      (value?.trim().isEmpty ?? true) ? "Note cannot be empty." : null;

  List<String> validateAllFields() {
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
    return validations.where((error) => error != null).cast<String>().toList();
  }

  Future<void> updateCase(String documentId) async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        final updatedCase = Case(
          advocate_id: storage.read('user')['advocate_id'],
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
          dateOfFiling: DateTime.parse(dateOfFiling.value),
          stage: stage.value,
          note: note.value,
        );

        await CaseFirebaseServices().updateCase(updatedCase, documentId);

        Get.snackbar(
          'Success',
          'Case updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offNamed('/home_page');
      } catch (e) {
        Get.snackbar(
          'Error',
          'An error occurred while updating Case: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
