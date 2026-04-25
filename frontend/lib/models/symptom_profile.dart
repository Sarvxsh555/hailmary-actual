/// Holds a user's symptom answers from the symptom analysis screen.
class SymptomProfile {
  final String? feverLevel;   // null | 'None' | 'Low' | 'Mid' | 'High'
  final String? coughType;    // null | 'None' | 'Dry' | 'Extreme'
  final bool hasSweats;
  final bool hasWeightLoss;
  final bool hasLossAppetite;
  final bool hasFatigue;
  final bool hasChestPain;
  final String duration;

  const SymptomProfile({
    this.feverLevel,
    this.coughType,
    this.hasSweats       = false,
    this.hasWeightLoss   = false,
    this.hasLossAppetite = false,
    this.hasFatigue      = false,
    this.hasChestPain    = false,
    this.duration        = '< 1 Week',
  });

  /// Compute a simple numeric severity score
  int get score {
    int s = 0;
    if (feverLevel == 'High') s += 3;
    else if (feverLevel == 'Mid') s += 2;
    else if (feverLevel == 'Low') s += 1;
    if (coughType == 'Extreme') s += 3;
    else if (coughType == 'Dry') s += 2;
    if (hasSweats)        s += 2;
    if (hasWeightLoss)    s += 2;
    if (hasLossAppetite)  s += 1;
    if (hasFatigue)       s += 1;
    if (hasChestPain)     s += 2;
    return s;
  }

  String get riskCategory {
    final s = score;
    if (s >= 10) return 'HIGH';
    if (s >= 5)  return 'MODERATE';
    if (s >= 1)  return 'LOW';
    return 'NONE';
  }

  /// Flat map for API submission
  Map<String, dynamic> toMap() => {
    'fever': feverLevel ?? 'None',
    'cough': coughType ?? 'None',
    'sweats': hasSweats,
    'weight_loss': hasWeightLoss,
    'loss_appetite': hasLossAppetite,
    'fatigue': hasFatigue,
    'chest_pain': hasChestPain,
    'duration': duration,
    'symptom_score': score,
    'risk_category': riskCategory,
  };
}
