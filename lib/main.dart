import 'package:material_ui/material_ui.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/auth/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.restore();
  runApp(const SnrMobileApp());
}

class SnrMobileApp extends StatelessWidget {
  const SnrMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SNR 360',
      debugShowCheckedModeBanner: false,
      theme: buildSnr360Theme(),
      routerConfig: appRouter,
    );
  }
}
