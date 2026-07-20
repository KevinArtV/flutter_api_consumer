import 'package:flutter/foundation.dart';
import '../../../../data/models/conductor_model.dart';
import '../../../../data/repositories/conductor_repository.dart';

class ConductorViewModel extends ChangeNotifier {
  final ConductorRepository conductorRepository;

  ConductorViewModel({required this.conductorRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  List<ConductorModel> _conductors = [];
  List<ConductorModel> get conductors => _conductors;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String errorMsg) {
    _error = errorMsg;
    notifyListeners();
  }

  Future<void> fetchConductors() async {
    _setLoading(true);
    _setError('');
    try {
      _conductors = await conductorRepository.getConductors();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteConductor(ConductorModel conductor) async {
    _setError('');
    try {
      await conductorRepository.deleteConductor(conductor.idConductor);
      _conductors.removeWhere((c) => c.idConductor == conductor.idConductor);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> saveConductor({
    ConductorModel? originalConductor,
    required String nombreCompleto,
    required String licenciaConducir,
    required String telefono,
    required String fechaContratacion,
  }) async {
    _setLoading(true);
    _setError('');
    try {
      final conductor = ConductorModel(
        idConductor: originalConductor?.idConductor ?? 0,
        nombreCompleto: nombreCompleto,
        licenciaConducir: licenciaConducir,
        telefono: telefono,
        fechaContratacion: fechaContratacion,
      );

      if (originalConductor != null) {
        await conductorRepository.updateConductor(conductor.idConductor, conductor);
      } else {
        await conductorRepository.createConductor(conductor);
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
