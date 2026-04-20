import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/models/legal_models.dart';

abstract class LegalRepository {
  Future<List<Court>> getCourts({String? location});
  Future<List<CaseModel>> getCases({String? courtId});
  Future<CaseModel> getCaseDetail(String id);
  Future<CaseInsight> getCaseInsight(String caseId);
}

class MockLegalRepository implements LegalRepository {
  final Random _random = Random();

  @override
  Future<List<Court>> getCourts({String? location}) async {
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(400)));
    
    return [
      Court(id: '1', name: 'Supreme Court of India', type: 'Supreme Court', location: 'New Delhi', activeCases: 1540),
      Court(id: '2', name: 'Karnataka High Court', type: 'High Court', location: 'Bengaluru', activeCases: 890),
      Court(id: '3', name: 'Bengaluru District Court', type: 'District Court', location: 'Bengaluru', activeCases: 2300),
      Court(id: '4', name: 'City Civil Court', type: 'Civil Court', location: 'Bengaluru', activeCases: 1200),
      Court(id: '5', name: 'Metropolitan Criminal Court', type: 'Criminal Court', location: 'Bengaluru', activeCases: 950),
    ].where((c) => location == null || c.location.toLowerCase().contains(location.toLowerCase())).toList();
  }

  @override
  Future<List<CaseModel>> getCases({String? courtId}) async {
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(400)));
    
    return List.generate(10, (index) => CaseModel(
      id: 'case_$index',
      caseNumber: 'OS/${2020 + index}/$index',
      title: index % 2 == 0 ? 'Property Dispute: A vs B' : 'Criminal Procedure: State vs X',
      status: index % 3 == 0 ? 'Active' : 'Closed',
      filingDate: DateTime.now().subtract(Duration(days: 365 * 2 + index * 10)),
      nextHearingDate: DateTime.now().add(Duration(days: 15 + index)),
      courtName: courtId == '2' ? 'Karnataka High Court' : 'Bengaluru District Court',
      judgeName: 'Hon\'ble Justice ${['R. Kumar', 'S. Murthy', 'V. Lakshmi'][index % 3]}',
      courtHall: 'Hall No. ${index + 5}',
      lastOrderSummary: 'Interim injunction granted pending further hearing. Both parties ordered to maintain status quo.',
      predictionConfidence: 0.65 + (_random.nextDouble() * 0.25),
    ));
  }

  @override
  Future<CaseModel> getCaseDetail(String id) async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(300)));
    return CaseModel(
      id: id,
      caseNumber: 'OS/2023/542',
      title: 'Land Encroachment Dispute: Bengaluru North',
      status: 'Active',
      filingDate: DateTime(2023, 5, 12),
      nextHearingDate: DateTime(2026, 5, 20),
      courtName: 'Karnataka High Court',
      judgeName: 'Hon\'ble Justice B. Vishwanath',
      courtHall: 'Court Hall 14',
      lastOrderSummary: 'The respondent is directed to file a counter-affidavit within four weeks. List the matter for final hearing on the next date.',
      predictionConfidence: 0.78,
    );
  }

  @override
  Future<CaseInsight> getCaseInsight(String caseId) async {
    await Future.delayed(Duration(milliseconds: 1000 + _random.nextInt(500)));
    return CaseInsight(
      title: "Insight",
      message: "Similar cases in Karnataka High Court have a 68% success rate for appellants in land disputes.",
      positives: [
        "Strong precedent similarity (State vs. Gowda 2018)",
        "High hearing count indicates thorough examination",
        "Documentary evidence matches successful patterns"
      ],
      negatives: [
        "Recent policy changes might affect outcome",
        "Extended duration in lower court noted"
      ],
      confidence: 0.72,
      riskLevel: "Medium",
    );
  }
}

class ApiLegalRepository implements LegalRepository {
  final String baseUrl = 'https://nyaymarg-api.onrender.com/api/v1';

  @override
  Future<List<Court>> getCourts({String? location}) async {
    final response = await http.get(Uri.parse('$baseUrl/courts/?state=${location ?? ""}'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Court.fromJson(json)).toList();
    }
    throw Exception('Failed to load courts');
  }

  @override
  Future<List<CaseModel>> getCases({String? courtId}) async {
    final url = courtId != null 
        ? '$baseUrl/courts/$courtId/cases'
        : '$baseUrl/cases/';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => CaseModel.fromJson(json)).toList();
    }
    throw Exception('Failed to load cases');
  }

  @override
  Future<CaseModel> getCaseDetail(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/cases/$id'));
    if (response.statusCode == 200) {
      return CaseModel.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load case detail');
  }

  @override
  Future<CaseInsight> getCaseInsight(String caseId) async {
    // Mapping to kanoon.dev insights as per api.txt
    final response = await http.get(Uri.parse('$baseUrl/kd/case/$caseId/insights'));
    if (response.statusCode == 200) {
      return CaseInsight.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load case insights');
  }
}
