import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_money/application/providers.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/core/theme/app_text_styles.dart';
import 'package:smart_money/domain/models/models.dart';
import 'package:smart_money/presentation/screens/auth/login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800, maxHeight: 800, imageQuality: 80);
      if (image == null) return;

      setState(() => _isUploading = true);
      
      final file = File(image.path);
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().toIso8601String()}.$fileExt';

      await ref.read(profileProvider.notifier).uploadAvatar(file, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile picture updated!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update picture: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTopAppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                children: [
                  _buildProfileHero(profileAsync),
                  const SizedBox(height: 40),
                  _buildSettingsMenu(context),
                  const SizedBox(height: 48),
                  _buildAppVersion(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Text('Smart Money', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.primary, fontSize: 20)),
          ]),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildProfileHero(AsyncValue<ProfileModel> profileAsync) {
    final name = profileAsync.value?.name ?? 'Loading...';
    final email = profileAsync.value?.email ?? '';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 112, height: 112,
          child: Stack(
            children: [
              Container(
                width: 112, height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, 
                      color: AppColors.surfaceContainerHigh,
                      image: profileAsync.value?.avatarUrl != null
                          ? DecorationImage(image: NetworkImage(profileAsync.value!.avatarUrl!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: profileAsync.value?.avatarUrl == null
                       ? const Icon(Icons.person, size: 48, color: AppColors.outline)
                       : null,
                  ),
                ),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: GestureDetector(
                  onTap: _isUploading ? null : _pickAndUploadImage,
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))]),
                    child: _isUploading 
                        ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(name, style: AppTextStyles.headlineLarge.copyWith(fontSize: 24)),
        const SizedBox(height: 4),
        Text(email, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline)),
      ],
    );
  }

  Widget _buildSettingsMenu(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('ACCOUNT SETTINGS', style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(children: [
            _settingsItem(
              icon: Icons.category_rounded,
              title: 'Manage Categories',
              onTap: () => _showManageCategoriesSheet(context, ref),
            ),
            _settingsItem(
              icon: Icons.payments_rounded,
              title: 'Manage Payment Methods',
              isLast: true,
              onTap: () => _showManagePaymentMethodsSheet(context, ref),
            ),
          ]),
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('DATA MANAGEMENT', style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(children: [
            _settingsItem(icon: Icons.ios_share_rounded, title: 'Export Data', isLast: true),
          ]),
        ),
        const SizedBox(height: 32),
        // Logout Button
        GestureDetector(
          onTap: () async {
            ref.read(isLoggedInProvider.notifier).logout();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(color: AppColors.errorContainer.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(100)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Text('Sign Out', style: AppTextStyles.titleMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _settingsItem({required IconData icon, required String title, bool isError = false, bool isLast = false, VoidCallback? onTap}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2)))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: isError ? AppColors.errorContainer.withValues(alpha: 0.5) : const Color(0xFFF1F5F9), shape: BoxShape.circle), child: Icon(icon, color: isError ? AppColors.error : AppColors.primary, size: 20)),
              const SizedBox(width: 16),
              Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500, color: isError ? AppColors.error : AppColors.onSurface)),
            ]),
            Icon(isError ? Icons.warning_rounded : Icons.chevron_right_rounded, color: isError ? AppColors.error.withValues(alpha: 0.3) : AppColors.outlineVariant, size: 20),
          ],
        ),
      ),
    );
  }

  // --- MANAGE CATEGORIES ---
  void _showManageCategoriesSheet(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.read(categoryListProvider);
    final categories = categoriesAsync.value ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Manage Categories', style: AppTextStyles.headlineSmall),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _showAddCategoryDialog(context, ref);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.primaryContainer.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(100)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.add_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 4),
                        Text('Add', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                      ]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: categories.isEmpty
                    ? Center(child: Text('No categories yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline)))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          return ListTile(
                            leading: Text(cat.icon ?? '📂', style: const TextStyle(fontSize: 24)),
                            title: Text(cat.name),
                            subtitle: Text(cat.type ?? 'general', style: AppTextStyles.labelSmall),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                              onPressed: () async {
                                await ref.read(categoryListProvider.notifier).delete(cat.id);
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedType = 'expense';
    String selectedIcon = '📂';

    final icons = ['🍽️', '🚗', '🛍️', '💰', '💻', '🏠', '🎮', '📚', '💊', '✈️', '🎬', '📱'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Add Category', style: AppTextStyles.headlineSmall),
              const SizedBox(height: 20),
              TextField(controller: nameController, decoration: const InputDecoration(hintText: 'Category name')),
              const SizedBox(height: 16),
              Text('Type', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Row(children: [
                _typeChip('expense', selectedType == 'expense', () => setSheetState(() => selectedType = 'expense')),
                const SizedBox(width: 8),
                _typeChip('income', selectedType == 'income', () => setSheetState(() => selectedType = 'income')),
              ]),
              const SizedBox(height: 16),
              Text('Icon', style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: icons.map((icon) => GestureDetector(
                  onTap: () => setSheetState(() => selectedIcon = icon),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: selectedIcon == icon ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: selectedIcon == icon ? Border.all(color: AppColors.primary, width: 2) : null,
                    ),
                    child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    final category = CategoryModel(id: '', name: name, icon: selectedIcon, type: selectedType);
                    await ref.read(categoryListProvider.notifier).add(category);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Add Category'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(100),
          border: isSelected ? Border.all(color: AppColors.primary) : null,
        ),
        child: Text(label, style: AppTextStyles.labelLarge.copyWith(color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }

  // --- MANAGE PAYMENT METHODS ---
  void _showManagePaymentMethodsSheet(BuildContext context, WidgetRef ref) {
    final methodsAsync = ref.read(paymentMethodListProvider);
    final methods = methodsAsync.value ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payment Methods', style: AppTextStyles.headlineSmall),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _showAddPaymentMethodDialog(context, ref);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.primaryContainer.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(100)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.add_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 4),
                        Text('Add', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                      ]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: methods.isEmpty
                    ? Center(child: Text('No payment methods yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline)))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: methods.length,
                        itemBuilder: (context, index) {
                          final method = methods[index];
                          return ListTile(
                            leading: const Icon(Icons.payment_rounded, color: AppColors.primary),
                            title: Text(method.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                              onPressed: () async {
                                await ref.read(paymentMethodListProvider.notifier).delete(method.id);
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddPaymentMethodDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Add Payment Method', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 20),
            TextField(controller: nameController, decoration: const InputDecoration(hintText: 'e.g. Cash, GoPay, BCA')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;
                  final method = PaymentMethodModel(id: '', name: name);
                  await ref.read(paymentMethodListProvider.notifier).add(method);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Add Method'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppVersion() {
    return Column(children: [
      Text('Smart Money v1.0.0', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.outlineVariant, fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text('Made with care for your financial freedom', style: AppTextStyles.labelSmall.copyWith(color: AppColors.outlineVariant, fontSize: 10)),
    ]);
  }
}
