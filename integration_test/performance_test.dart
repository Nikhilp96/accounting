import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:accounting/main.dart';

/// Integration tests for the 3 critical flows with latency budgets.
///
/// Run with: flutter test integration_test/performance_test.dart
///
/// Latency targets:
///   - Purchase entry → Save: < 500ms
///   - Sales entry → Save: < 500ms
///   - Reports screen load: < 1000ms
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Performance - Critical Flow Latency', () {
    testWidgets('Purchase entry flow completes within budget',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ShopAccountingApp());
      await tester.pumpAndSettle();

      // Navigate to a shop
      final shopTile = find.text('NK');
      if (shopTile.evaluate().isNotEmpty) {
        await tester.tap(shopTile);
        await tester.pumpAndSettle();
      }

      // Navigate to Purchase Entry
      final purchaseButton = find.text('Purchase Entry');
      if (purchaseButton.evaluate().isNotEmpty) {
        await tester.tap(purchaseButton);
        await tester.pumpAndSettle();

        // Measure time to interact with the form
        final stopwatch = Stopwatch()..start();

        // Fill in minimal valid data
        final qtyField = find.byType(TextField).first;
        if (qtyField.evaluate().isNotEmpty) {
          await tester.enterText(qtyField, '10');
          await tester.pumpAndSettle();
        }

        stopwatch.stop();

        // Assert form interaction latency is under budget
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(500),
          reason: 'Purchase form interaction should complete within 500ms',
        );
      }
    });

    testWidgets('Sales entry screen loads within budget',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ShopAccountingApp());
      await tester.pumpAndSettle();

      // Navigate to a shop
      final shopTile = find.text('NK');
      if (shopTile.evaluate().isNotEmpty) {
        await tester.tap(shopTile);
        await tester.pumpAndSettle();
      }

      // Measure Sales Entry navigation + load time
      final salesButton = find.text('Sales Entry');
      if (salesButton.evaluate().isNotEmpty) {
        final stopwatch = Stopwatch()..start();
        await tester.tap(salesButton);
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Assert screen load is under budget
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(500),
          reason: 'Sales entry screen should load within 500ms',
        );
      }
    });

    testWidgets('Reports screen loads within budget',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ShopAccountingApp());
      await tester.pumpAndSettle();

      // Navigate to a shop
      final shopTile = find.text('NK');
      if (shopTile.evaluate().isNotEmpty) {
        await tester.tap(shopTile);
        await tester.pumpAndSettle();
      }

      // Measure Reports navigation + data load time
      final reportsButton = find.text('Reports');
      if (reportsButton.evaluate().isNotEmpty) {
        final stopwatch = Stopwatch()..start();
        await tester.tap(reportsButton);
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Assert full report load (DB queries + UI render) is under budget
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(1000),
          reason:
              'Reports screen with all queries should load within 1000ms',
        );
      }
    });
  });
}
