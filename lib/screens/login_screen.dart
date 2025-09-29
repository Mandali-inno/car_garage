import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

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
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await authService.signInWithEmailAndPassword(
                      _emailController.text,
                      _passwordController.text,
                    );
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await authService.signInWithGoogle();
                },
                child: const Text('Sign in with Google'),
              ),
              const SizedBox(height: 10),
              if (Platform.isIOS) ...[
                ElevatedButton(
                  onPressed: () async {
                    await authService.signInWithApple();
                  },
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
