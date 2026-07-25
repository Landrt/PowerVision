import 'dart:math' as math;

/// Represents the risk classification level according to VoltCam spec (Section 7).
enum RiskTier {
  /// 0-39: Normal voltage behavior.
  stable,

  /// 40-69: Instability or fluctuations detected.
  monitor,

  /// 70-100: Critical over/undervoltage, micro-outages, or extreme staleness.
  protect;

  /// Returns lower bound of score range (inclusive).
  int get minScore {
    switch (this) {
      case RiskTier.stable:
        return 0;
      case RiskTier.monitor:
        return 40;
      case RiskTier.protect:
        return 70;
    }
  }

  /// Returns upper bound of score range (inclusive).
  int get maxScore {
    switch (this) {
      case RiskTier.stable:
        return 39;
      case RiskTier.monitor:
        return 69;
      case RiskTier.protect:
        return 100;
    }
  }

  /// Display name in French per spec.
  String get label {
    switch (this) {
      case RiskTier.stable:
        return 'Stable';
      case RiskTier.monitor:
        return 'À surveiller';
      case RiskTier.protect:
        return 'Protéger';
    }
  }

  /// Action recommendation text in French per spec Section 7.
  String get actionRecommendation {
    switch (this) {
      case RiskTier.stable:
        return 'Continuer la surveillance normale';
      case RiskTier.monitor:
        return "Éviter de brancher des appareils sensibles tant que l'instabilité persiste";
      case RiskTier.protect:
        return 'Débrancher de façon sûre les appareils sensibles et attendre une tension stable';
    }
  }
}

/// Appliance safety tip for a specific appliance type and risk level.
class ApplianceSafetyTip {
  final String categoryKey;
  final String name;
  final RiskTier riskTier;
  final String advice;
  final String urgency;

  const ApplianceSafetyTip({
    required this.categoryKey,
    required this.name,
    required this.riskTier,
    required this.advice,
    required this.urgency,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryKey': categoryKey,
      'name': name,
      'riskTier': riskTier.name,
      'advice': advice,
      'urgency': urgency,
    };
  }
}

/// Input parameters for calculating risk score.
class RiskScoreInput {
  /// Recent RMS voltage reading in Volts.
  final double recentVoltage;

  /// Target nominal grid voltage (defaults to 220.0V in Cameroon).
  final double nominalVoltage;

  /// Voltage variance or standard deviation over recent window in Volts.
  final double voltageVariance;

  /// Count of micro-outages detected in recent observation window.
  final int microOutageCount;

  /// Timestamp when the telemetry measurement was recorded.
  final DateTime lastTelemetryTimestamp;

  /// Reference current timestamp (defaults to DateTime.now() if null).
  final DateTime? currentTimestamp;

  const RiskScoreInput({
    required this.recentVoltage,
    this.nominalVoltage = 220.0,
    this.voltageVariance = 0.0,
    this.microOutageCount = 0,
    required this.lastTelemetryTimestamp,
    this.currentTimestamp,
  });
}

/// Breakdown of score sub-components for transparency and explainability.
class RiskScoreBreakdown {
  final double voltageDeviationPenalty;
  final double variancePenalty;
  final double microOutagePenalty;
  final double staleDataPenalty;
  final int totalScore;

  const RiskScoreBreakdown({
    required this.voltageDeviationPenalty,
    required this.variancePenalty,
    required this.microOutagePenalty,
    required this.staleDataPenalty,
    required this.totalScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'voltageDeviationPenalty': voltageDeviationPenalty,
      'variancePenalty': variancePenalty,
      'microOutagePenalty': microOutagePenalty,
      'staleDataPenalty': staleDataPenalty,
      'totalScore': totalScore,
    };
  }
}

/// Assessment result produced by [RiskScoreCalculator].
class RiskAssessmentResult {
  final int score;
  final RiskTier tier;
  final String label;
  final String recommendation;
  final RiskScoreBreakdown breakdown;
  final List<ApplianceSafetyTip> applianceTips;
  final DateTime calculatedAt;

  const RiskAssessmentResult({
    required this.score,
    required this.tier,
    required this.label,
    required this.recommendation,
    required this.breakdown,
    required this.applianceTips,
    required this.calculatedAt,
  });
}

/// Engine for calculating Protect Mode Risk Score (0-100) and producing safety guidance.
class RiskScoreCalculator {
  /// Default nominal voltage in Cameroon grid (220V or 230V standard).
  static const double defaultNominalVoltage = 220.0;

