import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Nueva versión (Arquitectura limpia y MVVM)
import 'data/repositories/conductor_repository.dart';
import 'ui/core/theme.dart';
import 'ui/features/conductor/view_models/conductor_view_model.dart';
import 'ui/features/conductor/views/conductor_list_view.dart';

// Versión antigua
import 'pages/conductor_list.dart' as old;

// Habilita 'true' para la nueva versión (Diseño Premium + MVVM), 'false' para la antigua
const bool useNewVersion = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  if (useNewVersion) {
    final conductorRepository = ConductorRepository();
    final conductorViewModel = ConductorViewModel(conductorRepository: conductorRepository);
    runApp(MyAppNew(viewModel: conductorViewModel));
  } else {
    runApp(const MyAppOld());
  }
}

// Nueva Versión
class MyAppNew extends StatelessWidget {
  const MyAppNew({super.key, required this.viewModel});
  final ConductorViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conductor Admin App - New',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: ConductorListView(viewModel: viewModel),
    );
  }
}

// Antigua Versión
class MyAppOld extends StatelessWidget {
  const MyAppOld({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conductor Admin App - Old',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const old.ConductorList(),
    );
  }
}
