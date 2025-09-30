import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/user/user_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/user/garage_list_screen.dart';
import 'screens/user/garage_details_screen.dart';
import 'screens/user/book_service_screen.dart';
import 'screens/user/user_bookings_screen.dart';
import 'screens/user/emergency_service_screen.dart';
import 'screens/admin/manage_garages_screen.dart';
import 'screens/admin/add_garage_screen.dart';
import 'screens/admin/emergency_requests_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'models.dart' as models;

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
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
      ],
      child: Builder(
        builder: (context) {
          final authService = Provider.of<AuthService>(context, listen: false);
          final firestoreService = Provider.of<FirestoreService>(context, listen: false);

          final router = GoRouter(
            refreshListenable: GoRouterRefreshStream(authService.user),
            routes: <RouteBase>[
              GoRoute(
                path: '/',
                builder: (BuildContext context, GoRouterState state) {
                  return const LoginScreen(); // Default to login screen
                },
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
              ShellRoute(
                builder: (context, state, child) {
                  return MainLayout(child: child);
                },
                routes: [
                  GoRoute(
                    path: '/user',
                    builder: (BuildContext context, GoRouterState state) {
                      return const UserDashboardScreen();
                    },
                  ),
                  GoRoute(
                    path: '/garage-list',
                    builder: (BuildContext context, GoRouterState state) {
                      return const GarageListScreen();
                    },
                  ),
                  GoRoute(
                    path: '/my-bookings',
                    builder: (BuildContext context, GoRouterState state) {
                      return const UserBookingsScreen();
                    },
                  ),
                  GoRoute(
                    path: '/emergency-service',
                    builder: (BuildContext context, GoRouterState state) {
                      return EmergencyServiceScreen();
                    },
                  ),
                  GoRoute(
                    path: '/admin',
                    builder: (BuildContext context, GoRouterState state) {
                      return const AdminDashboardScreen();
                    },
                  ),
                  GoRoute(
                    path: '/manage-garages',
                    builder: (BuildContext context, GoRouterState state) {
                      return ManageGaragesScreen();
                    },
                  ),
                  GoRoute(
                    path: '/emergency-requests',
                    builder: (BuildContext context, GoRouterState state) {
                      return EmergencyRequestsScreen();
                    },
                  ),
                ],
              ),
              GoRoute(
                path: '/garage-details',
                builder: (BuildContext context, GoRouterState state) {
                  final models.Garage garage = state.extra as models.Garage;
                  return GarageDetailsScreen(garage: garage);
                },
              ),
              GoRoute(
                path: '/book-service',
                builder: (BuildContext context, GoRouterState state) {
                  final Map<String, dynamic> args = state.extra as Map<String, dynamic>;
                  return BookServiceScreen(garage: args['garage'], service: args['service']);
                },
              ),
              GoRoute(
                path: '/add-garage',
                builder: (BuildContext context, GoRouterState state) {
                  return const AddGarageScreen();
                },
              ),
            ],
            redirect: (BuildContext context, GoRouterState state) async {
              final bool loggedIn = FirebaseAuth.instance.currentUser != null;
              final bool loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/registration';

              if (!loggedIn) {
                return loggingIn ? null : '/login';
              }

              if (loggingIn) {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final models.User? appUser = await firestoreService.getUser(user.uid);
                  if (appUser != null) {
                    if (appUser.role == 'admin') {
                      return '/admin';
                    } else {
                      return '/user';
                    }
                  }
                }
                return '/'; // Should not happen
              }

              return null;
            },
          );

          return MaterialApp.router(
            routerConfig: router,
            title: 'Car Service Finder',
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: context.watch<ThemeProvider>().themeMode,
          );
        },
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isUser = user != null; // Simplified check, you might want more specific role checks

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: isUser
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                switch (index) {
                  case 0:
                    context.go('/user');
                    break;
                  case 1:
                    context.go('/garage-list');
                    break;
                  case 2:
                    context.go('/my-bookings');
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store),
                  label: 'Garages',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Bookings',
                ),
              ],
            )
          : null,
      drawer: isUser
          ? null
          : Drawer(
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text('Admin Menu'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text('Dashboard'),
                    onTap: () => context.go('/admin'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.store),
                    title: const Text('Manage Garages'),
                    onTap: () => context.go('/manage-garages'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.warning),
                    title: const Text('Emergency Requests'),
                    onTap: () => context.go('/emergency-requests'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                      context.go('/login');
                    },
                  ),
                ],
              ),
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
