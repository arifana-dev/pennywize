import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/penny_app_bar.dart';
import '../../../../core/widgets/penny_mascot.dart';
import '../../../../core/widgets/slide_route.dart';
import '../../../expense/presentation/pages/add_expense_page.dart';
import '../bloc/scanner_bloc.dart';
import '../bloc/scanner_state.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final ImagePicker _picker = ImagePicker();
  File? _picked;

  Future<void> _pick(ImageSource source) async {
    try {
      final result = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (result == null) return;
      final file = File(result.path);
      if (!mounted) return;
      setState(() => _picked = file);
      context.read<ScannerBloc>().add(StartScan(file));
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Penny gak bisa buka kamera: $err')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PennyAppBar(
        eyebrow: 'OCR',
        title: 'Scan struk',
      ),
      body: BlocConsumer<ScannerBloc, ScannerState>(
        listener: (context, state) async {
          if (state.status == ScannerStatus.success && state.scanned != null) {
            final scanned = state.scanned!;
            context.read<ScannerBloc>().add(const ResetScanner());
            final result = await Navigator.of(context).push(
              SlideRoute(
                page: AddExpensePage(
                  prefill: scanned.expense,
                  scannedItems: scanned.items,
                ),
              ),
            );
            if (!context.mounted) return;
            if (result != null) {
              Navigator.of(context).pop();
            }
          }
          if (state.status == ScannerStatus.error && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          final scanning = state.status == ScannerStatus.scanning;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: _picked != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: SizedBox.expand(
                                child: Image.file(
                                  _picked!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Center(
                              child: scanning
                                  ? const _ScanningOverlay()
                                  : const _ScannerPlaceholder(),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: scanning
                              ? null
                              : () => _pick(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined,
                              size: 20),
                          label: const Text('Galeri'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              scanning ? null : () => _pick(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_rounded, size: 20),
                          label: const Text('Kamera'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScannerPlaceholder extends StatelessWidget {
  const _ScannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const PennyMascot(size: 76),
          ),
          const SizedBox(height: 22),
          Text(
            'Foto struk kamu',
            style: GoogleFonts.fraunces(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Penny baca otomatis dan isiin form-nya buat kamu.',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ScanningOverlay extends StatelessWidget {
  const _ScanningOverlay();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const PennyMascot(size: 76),
          ),
          const SizedBox(height: 22),
          const SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.scanningReceipt,
            style: GoogleFonts.fraunces(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
