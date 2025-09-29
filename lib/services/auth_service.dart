import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models.dart' as models;
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirestoreService _firestoreService;

  AuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn, FirestoreService? firestoreService})
    : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn(),
      _firestoreService = firestoreService ?? FirestoreService();

  Stream<User?> get user => _auth.authStateChanges();

  Future<User?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        oAuthCredential,
      );
      
      if (userCredential.user != null) {
        models.User? appUser = await _firestoreService.getUser(userCredential.user!.uid);
        if (appUser == null) {
          final newUser = models.User(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            role: 'user',
          );
          await _firestoreService.addUser(newUser);
        }
      }

      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User cancelled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user != null) {
        models.User? appUser = await _firestoreService.getUser(userCredential.user!.uid);
        if (appUser == null) {
          final newUser = models.User(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            role: 'user',
          );
          await _firestoreService.addUser(newUser);
        }
      }

      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
    String role,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      
      final newUser = models.User(
        uid: userCredential.user!.uid,
        email: email,
        role: role,
      );
      await _firestoreService.addUser(newUser);

      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
