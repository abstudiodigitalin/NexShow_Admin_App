import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'screens/root_shell.dart';
import 'theme/app_theme.dart';

class NexShowAdminApp extends StatelessWidget {
  const NexShowAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const RootShell(),
    );
  }
}
