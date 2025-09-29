import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:myapp/services/auth_service.dart';

import 'auth_service_test.mocks.dart';

// Add this line to avoid the need to create a new file for the mock
// @GenerateMocks([GoogleSignInAccount, GoogleSignInAuthentication])

@GenerateMocks([
  FirebaseAuth,
  GoogleSignIn,
  User,
  UserCredential,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
])
void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockGoogleSignIn mockGoogleSignIn;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockGoogleSignIn = MockGoogleSignIn();
      authService = AuthService(
        auth: mockFirebaseAuth,
        googleSignIn: mockGoogleSignIn,
      );
    });

    test('signInWithEmailAndPassword calls correct method', () async {
      final mockUserCredential = MockUserCredential();
      when(
        mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@test.com',
          password: 'password',
        ),
      ).thenAnswer((_) async => mockUserCredential);

      await authService.signInWithEmailAndPassword('test@test.com', 'password');

      verify(
        mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@test.com',
          password: 'password',
        ),
      );
    });

    test('createUserWithEmailAndPassword calls correct method', () async {
      final mockUserCredential = MockUserCredential();
      when(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@test.com',
          password: 'password',
        ),
      ).thenAnswer((_) async => mockUserCredential);

      await authService.createUserWithEmailAndPassword(
        'test@test.com',
        'password',
      );

      verify(
        mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@test.com',
          password: 'password',
        ),
      );
    });

    test('signInWithGoogle calls correct methods', () async {
      final mockGoogleSignInAccount = MockGoogleSignInAccount();
      final mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
      final mockUserCredential = MockUserCredential();

      when(
        mockGoogleSignIn.signIn(),
      ).thenAnswer((_) async => mockGoogleSignInAccount);
      when(
        mockGoogleSignInAccount.authentication,
      ).thenAnswer((_) async => mockGoogleSignInAuthentication);
      when(
        mockGoogleSignInAuthentication.accessToken,
      ).thenReturn('accessToken');
      when(mockGoogleSignInAuthentication.idToken).thenReturn('idToken');
      when(
        mockFirebaseAuth.signInWithCredential(any),
      ).thenAnswer((_) async => mockUserCredential);

      await authService.signInWithGoogle();

      verify(mockGoogleSignIn.signIn());
      // Verifying a getter directly is not standard. The behavior is implicitly
      // tested by verifying the methods that depend on its result.
      verify(
        mockFirebaseAuth.signInWithCredential(argThat(isA<AuthCredential>())),
      );
    });
  });
}
