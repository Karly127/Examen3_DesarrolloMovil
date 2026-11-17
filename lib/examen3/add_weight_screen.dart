import 'package:flutter/material.dart';
import 'weight_model.dart';

class AddWeightScreen extends StatefulWidget {
  const AddWeightScreen({super.key});

  @override
  State<AddWeightScreen> createState() => _AddWeightScreenState();
}

class _AddWeightScreenState extends State<AddWeightScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();

  @override
  void dispose() {
    _fechaController.dispose();
    _pesoController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final nuevoRegistro = WeightModel(
        fecha: _fechaController.text.trim(),
        pesoKilos: double.parse(_pesoController.text.trim()),
      );

      Navigator.pop(context, nuevoRegistro);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Peso'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fechaController,
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  hintText: 'Ej. 17 de Noviembre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La fecha no puede estar vacía';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              TextFormField(
                controller: _pesoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  hintText: 'Ej. 75.5',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El peso no puede estar vacío';
                  }
                  final peso = double.tryParse(value.trim());
                  if (peso == null || peso <= 0) {
                    return 'El peso debe ser un número mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),

              ElevatedButton(
                onPressed: _guardar,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}