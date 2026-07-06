import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mmac/ui/views/pages/main_layout.dart';
import 'package:mmac/core/constants/app_fonts.dart';

void main()async {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: AppFonts.primaryFont,
      ),
      home: const MainLayout(),
      //home:ResidencyLayout()
    );
  }
}
