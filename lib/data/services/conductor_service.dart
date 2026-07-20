import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/conductor_model.dart';

class ConductorService {
  // CONFIGURACIÓN DE SUPABASE REST API
  // Reemplaza con tus credenciales de Supabase
  static const String supabaseUrl = 'https://wmdhptmfyqkgpwvizlmx.supabase.co/rest/v1/';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String tableName = 'conductores'; // Nombre de tu tabla en Supabase
  static const String dbSchema = 'public'; // Cambia si tu tabla está en un esquema diferente a public

  static String get baseUrl {
    // Si se incluye la ruta REST completa, limpiamos para evitar duplicados
    if (supabaseUrl.contains('/rest/v1')) {
      final base = supabaseUrl.split('/rest/v1')[0];
      return '$base/rest/v1/$tableName';
    }
    final cleanUrl = supabaseUrl.endsWith('/') 
        ? supabaseUrl.substring(0, supabaseUrl.length - 1) 
        : supabaseUrl;
    return '$cleanUrl/rest/v1/$tableName';
  }

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'apikey': anonKey,
      'Authorization': 'Bearer $anonKey',
    };
    if (dbSchema != 'public') {
      headers['Accept-Profile'] = dbSchema;
      headers['Content-Profile'] = dbSchema;
    }
    return headers;
  }

  static Map<String, String> get _headersWithRepresentation => {
    ..._headers,
    'Prefer': 'return=representation',
  };

  static Future<List<ConductorModel>> getAll() async {
    final response = await http.get(
      Uri.parse('$baseUrl?select=*'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((json) => ConductorModel.fromJson(json as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load conductors: ${response.body}');
    }
  }

  static Future<ConductorModel> getById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl?id_conductor=eq.$id&select=*'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      if (data.isNotEmpty) {
        return ConductorModel.fromJson(data.first as Map<String, dynamic>);
      }
      throw Exception('Conductor not found');
    } else {
      throw Exception('Failed to load conductor: ${response.body}');
    }
  }

  static Future<ConductorModel> create(ConductorModel conductor) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: _headersWithRepresentation,
      body: jsonEncode({
        'nombre_completo': conductor.nombreCompleto,
        'licencia_conducir': conductor.licenciaConducir,
        'telefono': conductor.telefono,
        'fecha_contratacion': conductor.fechaContratacion,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      if (data.isNotEmpty) {
        return ConductorModel.fromJson(data.first as Map<String, dynamic>);
      }
      throw Exception('Failed to create conductor: Empty response body');
    } else {
      throw Exception('Failed to create conductor: ${response.body}');
    }
  }

  static Future<ConductorModel> update(int id, ConductorModel conductor) async {
    final response = await http.patch(
      Uri.parse('$baseUrl?id_conductor=eq.$id'),
      headers: _headersWithRepresentation,
      body: jsonEncode({
        'nombre_completo': conductor.nombreCompleto,
        'licencia_conducir': conductor.licenciaConducir,
        'telefono': conductor.telefono,
        'fecha_contratacion': conductor.fechaContratacion,
      }),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      if (data.isNotEmpty) {
        return ConductorModel.fromJson(data.first as Map<String, dynamic>);
      }
      throw Exception('Failed to update conductor: Empty response body');
    } else {
      throw Exception('Failed to update conductor: ${response.body}');
    }
  }

  static Future<void> delete(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl?id_conductor=eq.$id'),
      headers: _headers,
    );
    if (!(response.statusCode == 200 || response.statusCode == 204)) {
      throw Exception('Error: no se puede eliminar el conductor con id: $id (status code: ${response.statusCode})');
    }
  }
}
