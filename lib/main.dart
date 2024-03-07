import 'package:flutter/material.dart';
import 'package:lab9_642021157/pages/loginpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Watcharapong',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            background: Color.fromARGB(255, 163, 236, 145),
          ),
          useMaterial3: true,
        ),
        home: const LoginPage());
  }
}
