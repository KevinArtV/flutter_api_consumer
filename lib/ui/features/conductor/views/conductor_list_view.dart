// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../../data/models/conductor_model.dart';
import '../../../core/theme.dart';
import '../view_models/conductor_view_model.dart';
import 'conductor_form_view.dart';

class ConductorListView extends StatefulWidget {
  const ConductorListView({super.key, required this.viewModel});

  final ConductorViewModel viewModel;

  @override
  State<ConductorListView> createState() => _ConductorListViewState();
}

class _ConductorListViewState extends State<ConductorListView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.fetchConductors();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openConductorForm({ConductorModel? conductor}) async {
    final result = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ConductorFormView(
          viewModel: widget.viewModel,
          conductor: conductor,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.1);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
    if (result == true) {
      widget.viewModel.fetchConductors();
    }
  }

  Future<void> _confirmDelete(ConductorModel conductor) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 10),
              Text('Eliminar conductor'),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: Theme.of(context).dialogTheme.contentTextStyle ??
                  const TextStyle(color: Colors.white70, fontSize: 16),
              children: [
                const TextSpan(text: '¿Está seguro de que desea eliminar permanentemente a '),
                TextSpan(
                  text: conductor.nombreCompleto,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const TextSpan(text: '? Esta acción no se puede deshacer.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar', style: TextStyle(color: AppTheme.textDarkSecondary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final success = await widget.viewModel.deleteConductor(conductor);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Conductor "${conductor.nombreCompleto}" eliminado correctamente')),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.darkSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Error al eliminar: ${widget.viewModel.error}')),
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
              final conductors = widget.viewModel.conductors.where((conductor) {
                return conductor.nombreCompleto.toLowerCase().contains(_searchQuery) ||
                    conductor.licenciaConducir.toLowerCase().contains(_searchQuery) ||
                    conductor.telefono.toLowerCase().contains(_searchQuery);
              }).toList();

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                                child: const Text(
                                  'Conductores',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: FloatingActionButton.small(
                                  onPressed: () => _openConductorForm(conductor: null),
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Gestiona los conductores registrados en la base de datos de Supabase',
                            style: TextStyle(
                              color: AppTheme.textDarkSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.darkSurface.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.06)),
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Buscar por nombre, licencia o tel...',
                                hintStyle: const TextStyle(color: AppTheme.textDarkSecondary),
                                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primaryColor),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.close_rounded, color: AppTheme.textDarkSecondary),
                                        onPressed: () => _searchController.clear(),
                                      )
                                    : null,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Resultados encontrados: ${conductors.length}'
                                    : 'Total: ${widget.viewModel.conductors.length} conductores',
                                style: const TextStyle(
                                  color: AppTheme.textDarkSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (widget.viewModel.isLoading)
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    sliver: widget.viewModel.isLoading && widget.viewModel.conductors.isEmpty
                        ? const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(color: AppTheme.primaryColor),
                                  SizedBox(height: 16),
                                  Text(
                                    'Cargando conductores...',
                                    style: TextStyle(color: AppTheme.textDarkSecondary, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : widget.viewModel.error.isNotEmpty && widget.viewModel.conductors.isEmpty
                            ? SliverFillRemaining(
                                hasScrollBody: false,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.cloud_off_rounded, size: 64, color: Colors.redAccent),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Error de conexión',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          widget.viewModel.error,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: AppTheme.textDarkSecondary),
                                        ),
                                        const SizedBox(height: 24),
                                        ElevatedButton.icon(
                                          onPressed: widget.viewModel.fetchConductors,
                                          icon: const Icon(Icons.refresh_rounded),
                                          label: const Text('Reintentar'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : conductors.isEmpty
                                ? SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _searchQuery.isNotEmpty
                                                ? Icons.search_off_rounded
                                                : Icons.people_outline_rounded,
                                            size: 64,
                                            color: AppTheme.textDarkSecondary.withOpacity(0.5),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            _searchQuery.isNotEmpty
                                                ? 'No se encontraron resultados'
                                                : 'No hay conductores disponibles',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            _searchQuery.isNotEmpty
                                                ? 'Intenta con otros términos de búsqueda'
                                                : 'Usa el botón "+" arriba para agregar uno',
                                            style: const TextStyle(color: AppTheme.textDarkSecondary),
                                          ),
                                          if (_searchQuery.isEmpty) ...[
                                            const SizedBox(height: 24),
                                            ElevatedButton.icon(
                                              onPressed: widget.viewModel.fetchConductors,
                                              icon: const Icon(Icons.refresh_rounded),
                                              label: const Text('Actualizar'),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  )
                                : SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final conductor = conductors[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 12.0),
                                          child: _buildConductorCard(conductor),
                                        );
                                      },
                                      childCount: conductors.length,
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

  Widget _buildConductorCard(ConductorModel conductor) {
    final initials = conductor.nombreCompleto.trim().split(' ').take(2).map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').join();

    final int hash = conductor.nombreCompleto.hashCode;
    final List<Color> avatarColors = [
      HSLColor.fromAHSL(1.0, (hash % 360).toDouble(), 0.7, 0.5).toColor(),
      HSLColor.fromAHSL(1.0, ((hash + 60) % 360).toDouble(), 0.8, 0.6).toColor(),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openConductorForm(conductor: conductor),
            splashColor: AppTheme.primaryColor.withOpacity(0.05),
            highlightColor: AppTheme.primaryColor.withOpacity(0.02),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  Hero(
                    tag: 'avatar-${conductor.idConductor}',
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: avatarColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: avatarColors[0].withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials.isNotEmpty ? initials : 'C',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conductor.nombreCompleto,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDarkPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.badge_outlined, size: 14, color: AppTheme.textDarkSecondary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Lic: ${conductor.licenciaConducir}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textDarkSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 14, color: AppTheme.textDarkSecondary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Tel: ${conductor.telefono}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textDarkSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textDarkSecondary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Contratación: ${conductor.fechaContratacion}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textDarkSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit_rounded, color: AppTheme.primaryColor, size: 20),
                          onPressed: () => _openConductorForm(conductor: conductor),
                          tooltip: 'Editar',
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                          onPressed: () => _confirmDelete(conductor),
                          tooltip: 'Eliminar',
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
