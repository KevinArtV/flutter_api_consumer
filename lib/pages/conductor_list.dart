import 'package:api_consumer/pages/conductor_form.dart';
import 'package:flutter/material.dart';
import '../models/conductor_model.dart';
import '../services/conductor_service.dart';

class ConductorList extends StatefulWidget {
  const ConductorList({super.key});

  @override
  State<ConductorList> createState() => _ConductorListState();
}

class _ConductorListState extends State<ConductorList> {
  String _error = '';
  bool _isLoading = false;
  List<ConductorModel> _conductors = [];

  Future<void> _fetchConductors() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final conductors = await ConductorService.getAll();
      setState(() {
        _conductors = conductors;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openConductorForm({ConductorModel? conductor}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConductorForm(conductor: conductor)),
    );
    _fetchConductors();
  }

  Future<void> _deleteConductor(ConductorModel conductor) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Seguro que quiere eliminar a ${conductor.nombreCompleto}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      try {
        await ConductorService.delete(conductor.idConductor);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conductor eliminado correctamente')),
          );
        }
        await _fetchConductors();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(   
            SnackBar(content: Text('Error al eliminar conductor: $e')),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchConductors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conductor List')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {_openConductorForm(conductor: null)},
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text(_error)],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchConductors,
              child: _conductors.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text('No conductors available')],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _conductors.length,
                      itemBuilder: (context, index) {
                        final conductor = _conductors[index];
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(conductor.nombreCompleto),
                          subtitle: Text('Lic: ${conductor.licenciaConducir} | Tel: ${conductor.telefono}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => {_openConductorForm(conductor: conductor)},
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                onPressed: () => _deleteConductor(conductor),
                                icon: const Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}