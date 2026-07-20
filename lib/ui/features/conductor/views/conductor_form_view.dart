// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../../data/models/conductor_model.dart';
import '../../../core/theme.dart';
import '../view_models/conductor_view_model.dart';

class ConductorFormView extends StatefulWidget {
  const ConductorFormView({super.key, required this.viewModel, this.conductor});

  final ConductorViewModel viewModel;
  final ConductorModel? conductor;

  @override
  State<ConductorFormView> createState() => _ConductorFormViewState();
}

class _ConductorFormViewState extends State<ConductorFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _licenciaController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _fechaController = TextEditingController();
  
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
      // Default to current date for hiring date
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.darkSurface,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0B1120),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fechaController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombreController.text.trim();
    final licencia = _licenciaController.text.trim();
    final telefono = _telefonoController.text.trim();
    final fecha = _fechaController.text.trim();

    final success = await widget.viewModel.saveConductor(
      originalConductor: widget.conductor,
      nombreCompleto: nombre,
      licenciaConducir: licencia,
      telefono: telefono,
      fechaContratacion: fecha,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
                const SizedBox(width: 12),
                Text(_isEditMode ? 'Conductor actualizado correctamente' : 'Conductor creado correctamente'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.darkSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                const SizedBox(width: 12),
                Expanded(child: Text('Error: ${widget.viewModel.error}')),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.darkSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B1120),
              Color(0xFF070A13),
            ],
          ),
        ),
        child: SafeArea(
          child: ListenableBuilder(
            listenable: widget.viewModel,
            builder: (context, _) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          Text(
                            _isEditMode ? 'Editar Conductor' : 'Nuevo Conductor',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(24.0),
                    sliver: SliverToBoxAdapter(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Hero(
                                tag: _isEditMode ? 'avatar-${widget.conductor!.idConductor}' : 'new-avatar',
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _isEditMode ? Icons.edit_rounded : Icons.person_add_alt_1_rounded,
                                      size: 38,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                color: AppTheme.darkSurface.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white.withOpacity(0.06)),
                              ),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _nombreController,
                                    style: const TextStyle(color: Colors.white),
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'Nombre completo',
                                      prefixIcon: Icon(Icons.person_rounded, color: AppTheme.primaryColor),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Por favor ingresa el nombre';
                                      }
                                      if (value.trim().length < 3) {
                                        return 'El nombre debe tener al menos 3 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _licenciaController,
                                    style: const TextStyle(color: Colors.white),
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'Licencia de conducir',
                                      prefixIcon: Icon(Icons.badge_rounded, color: AppTheme.primaryColor),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Por favor ingresa la licencia';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _telefonoController,
                                    style: const TextStyle(color: Colors.white),
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      labelText: 'Teléfono',
                                      prefixIcon: Icon(Icons.phone_rounded, color: AppTheme.primaryColor),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Por favor ingresa el teléfono';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _fechaController,
                                    readOnly: true,
                                    onTap: _selectFecha,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: 'Fecha de contratación',
                                      prefixIcon: Icon(Icons.calendar_today_rounded, color: AppTheme.primaryColor),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Por favor selecciona una fecha';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: widget.viewModel.isLoading ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: widget.viewModel.isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        _isEditMode ? 'Guardar Cambios' : 'Registrar Conductor',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
