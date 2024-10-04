import 'package:comprobantes/app/app.dart';
import 'package:comprobantes/firebase_options.dart';
import 'package:comprobantes/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const PaymentApp(),
    ),
  );
}
