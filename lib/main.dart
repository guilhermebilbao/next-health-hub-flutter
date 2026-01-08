import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart'; // Adicionado
import 'package:firebase_messaging/firebase_messaging.dart'; // Adicionado
import 'app_routes.dart';
import 'auth/data/auth_service.dart';
import 'dashboard/presentation/viewmodel/dashboard_viewmodel.dart';
import 'services/notification_service.dart';

// Handler para mensagens em background
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Notificação recebida em background: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Inicializa o Firebase antes de qualquer outra coisa
  await Firebase.initializeApp();

  //Configura o handler de background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inicializa o serviço de notificações locais
  await NotificationService().init();

  await dotenv.load(fileName: './.env');

  final authService = AuthService();
  final bool loggedIn = await authService.isTokenValid();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardViewModel()..initDashboard(),
        ),
      ],
      child: MyApp(
        initialRoute: loggedIn ? AppRoutes.home : AppRoutes.onboarding,
      ),
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
