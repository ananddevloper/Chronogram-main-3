// import 'package:chronogram/screens/login/login_provider/login_otp_provider.dart';
// import 'package:chronogram/screens/login/login_provider/login_screen_provider.dart';
// import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_email_otp_provider.dart';
// import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_email_provider.dart';
// import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_mobile_otp_provider.dart';
// import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_screen_provider.dart';
// import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_screen.dart';
// import 'package:chronogram/screens/splash_screen/splash_screen.dart';
// import 'package:chronogram/service/connectivity_service.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await ConnectivityService().initialize();
//   runApp(const MyApp());
// }

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => SignUpScreenProvider()),
//         ChangeNotifierProvider(create: (_) => SignUpEmailProvider()),
//         ChangeNotifierProvider(create: (_) => SignUpMobileOtpProvider()),
//         ChangeNotifierProvider(create: (_) => SignUpEmailOtpProvider()),
//         ChangeNotifierProvider(create: (_) => LoginMobileScreenProvider()),
//         ChangeNotifierProvider(create: (_) => LoginMobileOtpScreenProvider()),
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         title: 'Chronogram',
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(
//             seedColor: Colors.orange,
//             brightness: Brightness.dark,
//           ),
//           useMaterial3: true,
//         ),
//         navigatorKey: navigatorKey,
//         home: const SplashScreen(),
//         builder: (context, child) {
//           return ConnectivityOverlay(child: child!);
//         },
//       ),
//     );
//   }
// }

// class ConnectivityOverlay extends StatefulWidget {
//   final Widget child;
//   const ConnectivityOverlay({super.key, required this.child});

//   @override
//   State<ConnectivityOverlay> createState() => _ConnectivityOverlayState();
// }

// class _ConnectivityOverlayState extends State<ConnectivityOverlay> {
//   bool _dialogShowing = false;
//   bool _wasOffline = false;
  
//   @override
//   void initState() {
//     super.initState();
//     ConnectivityService().connectivityStream.listen((isOnline) {
//       if (!isOnline) {
//         if (!_dialogShowing) {
//           _wasOffline = true;
//           _showNoInternetDialog();
//         }
//       } else if (_wasOffline) {
//         _wasOffline = false;
//         _dismissDialog();
//         _showBackOnlineSnackbar();
//         _resetAuthFlow();
//       }
//     });
//   }

//   void _dismissDialog() {
//     if (_dialogShowing) {
//       final context = navigatorKey.currentContext;
//       if (context != null) {
//         Navigator.of(context, rootNavigator: true).pop();
//       }
//       _dialogShowing = false;
//     }
//   }

//   void _showNoInternetDialog() {
//     final context = navigatorKey.currentContext;
//     if (context == null) return;

//     // Determine if we are in auth flow (not on HomeScreen)
//     bool isHome = false;
//     navigatorKey.currentState?.popUntil((route) {
//       if (route.settings.name == "HomeScreen") {
//         isHome = true;
//       }
//       return true; // Don't actually pop
//     });

//     if (isHome) return;

//     _dialogShowing = true;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       useRootNavigator: true,
//       builder: (context) => PopScope(
//         canPop: false,
//         child: AlertDialog(
//           backgroundColor: const Color(0xff1C1C1E),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: const Row(
//             children: [
//               Icon(Icons.wifi_off, color: Colors.orange),
//               SizedBox(width: 10),
//               Text("No Internet", style: TextStyle(color: Colors.white)),
//             ],
//           ),
//           content: const Text(
//             "Please check your internet connection to continue with registration.",
//             style: TextStyle(color: Colors.white70),
//           ),
//         ),
//       ),
//     ).then((_) => _dialogShowing = false);
//   }

//   void _showBackOnlineSnackbar() {
//     final context = navigatorKey.currentContext;
//     if (context == null) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text("Back Online! Restarting process..."),
//         backgroundColor: Colors.orange,
//         duration: Duration(seconds: 3),
//       ),
//     );
//   }

//   void _resetAuthFlow() {
//     // Check if we are on HomeScreen before resetting
//     bool isHome = false;
//     navigatorKey.currentState?.popUntil((route) {
//       if (route.settings.name == "HomeScreen") {
//         isHome = true;
//       }
//       return true;
//     });

//     if (isHome) return;

//     // Reset to start of registration/login if internet was lost during auth
//     navigatorKey.currentState?.pushAndRemoveUntil(
//       MaterialPageRoute(
//         builder: (_) => const SplashScreen(),
//         settings: const RouteSettings(name: "SplashScreen"),
//       ),
//       (route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }


import 'package:chronogram/screens/home_screen/photo_screen.dart';
import 'package:chronogram/screens/login/login_provider/login_otp_provider.dart';
import 'package:chronogram/screens/login/login_provider/login_screen_provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_email_otp_provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_email_provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_mobile_otp_provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:chronogram/screens/sign_up/sign_up_screen/sign_up_screen.dart';
import 'package:chronogram/screens/splash_screen/splash_screen.dart';
import 'package:chronogram/service/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConnectivityService().initialize();
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignUpScreenProvider()),
        ChangeNotifierProvider(create: (_) => SignUpEmailProvider()),
        ChangeNotifierProvider(create: (_) => SignUpMobileOtpProvider()),
        ChangeNotifierProvider(create: (_) => SignUpEmailOtpProvider()),
        ChangeNotifierProvider(create: (_) => LoginMobileScreenProvider()),
        ChangeNotifierProvider(create: (_) => LoginMobileOtpScreenProvider()),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chronogram',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.dark),
          useMaterial3: true,
        ),
        navigatorKey: navigatorKey,
        home: const SplashScreen(),
        builder: (context, child) {
          return ConnectivityOverlay(child: child!);
        },
      ),

    );
  }
}

class ConnectivityOverlay extends StatefulWidget {
  final Widget child;
  const ConnectivityOverlay({super.key, required this.child});
  @override
  State<ConnectivityOverlay> createState() => _ConnectivityOverlayState();
}

class _ConnectivityOverlayState extends State<ConnectivityOverlay> {
  bool _wasOffline = false;
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    ConnectivityService().connectivityStream.listen((isOnline) {
      if (!isOnline) {
        if (!_dialogShowing) {
          _wasOffline = true;
          _showNoInternetDialog();
        }
      } else if (_wasOffline) {
        _wasOffline = false;
        _dismissDialog();
        _showBackOnlineSnackbar();
        _resetAuthFlow();
      }
    });
  }

  void _dismissDialog() {
    if (_dialogShowing) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      _dialogShowing = false;
    }
  }

  void _showNoInternetDialog() {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Determine if we are in auth flow (not on HomeScreen)
    bool isHome = false;
    navigatorKey.currentState?.popUntil((route) {
      if (route.settings.name == "HomeScreen") {
        isHome = true;
      }
      return true; // Don't actually pop
    });

    if (isHome) return;

    _dialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: const Color(0xff1C1C1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.orange),
              SizedBox(width: 10),
              Text("No Internet", style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            "Please check your internet connection to continue with registration.",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ),
    ).then((_) => _dialogShowing = false);
  }

  void _showBackOnlineSnackbar() {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Back Online! Restarting process..."),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _resetAuthFlow() {
     // Check if we are on HomeScreen before resetting
    bool isHome = false;
    navigatorKey.currentState?.popUntil((route) {
      if (route.settings.name == "HomeScreen") {
        isHome = true;
      }
      return true;
    });

    if (isHome) return;

    // Reset to start of registration/login if internet was lost during auth
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const SplashScreen(),
      //  PhotoScreen(),
        settings: const RouteSettings(name: "SplashScreen"),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
  
}