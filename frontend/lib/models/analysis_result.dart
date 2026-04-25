class AnalysisResult {
  final String prediction;
  final double confidence;
  final String riskLevel;
  final String heatmapUrl;
  final String recommendation;
  // Extended fields
  final double whitePatchScore;
  final List<String> affectedZones;
  final String symptomRisk;

  AnalysisResult({
    required this.prediction,
    required this.confidence,
    required this.riskLevel,
    required this.heatmapUrl,
    required this.recommendation,
    this.whitePatchScore = 0.0,
    this.affectedZones = const [],
    this.symptomRisk = 'LOW',
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      prediction: json['prediction'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      riskLevel: json['risk_level'] ?? 'LOW',
      heatmapUrl: json['heatmap_url'] ?? '',
      recommendation: json['recommendation'] ?? '',
      whitePatchScore: (json['white_patch_score'] ?? 0.0).toDouble(),
      affectedZones: List<String>.from(json['affected_zones'] ?? []),
      symptomRisk: json['symptom_risk'] ?? 'LOW',
    );
  }

  Map<String, dynamic> toJson() => {
    'prediction': prediction,
    'confidence': confidence,
    'risk_level': riskLevel,
    'heatmap_url': heatmapUrl,
    'recommendation': recommendation,
    'white_patch_score': whitePatchScore,
    'affected_zones': affectedZones,
    'symptom_risk': symptomRisk,
  };

  String get predictionDisplay {
    switch (prediction) {
      case 'TB_DETECTED':          return 'TB Detected';
      case 'PNEUMONIA_DETECTED':   return 'Pneumonia Detected';
      case 'NORMAL':               return 'Normal';
      default: return prediction.replaceAll('_', ' ');
    }
  }
}
