import '../models/conductor_model.dart';
import '../services/conductor_service.dart';

class ConductorRepository {
  Future<List<ConductorModel>> getConductors() async {
    return await ConductorService.getAll();
  }

  Future<ConductorModel> getConductorById(int id) async {
    return await ConductorService.getById(id);
  }

  Future<ConductorModel> createConductor(ConductorModel conductor) async {
    return await ConductorService.create(conductor);
  }

  Future<ConductorModel> updateConductor(int id, ConductorModel conductor) async {
    return await ConductorService.update(id, conductor);
  }

  Future<void> deleteConductor(int id) async {
    await ConductorService.delete(id);
  }
}
