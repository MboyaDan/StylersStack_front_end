import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:stylerstack/models/cart_item.dart';
import 'package:stylerstack/models/favorite_item.dart';

import 'package:stylerstack/providers/auth_provider.dart';
import 'package:stylerstack/providers/address_provider.dart';
import 'package:stylerstack/providers/cart_provider.dart';
import 'package:stylerstack/providers/favorite_provider.dart';
import 'package:stylerstack/providers/location_provider.dart';
import 'package:stylerstack/providers/notification_provider.dart';
import 'package:stylerstack/providers/order_provider.dart';
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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

import 'package:stylerstack/widgets/fcm_intializer.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDir.path);

  Hive.registerAdapter(CartItemModelAdapter());
  Hive.registerAdapter(FavoriteItemAdapter());

  await Hive.openBox<CartItemModel>('cartBox');
  await Hive.openBox<FavoriteItem>('favoriteBox');

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );



  runApp(const StyleStackApp());
}

class StyleStackApp extends StatelessWidget {
  const StyleStackApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        /// Authentication
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        /// Router
        ProxyProvider<AuthProvider, GoRouter>(
          update: (_, auth, __) => createRouter(auth),
        ),

        /// Theme
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        /// API Service
        ProxyProvider2<AuthProvider, GoRouter, ApiService>(
          update: (_, auth, router, __) => ApiService(auth, router),
        ),

        /// Category Service
        ProxyProvider<ApiService, CategoryService>(
          update: (_, api, __) => CategoryService(api),
        ),

        /// Product Provider
        ChangeNotifierProxyProvider2<ApiService, CategoryService, ProductProvider>(
          create: (context) => ProductProvider(context.read<CategoryService>()),
          update: (_, api, catService, previous) =>
          (previous ?? ProductProvider(catService))..updateApiService(api),
        ),

        /// Location
        ChangeNotifierProvider(create: (_) => LocationProvider()..loadLocation()),

        /// Favorite Service
        ProxyProvider<ApiService, FavoriteService>(
          update: (_, api, __) => FavoriteService(api),
        ),

        /// Hive Favorite Box
        Provider<Box<FavoriteItem>>(
          create: (_) => Hive.box<FavoriteItem>('favoriteBox'),
        ),

        /// Favorite Provider
        ChangeNotifierProxyProvider2<FavoriteService, Box<FavoriteItem>, FavoriteProvider>(
          create: (context) => FavoriteProvider(
            Provider.of<FavoriteService>(context, listen: false),
            Provider.of<Box<FavoriteItem>>(context, listen: false),
          ),
          update: (_, service, box, previous) =>
          (previous ?? FavoriteProvider(service, box))..updateService(service),
        ),

        /// Payment Provider
        ChangeNotifierProxyProvider<ApiService, PaymentProvider>(
          create: (context) => PaymentProvider(context.read<ApiService>()),
          update: (_, api, previous) => previous!..updateApi(api),
        ),

        /// Cart Provider
        ChangeNotifierProxyProvider<ApiService, CartProvider>(
          create: (context) => CartProvider(context.read<ApiService>()),
          update: (_, api, __) => CartProvider(api),
        ),
//
        /// Address Provider
        ChangeNotifierProxyProvider2<AuthProvider, ApiService, AddressProvider>(
          create: (context) {
            final api = context.read<ApiService>();
            final provider = AddressProvider(api);
            final uid = context.read<AuthProvider>().user?.uid;
            if (uid != null) provider.fetchAddress(uid);
            return provider;
          },
          update: (context, auth, api, previous) {
            final provider = previous ?? AddressProvider(api);
            final uid = auth.user?.uid;
            if (uid != null) provider.fetchAddress(uid);
            return provider;
          },
        ),

        /// order Provider
        ChangeNotifierProxyProvider<ApiService, OrderProvider>(
          create: (context) => OrderProvider(context.read<ApiService>()),
          update: (_, api, previous) => previous!..updateApi(api),
        ),
    /// Notification Provider
    ChangeNotifierProxyProvider<ApiService, NotificationProvider>(
      create: (context) {
        final api = context.read<ApiService>();
        final provider = NotificationProvider(api, globalNavigatorKey);
        Future.microtask(()=>provider.initFCM());
        return provider;
        },
      update: (_, api, previous) {
        final provider = previous ?? NotificationProvider(api, globalNavigatorKey);
        provider.initFCM();
        return provider;
    },
    ),

        /// Connectivity Service
        Provider<ConnectivityService>(
          create: (_) => ConnectivityService(),
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: Consumer2<AuthProvider, GoRouter>(
        builder: (context, auth, router, _) {
          return Consumer<ConnectivityService>(
            builder: (context, conn, _) => StreamBuilder<bool>(
              stream: conn.internetStatusStream,
              builder: (context, snapshot) {
                final hasInternet = snapshot.data ?? true;

                return FCMInitializer(
                  child:MaterialApp.router(
                  routerConfig: router,
                  debugShowCheckedModeBanner: false,
                  themeMode: context.watch<ThemeProvider>().isDarkMode
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  darkTheme: ThemeData.dark(),
                  theme: ThemeData.light(),
                  builder: (context, child) => AuthFeedbackListener(
                    child: Stack(
                      children: [
                        child!,
                        ConnectivityBanner(hasInternet: hasInternet),
                      ],
                    ),
                  ),
                ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
