import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes/app_router.dart';
import 'services/session_service.dart';
import 'themes/app_theme.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final haySesion = await SessionService.haySesionActiva();
  final initialRoute = args.isNotEmpty
      ? args.first
      : (haySesion ? AppRoutes.dashboard : AppRoutes.login);

  runApp(InventarioApp(initialRoute: initialRoute));
}

class InventarioApp extends StatelessWidget {
  final String initialRoute;

  const InventarioApp({super.key, this.initialRoute = AppRoutes.login});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'InventarioApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: createRouter(initialLocation: initialRoute),
    );
  }
}
