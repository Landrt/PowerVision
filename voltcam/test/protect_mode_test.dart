import 'package:flutter_test/flutter_test.dart';
import 'package:voltcam/domain/protect_mode/risk_score_calculator.dart';

void main() {
  group('RiskScoreCalculator - Tier Classification & Boundaries', () {
    test('classifyScore maps 0-39 to RiskTier.stable', () {
      expect(RiskScoreCalculator.classifyScore(0), equals(RiskTier.stable));
      expect(RiskScoreCalculator.classifyScore(20), equals(RiskTier.stable));
      expect(RiskScoreCalculator.classifyScore(39), equals(RiskTier.stable));
    });

    test('classifyScore maps 40-69 to RiskTier.monitor', () {
      expect(RiskScoreCalculator.classifyScore(40), equals(RiskTier.monitor));
      expect(RiskScoreCalculator.classifyScore(55), equals(RiskTier.monitor));
      expect(RiskScoreCalculator.classifyScore(69), equals(RiskTier.monitor));
    });

    test('classifyScore maps 70-100 to RiskTier.protect', () {
      expect(RiskScoreCalculator.classifyScore(70), equals(RiskTier.protect));
      expect(RiskScoreCalculator.classifyScore(85), equals(RiskTier.protect));
      expect(RiskScoreCalculator.classifyScore(100), equals(RiskTier.protect));
    });

    test('classifyScore clamps out-of-bound values', () {
      expect(RiskScoreCalculator.classifyScore(-10), equals(RiskTier.stable));
      expect(RiskScoreCalculator.classifyScore(150), equals(RiskTier.protect));
    });

    test('RiskTier properties and recommendations match spec', () {
      expect(RiskTier.stable.label, equals('Stable'));
      expect(
        RiskTier.stable.actionRecommendation,
        equals('Continuer la surveillance normale'),
      );

      expect(RiskTier.monitor.label, equals('À surveiller'));
      expect(
        RiskTier.monitor.actionRecommendation,
        equals("Éviter de brancher des appareils sensibles tant que l'instabilité persiste"),
      );

      expect(RiskTier.protect.label, equals('Protéger'));
      expect(
        RiskTier.protect.actionRecommendation,
        equals('Débrancher de façon sûre les appareils sensibles et attendre une tension stable'),
      );
    });
  });

  group('RiskScoreCalculator - Calculation Scenarios', () {
    final referenceTime = DateTime.utc(2026, 7, 24, 18, 0, 0);

    test('Stable voltage scenario (220V nominal, minimal variance, 0 outages, fresh data)', () {
      final input = RiskScoreInput(
        recentVoltage: 220.0,
        nominalVoltage: 220.0,
        voltageVariance: 0.5,
        microOutageCount: 0,
        lastTelemetryTimestamp: referenceTime,
        currentTimestamp: referenceTime,
      );

      final result = RiskScoreCalculator.calculate(input);

      expect(result.score, lessThanOrEqualTo(39));
      expect(result.tier, equals(RiskTier.stable));
      expect(result.label, equals('Stable'));
      expect(result.recommendation, equals('Continuer la surveillance normale'));
      expect(result.breakdown.voltageDeviationPenalty, equals(0.0));
      expect(result.breakdown.microOutagePenalty, equals(0.0));
      expect(result.breakdown.staleDataPenalty, equals(0.0));
    });

    test('Unstable voltage scenario (fluctuations, variance, 1 micro-outage)', () {
      final input = RiskScoreInput(
        recentVoltage: 200.0, // 20V deviation from 220V
        nominalVoltage: 220.0,
        voltageVariance: 8.0, // moderate variance
        microOutageCount: 1, // 1 micro-outage
        lastTelemetryTimestamp: referenceTime.subtract(const Duration(minutes: 2)),
        currentTimestamp: referenceTime,
      );

      final result = RiskScoreCalculator.calculate(input);

      expect(result.score, greaterThanOrEqualTo(40));
      expect(result.score, lessThanOrEqualTo(69));
      expect(result.tier, equals(RiskTier.monitor));
      expect(result.label, equals('À surveiller'));
      expect(
        result.recommendation,
        equals("Éviter de brancher des appareils sensibles tant que l'instabilité persiste"),
      );
      expect(result.breakdown.voltageDeviationPenalty, greaterThan(0.0));
      expect(result.breakdown.microOutagePenalty, equals(15.0));
    });

    test('Overvoltage scenario (265V - severe surge)', () {
      final input = RiskScoreInput(
        recentVoltage: 265.0, // +45V deviation
        nominalVoltage: 220.0,
        voltageVariance: 5.0,
        microOutageCount: 0,
        lastTelemetryTimestamp: referenceTime,
        currentTimestamp: referenceTime,
      );

      final result = RiskScoreCalculator.calculate(input);

      expect(result.score, greaterThanOrEqualTo(70));
      expect(result.tier, equals(RiskTier.protect));
      expect(result.label, equals('Protéger'));
      expect(
        result.recommendation,
        equals('Débrancher de façon sûre les appareils sensibles et attendre une tension stable'),
      );
    });

    test('Undervoltage scenario (150V - severe drop)', () {
      final input = RiskScoreInput(
        recentVoltage: 150.0, // -70V deviation
        nominalVoltage: 220.0,
        voltageVariance: 2.0,
        microOutageCount: 0,
        lastTelemetryTimestamp: referenceTime,
        currentTimestamp: referenceTime,
      );

      final result = RiskScoreCalculator.calculate(input);

      expect(result.score, greaterThanOrEqualTo(70));
      expect(result.tier, equals(RiskTier.protect));
      expect(result.label, equals('Protéger'));
    });

    test('Zero voltage outage scenario (0V)', () {
      final input = RiskScoreInput(
        recentVoltage: 0.0,
        nominalVoltage: 220.0,
        voltageVariance: 0.0,
        microOutageCount: 0,
        lastTelemetryTimestamp: referenceTime,
        currentTimestamp: referenceTime,
      );

      final result = RiskScoreCalculator.calculate(input);

      expect(result.score, greaterThanOrEqualTo(70));
      expect(result.tier, equals(RiskTier.protect));
      expect(result.breakdown.voltageDeviationPenalty, equals(70.0));
    });

    test('Micro-outage accumulation scenario', () {
      final input = RiskScoreInput(
        recentVoltage: 218.0,
        nominalVoltage: 220.0,
        voltageVariance: 1.0,
        microOutageCount: 3, // 3 micro-outages = 30 pts penalty
        lastTelemetryTimestamp: referenceTime,
        currentTimestamp: referenceTime,
      );

      final result = RiskScoreCalculator.calculate(input);

      expect(result.breakdown.microOutagePenalty, equals(30.0));
      expect(result.score, greaterThanOrEqualTo(30));
    });

    test('Stale telemetry data penalty scenario', () {
      final inputFresh = RiskScoreInput(
        recentVoltage: 220.0,
        lastTelemetryTimestamp: referenceTime,
        currentTimestamp: referenceTime,
      );

      final inputStale = RiskScoreInput(
        recentVoltage: 220.0,
        lastTelemetryTimestamp: referenceTime.subtract(const Duration(minutes: 65)),
        currentTimestamp: referenceTime,
      );

      final freshResult = RiskScoreCalculator.calculate(inputFresh);
      final staleResult = RiskScoreCalculator.calculate(inputStale);

      expect(freshResult.breakdown.staleDataPenalty, equals(0.0));
      expect(staleResult.breakdown.staleDataPenalty, equals(25.0));
      expect(staleResult.score, equals(freshResult.score + 25));
    });
  });

  group('RiskScoreCalculator - Appliance Safety Tips', () {
    test('Safety tips cover refrigerators, TVs, laptops, and AC units for Stable tier', () {
      final tips = RiskScoreCalculator.getApplianceSafetyTips(RiskTier.stable);

      expect(tips.length, equals(4));

      final keys = tips.map((t) => t.categoryKey).toList();
      expect(keys, containsAll(['refrigerator', 'tv', 'laptop', 'ac_unit']));

      for (final tip in tips) {
        expect(tip.riskTier, equals(RiskTier.stable));
        expect(tip.urgency, equals('LOW'));
        expect(tip.advice, isNotEmpty);
      }
    });

    test('Safety tips cover refrigerators, TVs, laptops, and AC units for Monitor tier', () {
      final tips = RiskScoreCalculator.getApplianceSafetyTips(RiskTier.monitor);

      expect(tips.length, equals(4));

      final keys = tips.map((t) => t.categoryKey).toList();
      expect(keys, containsAll(['refrigerator', 'tv', 'laptop', 'ac_unit']));

      for (final tip in tips) {
        expect(tip.riskTier, equals(RiskTier.monitor));
        expect(tip.urgency, equals('MEDIUM'));
        expect(tip.advice, isNotEmpty);
      }
    });

    test('Safety tips cover refrigerators, TVs, laptops, and AC units for Protect tier', () {
      final tips = RiskScoreCalculator.getApplianceSafetyTips(RiskTier.protect);

      expect(tips.length, equals(4));

      final keys = tips.map((t) => t.categoryKey).toList();
      expect(keys, containsAll(['refrigerator', 'tv', 'laptop', 'ac_unit']));

      for (final tip in tips) {
        expect(tip.riskTier, equals(RiskTier.protect));
        expect(tip.urgency, equals('HIGH'));
        expect(tip.advice.contains('Débrancher') || tip.advice.contains('Couper') || tip.advice.contains('Protect'), isTrue);
      }
    });

    test('ApplianceSafetyTip toMap serializes correctly', () {
      const tip = ApplianceSafetyTip(
        categoryKey: 'refrigerator',
        name: 'Réfrigérateurs',
        riskTier: RiskTier.protect,
        advice: 'Débrancher immédiatement.',
        urgency: 'HIGH',
      );

      final map = tip.toMap();
      expect(map['categoryKey'], equals('refrigerator'));
      expect(map['riskTier'], equals('protect'));
      expect(map['urgency'], equals('HIGH'));
    });
  });
}
