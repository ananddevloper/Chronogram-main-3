import 'package:chronogram/app_helper/exit_user_dilog.dart';
import 'package:chronogram/auth_progress_indicator/auth_progress_indicator.dart';
import 'package:chronogram/buttons/buttons.dart';
import 'package:chronogram/screens/home_screen/home_screen.dart';
import 'package:chronogram/screens/login/login_helper/aseet_helper.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_profile_provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SignUpProfileScreen extends StatelessWidget {
  const SignUpProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpProfileProvider(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();
  @override
  Widget build(BuildContext context) {
    final provider = context.read<SignUpProfileProvider>();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if(didPop) return;
        showDialog(context: context, builder:(context) => ExitUser(),);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.18),
      
                /// 🔶 LOGO
                Center(
                  child: Image.asset(ScreenImage.allLogoBr, height: 70),
                ),
      
                const SizedBox(height: 40),
      
                Center(
                  child: const Text(
                    "Complete Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
      
                const SizedBox(height: 8),
      
                Center(
                  child: const Text(
                    "Enter your details to continue",
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                ),
      
                const SizedBox(height: 35),
      
                /// NAME FIELD
                Consumer<SignUpProfileProvider>(
                  builder: (context, p, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff1C1C1E),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextField(
                            controller: p.nameController,
                            onChanged: (_) => p.validateName(),
                            style: const TextStyle(color: Colors.white),
                            maxLength: 25,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                              TextInputFormatter.withFunction((oldValue, newValue) {
                                if (newValue.text.contains('  ')) {
                                  return oldValue;
                                }
                                return newValue;
                              }),
                            ],
                            decoration: const InputDecoration(
                              hintText: "Full Name",
                              hintStyle: TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                              counterText: '',
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 15,
                              ),
                            ),
                          ),
                        ),
      
                        /// 🔥 ERROR TEXT CENTER
                        if (p.nameError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Center(
                              child: Text(
                                p.nameError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
      
                const SizedBox(height: 20),
      
                /// DOB FIELD
                Consumer<SignUpProfileProvider>(
                  builder: (context, p, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff1C1C1E),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextField(
                            controller: p.dobController,
                            readOnly: true,
                            style: const TextStyle(color: Colors.white),
                            onTap: () async {
                              DateTime today = DateTime.now();
      
                              /// 🔥 Minimum allowed date (12 years old)
                              DateTime minAllowedDate = DateTime(
                                today.year - 12,
                                today.month,
                                today.day,
                              );
      
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    minAllowedDate, // 🔥 default selected
                                firstDate: DateTime(1950),
                                lastDate:
                                    minAllowedDate, // 🔥 12 saal se chhota select nahi hoga
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Color(0xffFF8C00),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                String month = picked.month.toString().padLeft(
                                  2,
                                  '0',
                                );
                                String day = picked.day.toString().padLeft(
                                  2,
                                  '0',
                                );
      
                                p.dobController.text =
                                    "${picked.year}-$month-$day";
                                p.validateDob();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Date of Birth",
                              hintStyle: const TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 15,
                              ),
                              suffixIcon: const Icon(
                                Icons.calendar_today,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                        /// 🔥 ERROR TEXT CENTER
                        if (p.dobError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Center(
                              child: Text(
                                p.dobError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
      
                const SizedBox(height: 40),
      
                /// FINISH BUTTON
                Consumer<SignUpProfileProvider>(
                  builder: (context, p, child) {
                    return AppButton(
                      title: "Finish",
                      isLoading: p.isLoading,
                      isEnabled: p.isValid,
                      onTap: () async {
                        String mobile = context
                            .read<SignUpScreenProvider>()
                            .mobileController
                            .text;

                        bool done = await p.completeProfileApi(mobile);

                        if (done) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                              settings: const RouteSettings(name: "HomeScreen"),
                            ),
                            (route) => false,
                          );
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 30),
                AuthProgressIndicator(
                  currentStep: 5,
                  totalSteps: 5,
                  message: "You're all set and ready to go!",
                ),
      
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
