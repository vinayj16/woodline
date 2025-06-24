import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:woodline/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Create user object based on Firebase User
  UserModel? _userFromFirebaseUser(User? user) {
    return user != null ? UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? 'New User',
      photoUrl: user.photoURL,
      role: 'customer', // Default role, can be updated later
      createdAt: DateTime.now(),
    ) : null;
  }

  // Auth change user stream
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // Sign in with email & password
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      rethrow;
    }
  }

  // Register with email & password
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    required String role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user display name
      await result.user?.updateDisplayName(displayName);
      await result.user?.reload();

      // Create user in Firestore
      final user = UserModel(
        id: result.user!.uid,
        email: email,
        displayName: displayName,
        role: role,
        createdAt: DateTime.now(),
      );

      // TODO: Save user to Firestore
      // await FirebaseFirestore.instance.collection('users').doc(user.id).set(user.toMap());

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      
      // Check if user is new
      if (result.additionalUserInfo!.isNewUser) {
        // Create user in Firestore
        final user = UserModel(
          id: result.user!.uid,
          email: result.user!.email ?? '',
          displayName: result.user!.displayName ?? 'New User',
          photoUrl: result.user!.photoURL,
          role: 'customer', // Default role
          createdAt: DateTime.now(),
        );
        
        // TODO: Save user to Firestore
        // await FirebaseFirestore.instance.collection('users').doc(user.id).set(user.toMap());
      }

      
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Get current user
  UserModel? getCurrentUser() {
    final user = _auth.currentUser;
    return _userFromFirebaseUser(user);
  }
}
