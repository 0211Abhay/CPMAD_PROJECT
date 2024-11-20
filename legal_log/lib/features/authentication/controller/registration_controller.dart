
import 'package:country_code_picker/country_code_picker.dart';
import 'package:get/get.dart';

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