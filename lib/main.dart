import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    ChangeNotifierProvider(
      create: (context) => themeProvider,
      child: const TravelFlowApp(),
    ),
  );
}

class TravelFlowApp extends StatelessWidget {
  const TravelFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'TravelFlow',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme.copyWith(
            textTheme: GoogleFonts.notoSansScTextTheme(),
          ),
          darkTheme: themeProvider.darkTheme.copyWith(
            textTheme: GoogleFonts.notoSansScTextTheme(
              Theme.of(context).brightness == Brightness.dark
                  ? Typography.whiteCupertino
                  : Typography.blackCupertino,
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
