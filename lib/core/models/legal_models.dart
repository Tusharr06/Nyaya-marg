import 'data_source.dart';

class Court {
  final String id;
  final String name;
  final String type; // Supreme Court, High Court, District, Civil, Criminal
  final String location;
  final int activeCases;
  final String judgeInfo;

  Court({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.activeCases,
    this.judgeInfo = 'Multiple Judges',
  });

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id']?.toString() ?? json['court_id']?.toString() ?? '',
      name: json['name'] ?? json['court_name'] ?? 'Unknown Court',
      type: json['type'] ?? json['court_type'] ?? 'District',
      location: json['location'] ?? json['state'] ?? 'India',
      activeCases: json['active_cases'] ?? 0,
    );
  }
}

class CaseModel {
  final String id;
  final String caseNumber;
  final String title;
  final String status;
  final DateTime filingDate;
  final DateTime? nextHearingDate;
  final String courtName;
  final String judgeName;
  final String courtHall;
  final String lastOrderSummary;
  final double predictionConfidence;
  final DataSourceType dataSource;

  CaseModel({
    required this.id,
    required this.caseNumber,
    required this.title,
    required this.status,
    required this.filingDate,
    this.nextHearingDate,
    required this.courtName,
    required this.judgeName,
    required this.courtHall,
    required this.lastOrderSummary,
    this.predictionConfidence = 0.0,
    this.dataSource = DataSourceType.dataset,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json) {
    return CaseModel(
      id: json['id']?.toString() ?? json['case_id']?.toString() ?? '',
      caseNumber: json['case_number'] ?? json['cnr'] ?? 'N/A',
      title: json['title'] ?? json['case_title'] ?? 'Title not available',
      status: json['status'] ?? 'Undetermined',
      filingDate: json['filing_date'] != null ? DateTime.parse(json['filing_date']) : DateTime.now(),
      nextHearingDate: json['next_hearing'] != null ? DateTime.parse(json['next_hearing']) : null,
      courtName: json['court_name'] ?? 'Unknown Court',
      judgeName: json['judge_name'] ?? 'N/A',
      courtHall: json['court_hall'] ?? 'N/A',
      lastOrderSummary: json['last_order'] ?? json['summary'] ?? 'No summary available.',
      predictionConfidence: (json['confidence'] ?? 0.0).toDouble(),
      dataSource: DataSourceType.live,
    );
  }
}

class CaseInsight {
  final String title;
  final String message;
  final List<String> positives;
  final List<String> negatives;
  final double confidence;
  final String riskLevel; // Low, Medium, High

  CaseInsight({
    required this.title,
    required this.message,
    required this.positives,
    required this.negatives,
    required this.confidence,
    required this.riskLevel,
  });

  factory CaseInsight.fromJson(Map<String, dynamic> json) {
    return CaseInsight(
      title: json['title'] ?? 'AI Legal Insight',
      message: json['message'] ?? (json['summary'] ?? 'No insight available.'),
      positives: List<String>.from(json['positives'] ?? []),
      negatives: List<String>.from(json['negatives'] ?? []),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      riskLevel: json['risk_level'] ?? 'Low',
    );
  }
}
