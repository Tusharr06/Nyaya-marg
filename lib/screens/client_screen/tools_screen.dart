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
/// TOOLS HOME – 6 PERFECTLY SIZED CARDS → FULL SCREENS
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
      'subtitle': 'AI checks if notice is genuine',
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
      'subtitle': 'Live status',
      'screen': TrackCaseScreen(),
    },
    {
      'icon': Icons.question_answer_rounded,
      'title': 'Ask a Lawyer',
      'subtitle': 'Get instant AI legal advice',
      'screen': AskLawyerScreen(),
    },
    {
      'icon': Icons.gavel_rounded,
      'title': 'Case Law Finder',
      'subtitle': 'Search Indian judgments',
      'screen': CaseLawFinderScreen(),
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
        centerTitle: false,
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
/// 1. DOCUMENT SUMMARIZER
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
        title: Text('Document Summarizer', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: false,
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
              if (_error.isNotEmpty) buildError(_error),
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
/// 2. FAKE OR REAL – USES GEMINI AI
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

  static const String _geminiApiKey = 'AIzaSyAUOLlfY3S9sQzaIEijYqJscZq6tzv9rnI';
  late final GenerativeModel _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _geminiApiKey);

  void _check() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isChecking = true);

    try {
      final prompt = Content.text('''
You are a legal authenticity expert. Analyze the following message and determine if it's likely **genuine** or **fake**.

Respond in **Markdown** with:
- **Verdict**: Genuine / Suspicious / Fake
- **Confidence**: High / Medium / Low
- **Reasons**: 3–5 bullet points

Focus on:
- Grammar & spelling
- Legal terminology
- Formatting & tone
- Urgency & threats
- Contact details

Message:
${_controller.text}
''');

      final response = await _model.generateContent([prompt]);
      setState(() {
        _result = response.text ?? 'No result.';
        _isChecking = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.height < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Fake or Real', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmall ? 16 : 20),
          child: Column(
            children: [
              buildIcon(isSmall, Icons.verified_rounded),
              const SizedBox(height: 20),
              buildDescription(isSmall, 'Paste any legal notice – AI checks authenticity.'),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'Paste message here...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _controller.text.isEmpty || _isChecking ? null : _check,
                icon: const Icon(Icons.security),
                label: Text(_isChecking ? 'Analyzing...' : 'Verify'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_isChecking) buildLoader(),
              if (_result.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 24),
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
                      strong: GoogleFonts.poppins(fontWeight: FontWeight.w700),
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
/// 3. ADD CASE
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
        title: Text('Add Case', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: false,
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
/// 4. TRACK CASE
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
        title: Text('Track Case', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmall ? 16 : 20),
          child: Column(
            children: [
              buildIcon(isSmall, Icons.search_rounded),
              const SizedBox(height: 20),
              buildDescription(isSmall, 'Enter case number and court to check live status'),
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

/// =========================================================
/// 5. ASK A LAWYER – AI LEGAL Q&A
/// =========================================================
class AskLawyerScreen extends StatefulWidget {
  const AskLawyerScreen({super.key});
  @override
  State<AskLawyerScreen> createState() => _AskLawyerScreenState();
}

class _AskLawyerScreenState extends State<AskLawyerScreen> {
  final _questionController = TextEditingController();
  String _answer = '';
  bool _isAsking = false;

  static const String _geminiApiKey = 'AIzaSyAUOLlfY3S9sQzaIEijYqJscZq6tzv9rnI';
  late final GenerativeModel _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _geminiApiKey);

  void _ask() async {
    if (_questionController.text.trim().isEmpty) return;

    setState(() {
      _isAsking = true;
      _answer = '';
    });

    try {
      final prompt = Content.text('''
You are a senior Indian lawyer. Answer the user's legal question in **simple, clear Hindi/English mix** (use English terms where needed).

Respond in **Markdown** with:
- **Answer**: 2–3 short sentences
- **Key Points**: 3–5 bullets
- **Next Steps**: 1–2 actions
- **Disclaimer**: This is AI-generated advice, not a substitute for professional legal consultation.

Question: ${_questionController.text}
''');

      final response = await _model.generateContent([prompt]);
      setState(() {
        _answer = (response.text ?? 'No answer received.').trim();
        _isAsking = false;
      });
    } catch (e) {
      setState(() {
        _answer = 'Error: $e';
        _isAsking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.height < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Ask a Lawyer', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmall ? 16 : 20),
          child: Column(
            children: [
              buildIcon(isSmall, Icons.question_answer_rounded),
              const SizedBox(height: 20),
              buildDescription(isSmall, 'Ask any legal question – get instant AI-powered advice.'),
              const SizedBox(height: 24),
              TextField(
                controller: _questionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'e.g., Can police arrest without warrant? What is Section 498A?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _questionController.text.isEmpty || _isAsking ? null : _ask,
                icon: const Icon(Icons.smart_toy),
                label: Text(_isAsking ? 'Thinking...' : 'Ask AI Lawyer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_isAsking) buildLoader(),
              if (_answer.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple),
                  ),
                  child: Markdown(
                    data: _answer,
                    selectable: true,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    styleSheet: MarkdownStyleSheet(
                      p: GoogleFonts.poppins(fontSize: 15, height: 1.7),
                      listBullet: GoogleFonts.poppins(fontSize: 14),
                      strong: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                      em: GoogleFonts.poppins(fontStyle: FontStyle.italic),
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
/// 6. CASE LAW FINDER (DEMO)
/// =========================================================
class CaseLawFinderScreen extends StatefulWidget {
  const CaseLawFinderScreen({super.key});
  @override
  State<CaseLawFinderScreen> createState() => _CaseLawFinderScreenState();
}

class _CaseLawFinderScreenState extends State<CaseLawFinderScreen> {
  final _queryController = TextEditingController();
  List<Map<String, String>> _results = [];
  bool _isSearching = false;

  final List<Map<String, String>> _mockCases = [
    {
      'title': 'Kesavananda Bharati v. State of Kerala',
      'citation': '(1973) 4 SCC 225',
      'court': 'Supreme Court of India',
      'summary': 'Established the **basic structure doctrine**. Parliament cannot amend fundamental rights.',
    },
    {
      'title': 'Shreya Singhal v. Union of India',
      'citation': '(2015) 5 SCC 1',
      'court': 'Supreme Court of India',
      'summary': 'Struck down **Section 66A** of IT Act as unconstitutional.',
    },
    {
      'title': 'Vishaka v. State of Rajasthan',
      'citation': '(1997) 6 SCC 241',
      'court': 'Supreme Court of India',
      'summary': 'Laid down **guidelines against sexual harassment** at workplace.',
    },
  ];

  void _search() {
    final query = _queryController.text.toLowerCase();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    Future.delayed(const Duration(seconds: 1), () {
      final filtered = _mockCases.where((c) => c['title']!.toLowerCase().contains(query) || c['summary']!.toLowerCase().contains(query)).toList();
      setState(() {
        _results = filtered;
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.height < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Case Law Finder', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmall ? 16 : 20),
          child: Column(
            children: [
              buildIcon(isSmall, Icons.gavel_rounded),
              const SizedBox(height: 20),
              buildDescription(isSmall, 'Search landmark Indian judgments.'),
              const SizedBox(height: 24),
              TextField(
                controller: _queryController,
                decoration: inputDecoration('Search Cases', Icons.search),
                onSubmitted: (_) => _search(),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isSearching ? null : _search,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_isSearching) buildLoader(),
              if (_results.isNotEmpty)
                Column(
                  children: _results.map((c) => Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigo),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['title']!, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text(c['citation']!, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 8),
                        Text(c['summary']!, style: GoogleFonts.poppins(fontSize: 14)),
                      ],
                    ),
                  )).toList(),
                ),
              if (!_isSearching && _results.isEmpty && _queryController.text.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Text('No cases found.', style: GoogleFonts.poppins()),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}