import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:legal_log/common_widgets/custom_text_fields.dart';
import 'package:legal_log/features/case_add/controller/case_add_controller.dart';

class CaseRegistrationScreen extends StatelessWidget {
  final CaseAddController controller = Get.put(CaseAddController());
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GetStorage storage = GetStorage();

  CaseRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String userId = storage.read('user')['advocate_id'];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.toNamed("/home_page");
            },
            icon: Icon(Icons.arrow_back)),
        title: Text('Case Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: controller.formKey, // Attach the form key
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'Register A Case',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Enter case details to register',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  // Form Fields
                  CustomTextField(
                    label: 'File No',
                    controller: controller.fileNoController,
                    prefixIcon: Icon(Icons.file_copy),
                    validator: controller.validateFileNo,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Case No.',
                    controller: controller.caseNoController,
                    prefixIcon: Icon(Icons.confirmation_number),
                    validator: controller.validateCaseNo,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Applicant Name',
                    controller: controller.applicantNameController,
                    prefixIcon: Icon(Icons.person),
                    validator: controller.validateApplicantName,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Other Applicant',
                    controller: controller.otherapplicantNameController,
                    prefixIcon: Icon(Icons.group),
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Opponent Name',
                    controller: controller.opponentNameController,
                    prefixIcon: Icon(Icons.person_off),
                    validator: controller.validateOpponentName,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Other Opponent',
                    controller: controller.otheropponentNameController,
                    prefixIcon: Icon(Icons.group_off),
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Our Client Name',
                    controller: controller.ourClientController,
                    prefixIcon: Icon(Icons.supervised_user_circle),
                    validator: controller.validateOurClient,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Area',
                    controller: controller.areaController,
                    prefixIcon: Icon(Icons.location_city),
                    validator: controller.validateArea,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Court',
                    controller: controller.courtController,
                    prefixIcon: Icon(Icons.account_balance),
                    validator: controller.validateCourt,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Judge',
                    controller: controller.judgeController,
                    prefixIcon: Icon(Icons.gavel),
                    validator: controller.validateJudge,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Our Advocates',
                    controller: controller.ourAdvocatesController,
                    prefixIcon: Icon(Icons.group_work),
                    validator: controller.validateOurAdvocates,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Opponent Advocates',
                    controller: controller.opponentAdvocatesController,
                    prefixIcon: Icon(Icons.group_off),
                  ),
                  const SizedBox(height: 10),

                  // Date of Filing Field
                  Obx(() {
                    return CustomTextField(
                      label: 'Date of Filing',
                      controller: TextEditingController(
                          text: controller.dateOfFiling.value.isNotEmpty
                              ? controller.dateOfFiling.value
                              : ''),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            controller.dateOfFiling.value =
                                '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
                          }
                        },
                      ),
                      validator: controller.validateDateOfFiling,
                    );
                  }),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Stage',
                    controller: controller.stageController,
                    validator: controller.validateStage,
                    prefixIcon: Icon(Icons.timeline),
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    label: 'Case Note',
                    controller: controller.noteController,
                    validator: controller.validateNote,
                    prefixIcon: Icon(Icons.note_add),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Check if the form is valid
                        if (controller.formKey.currentState?.validate() ??
                            false) {
                          // If valid, submit the case
                          controller.registerCase();
                          // controller.onClose();
                          // Get.offNamed('/home_page');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Add Case',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