  /// Classifies a numeric risk score (0-100) into a [RiskTier].
  static RiskTier classifyScore(int score) {
    final clamped = score.clamp(0, 100);
    if (clamped <= 39) {
      return RiskTier.stable;
    } else if (clamped <= 69) {
      return RiskTier.monitor;
    } else {
      return RiskTier.protect;
    }
  }

  /// Calculates the risk score and produces full risk assessment result.
  static RiskAssessmentResult calculate(RiskScoreInput input) {
    final now = input.currentTimestamp ?? DateTime.now();

    // 1. Voltage Deviation Penalty (0 - 70 points)
    // Nominal voltage in Cameroon: 220V
    final nominal = input.nominalVoltage > 0 ? input.nominalVoltage : defaultNominalVoltage;
    final v = input.recentVoltage;
    double vPenalty = 0.0;

    if (v <= 0) {
      // Zero voltage / Complete power loss
      vPenalty = 70.0;
    } else {
      final diff = (v - nominal).abs();
      // Tolerance threshold: ±10V deviation gets minimal penalty
      if (diff <= 10.0) {
        vPenalty = (diff / 10.0) * 5.0; // 0 to 5 pts
      } else if (diff <= 25.0) {
        // Mild deviation (e.g. 195V - 210V or 230V - 245V)
        vPenalty = 5.0 + ((diff - 10.0) / 15.0) * 25.0; // 5 to 30 pts
      } else if (diff <= 50.0) {
        // Moderate to severe deviation (e.g. 170V - 195V or 245V - 270V)
        vPenalty = 30.0 + ((diff - 25.0) / 25.0) * 35.0; // 30 to 65 pts
      } else {
        // Extreme deviation (< 170V or > 270V)
        vPenalty = 70.0;
      }
    }

    // 2. Voltage Variance / Fluctuation Penalty (0 - 30 points)
    final varVal = input.voltageVariance < 0 ? 0.0 : input.voltageVariance;
    double varPenalty = 0.0;
    if (varVal <= 2.0) {
      varPenalty = (varVal / 2.0) * 3.0; // 0 to 3 pts
    } else if (varVal <= 10.0) {
      varPenalty = 3.0 + ((varVal - 2.0) / 8.0) * 17.0; // 3 to 20 pts
    } else {
      varPenalty = 20.0 + math.min((varVal - 10.0) * 1.0, 10.0); // up to 30 pts
    }

    // 3. Micro-Outage Frequency Penalty (0 - 30 points)
    final outageCount = math.max(0, input.microOutageCount);
    double outagePenalty = 0.0;
    if (outageCount == 0) {
      outagePenalty = 0.0;
    } else if (outageCount == 1) {
      outagePenalty = 15.0;
    } else if (outageCount == 2) {
      outagePenalty = 25.0;
    } else {
      outagePenalty = 30.0;
    }

    // 4. Telemetry Data Age / Stale Data Penalty (0 - 25 points)
    final ageInMinutes = math.max(0, now.difference(input.lastTelemetryTimestamp).inMinutes);
    double agePenalty = 0.0;
    if (ageInMinutes <= 5) {
      agePenalty = 0.0;
    } else if (ageInMinutes <= 15) {
      agePenalty = 5.0 + ((ageInMinutes - 5) / 10.0) * 5.0; // 5 to 10 pts
    } else if (ageInMinutes <= 60) {
      agePenalty = 10.0 + ((ageInMinutes - 15) / 45.0) * 10.0; // 10 to 20 pts
    } else {
      agePenalty = 25.0;
    }

    // Calculate total score bounded strictly 0 - 100
    final rawTotal = vPenalty + varPenalty + outagePenalty + agePenalty;
    final finalScore = rawTotal.round().clamp(0, 100);

    final tier = classifyScore(finalScore);
    final breakdown = RiskScoreBreakdown(
      voltageDeviationPenalty: double.parse(vPenalty.toStringAsFixed(1)),
      variancePenalty: double.parse(varPenalty.toStringAsFixed(1)),
      microOutagePenalty: double.parse(outagePenalty.toStringAsFixed(1)),
      staleDataPenalty: double.parse(agePenalty.toStringAsFixed(1)),
      totalScore: finalScore,
    );

    final tips = getApplianceSafetyTips(tier);

    return RiskAssessmentResult(
      score: finalScore,
      tier: tier,
      label: tier.label,
      recommendation: tier.actionRecommendation,
      breakdown: breakdown,
      applianceTips: tips,
      calculatedAt: now,
    );
  }

