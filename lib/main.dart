import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/models.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart';
import 'home_screen.dart';
import 'screens/garage_details_screen.dart';
import 'screens/garage_management_screen.dart';
import 'screens/garage_registration_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/registration_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  runApp(const MyApp());
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.deepPurple;

    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.oswald(
        fontSize: 57,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepPurple.shade300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );

    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: Builder(
        builder: (context) {
          final authService = Provider.of<AuthService>(context, listen: false);
          return StreamProvider<User?>(
            create: (_) => authService.user,
            initialData: null,
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                final router = GoRouter(
                  refreshListenable: GoRouterRefreshStream(authService.user),
                  routes: <RouteBase>[
                    GoRoute(
                      path: '/',
                      builder: (BuildContext context, GoRouterState state) {
                        return const GarageManagementScreen();
                      },
                      routes: <RouteBase>[
                        GoRoute(
                          path: 'garage/:id',
                          builder: (BuildContext context, GoRouterState state) {
                            final String garageId = state.pathParameters['id']!;
                            return GarageDetailsScreen(garageId: garageId);
                          },
                        ),
                        GoRoute(
                          path: 'profile',
                          builder: (BuildContext context, GoRouterState state) {
                            return const ProfileScreen();
                          },
                        ),
                        GoRoute(
                          path: 'register-garage',
                          builder: (BuildContext antext, GoRouterState state) {
                            return const GarageRegistrationScreen();
                          },
                        ),
                        GoRoute(
                          path: 'garage-management',
                          builder: (BuildContext context, GoRouterState state) {
                            return const GarageManagementScreen();
                          },
                        ),
                      ],
                    ),
                    GoRoute(
                      path: '/login',
                      builder: (BuildContext context, GoRouterState state) {
                        return const LoginScreen();
                      },
                    ),
                    GoRoute(
                      path: '/registration',
                      builder: (BuildContext context, GoRouterState state) {
                        return const RegistrationScreen();
                      },
                    ),
                  ],
                  redirect: (BuildContext context, GoRouterState state) {
                    final bool loggedIn =
                        FirebaseAuth.instance.currentUser != null;

                    final bool loggingIn =
                        state.matchedLocation == '/login' ||
                        state.matchedLocation == '/registration';

                    if (!loggedIn) {
                      return loggingIn ? null : '/login';
                    }

                    if (loggingIn) {
                      return '/';
                    }

                    return null;
                  },
                );

                return MaterialApp.router(
                  routerConfig: router,
                  title: 'Car Service Finder',
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: themeProvider.themeMode,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
