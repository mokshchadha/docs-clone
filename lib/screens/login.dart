import 'package:docs/repository/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({Key? key}) : super(key: key);

  void signInWithGoogle(WidgetRef ref) {
    ref.read(authRepositoryProvider).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //provider ref allows us to interact with provider , widget ref allows us to interact with widgets
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          signInWithGoogle(ref);
        },
        icon: const Icon(Icons.login_sharp),
        label: const Text('Sign in with google'),
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(150, 50),
            primary: Colors.white,
            onPrimary: Colors.black),
      ),
    );
  }
}
