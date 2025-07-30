import 'package:expense_tracker_app_fl/router/app_router.dart';
import 'package:expense_tracker_app_fl/utils/RequestMethod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

void main() {

  setupDioInterceptors(); // ✅ Must be called before any privateDio usage

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
      theme: ThemeData.light(),
    );
  }
}
