import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/models/diagnosis_list_item.dart';
import '../data/models/history_filter.dart';
import '../data/repositories/history_repository.dart';
import 'repository_providers.dart';

final historyFilterProvider = StateProvider<HistoryFilter>((ref) => const HistoryFilter());

class HistoryListState {
  const HistoryListState({
    required this.items,
    required this.hasMore,
    required this.isLoadingMore,
    required this.page,
  });

  final List<DiagnosisListItem> items;
  final bool hasMore;
  final bool isLoadingMore;
  final int page;

  HistoryListState copyWith({
    List<DiagnosisListItem>? items,
    bool? hasMore,
    bool? isLoadingMore,
    int? page,
  }) => HistoryListState(
    items: items ?? this.items,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    page: page ?? this.page,
  );
}

class HistoryListNotifier extends AsyncNotifier<HistoryListState> {
  HistoryRepository get _repo => ref.watch(historyRepositoryProvider);

  @override
  Future<HistoryListState> build() async {
    final filter = ref.watch(historyFilterProvider);
    final result = await _repo.getDiagnoses(filter: filter, page: 0);
    return HistoryListState(items: result.items, hasMore: result.hasMore, isLoadingMore: false, page: 0);
  }

  Future<void> loadNextPage() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final filter = ref.read(historyFilterProvider);
    final nextPage = current.page + 1;
    final result = await _repo.getDiagnoses(filter: filter, page: nextPage);
    state = AsyncData(
      HistoryListState(
        items: [...current.items, ...result.items],
        hasMore: result.hasMore,
        isLoadingMore: false,
        page: nextPage,
      ),
    );
  }
}

final historyListProvider =
    AsyncNotifierProvider<HistoryListNotifier, HistoryListState>(HistoryListNotifier.new);
