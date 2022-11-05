import 'package:docs/models/error_model.dart';
import 'package:docs/repository/auth.dart';
import 'package:docs/router.dart';
import 'package:docs/screens/home_screen.dart';
import 'package:docs/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Docs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Docs'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  ErrorModel? errorModel;

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  void getUserData() async {
    errorModel = await ref.read(authRepositoryProvider).getUserData();
    if (errorModel != null && errorModel!.data != null) {
      ref.read(userProvider.notifier).update((state) => errorModel!.data);
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    //Scaffold(
    //   body: user != null ? const HomeScreen() : const LoginScreen());
    return MaterialApp.router(
        title: 'Docs',
        debugShowCheckedModeBanner: false,
        routeInformationParser: const RoutemasterParser(),
        routerDelegate: RoutemasterDelegate(
          routesBuilder: (context) {
            final user = ref.watch(userProvider);
            if (user != null && user.token.isNotEmpty) {
              return loggedInRoute;
            } else {
              return loggedOutRoute;
            }
          },
        ));
  }
}
