import 'package:flutter/material.dart';
import 'package:stylerstack/providers/address_provider.dart';
import 'package:stylerstack/providers/auth_provider.dart';
import 'package:stylerstack/providers/cart_provider.dart';
import 'package:stylerstack/providers/favorite_provider.dart';
import 'package:stylerstack/providers/product_provider.dart';
import 'package:stylerstack/providers/theme_provider.dart';
import 'package:stylerstack/providers/payment_provider.dart';
import 'package:stylerstack/services/connectivity_service.dart';
import 'package:stylerstack/router/app_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stylerstack/widgets/connectivity_banner.dart';

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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        Provider<ConnectivityService>(
          create: (_) => ConnectivityService(),
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: Consumer2<ThemeProvider, ConnectivityService>(
        builder: (context, themeController, connectivityService, child) {
          final router = createRouter(context.read<AuthProvider>());

          return StreamBuilder<bool>(
            stream: connectivityService.internetStatusStream,
            builder: (context, snapshot) {
              final hasInternet = snapshot.data ?? true;

              return MaterialApp.router(
                routerConfig: router,
                debugShowCheckedModeBanner: false,
                themeMode: themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                darkTheme: ThemeData.dark(),
                theme: ThemeData.light(),
                builder: (context, child) {
                  return Stack(
                    children: [
                      child!,
                      ConnectivityBanner(hasInternet: hasInternet), // reusable banner
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
