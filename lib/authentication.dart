import 'dart:async';
import 'dart:developer';

import 'package:clinisquare_auth/animated_steps.dart';
import 'package:clinisquare_auth/custom_logo_image.dart';
import 'package:clinisquare_auth/temp.dart';
import 'package:connect_design_system/animations/fade_and_scale_transition.dart';
import 'package:connect_design_system/components/misc/colors.dart';
import 'package:connect_design_system/components/misc/responsive.dart';
import 'package:connect_design_system/components/misc/snackbar.dart';
import 'package:connect_design_system/components/ui/buttons.dart';
import 'package:connect_design_system/components/ui/text_form_field.dart';
import 'package:connect_design_system/modules/authentication/providers/registration_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connect_design_system/modules/authentication/providers/authentication_provider.dart';

class AuthenticationScreen extends StatefulWidget {
  static const String route = "/authentication";
  final int? initialPage; // 0: Login Form, 1: Register Form
  final bool? isForgetpassword;
  final Function? onComplete;
  final Function? onFailed;
  const AuthenticationScreen({
    super.key,
    this.initialPage,
    this.onComplete,
    this.onFailed,
    this.isForgetpassword,
  });

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  PageController? pageController;
  int currentPage = 0;
  bool showPasscode = false;
  bool showsetPasscode = false;
  bool showresetPasscode = false;
  bool isLoading = false;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String fcmToken = '';

  getFCM() async {
    messaging.getToken().then(
      (token) {
        fcmToken = token!;
        log(fcmToken);
        setState(() {});
        // print(fcmToken);
      },
    );
  }

// Personal Details Page
  final detailsFormkey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  String gender = '';

//register page
  final registerformKey = GlobalKey<FormState>();
  TextEditingController newEmailController = TextEditingController();
  TextEditingController newPhoneController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final String verificationId = "";

  checkExistingNumber(String number) {
    Provider.of<AuthenticationProvider>(context, listen: false)
        .checkUserExist(baseURL, countryCode, "$countryCode$number")
        .then((value) {
      if (value.code == 400) {
        showSnackbar(context, value.message!, lightBlueColor);
      } else {
        verifyPhoneNumber(newPhoneController.text);
      }
    });
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    verificationCompleted(PhoneAuthCredential phoneAuthCredential) async {
      await auth.signInWithCredential(phoneAuthCredential);
      print("Auto Verification Completed");
    }

    verificationFailed(FirebaseAuthException authException) {
      print('Phone number verification failed. Code: ${authException.code}');
      print('Message: ${authException.message}');
    }

    codeSent(String verificationId, [int? forceResendingToken]) async {
      print('Please check your phone for the verification code.');
      verificationId = verificationId;
    }

    codeAutoRetrievalTimeout(String verificationId) {
      print("Verification Code Timeout");
    }

    await auth.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      timeout: const Duration(seconds: 5),
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

//otp Page
  TextEditingController otpController = TextEditingController();
  Timer timer = Timer(duration, () {});
  int time = 59;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (time == 0) {
          setState(() {
            timer.cancel();
            time = 59;
          });
        } else {
          setState(() {
            time--;
          });
        }
      },
    );
  }

  Future<void> _signInWithPhoneNumber() async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text,
      );
      await auth.signInWithCredential(credential);
      print("Phone number signed in");
      Navigator.pop(context);
    } catch (e) {
      print('Error signing in with phone number: $e');
    }
  }

//password setup page
  TextEditingController newPasscodeController = TextEditingController();
  TextEditingController reEnterPasscodeController = TextEditingController();

  register(String name, String email, String password, String phoneNumber) {
    isLoading = false;
    setState(() {});
    Provider.of<RegistrationProvider>(context, listen: false)
        .registerUser(baseURL, countryCode, "$countryCode$phoneNumber", email,
            password, name)
        .then(
      (value) {
        isLoading = false;
        setState(() {});
        if (value.status != null && value.status!) {
          showSnackbar(context, value.message!, lightBlueColor);
          login(value.data!.phoneNumber!, password);
        } else {
          log("${value.message}");
          showSnackbar(context, value.message!, lightBlueColor);
        }
      },
    );
  }

