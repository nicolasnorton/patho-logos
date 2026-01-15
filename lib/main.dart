import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patho_logos/view_model.dart';
import 'package:patho_logos/ui/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppViewModel()),
      ],
      child: MaterialApp(
        title: 'Patho-Logos',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00E5FF),
            brightness: Brightness.dark,
            surface: const Color(0xFF0F172A),
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
