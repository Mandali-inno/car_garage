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

  Future<void> _handleSignIn(Future<User?> signInFuture, BuildContext context) async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    try {
      final User? user = await signInFuture;
      if (user != null && mounted) {
        final models.User? appUser = await firestoreService.getUser(user.uid);
        if (appUser != null) {
          if (appUser.role == 'admin') {
            context.go('/admin');
          } else {
            context.go('/user');
          }
        } else {
          // Handle case where user exists in Auth but not in Firestore
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User data not found. Please register.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _handleSignIn(
                      authService.signInWithEmailAndPassword(
                        _emailController.text,
                        _passwordController.text,
                      ),
                      context,
                    );
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _handleSignIn(authService.signInWithGoogle(), context),
                child: const Text('Sign in with Google'),
              ),
              const SizedBox(height: 10),
              if (Platform.isIOS) ...[
                ElevatedButton(
                  onPressed: () => _handleSignIn(authService.signInWithApple(), context),
                  child: const Text('Sign in with Apple'),
                ),
                const SizedBox(height: 10),
              ],
              TextButton(
                onPressed: () {
                  context.go('/registration');
                },
                child: const Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
