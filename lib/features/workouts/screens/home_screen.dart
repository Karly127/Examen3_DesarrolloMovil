import 'package:fit_track_pro/core/storage/local_storage_service.dart';
import 'package:fit_track_pro/features/auth/screens/login_screen.dart';
import 'package:fit_track_pro/features/workouts/models/workout_model.dart';
import 'package:fit_track_pro/features/workouts/services/local_workout_service.dart';
import 'package:flutter/material.dart';
import 'package:fit_track_pro/examen3/weight_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalWorkoutService _dbService = LocalWorkoutService();

  List<WorkoutModel> _workouts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() {
      _isLoading = true;
    });

    final workouts = await _dbService.getWorkouts();

    if (!mounted) return;
    setState(() {
      _workouts = workouts;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    final storage = LocalStorageService();
    await storage.deleteToken();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  // Modal para crear (workout == null) o editar (workout != null)
  void _showWorkoutDialog({WorkoutModel? workout}) {
    final isEditing = workout != null;

    final titleController = TextEditingController(text: workout?.title);
    final categoryController = TextEditingController(text: workout?.category);
    final durationController = TextEditingController(
      text: workout?.durationMinutes.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEditing ? 'Editar Rutina' : 'Nueva Rutina'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              TextField(
                controller: durationController,
                decoration:
                    const InputDecoration(labelText: 'Duración (minutos)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final category = categoryController.text.trim();
              final durationMinutes =
                  int.tryParse(durationController.text) ?? 0;

              if (title.isEmpty || category.isEmpty || durationMinutes <= 0) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Por favor, complete todos los campos correctamente.',
                    ),
                  ),
                );
                return;
              }

              final updated = WorkoutModel(
                localId: workout?.localId, // null al crear, id al editar
                title: title,
                category: category,
                durationMinutes: durationMinutes,
              );

              if (isEditing) {
                await _dbService.updateWorkout(updated);
              } else {
                await _dbService.insertWorkout(updated);
              }

              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);

              await _loadWorkouts();

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isEditing ? 'Rutina actualizada' : 'Rutina creada',
                  ),
                ),
              );
            },
            child: Text(isEditing ? 'Actualizar' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  // Modal con los detalles de la rutina
  void _showWorkoutDetails(WorkoutModel workout) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.fitness_center)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    workout.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _detailRow(Icons.category, 'Categoría', workout.category),
            _detailRow(
              Icons.timer,
              'Duración',
              '${workout.durationMinutes} minutos',
            ),
            _detailRow(Icons.tag, 'ID', '${workout.localId}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _showWorkoutDialog(workout: workout);
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _deleteWorkout(int id, String title) async {
    await _dbService.deleteWorkout(id);

    if (mounted) {
      _loadWorkouts();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rutina "$title" eliminada')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis entrenamientos'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        actions: [
          //boton del examen uwu
          IconButton(
            icon: const Icon(Icons.monitor_weight),
            tooltip: 'Registro de Peso',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WeightScreen(),
                ),
              );
            },
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content: const Text(
                    '¿Estás seguro de que deseas cerrar sesión?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext); // primero cierra el diálogo
                        _logout();
                      },
                      child: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workouts.isEmpty
              ? const Center(child: Text('No hay entrenamientos guardados.'))
              : ListView.builder(
                  itemCount: _workouts.length,
                  itemBuilder: (context, index) {
                    final workout = _workouts[index];
                    return ListTile(
                      onTap: () => _showWorkoutDetails(workout),
                      leading:
                          const CircleAvatar(child: Icon(Icons.fitness_center)),
                      title: Text(
                        workout.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${workout.category} - ${workout.durationMinutes} min',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () =>
                                _showWorkoutDialog(workout: workout),
                            icon: const Icon(Icons.edit, color: Colors.blue),
                          ),
                          IconButton(
                            onPressed: () => _deleteWorkout(
                              workout.localId!,
                              workout.title,
                            ),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWorkoutDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}