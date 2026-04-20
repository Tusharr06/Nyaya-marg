import 'dart:io';

void main() {
  final dir = Directory('lib/screens/client_screen');
  if (!dir.existsSync()) return;

  final filesToUpdate = [
    'court_explorer_screen.dart',
    'case_detail_screen.dart',
    'precedents_screen.dart',
    'analytics_screen.dart',
  ];

  for (final fileName in filesToUpdate) {
    final file = File('${dir.path}/$fileName');
    if (!file.existsSync()) continue;

    String content = file.readAsStringSync();
    
    // Replace instantiation
    content = content.replaceAll(
      'final LegalRepository _repository = MockLegalRepository();',
      'late final LegalRepository _repository;',
    );

    // Add provider import if missing
    if (!content.contains("import 'package:provider/provider.dart';")) {
      content = "import 'package:provider/provider.dart';\n" + content;
    }

    // Initialize in initState
    if (content.contains('late final LegalRepository _repository;')) {
      content = content.replaceAll(
        'void initState() {',
        'void initState() {\n    _repository = context.read<LegalRepository>();',
      );
    }

    file.writeAsStringSync(content);
    print('Updated $fileName');
  }
}
