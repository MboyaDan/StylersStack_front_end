import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stylerstack/models/cart_item.dart';
import 'package:stylerstack/models/favorite_item.dart';
import 'package:stylerstack/providers/address_provider.dart';
import 'package:stylerstack/providers/auth_provider.dart';
import 'package:stylerstack/providers/cart_provider.dart';
import 'package:stylerstack/providers/favorite_provider.dart';
import 'package:stylerstack/providers/product_provider.dart';
import 'package:stylerstack/providers/theme_provider.dart';
import 'package:stylerstack/providers/payment_provider.dart';
import 'package:stylerstack/services/connectivity_service.dart';
import 'package:stylerstack/services/api_service.dart';
import 'package:stylerstack/router/app_router.dart';
import 'package:stylerstack/widgets/connectivity_banner.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
  Hive.registerAdapter(CartItemModelAdapter());
  Hive.registerAdapter(FavoriteItemAdapter());
  await Hive.openBox<CartItemModel>('cartBox');
  await Hive.openBox<FavoriteItem>('favoriteBox');
  await Firebase.initializeApp();
  runApp(const StyleStackApp());
}

class StyleStackApp extends StatelessWidget {
  const StyleStackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),

        ProxyProvider<AuthProvider, GoRouter>(
          update: (_, authProvider, __) => createRouter(authProvider),
        ),

        ProxyProvider2<AuthProvider, GoRouter, ApiService>(
          update: (_, authProvider, router, __) => ApiService(authProvider, router),
        ),

        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        //product provider
        ChangeNotifierProxyProvider<ApiService, ProductProvider>(
          create: (_) => ProductProvider(),
          update: (_, apiService, provider) {
            provider!.updateApiService(apiService);
            return provider;
    },
    ),

        ChangeNotifierProvider(create: (_) => FavoriteProvider()),

        ProxyProvider<ApiService, PaymentProvider>(
          update: (_, apiService, __) => PaymentProvider(apiService),
        ),

        ///cart provider
        ChangeNotifierProxyProvider<ApiService, CartProvider>(
          create: (context) => CartProvider(context.read<ApiService>()),
          update: (context, apiService, previous) =>
              CartProvider(apiService),
        ),

        ProxyProvider<ApiService, AddressProvider>(
          update: (_, apiService, __) => AddressProvider(apiService),
        ),

        Provider<ConnectivityService>(
          create: (_) => ConnectivityService(),
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: Consumer2<AuthProvider, GoRouter>(
        builder: (context, authProvider, router, _) {
          return Consumer<ConnectivityService>(
            builder: (context, connectivityService, _) {
              return StreamBuilder<bool>(
                stream: connectivityService.internetStatusStream,
                builder: (context, snapshot) {
                  final hasInternet = snapshot.data ?? true;

                  return MaterialApp.router(
                    routerConfig: router,
                    debugShowCheckedModeBanner: false,
                    themeMode: context.watch<ThemeProvider>().isDarkMode
                        ? ThemeMode.dark
                        : ThemeMode.light,
                    darkTheme: ThemeData.dark(),
                    theme: ThemeData.light(),
                    builder: (context, child) {
                      _listenForLogout(context, authProvider);

                      return Stack(
                        children: [
                          child!,
                          ConnectivityBanner(hasInternet: hasInternet),
                        ],
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _listenForLogout(BuildContext context, AuthProvider authProvider) {
    authProvider.addListener(() {
      if (authProvider.isLoggedOut) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have been logged out.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}
