import 'package:comprobantes/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PaymentApp());
}

class PaymentApp extends StatelessWidget {
  const PaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comprobantes de Pago',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PaymentHomePage(),
    );
  }
}

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

class PaymentHistory extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PaymentHistory({super.key});

  Future<void> _downloadReceipt(String paymentId) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('receipts/$paymentId.pdf');
    final String downloadUrl = await storageRef.getDownloadURL();

    // Descargar el archivo PDF usando la URL
    final http.Response response = await http.get(Uri.parse(downloadUrl));
    final pdfBytes = response.bodyBytes;

    // Utilizar el paquete `printing` para permitir la descarga o impresión
    await Printing.layoutPdf(onLayout: (format) => pdfBytes);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection('payments').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var payment = snapshot.data!.docs[index];
            return ListTile(
              title: Text('Cliente: ${payment['client']}'),
              subtitle: Text('Monto: ${payment['amount']}'),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _downloadReceipt(payment.id),
              ),
            );
          },
        );
      },
    );
  }
}
