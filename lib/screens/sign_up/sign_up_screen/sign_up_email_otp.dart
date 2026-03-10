import 'package:chronogram/app_helper/sign_up_edit_email_dialog.dart';
import 'package:chronogram/app_helper/exit_user_dilog.dart';
import 'package:chronogram/auth_progress_indicator/auth_progress_indicator.dart';
import 'package:chronogram/buttons/buttons.dart';
import 'package:chronogram/screens/login/login_helper/aseet_helper.dart';
import 'package:chronogram/app_helper/mask/email_mask/email_mask.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_email_otp_provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:provider/provider.dart';

class SignUpEmailOtpScreen extends StatefulWidget {
  const SignUpEmailOtpScreen({super.key, required this.email});
  final String email;
  @override
  State<SignUpEmailOtpScreen> createState() => _SignUpEmailOtpScreenState();
}

class _SignUpEmailOtpScreenState extends State<SignUpEmailOtpScreen> {
  List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SignUpEmailOtpProvider>().init(context);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                        SizedBox(height: MediaQuery.of(context).size.height * 0.18),

                        /// 🔶 LOGO
                        Image.asset(ScreenImage.allLogoBr, height: 70),

                        const SizedBox(height: 35),

                        const Text(
                          "Verify Email",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "OTP sent to your email",
                          style: TextStyle(color: Colors.white60, fontSize: 15),
                        ),

                        const SizedBox(height: 6),

                        /// masked email
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              EmailMask.maskEmail(widget.email.toLowerCase()),
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 6),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false, // must press Cancel or Yes Change
                                  builder: (context) => EditEmailDialog(),
                                );
                              },
                              child: Text(
                                'Change Email',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 35),

                        /// OTP FIELD
                        Consumer<SignUpEmailOtpProvider>(
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
                                        provider.emailOtpController.text = code;
                                      },
                                      onSubmit: (verificationCode) {
                                        provider.emailOtpController.text =
                                            verificationCode;
                                        provider.validEmailOtp();
                                      },
                                    );
                                  },
                                ),

                                const SizedBox(height: 12),

                                if (provider.emailOtpError != null)
                                  Text(
                                    provider.emailOtpError!,
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

                        Consumer<SignUpEmailOtpProvider>(
                          builder: (context, provider, child) {
                            if (provider.canResend) {
                              return GestureDetector(
                                onTap: provider.isResending
                                    ? null
                                    : () => provider.resendOtp(widget.email, context),
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

                            return Text.rich(
                              TextSpan(
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
                        Consumer<SignUpEmailOtpProvider>(
                          builder: (context, value, child) {
                            return AppButton(
                              title: "Continue",
                              isLoading: value.isLoading,
                              isEnabled: value.isEmailOtpValid,
                              onTap: () async {
                                bool success = await value.verifyEmailOtpApi(widget.email);
                                if (success) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignUpProfileScreen(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        /// PROGRESS BAR
                        const AuthProgressIndicator(
                          currentStep: 4,
                          totalSteps: 5,
                          message: "Almost there, just one more step!",
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
