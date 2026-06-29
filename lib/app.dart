import 'package:flutter/material.dart';
import 'package:albrain_core/albrain_core.dart';

import 'screens/client_shell.dart';

class ClientApp extends StatelessWidget {
  const ClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Albrain Books — Client',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AuthGate(child: ClientShell()),
    );
  }
}
