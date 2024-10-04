import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprobantes/features/history/payment_history.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;

class PaymentHomePage extends StatefulWidget {
  const PaymentHomePage({super.key});

  @override
  _PaymentHomePageState createState() => _PaymentHomePageState();
}

class _PaymentHomePageState extends State<PaymentHomePage> {
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addPayment() async {
    String client = _clientController.text;
    String amount = _amountController.text;

    if (client.isEmpty || amount.isEmpty) return;

    DocumentReference paymentRef = await _firestore.collection('payments').add({
      'client': client,
      'amount': amount,
      'date': DateTime.now(),
    });

    // Generar comprobante y subirlo a Firebase Storage
    await _generateAndUploadReceipt(paymentRef.id, client, amount);

    _clientController.clear();
    _amountController.clear();
  }

  Future<void> _generateAndUploadReceipt(
      String paymentId, String client, String amount) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child:
              pw.Text('Comprobante de pago\nCliente: $client\nMonto: $amount'),
        ),
      ),
    );

    final bytes = await pdf.save();
    final storageRef =
        FirebaseStorage.instance.ref().child('receipts/$paymentId.pdf');
    await storageRef.putData(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Pago'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 40,
                child: Icon(
                  Icons.account_balance,
                  size: 40,
                  color: Colors.indigo,
                ),
              ),
            ),
            ListTile(
              title: const Text('Historial de Pagos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentHistory(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _clientController,
              decoration: const InputDecoration(labelText: 'Cliente'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Monto'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addPayment,
              child: const Text('Registrar Pago'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PaymentHistory(),
            ),
          ],
        ),
      ),
    );
  }
}
