class AppConstants {
  // App info
  static const String appName = 'WoodLine';
  static const String appTagline = 'Craft. Connect. Customize.';
  
  // Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String messagesCollection = 'messages';
  
  // User roles
  static const String roleCustomer = 'customer';
  static const String roleWoodworker = 'woodworker';
  
  // Order statuses
  static const String orderStatusPending = 'pending';
  static const String orderStatusConfirmed = 'confirmed';
  static const String orderStatusInProgress = 'in_progress';
  static const String orderStatusCompleted = 'completed';
  static const String orderStatusCancelled = 'cancelled';
  
  // Asset paths
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImage = 'assets/images/placeholder.jpg';
  
  // Animation durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
  
  // Default values
  static const int defaultPageSize = 10;
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  
  // Validation messages
  static const String emailRequired = 'Please enter your email';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordRequired = 'Please enter your password';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String nameRequired = 'Please enter your name';
  
  // Error messages
  static const String somethingWentWrong = 'Something went wrong. Please try again.';
  static const String noInternetConnection = 'No internet connection';
  
  // Success messages
  static const String loginSuccessful = 'Login successful';
  static const String registrationSuccessful = 'Registration successful';
  static const String profileUpdated = 'Profile updated successfully';
}
