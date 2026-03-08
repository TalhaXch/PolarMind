import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'game/services/services.dart';
import 'game/controllers/controllers.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  final levelService = await LevelService.create();

  runApp(PolarMindApp(levelService: levelService));
}

class PolarMindApp extends StatelessWidget {
  final LevelService levelService;

  const PolarMindApp({super.key, required this.levelService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameStateController(levelService),
      child: MaterialApp(
        title: 'POLARMIND',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeData,
        home: const SplashScreen(),
      ),
    );
  }
}
