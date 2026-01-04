import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'app_routes.dart';
import 'auth/data/auth_service.dart';
import 'dashboard/presentation/viewmodel/dashboard_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: './.env');

  final authService = AuthService();
  final bool loggedIn = await authService.isTokenValid();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()..initDashboard()),
      ],
      child: MyApp(initialRoute: loggedIn ? AppRoutes.home : AppRoutes.onboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // Define as rotas centralizadas
      routes: AppRoutes.routes,
      // Define a rota inicial
      initialRoute: initialRoute,
    );
  }
}
