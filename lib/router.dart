import 'package:docs/screens/document_screen.dart';
import 'package:docs/screens/home_screen.dart';
import 'package:docs/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: HomeScreen()),
  '/document/:id': (route) =>
      MaterialPage(child: DocumentScreen(route.pathParameters['id'] ?? '')),
});