  /// Provides detailed appliance safety tips tailored to the given [RiskTier].
  static List<ApplianceSafetyTip> getApplianceSafetyTips(RiskTier tier) {
    switch (tier) {
      case RiskTier.stable:
        return const [
          ApplianceSafetyTip(
            categoryKey: 'refrigerator',
            name: 'Réfrigérateurs & Congélateurs',
            riskTier: RiskTier.stable,
            advice: 'Tension stable. Éviter d\'ouvrir inutilement les portes pour maintenir le froid.',
            urgency: 'LOW',
          ),
          ApplianceSafetyTip(
            categoryKey: 'tv',
            name: 'Téléviseurs & Matériel Audiovisuel',
            riskTier: RiskTier.stable,
            advice: 'Aucun risque majeur détecté. Utilisation normale autorisée.',
            urgency: 'LOW',
          ),
          ApplianceSafetyTip(
            categoryKey: 'laptop',
            name: 'Ordinateurs & Serveurs',
            riskTier: RiskTier.stable,
            advice: 'Alimentation secteur stable. Rechargement normal des batteries.',
            urgency: 'LOW',
          ),
          ApplianceSafetyTip(
            categoryKey: 'ac_unit',
            name: 'Climatiseurs & Moteurs',
            riskTier: RiskTier.stable,
            advice: 'Fonctionnement nominal sans baisse de tension.',
            urgency: 'LOW',
          ),
        ];

      case RiskTier.monitor:
        return const [
          ApplianceSafetyTip(
            categoryKey: 'refrigerator',
            name: 'Réfrigérateurs & Congélateurs',
            riskTier: RiskTier.monitor,
            advice: 'Surveiller les baisses de tension. Utiliser un protecteur de surtension à délai de démarrage (3-5 min).',
            urgency: 'MEDIUM',
          ),
          ApplianceSafetyTip(
            categoryKey: 'tv',
            name: 'Téléviseurs & Matériel Audiovisuel',
            riskTier: RiskTier.monitor,
            advice: 'Éviter de laisser les téléviseurs et décodeurs en veille sans prise régulée.',
            urgency: 'MEDIUM',
          ),
          ApplianceSafetyTip(
            categoryKey: 'laptop',
            name: 'Ordinateurs & Serveurs',
            riskTier: RiskTier.monitor,
            advice: 'Utiliser si possible un onduleur (UPS) ou passer le PC portable sur batterie.',
            urgency: 'MEDIUM',
          ),
          ApplianceSafetyTip(
            categoryKey: 'ac_unit',
            name: 'Climatiseurs & Moteurs',
            riskTier: RiskTier.monitor,
            advice: 'Éteindre les climatiseurs si la tension chute en dessous de 200V pour préserver le compresseur.',
            urgency: 'MEDIUM',
          ),
        ];

      case RiskTier.protect:
        return const [
          ApplianceSafetyTip(
            categoryKey: 'refrigerator',
            name: 'Réfrigérateurs & Congélateurs',
            riskTier: RiskTier.protect,
            advice: 'Débrancher immédiatement les moteurs et compresseurs. Risque très élevé de surchauffe et grillage.',
            urgency: 'HIGH',
          ),
          ApplianceSafetyTip(
            categoryKey: 'tv',
            name: 'Téléviseurs & Matériel Audiovisuel',
            riskTier: RiskTier.protect,
            advice: 'Débrancher impérativement les prises TV, consoles et décodeurs pour éviter un choc électrique.',
            urgency: 'HIGH',
          ),
          ApplianceSafetyTip(
            categoryKey: 'laptop',
            name: 'Ordinateurs & Serveurs',
            riskTier: RiskTier.protect,
            advice: 'Débrancher les chargeurs du secteur. Alimenter les appareils sensibles uniquement par UPS ou batterie.',
            urgency: 'HIGH',
          ),
          ApplianceSafetyTip(
            categoryKey: 'ac_unit',
            name: 'Climatiseurs & Moteurs',
            riskTier: RiskTier.protect,
            advice: 'Couper le disjoncteur des climatiseurs et gros équipements inductifs jusqu\'au retour de la stabilité.',
            urgency: 'HIGH',
          ),
        ];
    }
  }
}
