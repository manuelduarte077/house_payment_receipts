import 'package:comprobantes/features/receipt/view_receipts_screen.dart';
import 'package:comprobantes/features/receipt/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'widgets/custom_textfield.dart';
import 'widgets/date_time_picker_form.dart';

class CreateReceiptScreen extends StatefulWidget {
  const CreateReceiptScreen({super.key});

  @override
  _CreateReceiptScreenState createState() => _CreateReceiptScreenState();
}

class _CreateReceiptScreenState extends State<CreateReceiptScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de los campos
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _conceptController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _beneficiaryController = TextEditingController();

  // Campos del dropdown
  String? _receiptType;
  String? _status;
  String? _paymentMethod;

  // Fecha y hora
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  /// Método para guardar el comprobante en Firestore y Firebase Storage
  Future<void> _saveReceipt() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Crear un nuevo documento en Firestore y obtener su ID
        DocumentReference receiptRef =
            await FirebaseFirestore.instance.collection('payments').add({
          'client': _nameController.text,
          'amount': _amountController.text,
          'concept': _conceptController.text,
          'reference': _referenceController.text,
          'bank': _bankController.text,
          'account': _accountController.text,
          'beneficiary': _beneficiaryController.text,
          'type': _receiptType,
          'status': _status,
          'paymentMethod': _paymentMethod,
          'date': _selectedDate ?? DateTime.now(),
          'time':
              _selectedTime?.format(context) ?? TimeOfDay.now().format(context),
        });

        String receiptId = receiptRef.id;

        // Generar y subir el comprobante en PDF a Firebase Storage
        await _generateAndUploadReceipt(
          receiptId,
          _nameController.text,
          _amountController.text,
          _conceptController.text,
        );

        // Actualizar el documento de Firestore con la URL del PDF generado
        String pdfUrl = await _getDownloadUrl(receiptId);
        await receiptRef.update({'receiptUrl': pdfUrl});

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            content: Text(
              'Comprobante guardado exitosamente.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );

        // Limpiar el formulario
        _formKey.currentState!.reset();
        setState(() {
          _receiptType = null;
          _status = null;
          _paymentMethod = null;
          _selectedDate = null;
          _selectedTime = null;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewReceiptsScreen(receiptId: receiptId),
          ),
        );
      } catch (e) {
        // Manejo de errores
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            content: Text(
              'Error al guardar el comprobante: $e',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );
      }
    }
  }

  // Método para generar el comprobante en PDF y subirlo a Firebase Storage
  Future<void> _generateAndUploadReceipt(
      String paymentId, String client, String amount, String concept) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text(
            'Comprobante de pago\nCliente: $client\nMonto: $amount\nConcepto: $concept',
            style: const pw.TextStyle(fontSize: 18),
          ),
        ),
      ),
    );

    final bytes = await pdf.save();
    final storageRef =
        FirebaseStorage.instance.ref().child('receipts/$paymentId.pdf');

    await storageRef.putData(bytes);
  }

  // Método para obtener la URL de descarga del PDF subido a Firebase Storage
  Future<String> _getDownloadUrl(String paymentId) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('receipts/$paymentId.pdf');

    return await storageRef.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear Comprobante',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ///
              const SizedBox(height: 10),
              CustomDropdown(
                labelText: 'Tipo de Comprobante',
                value: _receiptType,
                items: const ['Factura', 'Recibo', 'Otro'],
                onChanged: (value) {
                  setState(() {
                    _receiptType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona un tipo';
                  }
                  return null;
                },
              ),

              ///
              const SizedBox(height: 10),
              CustomTextField(
                controller: _nameController,
                labelText: 'Nombre',
                keyboardType: TextInputType.name,
                icon: Icons.person,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa un nombre' : null,
              ),

              ///
              const SizedBox(height: 10),
              CustomTextField(
                controller: _amountController,
                labelText: 'Monto',
                keyboardType: TextInputType.number,
                icon: Icons.monetization_on,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa un monto' : null,
              ),

              ///
              const SizedBox(height: 10),
              CustomTextField(
                controller: _conceptController,
                labelText: 'Concepto',
                keyboardType: TextInputType.name,
                icon: Icons.description,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa un concepto' : null,
              ),

              ///
              const SizedBox(height: 10),
              CustomTextField(
                controller: _referenceController,
                labelText: 'Referencia',
                keyboardType: TextInputType.name,
                icon: Icons.person,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa una referencia' : null,
              ),

              ///
              const SizedBox(height: 10),
              CustomDropdown(
                labelText: 'Estado',
                value: _status,
                items: const ['Pendiente', 'Pagado', 'Cancelado'],
                onChanged: (value) {
                  setState(() {
                    _status = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona un estado';
                  }
                  return null;
                },
              ),

              ///
              const SizedBox(height: 10),
              CustomDropdown(
                labelText: 'Método de Pago',
                value: _paymentMethod,
                items: const ['Efectivo', 'Transferencia', 'Tarjeta'],
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona un método de pago';
                  }
                  return null;
                },
              ),

              ///
              const SizedBox(height: 10),
              CustomTextField(
                controller: _bankController,
                labelText: 'Banco',
                keyboardType: TextInputType.name,
                icon: Icons.home_work_outlined,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa un banco' : null,
              ),

              ///
              const SizedBox(height: 10),
              CustomTextField(
                controller: _accountController,
                labelText: 'Cuenta',
                keyboardType: TextInputType.number,
                icon: Icons.account_balance,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa una cuenta' : null,
              ),

              ///
              const SizedBox(height: 10),
              CustomTextField(
                controller: _beneficiaryController,
                labelText: 'Beneficiario',
                keyboardType: TextInputType.name,
                icon: Icons.person,
                validator: (value) =>
                    value!.isEmpty ? 'Por favor ingresa un beneficiario' : null,
              ),

              ///
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: DateTimePickerForm(),
              ),

              /// Botón para subir imagen del comprobante
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save_outlined),
                onPressed: _saveReceipt,
                label: const Text('Guardar Comprobante'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
