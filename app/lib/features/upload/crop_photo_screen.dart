import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/color_tokens.dart';

/// Foto yang siap diunggah: hasil potongan (PNG) atau foto utuh apa adanya.
class CroppedPhoto {
  const CroppedPhoto({required this.bytes, required this.contentType, required this.ext});
  final Uint8List bytes;
  final String contentType;
  final String ext;
}

/// Langkah potong foto sebelum diunggah -- cermin `web/components/upload/CropPanel.tsx`.
/// Pengguna menggeser kotak persegi ke daun yang ingin didiagnosis (buah, tangan, mulsa di luar
/// kotak tidak ikut dinilai model) atau memakai foto utuh. Kembali dengan `null` = batal.
/// Hanya memakai Flutter bawaan (dart:ui), tanpa paket tambahan.
class CropPhotoScreen extends StatefulWidget {
  const CropPhotoScreen({super.key, required this.bytes, required this.contentType, required this.ext});

  final Uint8List bytes;
  final String contentType;
  final String ext;

  @override
  State<CropPhotoScreen> createState() => _CropPhotoScreenState();
}

class _CropPhotoScreenState extends State<CropPhotoScreen> {
  static const double _minFraction = 0.25;
  static const double _defaultFraction = 0.8;
  static const double _maxOutputSide = 1280; // model hanya butuh 224 px; unggahan tetap ringan

  ui.Image? _image;
  Rect? _box; // dalam piksel ASLI foto (persegi)
  double _fraction = _defaultFraction;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  Future<void> _decode() async {
    try {
      final codec = await ui.instantiateImageCodec(widget.bytes);
      final frame = await codec.getNextFrame();
      if (!mounted) {
        frame.image.dispose();
        return;
      }
      setState(() {
        _image = frame.image;
        _box = _centeredBox(frame.image, _defaultFraction);
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'Foto tidak dapat dibuka untuk dipotong. Pakai foto utuh.');
    }
  }

  Rect _centeredBox(ui.Image image, double fraction) {
    final side = math.min(image.width, image.height) * fraction;
    return Rect.fromLTWH((image.width - side) / 2, (image.height - side) / 2, side, side);
  }

  Rect _clamp(Rect box, ui.Image image) {
    final side = math.min(box.width, math.min(image.width, image.height).toDouble());
    final left = box.left.clamp(0.0, image.width - side).toDouble();
    final top = box.top.clamp(0.0, image.height - side).toDouble();
    return Rect.fromLTWH(left, top, side, side);
  }

  void _resize(double fraction) {
    final image = _image;
    final box = _box;
    if (image == null || box == null) return;
    final side = math.min(image.width, image.height) * fraction;
    final center = box.center;
    setState(() {
      _fraction = fraction;
      _box = _clamp(Rect.fromCenter(center: center, width: side, height: side), image);
    });
  }

  void _useFull() {
    Navigator.of(context).pop(
      CroppedPhoto(bytes: widget.bytes, contentType: widget.contentType, ext: widget.ext),
    );
  }

  Future<void> _confirm() async {
    final image = _image;
    final box = _box;
    if (image == null || box == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final outSide = math.min(box.width, _maxOutputSide).roundToDouble();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawImageRect(
        image,
        box,
        Rect.fromLTWH(0, 0, outSide, outSide),
        Paint()..filterQuality = FilterQuality.high,
      );
      final picture = recorder.endRecording();
      final cropped = await picture.toImage(outSide.toInt(), outSide.toInt());
      final data = await cropped.toByteData(format: ui.ImageByteFormat.png);
      cropped.dispose();
      picture.dispose();
      if (data == null) throw StateError('encode gagal');
      if (!mounted) return;
      Navigator.of(context).pop(
        CroppedPhoto(bytes: data.buffer.asUint8List(), contentType: 'image/png', ext: 'png'),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Gagal memotong foto. Coba lagi atau pakai foto utuh.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    final box = _box;
    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        title: const Text('Pilih bagian daun'),
        backgroundColor: AppColors.parchment,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Geser kotak ke satu daun tomat dan atur ukurannya. Buah, tangan, atau mulsa di luar kotak tidak ikut dinilai.',
                style: TextStyle(fontSize: 13, color: AppColors.sage),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: image == null || box == null
                    ? Center(
                        child: _error == null
                            ? const CircularProgressIndicator(color: AppColors.moss)
                            : Text(_error!, textAlign: TextAlign.center),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final scale = math.min(
                            constraints.maxWidth / image.width,
                            constraints.maxHeight / image.height,
                          );
                          final shown = Size(image.width * scale, image.height * scale);
                          final shownBox = Rect.fromLTWH(
                            box.left * scale,
                            box.top * scale,
                            box.width * scale,
                            box.height * scale,
                          );
                          return Center(
                            child: SizedBox(
                              width: shown.width,
                              height: shown.height,
                              child: Stack(
                                children: [
                                  Positioned.fill(child: RawImage(image: image, fit: BoxFit.fill)),
                                  Positioned.fill(
                                    child: IgnorePointer(child: CustomPaint(painter: _DimPainter(shownBox))),
                                  ),
                                  Positioned.fromRect(
                                    rect: shownBox,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onPanUpdate: (details) {
                                        setState(() {
                                          _box = _clamp(box.shift(details.delta / scale), image);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Ukuran kotak', style: TextStyle(fontSize: 13)),
                  Expanded(
                    child: Slider(
                      value: _fraction,
                      min: _minFraction,
                      max: 1,
                      activeColor: AppColors.moss,
                      onChanged: image == null || _busy ? null : _resize,
                    ),
                  ),
                ],
              ),
              if (_error != null && image != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_error!, style: const TextStyle(fontSize: 12.5, color: AppColors.rust)),
                ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : _useFull,
                      child: const Text('Pakai foto utuh'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: image == null || _busy ? null : _confirm,
                      child: Text(_busy ? 'Memproses…' : 'Pakai bagian ini'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Menggelapkan area di luar kotak potong.
class _DimPainter extends CustomPainter {
  _DimPainter(this.box);
  final Rect box;

  @override
  void paint(Canvas canvas, Size size) {
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRect(box),
    );
    canvas.drawPath(outside, Paint()..color = const Color(0x73000000));
  }

  @override
  bool shouldRepaint(_DimPainter oldDelegate) => oldDelegate.box != box;
}
