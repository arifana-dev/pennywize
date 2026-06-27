import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/penny_app_bar.dart';
import '../../../../services/widget_service.dart';
import '../widget_backgrounds.dart';

class WidgetCustomizationPage extends StatefulWidget {
  const WidgetCustomizationPage({super.key});

  @override
  State<WidgetCustomizationPage> createState() =>
      _WidgetCustomizationPageState();
}

class _WidgetCustomizationPageState extends State<WidgetCustomizationPage> {
  String? _selectedAssetId;
  File? _customFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    final cur = await WidgetService.instance.currentBackground();
    if (!mounted) return;
    setState(() {
      if (cur.imagePath != null && File(cur.imagePath!).existsSync()) {
        _customFile = File(cur.imagePath!);
        _selectedAssetId = null;
      } else {
        _selectedAssetId = cur.assetName ?? builtInBackgrounds.first.id;
      }
    });
  }

  Future<void> _pickGallery() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1200,
    );
    if (result == null) return;
    setState(() {
      _customFile = File(result.path);
      _selectedAssetId = null;
    });
  }

  Future<void> _apply() async {
    setState(() => _saving = true);
    try {
      if (_customFile != null) {
        await WidgetService.instance.setCustomBackground(_customFile!);
      } else if (_selectedAssetId != null) {
        await WidgetService.instance.setBuiltInBackground(_selectedAssetId!);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Widget kamu sudah diperbarui')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PennyAppBar(
        eyebrow: 'WIDGET',
        title: 'Tampilan',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  Text(
                    'PRATINJAU',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PreviewWidget(
                    size: WidgetSize.medium,
                    customFile: _customFile,
                    assetPath: _builtInPath(),
                  ),
                  const SizedBox(height: 12),
                  _PreviewWidget(
                    size: WidgetSize.small,
                    customFile: _customFile,
                    assetPath: _builtInPath(),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'PILIH BACKGROUND',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: builtInBackgrounds.length + 1,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.4,
                    ),
                    itemBuilder: (context, index) {
                      if (index == builtInBackgrounds.length) {
                        return _GalleryTile(
                          file: _customFile,
                          isSelected: _customFile != null,
                          onTap: _pickGallery,
                        );
                      }
                      final bg = builtInBackgrounds[index];
                      final selected = _customFile == null &&
                          _selectedAssetId == bg.id;
                      return _BgTile(
                        background: bg,
                        selected: selected,
                        onTap: () {
                          setState(() {
                            _selectedAssetId = bg.id;
                            _customFile = null;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: ElevatedButton(
                onPressed: _saving ? null : _apply,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Text(_saving ? 'Menyimpan...' : 'Terapkan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _builtInPath() {
    if (_selectedAssetId == null) return null;
    return builtInBackgrounds
        .firstWhere(
          (b) => b.id == _selectedAssetId,
          orElse: () => builtInBackgrounds.first,
        )
        .assetPath;
  }
}

enum WidgetSize { small, medium }

class _PreviewWidget extends StatelessWidget {
  const _PreviewWidget({
    required this.size,
    required this.customFile,
    required this.assetPath,
  });

  final WidgetSize size;
  final File? customFile;
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    final isSmall = size == WidgetSize.small;
    final width = isSmall ? 180.0 : double.infinity;
    final height = isSmall ? 90.0 : 138.0;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (customFile != null)
              Image.file(customFile!, fit: BoxFit.cover)
            else if (assetPath != null)
              SvgPicture.asset(assetPath!, fit: BoxFit.cover)
            else
              Container(color: AppColors.primarySoft),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.charcoal.withValues(alpha: 0.0),
                    AppColors.charcoal.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'HARI INI',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        CurrencyFormatter.format(85000),
                        style: GoogleFonts.fraunces(
                          fontSize: isSmall ? 22 : 28,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.6,
                          color: Colors.white,
                        ),
                      ),
                      if (!isSmall) ...[
                        const SizedBox(height: 4),
                        Text(
                          'dari 3 transaksi',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.widgetMessageOfDay(DateTime.now()),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BgTile extends StatelessWidget {
  const _BgTile({
    required this.background,
    required this.selected,
    required this.onTap,
  });

  final WidgetBackground background;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.charcoal : AppColors.divider,
            width: selected ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SvgPicture.asset(background.assetPath, fit: BoxFit.cover),
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.charcoal.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    background.label,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              if (selected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: AppColors.charcoal,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.file,
    required this.isSelected,
    required this.onTap,
  });

  final File? file;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.charcoal : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (file != null)
                Image.file(file!, fit: BoxFit.cover)
              else
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate_rounded,
                          color: AppColors.textPrimary, size: 28),
                      const SizedBox(height: 6),
                      Text(
                        'Galeri',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              if (isSelected && file != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: AppColors.charcoal,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
