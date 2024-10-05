import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comprobantes/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import '../create_receipt_screen.dart';
import '../view_receipts_screen.dart';
import 'custom_drawer.dart';

import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context);
    final role = authService.role;

    return Scaffold(
      drawer: role == 'admin' ? const CustomDrawer() : null,
      appBar: AppBar(
        title: Text('Home - ${role == 'admin' ? 'Admin' : 'User'}'),
        actions: [
          if (role == 'viewer')
            IconButton(
              onPressed: () {
                authService.signOut();
              },
              icon: const Icon(Icons.logout),
            )
          else
            IconButton(
              icon: const Icon(Icons.brightness_4),
              onPressed: () {
                themeProvider.toggleTheme(
                  themeProvider.themeMode == ThemeMode.light,
                );
              },
            ),
        ],
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: role == 'admin'
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF6C63FF),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateReceiptScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.add_circle_outline,
                color: Colors.white,
                size: 28,
              ),
              tooltip: 'Crear recibo',
              label: Text(
                'Crear recibo',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: StreamBuilder(
        stream: firestore.collection('payments').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return _buildListReceipts(snapshot: snapshot);
              } else {
                return _buildGridReceipts(snapshot: snapshot);
              }
            },
          );
        },
      ),
    );
  }

  // Widget que muestra los recibos en forma de lista (para pantallas móviles)
  Widget _buildListReceipts({required AsyncSnapshot<QuerySnapshot> snapshot}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        final payment = snapshot.data!.docs[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8, top: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.receipt_outlined),
            title: Text('Cantidad ${payment['amount']} USD'),
            subtitle: Text('Cliente: ${payment['client']}'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showReceiptDetails(context);
            },
          ),
        );
      },
    );
  }

  // Widget que muestra los recibos en forma de Grid (para pantallas más grandes, web/tablets)
  Widget _buildGridReceipts({AsyncSnapshot<QuerySnapshot>? snapshot}) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 3,
      ),
      itemCount: snapshot?.data?.docs.length,
      itemBuilder: (context, index) {
        final payment = snapshot?.data?.docs[index];

        return Card(
          elevation: 2.0,
          child: InkWell(
            onTap: () {
              _showReceiptDetails(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.receipt, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    'Cantidad: ${payment?['amount']} USD',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Cliente: ${payment?['client']}',
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Fecha: ${formatter.format(payment?['date'].toDate())}',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Mostrar detalles del recibo usando un modal
  void _showReceiptDetails(BuildContext context) {
    showModalBottomSheet(
      enableDrag: false,
      isDismissible: false,
      context: context,
      scrollControlDisabledMaxHeightRatio: 0.9,
      builder: (context) {
        return const ViewReceiptsScreen();
      },
    );
  }
}
