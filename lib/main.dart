import 'package:coin_clicker/widgets/common/main_button copy.dart';
import 'package:coin_clicker/widgets/effects/sunburst_painter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coin_clicker/providers/game_provider.dart';
import 'package:coin_clicker/pages/start_page.dart';
import 'package:coin_clicker/pages/main_game_page.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CoinClickerApp());
}

class CoinClickerApp extends StatelessWidget {
  const CoinClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
      ],
      child: const MaterialApp(
        title: 'Coin Clicker',
        debugShowCheckedModeBanner: false,
        home: MainGamePage(),
        // home: Scaffold(
        //   backgroundColor: Colors.white,
        //   body: Center(
        //     child: NativeButton(
        //       width: 256,
        //       height: 72,
        //       onPressed: () => print('Button Pressed!'),
        //       child: const Text('Hello'),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}