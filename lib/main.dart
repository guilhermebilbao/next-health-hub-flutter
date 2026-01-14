import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app_routes.dart';
import 'auth/data/auth_service.dart';
import 'dashboard/presentation/viewmodel/dashboard_viewmodel.dart';
import 'services/notification_service.dart';

// Handler para mensagens em background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Notificação recebida em background: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase
  await Firebase.initializeApp();

  // Configura o handler de background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inicializa o serviço de notificações locais
  final notificationService = NotificationService();
  await notificationService.init();

  // Configura o handler para mensagens em foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Mensagem recebida em foreground: ${message.notification?.title}');

    // Se a mensagem tiver uma notificação, exibe usando local_notifications
    if (message.notification != null) {
      notificationService.showNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );
    }
  });

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
      routes: AppRoutes.routes,
      initialRoute: initialRoute,
    );
  }
}
