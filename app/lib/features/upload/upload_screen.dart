import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/color_tokens.dart';
import '../../data/models/zone.dart';
import '../../providers/auth_providers.dart';
import '../../providers/dashboard_providers.dart';
import '../../providers/history_providers.dart';
import '../../providers/notifications_providers.dart';
import '../../providers/upload_flow_controller.dart';
import '../../providers/zones_providers.dart';
import '../../routing/route_paths.dart';
import '../../shared/widgets/avatar_initials_chip.dart';
import '../../shared/widgets/icons.dart';
import '../../shared/widgets/severity_chip.dart';
import '../../shared/widgets/state_views.dart';
import 'widgets/camera_dropzone.dart';
import 'widgets/upload_progress_overlay.dart';
import 'widgets/upload_tips_card.dart';
import 'widgets/zone_selector_pill.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key, this.preselectZoneId});
  final String? preselectZoneId;

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final _picker = ImagePicker();
  bool _initializedSelection = false;

  Future<void> _pick(ImageSource source) async {
    final zones = ref.read(zonesProvider).value ?? [];
    final selectedZoneId = ref.read(selectedZoneIdProvider);
    final zone = zones.where((z) => z.id == selectedZoneId).firstOrNull;
    if (zone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih zona terlebih dahulu.')),
      );
      return;
    }

    final xfile = await _picker.pickImage(source: source, imageQuality: 88);
    if (xfile == null) return;

    final bytes = await xfile.readAsBytes();
    final ext = xfile.name.split('.').last;
    final contentType = ext.toLowerCase() == 'png' ? 'image/png' : 'image/jpeg';

    await ref.read(uploadFlowControllerProvider.notifier).startUpload(
          bytes: bytes,
          contentType: contentType,
          ext: ext,
          zoneId: zone.id,
          cropType: zone.cropType.toJson(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final zonesAsync = ref.watch(zonesProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final uploadState = ref.watch(uploadFlowControllerProvider);

    ref.listen(uploadFlowControllerProvider, (previous, next) {
      if (next is UploadFlowSuccess) {
        // Riverpod tidak tahu diagnosis baru ini memengaruhi provider lain
        // (dashboard, detail zona, notifikasi) karena semuanya query
        // terpisah tanpa dependensi eksplisit ke tabel diagnoses/
        // vegetation_index_readings -- invalidate manual di sini supaya
        // tidak menampilkan data basi begitu pengguna pindah tab.
        ref.invalidate(historyListProvider);
        ref.invalidate(dashboardSummaryProvider);
        ref.invalidate(notificationsProvider);
        final zoneId = ref.read(selectedZoneIdProvider);
        if (zoneId != null) ref.invalidate(zoneDetailProvider(zoneId));
        ref.read(uploadFlowControllerProvider.notifier).reset();
        context.push(RoutePaths.diagnosisResultPath(next.diagnosisId));
      }
    });

    // `ref.listen` hanya menangkap PERUBAHAN berikutnya, bukan data yang
    // sudah tersedia saat widget ini pertama kali dibangun (mis. zona baru
    // saja ditambahkan lewat tab Profil sebelum berpindah ke sini) -- jadi
    // inisialisasi juga langsung dari `zonesAsync.value` tiap build,
    // idempotent lewat flag `_initializedSelection`.
    void maybeInitSelection(List<Zone>? zones) {
      if (_initializedSelection || zones == null || zones.isEmpty) return;
      _initializedSelection = true;
      final preselect = zones.where((z) => z.id == widget.preselectZoneId).firstOrNull;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedZoneIdProvider.notifier).state = (preselect ?? zones.first).id;
      });
    }

    maybeInitSelection(zonesAsync.value);
    ref.listen(zonesProvider, (previous, next) => maybeInitSelection(next.value));

    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Unggah Foto',
                      style: GoogleFonts.fraunces(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    profileAsync.when(
                      data: (p) => AvatarInitialsChip(initials: p?.initials ?? '?'),
                      loading: () => const SizedBox(width: 34, height: 34),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ambil atau unggah foto daun untuk mulai diagnosis',
                  style: TextStyle(fontSize: 13, color: AppColors.sage),
                ),
                const SizedBox(height: 16),
                zonesAsync.when(
                  loading: () => const LoadingView(),
                  error: (e, _) => ErrorStateView(message: 'Gagal memuat zona: $e'),
                  data: (zones) {
                    final selectedId = ref.watch(selectedZoneIdProvider);
                    final selected = zones.where((z) => z.id == selectedId).firstOrNull;
                    return ZoneSelectorPill(
                      zones: zones,
                      selectedZone: selected,
                      onSelect: (z) => ref.read(selectedZoneIdProvider.notifier).state = z.id,
                    );
                  },
                ),
                const SizedBox(height: 16),
                CameraDropzone(onTap: () => _pick(ImageSource.camera)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _pick(ImageSource.gallery),
                    icon: const Icon(AppIcons.gallery, size: 18),
                    label: const Text('Pilih dari galeri'),
                  ),
                ),
                const SizedBox(height: 16),
                const UploadTipsCard(),
                const SizedBox(height: 20),
                const Text('Riwayat terbaru', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Consumer(
                  builder: (context, ref, _) {
                    final recentAsync = ref.watch(historyListProvider);
                    return recentAsync.when(
                      loading: () => const LoadingView(),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (state) {
                        final recent = state.items.take(3).toList();
                        if (recent.isEmpty) {
                          return const EmptyState(message: 'Belum ada riwayat diagnosis.');
                        }
                        return Column(
                          children: recent
                              .map(
                                (d) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(d.diseaseName, style: const TextStyle(fontSize: 13)),
                                  subtitle: Text(d.zoneName, style: const TextStyle(fontSize: 11.5)),
                                  trailing: SeverityChip(severity: d.severity),
                                  onTap: () => context.push(RoutePaths.diagnosisResultPath(d.diagnosisId)),
                                ),
                              )
                              .toList(),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          if (uploadState is! UploadFlowIdle && uploadState is! UploadFlowSuccess)
            Positioned.fill(
              child: UploadProgressOverlay(
                state: uploadState,
                onRetry: () => ref.read(uploadFlowControllerProvider.notifier).retry(),
                onCancel: () => ref.read(uploadFlowControllerProvider.notifier).reset(),
              ),
            ),
        ],
      ),
    );
  }
}
