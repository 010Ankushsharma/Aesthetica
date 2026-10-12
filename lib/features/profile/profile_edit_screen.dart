import 'package:aesthetica/core/constants/app_colors.dart';
import 'package:aesthetica/core/constants/app_spacing.dart';
import 'package:aesthetica/core/utils/extensions.dart';
import 'package:aesthetica/core/widgets/gradient_button.dart';
import 'package:aesthetica/data/models/models.dart';
import 'package:aesthetica/data/repositories/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late TextEditingController _nameController;
  late int _age;
  late String _gender;
  late double _height;
  late double _weight;
  late double _bodyFat;
  late Difficulty _experience;

  @override
  void initState() {
    super.initState();
    final p = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: p.name);
    _age = p.age;
    _gender = p.gender;
    _height = p.heightCm;
    _weight = p.weightKg;
    _bodyFat = p.bodyFatPercent;
    _experience = p.experience;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = ref.read(userProfileProvider);
    final updated = UserProfile(
      id: current.id,
      name: _nameController.text.trim(),
      email: current.email,
      age: _age,
      gender: _gender,
      heightCm: _height,
      weightKg: _weight,
      bodyFatPercent: _bodyFat,
      experience: _experience,
      goals: current.goals,
      streak: current.streak,
      level: current.level,
      xp: current.xp,
      coins: current.coins,
    );
    await ref.read(userNotifierProvider.notifier).updateProfile(updated);
    if (mounted) {
      context.hapticMedium();
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: AppSpacing.md),
          _SliderField(
            label: 'Age',
            value: _age.toDouble(),
            min: 16,
            max: 80,
            unit: 'yrs',
            onChanged: (v) => setState(() => _age = v.round()),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: const InputDecoration(labelText: 'Gender'),
            items: ['Male', 'Female', 'Other']
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (v) => setState(() => _gender = v!),
          ),
          const SizedBox(height: AppSpacing.md),
          _SliderField(
            label: 'Height',
            value: _height,
            min: 140,
            max: 220,
            unit: 'cm',
            onChanged: (v) => setState(() => _height = v),
          ),
          const SizedBox(height: AppSpacing.md),
          _SliderField(
            label: 'Weight',
            value: _weight,
            min: 40,
            max: 150,
            unit: 'kg',
            onChanged: (v) => setState(() => _weight = v),
          ),
          const SizedBox(height: AppSpacing.md),
          _SliderField(
            label: 'Body Fat',
            value: _bodyFat,
            min: 5,
            max: 40,
            unit: '%',
            onChanged: (v) => setState(() => _bodyFat = v),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<Difficulty>(
            value: _experience,
            decoration: const InputDecoration(labelText: 'Experience'),
            items: Difficulty.values
                .map(
                  (d) => DropdownMenuItem(
                    value: d,
                    child: Text(d.name.capitalize),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _experience = v!),
          ),
          const SizedBox(height: AppSpacing.xl),
          GradientButton(
            label: 'Save Changes',
            icon: Icons.check_rounded,
            width: double.infinity,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String unit;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: context.textTheme.titleMedium),
            Text(
              '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} $unit',
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: AppColors.accent,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
