import 'dart:convert';

class AnalysisResult {
  final String status;
  final String detectedConflict;
  final List<String> visualFeatures;
  final String winningHypothesis;
  final double confidenceScore;
  final String reasoningTrace;
  final String recommendedAction;

  AnalysisResult({
    required this.status,
    required this.detectedConflict,
    required this.visualFeatures,
    required this.winningHypothesis,
    required this.confidenceScore,
    required this.reasoningTrace,
    required this.recommendedAction,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      status: json['status'] ?? 'Unknown',
      detectedConflict: json['detected_conflict'] ?? '',
      visualFeatures: List<String>.from(json['visual_features'] ?? []),
      winningHypothesis: json['winning_hypothesis'] ?? '',
      confidenceScore: (json['confidence_score'] ?? 0.0).toDouble(),
      reasoningTrace: json['reasoning_trace'] ?? '',
      recommendedAction: json['recommended_action'] ?? '',
    );
  }

  factory AnalysisResult.fromString(String jsonString) {
    // Try to clean markdown code blocks if present
    String cleaned = jsonString.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.replaceAll('```json', '').replaceAll('```', '');
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceAll('```', '');
    }
    
    return AnalysisResult.fromJson(jsonDecode(cleaned));
  }
}
