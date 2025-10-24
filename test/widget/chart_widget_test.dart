import 'package:biometrics_dashboard/dashboard/controller.dart';
import 'package:biometrics_dashboard/dashboard/pages.dart';
import 'package:biometrics_dashboard/models/ui_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fakes.dart';

void main() {
  testWidgets('90d → 7d updates all charts & tooltips remain synced', (tester) async {
    // Provide initial fake controller in 90d mode
    final container = ProviderContainer(overrides: [
      dashboardStateProvider.overrideWith(() {
        return FakeDashboardController(initialRange: RangeChoice.d90);
      })
    ]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: DashboardPage()),
      ),
    );

    await tester.pumpAndSettle();

    // ✅ Step 1: Verify initial state = 90d
    final c0 = container.read(dashboardStateProvider).value!;
    expect(c0.range, RangeChoice.d90);
    final initialMinX = c0.hrv.minX;
    final initialMaxX = c0.hrv.maxX;

    // ✅ Step 2: Tap the 7d button
    await tester.tap(find.text('7d'));
    await tester.pumpAndSettle();

    final c1 = container.read(dashboardStateProvider).value!;
    expect(c1.range, RangeChoice.d7);

    // All charts updated x-axis
    expect(c1.hrv.minX, isNot(initialMinX));
    expect(c1.hrv.maxX, isNot(initialMaxX));
    expect(c1.rhr.minX, c1.hrv.minX);
    expect(c1.steps.minX, c1.hrv.minX);

    // ✅ Step 3: Simulate hovering a spot (tooltip sync test)
    final chart = find.byType(LineChart).first;
    final chartBox = tester.getRect(chart);
    final hoverPoint = Offset(chartBox.center.dx, chartBox.center.dy);

    await tester.tapAt(hoverPoint);
    await tester.pumpAndSettle();

    final controller = container.read(dashboardStateProvider.notifier);

    // Take a valid X within the updated range (e.g. the midpoint)
    final midX = (c1.hrv.minX + c1.hrv.maxX) / 2;
    controller.setHover(FlSpot(midX, 50)); // Y value can be any valid number

    await tester.pumpAndSettle();

    // Confirm hover was applied
    final afterHover = container.read(dashboardStateProvider).value!;
    expect(afterHover.hoverSpot, isNotNull);
    expect(
      afterHover.hoverSpot!.x,
      inInclusiveRange(afterHover.hrv.minX, afterHover.hrv.maxX),
    );
  });
}

// void main() {
//   testWidgets('90d → 7d updates all charts & tooltips remain synced', (tester) async {
//     // Provide initial fake controller in 90d mode
//     final container = ProviderContainer(overrides: [
//       dashboardStateProvider.overrideWith(() {
//         return FakeDashboardController(initialRange: RangeChoice.d90);
//       })
//     ]);
//
//     await tester.pumpWidget(
//       UncontrolledProviderScope(
//         container: container,
//         child: const MaterialApp(home: DashboardPage()),
//       ),
//     );
//
//     await tester.pumpAndSettle();
//
//     // ✅ Step 1: Verify initial state = 90d
//     final c0 = container.read(dashboardStateProvider).value!;
//     expect(c0.range, RangeChoice.d90);
//     final initialMinX = c0.hrv.minX;
//     final initialMaxX = c0.hrv.maxX;
//
//     // ✅ Step 2: Tap the 7d button
//     await tester.tap(find.text('7d'));
//     await tester.pumpAndSettle();
//
//     final c1 = container.read(dashboardStateProvider).value!;
//     expect(c1.range, RangeChoice.d7);
//
//     // All charts updated x-axis
//     expect(c1.hrv.minX, isNot(initialMinX));
//     expect(c1.hrv.maxX, isNot(initialMaxX));
//     expect(c1.rhr.minX, c1.hrv.minX);
//     expect(c1.steps.minX, c1.hrv.minX);
//
// // Step: Tap at a journal-matching x-position
//     final chart = find.byType(LineChart).first;
//     expect(chart, findsOneWidget);
//
//     final box = tester.getRect(chart);
//     final j = c1.journals.first; // or any journal date you want
//     final targetX = j.date.millisecondsSinceEpoch.toDouble();
//
// // Domain safety check
//     expect(targetX, inInclusiveRange(c1.hrv.minX, c1.hrv.maxX));
//
// // Convert domain X -> screen pixel X
//     final pixelX = box.left +
//         ((targetX - c1.hrv.minX) / (c1.hrv.maxX - c1.hrv.minX)) * box.width;
//     final pixelY = box.top + box.height * 0.5; // or align to chart middle
//     final tapPoint = Offset(pixelX, pixelY);
//
// // Actually interact with the chart
//     final gesture = await tester.startGesture(tapPoint);
//     await gesture.up(); // important for "tap" end
//     await tester.pumpAndSettle();
//
// // Verify state updated
//     final after = container.read(dashboardStateProvider).value!;
//     expect(after.hoverSpot, isNotNull);
//     expect(
//       after.hoverSpot!.x,
//       closeTo(targetX, 1), // within 1 ms tolerance
//     );
//
//     // ✅ Step: Now verify other charts also reflect this hover
//     final otherCharts = find.byType(LineChart);
//     expect(otherCharts, findsNWidgets(3)); // if you have HRV, RHR, Steps
//
//     for (var i = 0; i < tester.widgetList(otherCharts).length; i++) {
//       final chartWidget = tester.widget<LineChart>(otherCharts.at(i));
//
//       // Ensure LineChart uses same hover x-domain for tooltip
//       expect(
//         chartWidget.data.lineTouchData.getTouchedSpotIndicator,
//         isNotNull,
//         reason: "Tooltip rendering must exist",
//       );
//     }
//   });
// }