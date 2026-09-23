import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/color_tokens.dart';
import '../../providers/history_providers.dart';
import '../../providers/zones_providers.dart';
import '../../shared/widgets/state_views.dart';
import 'widgets/history_filter_bar.dart';
import 'widgets/history_list_tile.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key, this.preselectZoneId});
  final String? preselectZoneId;

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _scrollController = ScrollController();
  bool _appliedPreselect = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
      ref.read(historyListProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_appliedPreselect && widget.preselectZoneId != null) {
      _appliedPreselect = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(historyFilterProvider.notifier).state =
            ref.read(historyFilterProvider).copyWith(zoneId: widget.preselectZoneId);
      });
    }

    final filter = ref.watch(historyFilterProvider);
    final listAsync = ref.watch(historyListProvider);
    final zonesAsync = ref.watch(zonesProvider);

    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
              child: Text('Riwayat', style: GoogleFonts.fraunces(fontSize: 22, fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: HistoryFilterBar(
                filter: filter,
                zones: zonesAsync.value ?? [],
                onChanged: (f) => ref.read(historyFilterProvider.notifier).state = f,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: listAsync.when(
                loading: () => const LoadingView(),
                error: (e, _) => ErrorStateView(
                  message: 'Gagal memuat riwayat: $e',
                  onRetry: () => ref.invalidate(historyListProvider),
                ),
                data: (state) {
                  if (state.items.isEmpty) {
                    return const EmptyState(message: 'Belum ada diagnosis yang cocok dengan filter ini.');
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(historyListProvider),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                      itemCount: state.items.length + (state.hasMore ? 1 : 0),
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        if (index >= state.items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.moss),
                              ),
                            ),
                          );
                        }
                        return HistoryListTile(item: state.items[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
