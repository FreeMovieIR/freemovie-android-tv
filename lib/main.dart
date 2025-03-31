import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:freemovie_android_tv/data/repo/home_repo.dart';

import 'screens/home/bloc/home_bloc.dart';
import 'screens/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set preferred orientations for TV
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
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
        supportedLocales: const [
          Locale('fa', 'IR'), // Persian
        ],
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF0F111D),
          primaryColor: const Color(0xFF4A148C),
          fontFamily: 'Vazir',
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4A148C),
            secondary: Color(0xFF6A1B9A),
            surface: Color(0xFF0F111D),
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
