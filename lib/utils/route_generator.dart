import 'package:flutter/material.dart';
import 'package:woodline/screens/splash/splash_screen.dart';
import 'package:woodline/screens/onboarding/onboarding_screen.dart';
import 'package:woodline/screens/auth/login_screen.dart';
import 'package:woodline/screens/auth/register_screen.dart';
import 'package:woodline/screens/main/main_screen.dart';
import 'package:woodline/screens/products/product_detail_screen.dart';
import 'package:woodline/screens/products/add_edit_product_screen.dart';
import 'package:woodline/screens/orders/checkout_screen.dart';
import 'package:woodline/screens/orders/order_confirmation_screen.dart';
import 'package:woodline/screens/chat/chat_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case '/main':
        return MaterialPageRoute(builder: (_) => const MainScreen());
      
      case '/product-detail':
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: args),
          );
        }
        return _errorRoute();
      
      case '/add-product':
        return MaterialPageRoute(
          builder: (_) => const AddEditProductScreen(),
        );
      
      case '/edit-product':
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => AddEditProductScreen(
              product: args['product'],
            ),
          );
        }
        return _errorRoute();
      
      case '/checkout':
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => CheckoutScreen(
              items: args['items'],
              subtotal: args['subtotal'],
              shippingFee: args['shippingFee'],
              totalAmount: args['totalAmount'],
              sellerId: args['sellerId'],
            ),
          );
        }
        return _errorRoute();
      
      case '/order-confirmation':
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => OrderConfirmationScreen(
              orderId: args['orderId'],
              showSuccess: args['showSuccess'] ?? true,
            ),
          );
        }
        return _errorRoute();
      
      case '/chat':
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: args['chatId'],
              otherUserId: args['otherUserId'],
              otherUserName: args['otherUserName'],
              otherUserImageUrl: args['otherUserImageUrl'],
            ),
          );
        }
        return _errorRoute();
      
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(
          child: Text('Page not found'),
        ),
      ),
    );
  }
}