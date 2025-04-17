import 'package:flutter/material.dart';
import 'package:stylerstack/providers/auth_provider.dart';
import 'package:stylerstack/providers/theme_provider.dart';
import 'package:stylerstack/router/app_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const StyleStackApp());
}

class StyleStackApp extends StatelessWidget {
  const StyleStackApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create:(_)=> AuthProvider()),
        ChangeNotifierProvider(create: (_)=>ThemeProvider())
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeController, child) {
          ///creating GoRouter instance
          final router = createRouter(Provider.of<AuthProvider>(context));
          return MaterialApp.router(
            routerConfig: router,
            debugShowCheckedModeBanner: false,
            themeMode: themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            darkTheme: ThemeData.dark(),
            theme: ThemeData.light(),
          );
        },
      ),
      );
  }
}