// Login Page
  String countryCode = '+91';
  TextEditingController phoneController =
      TextEditingController(text: '7506105831');
  TextEditingController passcodeController =
      TextEditingController(text: '123456');
  final loginformKey = GlobalKey<FormState>();

  login(String phone, String passcode) {
    isLoading = true;
    setState(() {});

    Provider.of<AuthenticationProvider>(context, listen: false)
        .login(baseURL, phone, passcode)
        .then(
      (value) {
        isLoading = false;
        setState(() {});
        if (value.status != null && value.status!) {
          // token = value.data!.token!;
          // userId = value.data!.id!;
          // Provider.of<UserProvider>(context, listen: false)
          //     .userDetails(baseURL, "${value.data!.id!}")
          //     .then((value) {
          //   // if(value.status!)
          //   Navigator.pushAndRemoveUntil(
          //     context,
          //     MaterialPageRoute(
          //       builder: (_) => const WorkSpaceScreen(),
          //     ),
          //     (route) => false,
          //   );
          // });
          // log(token);
          // Provider.of<SessionProvider>(context, listen: false)
          //     .updateSessionState(true);

          //? Please Change before Production
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => const DashboardScreen(),
          //   ),
          //   (route) => false,
          // );
        } else {
          log("${value.message}");
          showSnackbar(context, value.message!, lightBlueColor);
        }
      },
    );
  }

  // Reset Password
  TextEditingController setPassController = TextEditingController();
  TextEditingController reEnterPassController = TextEditingController();
  final resetPassKey = GlobalKey<FormState>();
  String userid = '';
  checkuserNumber(String number) {
    Provider.of<AuthenticationProvider>(context, listen: false)
        .checkUserExist(baseURL, countryCode, "$countryCode$number")
        .then((value) {
      if (value.code == 400) {
        verifyPhoneNumber(number);
        userid = "${value.data!.id}";
      } else {
        showSnackbar(context, value.message!, lightBlueColor);
      }
    });
  }

  resetPassword() {
    Provider.of<AuthenticationProvider>(context, listen: false)
        .resetPassword(
            baseURL, userid, setPassController.text, reEnterPassController.text)
        .then((value) {
      if (value.status != null && value.status!) {
        pageController!.nextPage(duration: duration, curve: curve);
      } else {
        showSnackbar(context, '${value.message}', lightBlueColor);
      }
    });
  }

  @override
  void initState() {
    if (widget.isForgetpassword != null && widget.isForgetpassword!) {
      currentPage = 3;
    } else {
      if (widget.initialPage != null) {
        currentPage = widget.initialPage!;
      }
    }
    // getFCM();
    pageController = PageController(initialPage: currentPage);
    getHeight();
    super.initState();
  }

  @override
  void dispose() {
    if (timer.isActive) {
      timer.cancel();
    }
    super.dispose();
  }

  double _height = 0;
  GlobalKey logoKey = GlobalKey();

  getHeight() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _height = logoKey.currentContext!.size!.height;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: forms(context));
  }

  Widget forms(context) {
    // print("HEIGHTT: $_height");
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            currentPage > 1 && currentPage != 5
                ? Padding(
                    padding: EdgeInsets.fromLTRB(
                      0,
                      _height,
                      defaultPadding,
                      0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CDSButton(
                          mainAxisSize: MainAxisSize.min,
                          leftIcon: CupertinoIcons.arrow_left,
                          bgColor: themeData(context).colorScheme.background,
                          textColor: textTheme(context).titleLarge!.color,
                          onTap: widget.isForgetpassword != null &&
                                  widget.isForgetpassword!
                              ? () => Navigator.pop(context)
                              : () {
                                  pageController!.previousPage(
                                    duration: duration,
                                    curve: curve,
                                  );
                                },
                        ),
                        Text(
                          widget.isForgetpassword != null &&
                                  widget.isForgetpassword!
                              ? "Forgot Password"
                              : "Account Set up",
                          style: textTheme(context).titleMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        widget.isForgetpassword != null &&
                                widget.isForgetpassword!
                            ? const SizedBox()
                            : Text(
                                "${currentPage - 1}/4",
                                style: textTheme(context).titleMedium!.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                textAlign: TextAlign.end,
                              ),
                      ],
                    ),
                  )
                : const SizedBox(),
            currentPage != 1 && currentPage != 5
                ? widget.isForgetpassword != null && widget.isForgetpassword!
                    ? const SizedBox()
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding),
                        child: AnimatedSteps(
                          steps: 4,
                          current: currentPage.toDouble() - 1,
                        ),
                      )
                : const SizedBox(),
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: pageController,
                onPageChanged: (page) {
                  currentPage = page;
                  setState(() {});
                },
                children: [
                  registerForm(context),
                  personalDetailsForm(context),
                  forgotPasscodeForm(context),
                  setPasswordForm(context),
                  confirmationSection(context),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          key: logoKey,
          left: 0,
          top: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              defaultPadding,
              defaultPadding + mediaQuery(context).padding.top,
              defaultPadding,
              defaultPadding,
            ),
            child: FadeAndScaleTransition(
              child: CustomLogoImage(
                size: 100,
                imgUrl: "${appAssets(liveURL)}/AartasLogo.png",
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget confirmationSection(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FadeAndScaleTransition(
          child: Container(
            width: defaultWidth,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(
              bottom: defaultPadding * 3,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FadeAndScaleTransition(
                  index: 3,
                  child: Icon(
                    CupertinoIcons.check_mark_circled_solid,
                    size: textTheme(context).displayMedium!.fontSize,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(
                  height: defaultPadding,
                ),
                Text(
                  widget.isForgetpassword != null && widget.isForgetpassword!
                      ? "Password Reset Successfully"
                      : "Account Setup Completed",
                  style: textTheme(context).headlineSmall!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  // textAlign: TextAlign.center,
                ),
                Text(
                  "Your account is successfully created. Please Login",
                  style: textTheme(context).bodySmall!.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  // textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        FadeAndScaleTransition(
          index: 3,
          child: Container(
            width: defaultWidth,
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding * 1.5,
            ),
            child: CDSButton(
              padding: const EdgeInsets.all(12),
              // isLoading: true,
              // mainAxisSize: MainAxisSize.min,
              label: "Login",
              onTap: () {
                isLoading = false;
                pageController!.jumpToPage(0);
              },
            ),
          ),
        ),
        SizedBox(
          height: mediaQuery(context).padding.bottom + (defaultPadding * 2),
        ),
      ],
    );
  }

  Widget setPasswordForm(context) {
    return Form(
      key: resetPassKey,
      child: SingleChildScrollView(
        child: SizedBox(
          height: mediaQuery(context).size.height -
              (AppBar().preferredSize.height * 3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: defaultWidth,
                padding: const EdgeInsets.only(
                  bottom: defaultPadding * 3,
                  // left: defaultPadding * 1.5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Set Passcode",
                      style: textTheme(context).headlineSmall!.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      "Set a 6-digit passcode for your password security",
                      style: textTheme(context).bodySmall!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: defaultWidth,
                child: Stack(
                  children: [
                    ConnectTextFormField(
                      controller: setPassController,
                      contentPadding: const EdgeInsets.all(16),
                      title: "Passcode*",
                      obscureText: !showsetPasscode,
                      maxLines: 1,
                      hintText: "Ex. 123456",
                      keyboardType: TextInputType.visiblePassword,
                      validator: (p0) {
                        if (p0 != reEnterPassController.text) {
                          return 'Password Does not match';
                        }
                        return null;
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CDSButton(
                        padding: const EdgeInsets.all(9),
                        mainAxisSize: MainAxisSize.min,
                        leftIcon: showsetPasscode
                            ? CupertinoIcons.eye_fill
                            : CupertinoIcons.eye_slash,
                        bgColor: themeData(context).scaffoldBackgroundColor,
                        textColor: blueColor,
                        iconSize: textTheme(context).titleLarge!.fontSize,
                        onTap: () {
                          showsetPasscode = !showsetPasscode;
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                width: defaultWidth,
                child: Stack(
                  children: [
                    ConnectTextFormField(
                      contentPadding: const EdgeInsets.all(16),
                      controller: reEnterPassController,
                      title: "Re-enter Passcode*",
                      obscureText: !showresetPasscode,
                      maxLines: 1,
                      hintText: "Re-enter Passcode",
                      keyboardType: TextInputType.visiblePassword,
                      validator: (p0) {
                        if (p0 != setPassController.text) {
                          return 'Password Does not match';
                        }
                        return null;
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CDSButton(
                        padding: const EdgeInsets.all(9),
                        mainAxisSize: MainAxisSize.min,
                        leftIcon: showresetPasscode
                            ? CupertinoIcons.eye_fill
                            : CupertinoIcons.eye_slash,
                        bgColor: Colors.transparent,
                        textColor: blueColor,
                        iconSize: textTheme(context).titleLarge!.fontSize,
                        onTap: () {
                          showresetPasscode = !showresetPasscode;
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: duration,
                height: mediaQuery(context).viewInsets.bottom != 0
                    ? defaultPadding
                    : defaultPadding * 2,
              ),
              CDSButton(
                width: defaultWidth,
                padding: const EdgeInsets.all(12),
                // isLoading: true,
                // mainAxisSize: MainAxisSize.min,

                label: "Next",
                onTap: () {
                  if (resetPassKey.currentState!.validate()) {
                    resetPassword();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget forgotPasscodeForm(context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: defaultWidth,
        height: mediaQuery(context).size.height -
            (AppBar().preferredSize.height * 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: defaultWidth,
              alignment: Alignment.center,
              padding: const EdgeInsets.only(
                bottom: defaultPadding * 3,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Forgot Password?",
                    style: textTheme(context).headlineSmall!.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Text(
                    "lorem ipsum have sent verification code on the registered contact no.",
                    style: textTheme(context).bodySmall!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: defaultWidth,
              child: Row(
                children: [
                  Expanded(
                    child: ConnectTextFormField(
                      controller: phoneController,
                      // title: "Phone Number",
                      keyboardType: TextInputType.number,
                      contentPadding: const EdgeInsets.all(16),
                      hintText: "Enter phone number here",
                      maxLength: 10,

                      // prefixWidget: Container(
                      //   decoration: const BoxDecoration(
                      //     border: Border(
                      //       right: BorderSide(
                      //         width: 2,
                      //       ),
                      //     ),
                      //   ),
                      //   margin: const EdgeInsets.only(
                      //     right: defaultPadding,
                      //     top: defaultPadding,
                      //     bottom: defaultPadding,
                      //   ),
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: defaultPadding,
                      //     // vertical: defaultPadding / 2,
                      //   ),
                      //   child: Text(
                      //     "+91",
                      //     style: textTheme(context).titleMedium!.copyWith(
                      //           fontWeight: FontWeight.w600,
                      //         ),
                      //   ),
                      // ),
                      // enabled: false,
                    ),
                  ),
                  const SizedBox(
                    width: defaultPadding,
                  ),
                  CDSButton(
                    label: "Send OTP",
                    padding: const EdgeInsets.all(11),
                    isLoading: isLoading,
                    onTap: time == 59
                        ? () {
                            startTimer();
                            checkuserNumber(phoneController.text);
                          }
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              width: defaultWidth,
              child: Stack(
                children: [
                  ConnectTextFormField(
                    width: defaultWidth,
                    controller: otpController,
                    contentPadding: const EdgeInsets.all(16),
                    // title: "OTP",
                    hintText: "Your 6 Digit OTP",
                    keyboardType: TextInputType.number,
                  ),
                  time != 59
                      ? const SizedBox()
                      : Positioned(
                          right: 8,
                          bottom: 12,
                          child: Text(
                            "${time}s",
                            style: textTheme(context).bodySmall!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CDSButton(
              width: defaultWidth,
              // isLoading: true,
              // mainAxisSize: MainAxisSize.min,
              padding: const EdgeInsets.all(12),
              label: "Next",
              onTap: () {
                _signInWithPhoneNumber();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget registerForm(context) {
    return Form(
      key: registerformKey,
      child: SingleChildScrollView(
        child: SizedBox(
          height: mediaQuery(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: defaultWidth,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(
                  // left: defaultPadding * 2,
                  bottom: defaultPadding * 2,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome to Connect 2.0",
                      style: textTheme(context).headlineSmall!.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      "lorem ipsum have sent verification code on the registered contact no.",
                      style: textTheme(context).bodySmall!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: defaultWidth,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ConnectTextFormField(
                        controller: newPhoneController,
                        // title: "Phone Number",
                        validator: (value) {
                          if (value!.isEmpty && value.length != 10) {
                            return "Enter Correct Phone Number";
                          } else {
                            return null;
                          }
                        },
                        contentPadding: const EdgeInsets.all(16),
                        hintText: "Enter phone number here",
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        // prefixWidget: Container(
                        //   decoration: const BoxDecoration(
                        //     border: Border(
                        //       right: BorderSide(
                        //         width: 2,
                        //       ),
                        //     ),
                        //   ),
                        //   margin: const EdgeInsets.only(
                        //     right: defaultPadding,
                        //     top: defaultPadding,
                        //     bottom: defaultPadding,
                        //   ),
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: defaultPadding,
                        //     // vertical: defaultPadding / 2,
                        //   ),
                        //   child: Text(
                        //     "+91",
                        //     style: textTheme(context).titleMedium!.copyWith(
                        //           fontWeight: FontWeight.w600,
                        //         ),
                        //   ),
                        // ),
                        // enabled: false,
                      ),
                    ),
                    const SizedBox(
                      width: defaultPadding,
                    ),
                    CDSButton(
                      padding: const EdgeInsets.all(11),
                      label: "Send OTP",
                      onTap: () {
                        if (registerformKey.currentState!.validate()) {
                          startTimer();
                          checkExistingNumber(newPhoneController.text);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: defaultPadding,
              ),
              ConnectTextFormField(
                width: defaultWidth,
                controller: otpController,
                // title: "OTP",
                contentPadding: const EdgeInsets.all(16),
                hintText: "Your 6 Digit OTP",
                keyboardType: TextInputType.number,
                // suffixWidget: time == 59
                //     ? const SizedBox()
                //     : Padding(
                //         padding: const EdgeInsets.all(defaultPadding),
                //         child: Text(
                //           "${time}s",
                //           style: textTheme(context).titleMedium!.copyWith(
                //                 fontWeight: FontWeight.w600,
                //                 color: primaryColor,
                //               ),
                //         ),
                //       ),
              ),

              // Container(
              //   padding: const EdgeInsets.fromLTRB(
              //     0,
              //     0,
              //     0,
              //     defaultPadding / 2,
              //   ),
              //   alignment: Alignment.centerRight,
              //   child: FittedBox(
              //     child: CDSButton(
              //       borderRadius: BorderRadius.zero,
              //       mainAxisSize: MainAxisSize.min,
              //       label: "Resend OTP?",
              //       textColor: blueColor,
              //       padding: const EdgeInsets.fromLTRB(
              //         0,
              //         0,
              //         defaultPadding * 2,
              //         defaultPadding / 2,
              //       ),
              //       bgColor: themeData(context).colorScheme.background,
              //       decoration: TextDecoration.underline,
              //       onTap: () {},
              //     ),
              //   ),
              // ),
              const SizedBox(
                height: defaultPadding,
              ),
              CDSButton(
                width: defaultWidth,
                padding: const EdgeInsets.all(12),
                isLoading: isLoading,
                // mainAxisSize: MainAxisSize.min,
                label: "Next",
                onTap: () {
                  _signInWithPhoneNumber();
                },
              ),
              FadeAndScaleTransition(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding * 1.5,
                    // vertical: defaultPadding,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "Already have an account?  ",
                        style: textTheme(context).titleSmall!.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      CDSButton(
                        label: "Sign In",
                        mainAxisSize: MainAxisSize.min,
                        textColor: primaryColor,
                        textStyle: textTheme(context).titleSmall!.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        borderRadius: BorderRadius.zero,
                        padding: const EdgeInsets.symmetric(
                          vertical: defaultPadding / 2,
                        ),
                        bgColor: themeData(context).colorScheme.background,
                        decoration: TextDecoration.underline,
                        onTap: () {
                          pageController!.jumpToPage(0);
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget personalDetailsForm(context) {
    return Form(
      key: detailsFormkey,
      child: SingleChildScrollView(
        child: SizedBox(
          height: mediaQuery(context).size.height - (_height * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: defaultWidth,
                padding: const EdgeInsets.only(
                  bottom: defaultPadding * 3,
                  // left: defaultPadding * 1.5,
                  // right: defaultPadding * 1.5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tell us a bit about you",
                      style: textTheme(context).headlineSmall!.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      "That will help us better account setup for you",
                      style: textTheme(context).bodySmall!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              ConnectTextFormField(
                width: defaultWidth,
                contentPadding: const EdgeInsets.all(16),
                hintText: "Full Name",
                controller: nameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Name";
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(
                height: defaultPadding,
              ),
              ConnectTextFormField(
                width: defaultWidth,
                contentPadding: const EdgeInsets.all(16),
                hintText: "Email",
                controller: newEmailController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Enter Email";
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(
                height: defaultPadding,
              ),
              SizedBox(
                width: defaultWidth,
                child: Stack(
                  children: [
                    ConnectTextFormField(
                      contentPadding: const EdgeInsets.all(16),
                      width: defaultWidth,
                      controller: newPasscodeController,
                      // title: "Passcode*",
                      obscureText: !showPasscode,
                      maxLines: 1,
                      hintText: "Enter Passcode here",
                      keyboardType: TextInputType.number,
                      // enabled: false,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Passcode";
                        } else {
                          return null;
                        }
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CDSButton(
                        padding: const EdgeInsets.all(9),
                        mainAxisSize: MainAxisSize.min,
                        leftIcon: showPasscode
                            ? CupertinoIcons.eye_fill
                            : CupertinoIcons.eye_slash,
                        bgColor: themeData(context).scaffoldBackgroundColor,
                        iconSize: 20,
                        textColor: blueColor,
                        onTap: () {
                          showPasscode = !showPasscode;
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: defaultPadding * 1.5,
              //   ),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: ConnectDropDownField(
              //           title: "Gender",
              //           items: const ["Male", "Female", "Others"],
              //           value: "Male",
              //           onChanged: (val) {
              //             gender = val;
              //           },
              //         ),
              //       ),
              //       const SizedBox(
              //         width: defaultPadding,
              //       ),
              //       Expanded(
              //         child: ConnectTextFormField(
              //           controller: dobController,
              //           keyboardType: TextInputType.number,
              //           inputFormatters: [
              //             DateFormatter(),
              //             FilteringTextInputFormatter.allow(RegExp('[0-9/]')),
              //             LengthLimitingTextInputFormatter(10)
              //           ],
              //           title: "Date Of Birth",
              //           hintText: "dd/mm/yyyy",
              //           maxLength: 10,
              //           suffixWidget: CDSButton(
              //             mainAxisSize: MainAxisSize.min,
              //             leftIcon: CupertinoIcons.calendar,
              //             bgColor: Colors.transparent,
              //             textColor: blueColor,
              //             onTap: () {
              //               setState(() {});
              //             },
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              AnimatedContainer(
                duration: duration,
                height: mediaQuery(context).viewInsets.bottom != 0
                    ? defaultPadding
                    : defaultPadding * 2,
              ),
              CDSButton(
                width: defaultWidth,
                padding: const EdgeInsets.all(12),
                // isLoading: isLoading,
                // mainAxisSize: MainAxisSize.min,
                label: "Register",
                onTap: () {
                  if (detailsFormkey.currentState!.validate()) {
                    register(nameController.text, newEmailController.text,
                        newPasscodeController.text, newPhoneController.text);

                    // pageController!.jumpToPage(5);
                  }
                },
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: defaultPadding * 1.5,
              //     vertical: defaultPadding / 2,
              //   ),
              //   child: Wrap(
              //     alignment: WrapAlignment.center,
              //     runAlignment: WrapAlignment.center,
              //     crossAxisAlignment: WrapCrossAlignment.center,
              //     children: [
              //       Text(
              //         "Already have an account? ",
              //         style: textTheme(context).titleLarge!.copyWith(
              //               fontWeight: FontWeight.w600,
              //             ),
              //       ),
              //       CDSButton(
              //         label: "Login",
              //         mainAxisSize: MainAxisSize.min,
              //         textColor: blueColor,
              //         borderRadius: BorderRadius.zero,
              //         padding: const EdgeInsets.symmetric(
              //           vertical: defaultPadding / 2,
              //         ),
              //         bgColor: themeData(context).colorScheme.background,
              //         decoration: TextDecoration.underline,
              //         onTap: () {
              //           pageController!.jumpToPage(0);
              //         },
              //       )
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget loginForm(context) {
    return Form(
      key: loginformKey,
      child: Container(
        margin: const EdgeInsets.all(16),
        height: mediaQuery(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FadeAndScaleTransition(
              index: 2,
              child: SizedBox(
                width: defaultWidth,
                // padding: const EdgeInsets.symmetric(
                //   horizontal: defaultPadding * 2,
                // ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back!",
                      style: textTheme(context).headlineSmall!.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      "Please enter your credentials.",
                      style: textTheme(context).bodySmall!.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: defaultPadding * 2,
            ),
            FadeAndScaleTransition(
              child: ConnectTextFormField(
                width: defaultWidth,
                controller: phoneController,
                keyboardType: TextInputType.number,
                contentPadding: const EdgeInsets.all(16),
                hintText: "Enter phone number here",
                maxLength: 10,
                validator: (value) {
                  if (value!.isEmpty && value.length != 10) {
                    return "Enter Correct Phone Number";
                  } else {
                    return null;
                  }
                },
                fillColor: themeData(context).scaffoldBackgroundColor,
                // prefixWidget: Container(
                //   decoration: const BoxDecoration(
                //     border: Border(
                //       right: BorderSide(
                //         width: 2,
                //       ),
                //     ),
                //   ),
                //   // margin: const EdgeInsets.only(
                //   //   right: defaultPadding,
                //   //   top: defaultPadding,
                //   //   bottom: defaultPadding,
                //   // ),
                //   // padding: const EdgeInsets.symmetric(
                //   //   horizontal: defaultPadding / 2,
                //   //   // vertical: defaultPadding / 2,
                //   // ),
                //   child: Text(
                //     "+91",
                //     style: textTheme(context).titleMedium!.copyWith(
                //           fontWeight: FontWeight.w600,
                //         ),
                //   ),
                // ),
                // enabled: false,
              ),
            ),
            const SizedBox(
              height: defaultPadding,
            ),
            FadeAndScaleTransition(
              child: SizedBox(
                width: defaultWidth,
                child: Stack(
                  children: [
                    ConnectTextFormField(
                      width: defaultWidth,
                      controller: passcodeController,
                      // title: "Passcode*",
                      obscureText: !showPasscode,
                      contentPadding: const EdgeInsets.all(16),
                      maxLines: 1,
                      hintText: "Enter Passcode here",
                      // enabled: false,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter Passcode";
                        } else {
                          return null;
                        }
                      },
                      fillColor: themeData(context).scaffoldBackgroundColor,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CDSButton(
                        padding: const EdgeInsets.all(12),
                        mainAxisSize: MainAxisSize.min,
                        iconSize: 16,
                        leftIcon: showPasscode
                            ? CupertinoIcons.eye_fill
                            : CupertinoIcons.eye_slash,
                        bgColor: Colors.transparent,
                        textColor: blueColor,
                        onTap: () {
                          showPasscode = !showPasscode;
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FadeAndScaleTransition(
              child: Container(
                width: defaultWidth,
                alignment: Alignment.centerRight,
                child: FittedBox(
                  child: CDSButton(
                    // width: defaultWidth,
                    alignment: Alignment.centerRight,
                    borderRadius: BorderRadius.zero,
                    mainAxisSize: MainAxisSize.min,
                    label: "Forgot Password?",
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                    textColor: primaryColor,
                    bgColor: themeData(context).colorScheme.background,
                    decoration: TextDecoration.underline,
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => const OnboardingScreen(
                      //       // initialPage: 3,
                      //       isForgetPassword: true,
                      //     ),
                      //   ),
                      // );
                    },
                  ),
                ),
              ),
            ),
            FadeAndScaleTransition(
              child: CDSButton(
                width: defaultWidth,
                padding: const EdgeInsets.all(12),
                bgColor: textTheme(context).titleSmall!.color,
                isLoading: isLoading,
                label: "Login",
                onTap: () {
                  if (loginformKey.currentState!.validate()) {
                    login("$countryCode${phoneController.text}",
                        passcodeController.text);
                  }
                },
              ),
            ),
            FadeAndScaleTransition(
              child: Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "Don't have an account?  ",
                    style: textTheme(context).bodySmall!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  CDSButton(
                    label: "Sign Up",
                    // width: 60,
                    mainAxisSize: MainAxisSize.min,
                    textColor: primaryColor,
                    // textStyle: textTheme(context).titleSmall!.copyWith(
                    //       fontWeight: FontWeight.w500,
                    //       decoration: TextDecoration.underline,
                    //     ),
                    decoration: TextDecoration.underline,
                    borderRadius: BorderRadius.zero,
                    padding: const EdgeInsets.symmetric(
                      vertical: defaultPadding / 2,
                    ),
                    bgColor: themeData(context).colorScheme.background,
                    onTap: () {
                      pageController!.jumpToPage(1);
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
