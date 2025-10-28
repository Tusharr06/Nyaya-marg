// lib/screens/client_screen/tools_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyaya_marg/theme/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// =========================================================
/// TOOLS HOME – 4 PERFECTLY SIZED CARDS → FULL SCREENS
/// =========================================================
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  final List<Map<String, dynamic>> tools = const [
    {
      'icon': Icons.summarize_rounded,
      'title': 'Document Summarizer',
      'subtitle': 'Get AI summary of legal documents',
      'screen': DocumentSummarizerScreen(),
    },
    {
      'icon': Icons.verified_rounded,
      'title': 'Fake or Real',
      'subtitle': 'Check if notice or message is genuine',
      'screen': FakeOrRealScreen(),
    },
    {
      'icon': Icons.add_box_rounded,
      'title': 'Add Case',
      'subtitle': 'Save or track your ongoing case',
      'screen': AddCaseScreen(),
    },
    {
      'icon': Icons.search_rounded,
      'title': 'Track Case',
      'subtitle': 'Live status (Demo Mode)',
      'screen': TrackCaseScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmall = size.height < 700;
    final double cardWidth = (size.width - (isSmall ? 36 : 48)) / 2;
    final double cardHeight = cardWidth * 1.1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Legal Tools & Utilities',
          style: GoogleFonts.poppins(
            fontSize: isSmall ? 20 : 23,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: false, // LEFT
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 16 : 20,
            vertical: isSmall ? 10 : 14,
          ),
          child: GridView.builder(
            itemCount: tools.length,
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: isSmall ? 14 : 18,
              crossAxisSpacing: isSmall ? 14 : 18,
              childAspectRatio: cardWidth / cardHeight,
            ),
            itemBuilder: (context, index) {
              final tool = tools[index];
              return _buildToolCard(context, tool, isSmall);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, Map<String, dynamic> tool, bool isSmall) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => tool['screen'] as Widget),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(isSmall ? 12 : 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isSmall ? 12 : 16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                tool['icon'] as IconData,
                color: AppColors.primaryBlue,
                size: isSmall ? 32 : 38,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              tool['title'] as String,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: isSmall ? 13 : 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              tool['subtitle'] as String,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.black54,
                fontSize: isSmall ? 10 : 11,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// =========================================================
/// REUSABLE UI HELPERS
/// =========================================================
Widget buildIcon(bool isSmall, IconData icon) => Container(
      padding: EdgeInsets.all(isSmall ? 20 : 24),
      decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: AppColors.primaryBlue, size: isSmall ? 48 : 56),
    );

Widget buildDescription(bool isSmall, String text) => Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(fontSize: isSmall ? 15 : 16, color: Colors.black87, height: 1.5),
    );

Widget buildLoader() => const Padding(
      padding: EdgeInsets.only(top: 24),
      child: Column(children: [
        CircularProgressIndicator(color: AppColors.primaryBlue),
        SizedBox(height: 12),
        Text('Processing...', style: TextStyle(color: Colors.black54)),
      ]),
    );

Widget buildError(String error) => Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Markdown(
        data: error,
        selectable: true,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        styleSheet: MarkdownStyleSheet(p: GoogleFonts.poppins(fontSize: 14)),
      ),
    );

InputDecoration inputDecoration(String label, [IconData? icon]) => InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      prefixIcon: icon != null ? Icon(icon) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

/// =========================================================
/// 1. DOCUMENT SUMMARIZER – LEFT TITLE
/// =========================================================
class DocumentSummarizerScreen extends StatefulWidget {
  const DocumentSummarizerScreen({super.key});
  @override
  State<DocumentSummarizerScreen> createState() => _DocumentSummarizerScreenState();
}

class _DocumentSummarizerScreenState extends State<DocumentSummarizerScreen> {
  String? _fileName;
  String _summary = '';
  bool _isLoading = false;
  String _error = '';

