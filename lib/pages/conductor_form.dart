import 'package:flutter/material.dart';
import '../models/conductor_model.dart';
import '../services/conductor_service.dart';

class ConductorForm extends StatefulWidget {
  const ConductorForm({super.key, this.conductor});

  final ConductorModel? conductor;

  @override
  State<ConductorForm> createState() => _ConductorFormState();
}

class _ConductorFormState extends State<ConductorForm> {
  final _nombreController = TextEditingController();
  final _licenciaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _fechaController = TextEditingController();
  
  bool _isSubmitting = false;
  String _error = '';
  bool get _isEditMode => widget.conductor != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _nombreController.text = widget.conductor!.nombreCompleto;
      _licenciaController.text = widget.conductor!.licenciaConducir;
      _telefonoController.text = widget.conductor!.telefono;
      _fechaController.text = widget.conductor!.fechaContratacion;
    } else {
      final now = DateTime.now();
      _fechaController.text = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _licenciaController.dispose();
    _telefonoController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  Future<void> _selectFecha() async {
    DateTime initial = DateTime.tryParse(_fechaController.text) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime(2040),
    );

    if (picked != null) {
      setState(() {
        _fechaController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submitForm() async {
    if (_nombreController.text.trim().isEmpty ||
        _licenciaController.text.trim().isEmpty ||
        _telefonoController.text.trim().isEmpty ||
        _fechaController.text.trim().isEmpty) {
      setState(() {
        _error = 'Por favor, complete todos los campos.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = '';
    });

    try {
      final conductor = ConductorModel(
        idConductor: widget.conductor?.idConductor ?? 0,
        nombreCompleto: _nombreController.text.trim(),
        licenciaConducir: _licenciaController.text.trim(),
        telefono: _telefonoController.text.trim(),
        fechaContratacion: _fechaController.text.trim(),
      );

      if (_isEditMode) {
        await ConductorService.update(conductor.idConductor, conductor);
      } else {
        await ConductorService.create(conductor);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Modificar un conductor' : 'Crear un conductor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre Completo'),
                textInputAction: TextInputAction.next,
              ),
              TextField(
                controller: _licenciaController,
                decoration: const InputDecoration(labelText: 'Licencia de Conducir'),
                textInputAction: TextInputAction.next,
              ),
              TextField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _fechaController,
                decoration: const InputDecoration(labelText: 'Fecha de Contratación'),
                readOnly: true,
                onTap: _selectFecha,
              ),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_error, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditMode ? 'Actualizar' : 'Crear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
