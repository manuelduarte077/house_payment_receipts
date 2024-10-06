import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprobantes/features/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewReceiptsScreen extends StatelessWidget {
  final String receiptId;
  const ViewReceiptsScreen({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final role = authService.role;

    return ClipPath(
      clipper: const ShapeBorderClipper(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle del Comprobante'),
          backgroundColor: const Color(0xFF6C63FF),
        ),
        body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('payments')
              .doc(receiptId)
              .get(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData ||
                snapshot.data == null ||
                !snapshot.data!.exists) {
              return const Center(child: Text('Comprobante no encontrado.'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Comprobante de pago',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),

                      // Detalles del comprobante
                      _buildDetailRow(
                          'Monto:', '\$ ${data['amount']}', Icons.attach_money),
                      _buildDetailRow('Fecha:', '2025-10-15', Icons.date_range),
                      _buildDetailRow('Hora:', data['time'], Icons.access_time),
                      _buildDetailRow(
                          'Concepto:', data['concept'], Icons.description),
                      _buildDetailRow('Referencia:', data['reference'],
                          Icons.confirmation_number),
                      _buildDetailRow(
                          'Estado:', data['status'], Icons.check_circle),
                      _buildDetailRow('Método de pago:', data['paymentMethod'],
                          Icons.payment),
                      _buildDetailRow(
                          'Banco:', data['bank'], Icons.account_balance),
                      _buildDetailRow(
                          'Cuenta:', data['account'], Icons.credit_card),
                      _buildDetailRow(
                          'Beneficiario:', data['beneficiary'], Icons.person),

                      const SizedBox(height: 20),

                      // Botón para descargar comprobante
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          onPressed: () {
                            // Lógica para descargar comprobante
                          },
                          label: const Text('Descargar Comprobante'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Botón para imprimir comprobante, solo visible si el usuario es admin
                      if (role == 'admin')
                        Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.print),
                            onPressed: () {
                              // Lógica para imprimir comprobante

                              // Mostrar mensaje de éxito
                            },
                            label: const Text('Imprimir Comprobante'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Método para construir filas de detalles del comprobante
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
