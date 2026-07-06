// lib/screens/settings/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'package:ufit/theme/theme_ext.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  double _weight = 70;
  double _height = 170;
  int _age = 25;
  String _gender = 'male';
  String _goal = 'maintain';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    if (user != null) {
      _nameCtrl.text = user.name;
      _weight = user.weightKg ?? 70;
      _height = user.heightCm ?? 170;
      _age = user.age ?? 25;
      _gender = user.gender ?? 'male';
      _goal = user.fitnessGoal ?? 'maintain';
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = ref.watch(currentFirebaseUserProvider);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                : const Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    backgroundImage: firebaseUser?.photoURL != null ? NetworkImage(firebaseUser!.photoURL!) : null,
                    child: firebaseUser?.photoURL == null
                        ? Text(
                            _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : 'U',
                            style: const TextStyle(color: AppColors.primary, fontSize: 36, fontWeight: FontWeight.w800),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 32, height: 32,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(),
            const SizedBox(height: 28),

            _label('Name'),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline_rounded)),
              onChanged: (_) => setState(() {}),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 20),

            _label('Gender'),
            Row(
              children: [
                Expanded(child: _GenderBtn('male', '👨', 'Male', _gender, (v) => setState(() => _gender = v))),
                const SizedBox(width: 10),
                Expanded(child: _GenderBtn('female', '👩', 'Female', _gender, (v) => setState(() => _gender = v))),
                const SizedBox(width: 10),
                Expanded(child: _GenderBtn('other', '🧑', 'Other', _gender, (v) => setState(() => _gender = v))),
              ],
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 20),

            _label('Age: $_age'),
            Slider(value: _age.toDouble(), min: 13, max: 80, divisions: 67, activeColor: AppColors.primary, inactiveColor: context.border, onChanged: (v) => setState(() => _age = v.toInt())),

            _label('Weight: ${_weight.toStringAsFixed(1)} kg'),
            Slider(value: _weight, min: 30, max: 200, divisions: 340, activeColor: AppColors.weightColor, inactiveColor: context.border, onChanged: (v) => setState(() => _weight = double.parse(v.toStringAsFixed(1)))),

            _label('Height: ${_height.toStringAsFixed(0)} cm'),
            Slider(value: _height, min: 100, max: 230, divisions: 130, activeColor: AppColors.secondary, inactiveColor: context.border, onChanged: (v) => setState(() => _height = double.parse(v.toStringAsFixed(0)))),

            const SizedBox(height: 8),
            _label('Fitness Goal'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _GoalChip('lose_weight', '🔥 Lose Weight', _goal, (v) => setState(() => _goal = v)),
                _GoalChip('gain_muscle', '💪 Gain Muscle', _goal, (v) => setState(() => _goal = v)),
                _GoalChip('maintain', '⚖️ Stay Fit', _goal, (v) => setState(() => _goal = v)),
                _GoalChip('active_lifestyle', '🏃 Active Life', _goal, (v) => setState(() => _goal = v)),
              ],
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, imageQuality: 80);
    if (file == null) return;
    // In production: upload to Firebase Storage, then update photoURL
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile photo update requires Firebase Storage setup')),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final user = ref.read(userProvider);
      if (user != null) {
        user.name = _nameCtrl.text.trim().isEmpty ? user.name : _nameCtrl.text.trim();
        user.weightKg = _weight;
        user.heightCm = _height;
        user.age = _age;
        user.gender = _gender;
        user.fitnessGoal = _goal;
        await ref.read(userProvider.notifier).saveUser(user);
      }
      // Update Firebase displayName too
      await AuthService.updateProfile(displayName: _nameCtrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated ✓'), backgroundColor: AppColors.success),
        );
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }
}

class _GenderBtn extends StatelessWidget {
  final String value, emoji, label, selected;
  final Function(String) onTap;
  const _GenderBtn(this.value, this.emoji, this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : context.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : context.border, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: isSelected ? AppColors.primary : context.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String value, label, selected;
  final Function(String) onTap;
  const _GoalChip(this.value, this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : context.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : context.border, width: isSelected ? 1.5 : 1),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, color: isSelected ? AppColors.primary : context.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}
