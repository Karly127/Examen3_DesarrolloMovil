import 'package:flutter/material.dart';
import 'weight_model.dart';
import 'add_weight_screen.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  List<WeightModel> registros = [];

  Future<void> _abrirFormularioAgregar() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWeightScreen()),
    );

    if (resultado != null && resultado is WeightModel) {
      setState(() {
        registros.add(resultado);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitTrack Pro'),
      ),
      body: registros.isEmpty
          ? const Center(
              child: Text(
                'No hay registros',
                style: TextStyle(fontSize: 18.0),
              ),
            )
          : ListView.builder(
              itemCount: registros.length,
              itemBuilder: (context, index) {
                final registro = registros[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.monitor_weight, color: Colors.blue),
                    title: Text(
                      '${registro.pesoKilos} kg',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                    subtitle: Text('Fecha: ${registro.fecha}'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormularioAgregar,
        child: const Icon(Icons.add),
      ),
    );
  }
}