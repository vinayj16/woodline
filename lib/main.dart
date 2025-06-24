import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woodline/providers/user_provider.dart';
import 'package:woodline/providers/product_provider.dart';
import 'package:woodline/providers/order_provider.dart';
import 'package:woodline/screens/splash/splash_screen.dart';
import 'package:woodline/theme/app_theme.dart';
import 'package:woodline/utils/route_generator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'WoodLine',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}