import 'package:comprobantes/features/payment/payment_home.dart';
import 'package:flutter/material.dart';

class PaymentApp extends StatelessWidget {
  const PaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comprobantes de Pago',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const PaymentHomePage(),
    );
  }
}
