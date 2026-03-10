import 'package:chronogram/app_helper/sign_up_change_mobile_number.dart';
import 'package:chronogram/app_helper/exit_user_dilog.dart';
import 'package:chronogram/auth_progress_indicator/auth_progress_indicator.dart';
import 'package:chronogram/app_helper/mobile_mask/mobile_mask.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:chronogram/buttons/buttons.dart';
import 'package:chronogram/screens/login/login_helper/aseet_helper.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_mobile_otp_provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';

class SignUpMobileOtpScreen extends StatefulWidget {
  const SignUpMobileOtpScreen({super.key});
  @override
  State<SignUpMobileOtpScreen> createState() => _SignUpMobileOtpScreenState();
}

class _SignUpMobileOtpScreenState extends State<SignUpMobileOtpScreen> {
  List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((value){
      context.read<SignUpMobileOtpProvider>().init(context);
    });
    
  }

  @override
  Widget build(BuildContext context) {
    final mobile = context.read<SignUpScreenProvider>().mobileController.text;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // const Spacer(),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.18),

                        /// 🔶 LOGO
                        Image.asset(ScreenImage.allLogoBr, height: 70),

                        const SizedBox(height: 35),

                        const Text(
                          "Verify OTP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "OTP sent to ${MobileMask().maskNumber(mobile)}",
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 5),
                            //Edit Button
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false, // must press Cancel or Yes Change
                                  builder: (context) => EditMobileDialog(),
                                );
                              },
                              child: Text(
                                'Change Number',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        /// SIM DETECTED
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xff1C1C1E),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "SIM Detected",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 35),

                        /// OTP FIELD
                        Consumer<SignUpMobileOtpProvider>(
                          builder: (context, provider, child) {
                            return Column(
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    double totalWidth = constraints.maxWidth;

                                    double fieldWidth = (totalWidth - 24) / 6;

                                    if (fieldWidth > 55) fieldWidth = 55;
                                    if (fieldWidth < 34) fieldWidth = 34;

                                    return OtpTextField(
                                      numberOfFields: 6,
                                      fieldWidth: fieldWidth,
                                      fieldHeight: 60,
                                      borderRadius: BorderRadius.circular(14),
                                      showFieldAsBox: true,
                                      filled: true,
                                      fillColor: const Color(0xff1C1C1E),
                                      borderColor: Colors.white12,
                                      focusedBorderColor: Colors.orange,
                                      enabledBorderColor: Colors.white12,
                                      cursorColor: Colors.orange,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onCodeChanged: (code) {
                                        provider.mobileOtpController.text =
                                            code;
                                      },
                                      onSubmit: (verificationCode) {
                                        provider.mobileOtpController.text =
                                            verificationCode;
                                        provider.validMobileOtp();
                                      },
                                    );
                                  },
                                ),

                                const SizedBox(height: 12),

                                if (provider.mobileOtpError != null)
                                  Text(
                                    provider.mobileOtpError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 25),

                        Consumer<SignUpMobileOtpProvider>(
                          builder: (context, provider, child) {
                            if (provider.canResend) {
                              return GestureDetector(
                                onTap: provider.isResending
                                    ? null
                                    : () => provider.resendOtp(context),
                                child: Text(
                                  provider.isResending
                                      ? "Sending..."
                                      : "Resend OTP",
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }

                            return RichText(
                              text: TextSpan(
                                text: "Resend OTP in ",
                                style: const TextStyle(color: Colors.white60),
                                children: [
                                  TextSpan(
                                    text: provider.timerText,
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),

                        /// CONTINUE BUTTON
                        Consumer<SignUpMobileOtpProvider>(
                          builder: (context, value, child) {
                            return AppButton(
                              title: "Continue",
                              isLoading: value.isLoading,
                              isEnabled: value.isMobileOtpValid,
                              onTap: () async {
                                bool success = await value.verifyMobileOtp(context);
                                if (success) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignUpEmailScreen(),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        /// PROGRESS BAR
                        _buildProgressBar(),

                        /// keyboard safe
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

  /// 🔥 PROGRESS BAR METHOD
  Widget _buildProgressBar() {
    return const AuthProgressIndicator(
      currentStep: 2,
      totalSteps: 5,
      message: "We’re verifying your information securely",
    );
  }
}
