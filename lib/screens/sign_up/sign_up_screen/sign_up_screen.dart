import 'package:chronogram/auth_progress_indicator/auth_progress_indicator.dart';
import 'package:chronogram/buttons/buttons.dart';
import 'package:chronogram/screens/login/login_helper/aseet_helper.dart';
import 'package:chronogram/screens/login/login_provider/login_screen_provider.dart';
import 'package:chronogram/screens/login/login_screen/login_screen.dart';
import 'package:chronogram/service/api_service.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_mobile_otp.dart';
import 'package:chronogram/app_helper/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  SignUpScreenProvider get signUpScreenProvider =>
      Provider.of<SignUpScreenProvider>(
        context,
        listen: false,
      ); //// This Line use for provider
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.18),

                /// 🔶 LOGO WITH GLOW
                Image.asset(ScreenImage.allLogoBr, height: 70),

                const SizedBox(height: 35),

                /// 🔤 TITLE
                const Text(
                  "Enter Mobile Number",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "We'll send you a verification code",
                  style: TextStyle(color: Colors.white60, fontSize: 15),
                ),

                const SizedBox(height: 35),

                /// 📱 MOBILE FIELD
                Consumer<SignUpScreenProvider>(
                  builder: (context, value, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //Input Box
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff1C1C1E),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextFormField(
                            controller: value.mobileController,
                            keyboardType: TextInputType.phone,

                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            onChanged: (v) {
                              value.checkMobileValid();
                            },

                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  "+91  ",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              hintText: "Enter 10-digits mobile number",
                              hintStyle: const TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 18,
                              ),
                            ),
                          ),
                        ),
                        if (value.mobileError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 5),
                            child: Text(
                              value.mobileError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 30),

                /// 🔘 CONTINUE BUTTON
                Consumer<SignUpScreenProvider>(
                  builder: (context, value, child) {
                    return AppButton(
                      title: "Continue",
                      isLoading: value.isLoading,
                      isEnabled: value.isMobileValid,
                      onTap: () async {
                        if (value.validateMobile()) {
                          String mobile = value.mobileController.text;
                          if (value.isCooldownActive(mobile) ) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpMobileOtpScreen(),
                              ),
                            );
                            return;
                          }
                         String result = await value.sendOtp(mobile);
                         if (!context.mounted) return;
                          if (result == "success") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpMobileOtpScreen(),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),

                /// ✨ POSITIVE PROGRESS MESSAGE
                const SizedBox(height: 25),

                /// 🔁 LOGIN TEXT
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginMobileScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50), /////
                const AuthProgressIndicator(
                  currentStep: 1,
                  totalSteps: 5,
                  message: "Let’s get started with your registration",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
