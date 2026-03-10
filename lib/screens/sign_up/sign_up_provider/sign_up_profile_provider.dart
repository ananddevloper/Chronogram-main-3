import 'package:flutter/material.dart';
import '../../../service/api_service.dart';
import '../../../app_helper/token_saver_helper/token_saver_helper.dart';

class SignUpProfileProvider extends ChangeNotifier {
  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  String? nameError;
  String? dobError;

  bool isValid = false;
  bool isLoading = false;

  //// Name Validation
  void validateName() {
    String name = nameController.text;

    // Collapse multiple interior spaces into one
    if (name.contains('  ')) {
      name = name.replaceAll(RegExp(r'\s+'), ' ');
      nameController.value = nameController.value.copyWith(
        text: name,
        selection: TextSelection.collapsed(offset: name.length),
      );
    }

    String trimmedName = name.trim();
    RegExp nameRegex = RegExp(r"^[a-zA-Z ]{2,25}$");

    if (trimmedName.isEmpty) {
      nameError = null;
    } else if (!nameRegex.hasMatch(trimmedName)) {
      nameError = "Enter valid name (only letters)";
    } else {
      nameError = null;
    }

    checkAllValid();
    notifyListeners();
  }

  void validateDob() {
    String dob = dobController.text.trim();

    if (dob.isEmpty) {
      dobError = "Select DOB";
    } else {
      DateTime selectedDate = DateTime.parse(dob);
      DateTime today = DateTime.now();

      int age = today.year - selectedDate.year;

      if (today.month < selectedDate.month ||
          (today.month == selectedDate.month && today.day < selectedDate.day)) {
        age--;
      }

      if (age < 12) {
        dobError = "You must be at least 12 years old";
      } else {
        dobError = null;
      }
    }

    checkAllValid();
    notifyListeners();
  }

  void checkAllValid() {
    isValid =
        nameError == null &&
        dobError == null &&
        nameController.text.isNotEmpty &&
        dobController.text.isNotEmpty;
  }

  Future<bool> completeProfileApi(String mobile) async {
    validateName();
    validateDob();

    if (!isValid) return false;

    isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.completeProfile(
        name: nameController.text.trim().replaceAll(RegExp(r'\s+'), ' '),
        dob: dobController.text.trim(),
        mobile: mobile,
      );

      if (result?['accessToken'] == null) {
        dobError = result?['error'];
        return false;
      }

      String finalToken = result?["accessToken"];
      await TokenHelper.saveToken(finalToken);
      return true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    super.dispose();
  }
}
