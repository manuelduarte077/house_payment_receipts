import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Pagos'),
      ),
      body: StreamBuilder(
        stream: _firestore.collection('payments').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
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
      ),
    );
  }
}
