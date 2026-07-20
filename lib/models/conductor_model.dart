class ConductorModel {
  int idConductor;
  String nombreCompleto;
  String licenciaConducir;
  String telefono;
  String fechaContratacion;

  ConductorModel({
    required this.idConductor,
    required this.nombreCompleto,
    required this.licenciaConducir,
    required this.telefono,
    required this.fechaContratacion,
  });

  factory ConductorModel.fromJson(Map<String, dynamic> json) {
    return ConductorModel(
      idConductor: json['id_conductor'] as int? ?? 0,
      nombreCompleto: json['nombre_completo'] as String? ?? '',
      licenciaConducir: json['licencia_conducir'] as String? ?? '',
      telefono: json['telefono'] as String? ?? '',
      fechaContratacion: json['fecha_contratacion'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_conductor': idConductor,
      'nombre_completo': nombreCompleto,
      'licencia_conducir': licenciaConducir,
      'telefono': telefono,
      'fecha_contratacion': fechaContratacion,
    };
  }
}
