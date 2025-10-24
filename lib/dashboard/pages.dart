import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ui_state.dart';
import 'controller.dart';
import 'widgets.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final stateAsync = ref.watch(dashboardStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometrics Dashboard', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: stateAsync.whenOrNull(
            data: (state) => [
              IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: state.loading ? null : () => ref.read(dashboardStateProvider.notifier).reload()
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(children: [
                    const Text('Large'),
                    Switch(
                        value: state.large,
                        onChanged: state.loading ? null : (value) {
                          ref.read(dashboardStateProvider.notifier).toggleLarge(value);
                        }
                    )
                  ])
              )
            ]
        ),
      ),
      body: stateAsync.when(
        loading: () => const Center(
            child: CupertinoActivityIndicator(radius: 22,)
        ),
        skipLoadingOnRefresh: false,
        error: (e, st) => StatusView(
            icon: Icons.error_outline,
            iconColor: Colors.red.shade400,
            title: 'Failed to load data',
            onAction: () => ref.read(dashboardStateProvider.notifier).reload(),
            subtitle: e.toString()
        ),
        data: (state) {
          if (state.raw.isEmpty) {
            return const StatusView(
              icon: Icons.hourglass_empty_rounded,
              iconColor: Colors.grey,
              title: 'No Data Available',
            );
          }
          return DashboardBody(
            range: state.range,
            isLoading: state.loading,
            onRangeSelected: (value){
              ref.read(dashboardStateProvider.notifier).setRange(value);
            },
          );
        },
      ),
    );
  }
}

class DashboardBody extends StatelessWidget {
  final RangeChoice range;
  final bool isLoading;
  final ValueChanged<RangeChoice> onRangeSelected;

  const DashboardBody({super.key, required this.range, required this.isLoading, required this.onRangeSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(children: [
        RangePicker(
            selected: range,
            isLoading: isLoading,
            onSelect: onRangeSelected
        ),
        ChartCard(
            type: ChartType.hrv
        ),
        ChartCard(
            type: ChartType.rhr
        ),
        ChartCard(
            type: ChartType.steps
        ),
      ]),
    );
  }
}