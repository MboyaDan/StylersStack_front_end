import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

import 'package:stylerstack/models/cart_item.dart';
import 'package:stylerstack/models/favorite_item.dart';

import 'package:stylerstack/providers/address_provider.dart';
import 'package:stylerstack/providers/auth_provider.dart';
import 'package:stylerstack/providers/cart_provider.dart';
import 'package:stylerstack/providers/favorite_provider.dart';
import 'package:stylerstack/providers/location_provider.dart';
import 'package:stylerstack/providers/product_provider.dart';
import 'package:stylerstack/providers/theme_provider.dart';
import 'package:stylerstack/providers/payment_provider.dart';

import 'package:stylerstack/services/category_service.dart';
import 'package:stylerstack/services/connectivity_service.dart';
import 'package:stylerstack/services/api_service.dart';
import 'package:stylerstack/services/favorite_service.dart';

import 'package:stylerstack/router/app_router.dart';
import 'package:stylerstack/widgets/auth_feedback_listener.dart';
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
        /// --- Auth & Router ---
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ProxyProvider<AuthProvider, GoRouter>(
          update: (_, auth, __) => createRouter(auth),
        ),

        /// --- ApiService ---
        ProxyProvider2<AuthProvider, GoRouter, ApiService>(
          update: (_, auth, router, __) => ApiService(auth, router),
        ),

        /// --- Theme ---
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        /// --- Category ---
        ProxyProvider<ApiService, CategoryService>(
          update: (_, api, __) => CategoryService(api),
        ),

        /// --- Product Provider ---
        ChangeNotifierProxyProvider2<ApiService, CategoryService, ProductProvider>(
          create: (context) {
            final catService = context.read<CategoryService>();
            return ProductProvider(catService);
          },
          update: (_, api, catService, previous) {
            final provider = previous ?? ProductProvider(catService);
            provider.updateApiService(api);
            return provider;
          },
        ),

        ///location provider

        ChangeNotifierProvider(
          create: (_) => LocationProvider()..loadLocation(),
        ),



        /// --- FavoriteService (depends on ApiService) ---
        ProxyProvider<ApiService, FavoriteService>(
          update: (_, api, __) => FavoriteService(api),
        ),

        Provider<Box<FavoriteItem>>(
          create: (_) => Hive.box<FavoriteItem>('favoriteBox'),
        ),


        /// --- FavoriteProvider (depends on FavoriteService + Hive box) ---
        ChangeNotifierProxyProvider2<FavoriteService, Box<FavoriteItem>, FavoriteProvider>(
          create: (context) {
            final favoriteService = Provider.of<FavoriteService>(context, listen: false);
            final box = Provider.of<Box<FavoriteItem>>(context, listen: false);
            return FavoriteProvider(favoriteService, box);
          },
          update: (context, favoriteService, box, previous) {
            final provider = previous ?? FavoriteProvider(favoriteService, box);
            provider.updateService(favoriteService);
            return provider;
          },
        ),




        /// --- Payment ---
        /// --- Payment ---
        ChangeNotifierProxyProvider<ApiService, PaymentProvider>(
          create: (context) => PaymentProvider(context.read<ApiService>()),
          update: (_, api, previous) => previous!..updateApi(api),
        ),


        /// --- Cart ---
        ChangeNotifierProxyProvider<ApiService, CartProvider>(
          create: (context) => CartProvider(context.read<ApiService>()),
          update: (_, api, __) => CartProvider(api),
        ),

        /// --- Address ---
        ChangeNotifierProxyProvider2<AuthProvider, ApiService, AddressProvider>(
          create: (context) {
            final auth = context.read<AuthProvider>();
            final api = context.read<ApiService>();
            final provider = AddressProvider(api);

            final uid = auth.user?.uid;
            if (uid != null) {
              provider.fetchAddress(uid);
            }

            return provider;
          },
          update: (context, auth, api, previous) {
            final provider = previous ?? AddressProvider(api);
            final uid = auth.user?.uid;

            if (uid != null) {
              provider.fetchAddress(uid);
            }

            return provider;
          },
        ),


        /// --- Connectivity ---
        Provider<ConnectivityService>(
          create: (_) => ConnectivityService(),
          dispose: (_, svc) => svc.dispose(),
        ),
      ],
      child: Consumer2<AuthProvider, GoRouter>(
        builder: (context, auth, router, _) {
          return Consumer<ConnectivityService>(
            builder: (context, conn, _) => StreamBuilder<bool>(
              stream: conn.internetStatusStream,
              builder: (context, snap) {
                final hasInternet = snap.data ?? true;
                return MaterialApp.router(
                  routerConfig: router,
                  debugShowCheckedModeBanner: false,
                  themeMode: context.watch<ThemeProvider>().isDarkMode
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  darkTheme: ThemeData.dark(),
                  theme: ThemeData.light(),
                  builder: (context, child) {
                    return AuthFeedbackListener(
                    child: Stack(
                      children: [
                        child!,
                        ConnectivityBanner(
                          hasInternet: hasInternet,
                    ),
                    ],
                    ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

}
