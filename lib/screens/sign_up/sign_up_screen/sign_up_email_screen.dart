import 'package:chronogram/app_helper/exit_user_dilog.dart';
import 'package:chronogram/auth_progress_indicator/auth_progress_indicator.dart';
import 'package:chronogram/buttons/buttons.dart';

import 'package:chronogram/screens/login/login_helper/aseet_helper.dart';
import 'package:chronogram/screens/login/login_provider/login_screen_provider.dart';
import 'package:chronogram/screens/login/login_screen/login_screen.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_email_otp_provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_email_provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_email_otp.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_mobile_otp.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SignUpEmailScreen extends StatefulWidget {
  const SignUpEmailScreen({super.key});
  @override
  State<SignUpEmailScreen> createState() => _SignUpEmailScreenState();
}

class _SignUpEmailScreenState extends State<SignUpEmailScreen> {
  SignUpEmailProvider get emailScreenProvider =>
      Provider.of<SignUpEmailProvider>(context, listen: false);
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        showDialog(context: context, builder: (context) => ExitUser());
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
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

                        /// TITLE
                        Center(
                          child: const Text(
                            "Enter Your Email",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Center(
                          child: const Text(
                            "We'll send a verification code to this email",
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          ),
                        ),

                        const SizedBox(height: 35),

                        /// 📧 EMAIL FIELD
                        Consumer<SignUpEmailProvider>(
                          builder: (context, value, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xff1C1C1E),
                                    borderRadius: BorderRadius.circular(15),
                                    border: value.emailError != null
                                        ? Border.all(
                                            color: Colors.red,
                                            width: 1,
                                          )
                                        : Border.all(color: Colors.white12),
                                  ),
                                  child: TextFormField(
                                    controller: value.emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.white),
                                    cursorColor: Colors.orange,
                                    onChanged: (v) {
                                      value.validateEmail();
                                    },
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.mail_outline,
                                        color: Colors.white54,
                                      ),
                                      hintText: "abcd123@gmail.com",
                                      hintStyle: TextStyle(
                                        color: Colors.white38,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                    ),
                                  ),
                                ),

                                if (value.emailError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 6,
                                      left: 8,
                                    ),
                                    child: Text(
                                      value.emailError!,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 40),

                        /// 🔘 CONTINUE BUTTON
                        Consumer<SignUpEmailProvider>(
                          builder: (context, value, child) {
                            return AppButton(
                              title: "Continue",
                              isLoading: value.isLoading,
                              isEnabled: value.isEmailValid,
                              onTap: () async {
                                String result = await value.linkEmailApi();

                                if (!context.mounted) return;

                                if (result == "success") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChangeNotifierProvider(
                                        create: (_) => SignUpEmailOtpProvider(),
                                        child: SignUpEmailOtpScreen(
                                          email: value.emailController.text,
                                        ),
                                      ),
                                    ),
                                  ).then((_) {
                                    value.emailController.clear();
                                    value.emailError = null;
                                    value.isEmailValid = false;
                                    value.notifyListeners();
                                  });
                                }
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 35),

                        const AuthProgressIndicator(
                          currentStep: 3,
                          totalSteps: 5,
                          message: "Setting up strong protection for your account",
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).viewInsets.bottom,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
