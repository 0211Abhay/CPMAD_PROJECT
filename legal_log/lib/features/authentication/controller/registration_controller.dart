
import 'package:country_code_picker/country_code_picker.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class RegistrationController extends GetxController {
  var selectedCountryCode = '+91'.obs; // Default to India
  var agreeToTerms = false.obs;

  void toggleAgreeToTerms() {
    agreeToTerms.value = !agreeToTerms.value;
  }

  void updateCountryCode(CountryCode code) {
    selectedCountryCode.value = code.dialCode!;
  }
}