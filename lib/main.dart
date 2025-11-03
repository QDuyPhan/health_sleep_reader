import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:health_sleep_reader/controller/main_controller.dart';
import 'package:health_sleep_reader/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_sleep_reader/screens/main_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/services.dart'; // Thêm import này
import 'package:intl/intl.dart'; // <-- THÊM DÒNG NÀY
import 'package:intl/date_symbol_data_local.dart'; // <-- THÊM DÒNG NÀY

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);

  runApp(
    ChangeNotifierProvider(
      create: (_) => MainController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark, // Giao diện tối cho đẹp
      ),
      home: MainScreen(),
    );
  }
}
