import 'package:docs/models/error_model.dart';
import 'package:docs/repository/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  void signInWithGoogle(WidgetRef ref, BuildContext ctx) async {
    final sMessanger = ScaffoldMessenger.of(ctx);
    final navigator = Routemaster.of(ctx);

    /*Not a good idea to keep passing the context in an async app*/

    final ErrorModel errorModel =
        await ref.read(authRepositoryProvider).signInWithGoogle();
    if (errorModel.error == null) {
      ref.read(userProvider.notifier).update((state) => errorModel.data);
      navigator.replace('/');
    } else {
      sMessanger.showSnackBar(SnackBar(content: Text(errorModel.error ?? '')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //provider ref allows us to interact with provider , widget ref allows us to interact with widgets
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          signInWithGoogle(ref, context);
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
