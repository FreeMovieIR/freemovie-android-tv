import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/repo/home_repo.dart';
import 'screens/home/bloc/home_bloc.dart';
import 'screens/home/home_screen.dart';
import 'utils/web/http_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set preferred orientations for TV
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialize API clients and load API keys
  await initializeApiClients();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(homeRepository: homeRepository),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'فیری مووی',
        locale: const Locale('fa', 'IR'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fa', 'IR')],
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF020618),
          primaryColor: const Color(0xFF4A148C),
          fontFamily: 'Vazir',
          // focusColor: Colors.transparent,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFBEDBFF),
            secondary: Color(0xFF1447E6),
            surface: Color(0xFF0F172B),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white, fontFamily: 'Vazir'),
            bodyMedium: TextStyle(color: Colors.white, fontFamily: 'Vazir'),
          ),
          brightness: Brightness.dark,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
