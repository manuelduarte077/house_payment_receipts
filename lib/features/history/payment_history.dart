import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../receipt/view_receipts_screen.dart';

class PaymentHistory extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PaymentHistory({super.key});

  // Método para descargar y mostrar el PDF del recibo
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
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder(
        stream: _firestore.collection('payments').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No se encontraron pagos.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var payment = snapshot.data!.docs[index];
              final DateTime date = (payment['date'] as Timestamp).toDate();
              final String formattedDate =
                  DateFormat('yyyy-MM-dd').format(date);

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.receipt_long_outlined,
                            size: 40,
                            color: Color(0xFF6C63FF),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cliente: ${payment['client']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text('Monto: ${payment['amount']} USD'),
                                Text('Fecha: $formattedDate'),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.download,
                              color: Color(0xFF6C63FF),
                            ),
                            onPressed: () => _downloadReceipt(payment.id),
                            tooltip: 'Descargar comprobante',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Ver detalles'),
                          onPressed: () {
                            showModalBottomSheet(
                              enableDrag: false,
                              isDismissible: false,
                              context: context,
                              scrollControlDisabledMaxHeightRatio: 0.9,
                              builder: (context) {
                                return ViewReceiptsScreen(
                                  receiptId: payment.id,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
