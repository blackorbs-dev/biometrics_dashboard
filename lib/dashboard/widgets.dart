import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/journal_entry.dart';
import '../models/ui_state.dart';
import 'controller.dart';

class RangePicker extends StatelessWidget {
  final RangeChoice selected;
  final bool isLoading;
  final ValueChanged<RangeChoice> onSelect;

  const RangePicker({super.key, required this.selected, required this.isLoading, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ChoiceChip(label: const Text('7d'), selected: selected == RangeChoice.d7, onSelected: isLoading ? null : (_) => onSelect(RangeChoice.d7)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ChoiceChip(label: const Text('30d'), selected: selected == RangeChoice.d30, onSelected: isLoading ? null : (_) => onSelect(RangeChoice.d30)),
      ),
      ChoiceChip(label: const Text('90d'), selected: selected == RangeChoice.d90, onSelected: isLoading ? null : (_) => onSelect(RangeChoice.d90)),
    ]);
  }
}

class ChartCard extends ConsumerWidget {
  final ChartType type;

  const ChartCard({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardStateProvider).requireValue;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    DateTime? lastDrawnDate;

    // Define chart color styles depending on theme
    final chartData = switch (type) {
      ChartType.hrv => _ChartData(
        series: state.hrv,
        title: "Heart Rate Variability (HRV)",
        unit: "ms",
        baseColor: isDark ? Colors.tealAccent.shade200 : Colors.teal,
        colorGradient: isDark
            ? [Colors.tealAccent.shade700, Colors.tealAccent.shade400]
            : [Colors.tealAccent.shade400, Colors.teal.shade400],
      ),
      ChartType.rhr => _ChartData(
        series: state.rhr,
        title: "Resting Heart Rate (RHR)",
        unit: "bpm",
        baseColor: isDark ? Colors.redAccent.shade200 : Colors.redAccent,
        colorGradient: isDark
            ? [Colors.redAccent.shade100, Colors.redAccent.shade400]
            : [Colors.redAccent.shade100, Colors.red.shade400],
      ),
      ChartType.steps => _ChartData(
        series: state.steps,
        title: "Daily Steps",
        unit: "steps",
        baseColor: isDark ? Colors.indigoAccent.shade200 : Colors.indigo,
        colorGradient: isDark
            ? [Colors.indigoAccent.shade100, Colors.indigoAccent.shade400]
            : [Colors.indigoAccent.shade100, Colors.indigo.shade400],
      ),
    };

    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      chartData.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      chartData.unit,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.textTheme.titleSmall?.color?.withAlpha(150),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 182,
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                          touchCallback: (FlTouchEvent event, LineTouchResponse? resp) {
                            if (!event.isInterestedForInteractions || resp == null) {
                              ref.read(dashboardStateProvider.notifier).clearHover();
                              return;
                            }
                            final spot = resp.lineBarSpots?.first;
                            if (spot != null) {
                              ref.read(dashboardStateProvider.notifier).setHover(spot);
                            }
                          },
                          touchTooltipData: LineTouchTooltipData(
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                              maxContentWidth: 200,
                              tooltipBorderRadius: BorderRadius.circular(12),
                              getTooltipItems: (List<LineBarSpot> spots) {
                                return spots.map((spot) {
                                  final dt = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                                  final journal = state.journals.firstWhere( (j) => j.date.year == dt.year && j.date.month == dt.month && j.date.day == dt.day,
                                    orElse: () => JournalEntry(date: DateTime(0), mood: -1, note: ''),
                                  );
                                  if(journal.mood == -1) return null;
                                  return LineTooltipItem(
                                      'Journal Entry\n',
                                      theme.textTheme.titleMedium!.copyWith( color: Colors.white),
                                      textAlign: TextAlign.left,
                                      children: [
                                        TextSpan( text: 'Mood: ', style: theme.textTheme.titleSmall!.copyWith(color: Colors.white70), ),
                                        TextSpan( text: '\u2605\u2605\u2605\u2605\u2605\n', style: theme.textTheme.titleSmall!.copyWith( color: Colors.orange ), ),
                                        TextSpan( text: journal.note, style: theme.textTheme.titleSmall!.copyWith(color: Colors.white70), ),
                                      ]
                                  );
                                }).toList();
                              }
                          )
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: theme.dividerColor.withAlpha(15),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(),
                        rightTitles: const AxisTitles(),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: type == ChartType.steps ? 42 : 28,
                            getTitlesWidget: (v, _) => Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                v.toStringAsFixed(0),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.textTheme.bodyMedium?.color?.withAlpha(150),
                                ),
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: (chartData.series.maxX - chartData.series.minX) / 4,
                            getTitlesWidget: (v, _) {
                              final dt = DateTime.fromMillisecondsSinceEpoch(v.toInt());
                              if (lastDrawnDate != null && state.range != RangeChoice.d7) {
                                final diff = dt.difference(lastDrawnDate!).inDays;
                                if (diff.abs() < 5) return const SizedBox.shrink();
                              }
                              lastDrawnDate = dt;
                              return Text(
                                DateFormat('MMM d').format(dt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodyMedium?.color?.withAlpha(150),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        border: Border.all(color: theme.dividerColor.withAlpha(20)),
                      ),
                      minX: chartData.series.minX,
                      maxX: chartData.series.maxX,
                      minY: chartData.series.minY,
                      maxY: chartData.series.maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData.series.spots,
                          isCurved: true,
                          barWidth: 3,
                          gradient: LinearGradient(colors: chartData.colorGradient),
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: chartData.colorGradient
                                  .map((c) => c.withAlpha(15)).toList(),
                            ),
                          ),
                        ),
                      ],
                      extraLinesData: ExtraLinesData(
                        verticalLines: state.hoverSpot != null ? [
                          VerticalLine(
                            x: state.hoverSpot!.x,
                            color: chartData.baseColor.withAlpha(160),
                            strokeWidth: 1,
                          )
                        ] : [],
                      ),
                    ),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  ),
                ),
              ],
            ),
          ),
          if (state.loading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(30),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: theme.cardColor,
                  child: CupertinoActivityIndicator(
                    radius: 16,
                    color: chartData.baseColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChartData {
  final ChartSeries series;
  final String title;
  final String unit;
  final Color baseColor;
  final List<Color> colorGradient;

  const _ChartData({required this.series, required this.title, required this.unit, required this.baseColor, required this.colorGradient});
}

class StatusView extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String actionText;

  const StatusView({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionText = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(38),
                ),
                child: Icon(icon, color: iconColor, size: 46),
              ),
              Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
              if (onAction != null) ...[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onAction,
                  child: Text(actionText),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