  static const String _geminiApiKey = 'AIzaSyAUOLlfY3S9sQzaIEijYqJscZq6tzv9rnI';
  late final GenerativeModel _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _geminiApiKey);

  Future<void> _pickAndSummarize() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
        withData: true,
      );
      if (result == null || result.files.single.bytes == null) return;

      final bytes = result.files.single.bytes!;
      final name = result.files.single.name;

      setState(() {
        _fileName = name;
        _isLoading = true;
        _summary = '';
        _error = '';
      });

      final extracted = await _extractText(bytes, name);
      if (extracted.trim().isEmpty) throw Exception('No text found in document.');

      final text = extracted.length > 12000 ? '${extracted.substring(0, 12000)}… (truncated)' : extracted;

      final prompt = Content.text('''
You are a legal expert. Extract **exactly 6–7 key points** in **clean Markdown bullet list only**.
Use **-** for bullets. No intro. No conclusion.

Must include:
- Parties involved
- Key clauses or terms
- Important dates or deadlines
- Potential risks
- Recommended action

Document:
$text
''');

      final response = await _model.generateContent([prompt]);
      setState(() {
        _summary = response.text ?? 'No result.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<String> _extractText(Uint8List bytes, String fileName) async {
    if (fileName.toLowerCase().endsWith('.pdf')) {
      try {
        final document = PdfDocument(inputBytes: bytes);
        final text = PdfTextExtractor(document).extractText();
        document.dispose();
        return text;
      } catch (_) {
        return '';
      }
    }
    return String.fromCharCodes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.height < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Document Summarizer',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: false, // LEFT
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmall ? 16 : 20),
          child: Column(
            children: [
              buildIcon(isSmall, Icons.summarize_rounded),
              const SizedBox(height: 20),
              buildDescription(isSmall, 'Upload a PDF or TXT legal document – get 6–7 key points instantly.'),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickAndSummarize,
                icon: Icon(_isLoading ? Icons.hourglass_empty : Icons.upload_file),
                label: Text(_fileName == null ? 'Upload Document' : 'Re-upload ($_fileName)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_fileName != null && !_isLoading)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                  child: Text('Selected: $_fileName', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54), textAlign: TextAlign.center),
                ),
              if (_isLoading) buildLoader(),
              if (_error.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red)),
                  child: Text(_error, style: const TextStyle(color: Colors.redAccent)),
                ),
              if (_summary.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text('Key Points', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey)),
                      child: Markdown(
                        data: _summary,
                        selectable: true,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.poppins(fontSize: 14, height: 1.6),
                          listBullet: GoogleFonts.poppins(fontSize: 14),
                          strong: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

/// =========================================================
/// 2. FAKE OR REAL – LEFT TITLE
/// =========================================================
class FakeOrRealScreen extends StatefulWidget {
  const FakeOrRealScreen({super.key});
  @override
  State<FakeOrRealScreen> createState() => _FakeOrRealScreenState();
}

class _FakeOrRealScreenState extends State<FakeOrRealScreen> {
  final _controller = TextEditingController();
  String _result = '';
  bool _isChecking = false;

  void _check() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isChecking = true);
    await Future.delayed(const Duration(seconds: 2));

    final text = _controller.text.toLowerCase();
    final isGenuine = text.contains('court') ||
        text.contains('summons') ||
        text.contains('notice') ||
        text.contains('advocate') ||
        text.contains('section') ||
        text.contains('ipc');

    setState(() {
      _isChecking = false;
      _result = isGenuine
          ? '**Likely Genuine**\n\nContains legal keywords like "court", "summons", "notice", "IPC".'
          : '**Suspicious**\n\nNo legal terms found. Could be fake.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.height < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Fake or Real',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: false, // LEFT
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmall ? 16 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildIcon(isSmall, Icons.verified_rounded),
              const SizedBox(height: 20),
              buildDescription(isSmall, 'Paste any legal notice to verify authenticity.'),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Paste message here...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _controller.text.isEmpty ? null : _check,
                icon: const Icon(Icons.security),
                label: const Text('Verify'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              if (_isChecking)
                buildLoader()
              else if (_result.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _result.contains('Genuine') ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _result.contains('Genuine') ? Colors.green : Colors.orange),
                  ),
                  child: Markdown(
                    data: _result,
                    selectable: true,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.poppins(fontSize: 15, height: 1.6),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// =========================================================
/// 3. ADD CASE – LEFT TITLE
/// =========================================================
class AddCaseScreen extends StatefulWidget {
  const AddCaseScreen({super.key});
  @override
  State<AddCaseScreen> createState() => _AddCaseScreenState();
}

class _AddCaseScreenState extends State<AddCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caseNo = TextEditingController();
  final _court = TextEditingController();
  final _party = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.height < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Add Case',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: false, // LEFT
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmall ? 16 : 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                buildIcon(isSmall, Icons.add_box_rounded),
                const SizedBox(height: 20),
                buildDescription(isSmall, 'Enter case details to start tracking.'),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _caseNo,
                  decoration: inputDecoration('Case Number'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _court,
                  decoration: inputDecoration('Court Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _party,
                  decoration: inputDecoration('Opposite Party'),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Case ${_caseNo.text} saved!'), backgroundColor: Colors.green),
                      );
                      _caseNo.clear();
                      _court.clear();
                      _party.clear();
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Case'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =========================================================
/// 4. TRACK CASE – LEFT TITLE
/// =========================================================
class TrackCaseScreen extends StatefulWidget {
  const TrackCaseScreen({super.key});
  @override
  State<TrackCaseScreen> createState() => _TrackCaseScreenState();
}

class _TrackCaseScreenState extends State<TrackCaseScreen> {
  final _caseNo = TextEditingController();
  final _court = TextEditingController();
  String _result = '';
  bool _isLoading = false;
  String _error = '';

  final List<Map<String, String>> _mockCases = [
    {
      'case': '12345/2024',
      'court': 'supreme',
      'status': '''
**Case Status**: Pending (Admitted)
- **Last Hearing**: 15-Oct-2025
- **Next Hearing**: 20-Nov-2025
- **Judge**: Justice D.Y. Chandrachud
- **Case Type**: Writ Petition (Civil)
''',
    },
    {
      'case': 'crl.a. 456/2023',
      'court': 'delhi',
      'status': '''
**Case Status**: Disposed (Dismissed)
- **Last Hearing**: 10-Sep-2025
- **Next Hearing**: N/A (Closed)
- **Judge**: Justice Sanjiv Khanna
- **Case Type**: Criminal Appeal
''',
    },
    {
      'case': 'wp/789/2025',
      'court': 'bombay',
      'status': '''
**Case Status**: In Progress
- **Last Hearing**: 05-Oct-2025
- **Next Hearing**: 12-Dec-2025
- **Judge**: Justice S.V. Gangapurwala
- **Case Type**: Writ Petition
''',
    },
    {
      'case': '101/01/2024',
      'court': 'new delhi',
      'status': '''
**Case Status**: Pending (Notice Issued)
- **Last Hearing**: 25-Oct-2025
- **Next Hearing**: 28-Nov-2025
- **Judge**: District Judge R.K. Sharma
- **Case Type**: Civil Suit
''',
    },
  ];

  Future<void> _track() async {
    final inputCase = _caseNo.text.trim();
    final inputCourt = _court.text.trim().toLowerCase();

    if (inputCase.isEmpty || inputCourt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill both fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '';
      _error = '';
    });

    await Future.delayed(const Duration(seconds: 2));

    final matchedCase = _mockCases.firstWhere(
      (c) =>
          inputCase.toLowerCase().contains(c['case']!.toLowerCase()) &&
          inputCourt.contains(c['court']!),
      orElse: () => {},
    );

    setState(() {
      _isLoading = false;
      if (matchedCase.isNotEmpty) {
        _result = matchedCase['status']!;
      } else {
        _error = 'Case not found. Try one of these:\n\n'
            '• **12345/2024** + Supreme Court\n'
            '• **CRL.A. 456/2023** + Delhi High Court\n'
            '• **WP/789/2025** + Bombay High Court\n'
            '• **101/01/2024** + New Delhi District Court';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.height < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Track Case',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: false, // LEFT
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmall ? 16 : 20),
          child: Column(
            children: [
              buildIcon(isSmall, Icons.search_rounded),
              const SizedBox(height: 20),
              buildDescription(isSmall, 'Enter case number and court to check live status. (Demo Mode)'),
              const SizedBox(height: 32),
              TextField(
                controller: _caseNo,
                decoration: inputDecoration('Case Number', Icons.numbers),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _court,
                decoration: inputDecoration('Court Name', Icons.account_balance),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _track,
                icon: Icon(_isLoading ? Icons.hourglass_empty : Icons.search),
                label: Text(_isLoading ? 'Searching...' : 'Track Case'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_isLoading) buildLoader(),
              if (_error.isNotEmpty) buildError(_error),
              if (_result.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Markdown(
                    data: _result,
                    selectable: true,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.poppins(fontSize: 15, height: 1.6),
                      listBullet: GoogleFonts.poppins(),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}