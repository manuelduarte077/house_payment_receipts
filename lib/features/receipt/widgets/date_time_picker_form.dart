import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePickerForm extends StatefulWidget {
  const DateTimePickerForm({super.key});

  @override
  _DateTimePickerFormState createState() => _DateTimePickerFormState();
}

class _DateTimePickerFormState extends State<DateTimePickerForm> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Método para seleccionar la fecha
  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Método para seleccionar la hora
  Future<void> _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Campo para seleccionar fecha
        Expanded(
          child: GestureDetector(
            onTap: _selectDate,
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: _selectedDate == null
                      ? 'Fecha'
                      : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  hintStyle: const TextStyle(
                    fontSize: 16,
                  ),
                  suffixIcon: const Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFF6C63FF),
                    size: 28,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => _selectedDate == null
                    ? 'Por favor selecciona una fecha'
                    : null,
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Campo para seleccionar hora
        Expanded(
          child: GestureDetector(
            onTap: _selectTime,
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: _selectedTime == null
                      ? 'Hora'
                      : _selectedTime!.format(context),
                  labelStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  hintStyle: const TextStyle(
                    fontSize: 16,
                  ),
                  suffixIcon: const Icon(
                    Icons.access_time_outlined,
                    color: Color(0xFF6C63FF),
                    size: 28,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) => _selectedTime == null
                    ? 'Por favor selecciona una hora'
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
