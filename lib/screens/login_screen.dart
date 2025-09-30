import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models.dart' as models;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  Future<void> _handleSignIn(Future<User?> signInFuture) async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final User? user = await signInFuture;
      if (user == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorText = 'Sign-in failed. Please try again.';
          });
        }
        return;
      }

      if (mounted) {
        final firestoreService =
            Provider.of<FirestoreService>(context, listen: false);
        final models.User? appUser = await firestoreService.getUser(user.uid);

        if (appUser == null) {
          setState(() {
            _isLoading = false;
            _errorText = 'User data not found. Please register.';
          });
          return;
        }

        if (mounted) {
          if (appUser.role == 'admin') {
            context.go('/admin');
          } else {
            context.go('/user');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorText = 'Sign-in failed: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Text('Welcome Back!', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _handleSignIn(
                          authService.signInWithEmailAndPassword(
                            _emailController.text,
                            _passwordController.text,
                          ),
                        );
                      }
                    },
                    child: const Text('Login'),
                  ),
                if (_errorText != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('or'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => _handleSignIn(authService.signInWithGoogle()),
                  icon: Image.asset('assets/images/google_logo.png', height: 24.0),
                  label: const Text('Sign in with Google'),
                ),
                const SizedBox(height: 10),
                if (Platform.isIOS) ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _handleSignIn(authService.signInWithApple()),
                    icon: Image.asset('assets/images/apple_logo.png', height: 24.0, color: Colors.white),
                    label: const Text('Sign in with Apple'),
                  ),
                ],
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    context.go('/registration');
                  },
                  child: const Text("Don't have an account? Register"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
