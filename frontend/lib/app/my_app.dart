import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../views/pages/my_aliments_groups_page.dart';
import '../views/pages/add_diet_page.dart';
import '/providers/security_provider.dart';
import '/providers/theme_mode_provider.dart';
import '/views/pages/login_page.dart';
import '/views/pages/signup_page.dart';
import '/views/pages/my_home_page.dart';


class MyApp extends ConsumerWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final securityNotifier = ref.read(securityProvider.notifier);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Diet App',
      themeMode: themeMode,
      theme: _light,
      darkTheme: _dark,

      initialRoute: securityNotifier.isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => MyHomePage(),
        '/signup': (context) => SignupPage(),
        '/my_aliment_groups': (context) => MyAlimentGroupsPage(),
        '/add_diet': (context) => AddDietPage(),
      },
    );
  }
}

final _light = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: Colors.white,
    elevation: 0,
  ),
);

final _dark = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
  bottomAppBarTheme: const BottomAppBarTheme(
    color: Colors.black, 
    elevation: 0,
  ),
);