import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes/app_router.dart';
import 'themes/app_theme.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final initialRoute = args.isNotEmpty ? args.first : AppRoutes.dashboard;
  runApp(InventarioApp(initialRoute: initialRoute));
}

class InventarioApp extends StatelessWidget {
  final String initialRoute;

  const InventarioApp({super.key, this.initialRoute = AppRoutes.dashboard});

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
