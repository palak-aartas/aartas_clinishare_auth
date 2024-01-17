import 'package:clinisquare_auth/authentication.dart';
import 'package:clinisquare_auth/custom_logo_image.dart';
import 'package:clinisquare_auth/firebase_options.dart';
import 'package:clinisquare_auth/temp.dart';
import 'package:connect_design_system/components/misc/colors.dart';
import 'package:connect_design_system/components/misc/responsive.dart';
import 'package:connect_design_system/components/misc/themes.dart';
import 'package:connect_design_system/connect_design_system.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: const ConnectApiProvider(child: Theming()),
    );
  }
}

class Theming extends StatelessWidget {
  const Theming({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var isDarkTheme = Provider.of<ThemeProvider>(context).isDarkTheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      theme: isDarkTheme ? darkThemeData(context) : lightThemeData(context),
      title: "Aartas CliniSquare",
      home: const MyHomePage(),
      builder: (context, child) {
        return child!;
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, this.initialPage, this.isForgetPassword});
  static const String route = "/";
  final int? initialPage;
  final bool? isForgetPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeData(context).colorScheme.background,
      body: Stack(
        children: [
          Row(
            children: [
              const Expanded(
                child: AuthenticationScreen(
                  // initialPage: initialPage != null ? initialPage! : 0,
                  isForgetpassword: false,
                ),
              ),
              AnimatedContainer(
                margin: isMobile(context)
                    ? EdgeInsets.zero
                    : EdgeInsets.fromLTRB(
                        0,
                        mediaQuery(context).padding.top + 16,
                        defaultPadding,
                        mediaQuery(context).padding.bottom + 16,
                      ),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(defaultPadding),
                ),
                curve: Curves.fastEaseInToSlowEaseOut,
                duration: duration * 3,
                width:
                    isMobile(context) ? 0 : mediaQuery(context).size.width / 2,
                child: isMobile(context)
                    ? const SizedBox()
                    : const OnboardingCarouselSlider(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingCarouselSlider extends StatelessWidget {
  const OnboardingCarouselSlider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: f7Color,
      padding: const EdgeInsets.symmetric(vertical: 100),
      child: CustomLogoImage(
        imgUrl: "$imgUrl/LoginImage.png",
        size: mediaQuery(context).size.width / 2,
        fit: BoxFit.contain,
      ),
    );
  }
}
