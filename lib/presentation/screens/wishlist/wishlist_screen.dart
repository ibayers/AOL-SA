import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_money/application/providers.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/core/theme/app_text_styles.dart';
import 'package:smart_money/core/utils/formatters.dart';
import 'package:smart_money/domain/models/models.dart';
import 'package:smart_money/core/utils/notification_service.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final wishlistAsync = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: wishlistAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (items) => ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  children: [
                    ...items.map(_wishlistCard),
                    const SizedBox(height: 16),
                    _buildEmptyPrompt(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Moni',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text('My Wishlist', style: AppTextStyles.headlineMedium),
            ],
          ),
          GestureDetector(
            onTap: _showAddDialog,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_rounded, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wishlistCard(WishlistItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildThumbnail(item.imagePath),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('Target', style: AppTextStyles.labelMedium),
                        const SizedBox(width: 6),
                        Text(
                          CurrencyFormatter.format(item.price),
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.isPending)
                GestureDetector(
                  onTap: () => _showInvestDialog(item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.savings_rounded,
                          color: AppColors.onPrimary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Invest',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.secondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Goal Reached!',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${CurrencyFormatter.format(item.savedAmount)} / ${CurrencyFormatter.format(item.price)}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(item.progress * 100).toInt()}%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.progress,
              backgroundColor: AppColors.surfaceContainer,
              color: item.isCompleted
                  ? AppColors.secondary
                  : AppColors.primaryContainer,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          Icons.image_outlined,
          color: AppColors.primary.withValues(alpha: 0.4),
          size: 24,
        ),
      );
    }
    final isNetwork =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: isNetwork
          ? Image.network(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
            )
          : Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
            ),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      color: AppColors.primaryContainer.withValues(alpha: 0.08),
      child: Icon(
        Icons.image_outlined,
        color: AppColors.primary.withValues(alpha: 0.4),
        size: 24,
      ),
    );
  }

  Widget _buildEmptyPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text("What's next?", style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Saving for a vacation or a new car?',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String? selectedImagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Add Wishlist Item', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Item name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Target price',
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 24),
              Text('Photo (Optional)', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final path = await _pickImage();
                  if (path != null) {
                    setSheetState(() => selectedImagePath = path);
                  }
                },
                child: selectedImagePath != null
                    ? Stack(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: FileImage(File(selectedImagePath!)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () =>
                                  setSheetState(() => selectedImagePath = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.inverseSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        height: 72,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_rounded,
                              color: AppColors.outline.withValues(alpha: 0.8),
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Add a photo of the item',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.outline.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final price =
                        double.tryParse(
                          priceController.text.replaceAll(
                            RegExp(r'[^0-9.]'),
                            '',
                          ),
                        ) ??
                        0;
                    if (name.isEmpty || price <= 0) return;

                    final item = WishlistItemModel(
                      id: '',
                      name: name,
                      price: price,
                      savedAmount: 0,
                      status: 'pending',
                      imagePath: selectedImagePath,
                    );
                    await ref.read(wishlistProvider.notifier).add(item);
                    if (ctx.mounted) {
                      NotificationService.showSuccess('Added to wishlist');
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add to Wishlist'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: Text('Camera', style: AppTextStyles.titleSmall),
                subtitle: Text(
                  'Take a new photo',
                  style: AppTextStyles.bodySmall,
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.secondary,
                  ),
                ),
                title: Text('Gallery', style: AppTextStyles.titleSmall),
                subtitle: Text(
                  'Choose from gallery',
                  style: AppTextStyles.bodySmall,
                ),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return null;
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    return image?.path;
  }

  void _showInvestDialog(WishlistItemModel item) {
    final controller = TextEditingController();
    final remaining = item.price - item.savedAmount;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Invest for ${item.name}',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Remaining: ${CurrencyFormatter.format(remaining)}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Enter amount',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.outline.withValues(alpha: 0.5),
                ),
                prefixText: 'Rp ',
                prefixStyle: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final amount = double.tryParse(
                    controller.text.replaceAll(RegExp(r'[^0-9.]'), ''),
                  );
                  if (amount == null || amount <= 0) {
                    NotificationService.showError('Enter a valid amount');
                    return;
                  }
                  Navigator.pop(ctx);
                  ref.read(wishlistProvider.notifier).invest(item.id, amount);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Text(
                  'Invest',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
