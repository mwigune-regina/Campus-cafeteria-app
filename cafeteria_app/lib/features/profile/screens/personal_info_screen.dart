import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/profile_avatar.dart';

/// "Personal information" — an extension of the profile screen reached from
/// the Profile > Personal information row. Lets the user change their avatar
/// (via the shared [ProfileAvatar]) and edit registration number / year of
/// study. Email is shown read-only. Reachable inside the student shell so the
/// bottom nav stays visible.
class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  late final TextEditingController _regController;
  int? _yearOfStudy;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _regController = TextEditingController(text: user?.registrationNumber ?? '');
    _yearOfStudy = user?.yearOfStudy;
  }

  @override
  void dispose() {
    _regController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    FocusScope.of(context).unfocus();

    setState(() => _saving = true);
    final error = await ref.read(authProvider.notifier).updateProfile(
          registrationNumber: _regController.text.trim(),
          yearOfStudy: _yearOfStudy,
        );
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error ?? 'Profile saved'),
      backgroundColor: error == null ? AppColors.success : AppColors.danger,
    ));
    if (error == null && context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isStudent = user?.role == 'student';

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: ProfileAvatar(showCameraBadge: false, showEditLabel: true)),
                      const SizedBox(height: 28),
                      _label('Email'),
                      _readOnlyField(user?.email ?? ''),
                      if (isStudent) ...[
                        const SizedBox(height: 22),
                        _label('Registration Number'),
                        _regField(),
                        const SizedBox(height: 22),
                        _label('Year of study'),
                        _yearField(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.navyBlue,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: [
          Material(
            color: AppColors.white.withValues(alpha: 0.15),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.canPop() ? context.pop() : context.go('/profile'),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(Icons.arrow_back, color: AppColors.white, size: 22),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Personal information',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          // Balances the back button so the title stays centered.
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, color: AppColors.textDark, fontWeight: FontWeight.w500),
      ),
    );
  }

  InputDecoration _fieldDecoration({String? hint}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.textLight.withValues(alpha: 0.4)),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textLight),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.navyBlue, width: 1.5),
      ),
    );
  }

  Widget _readOnlyField(String value) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      enabled: false,
      style: TextStyle(color: AppColors.textLight),
      decoration: _fieldDecoration(),
    );
  }

  Widget _regField() {
    return TextField(
      controller: _regController,
      style: TextStyle(color: AppColors.textDark),
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [LengthLimitingTextInputFormatter(50)],
      decoration: _fieldDecoration(hint: '20**-**-*****'),
    );
  }

  Widget _yearField() {
    return DropdownButtonFormField<int>(
      initialValue: _yearOfStudy,
      isExpanded: true,
      style: TextStyle(color: AppColors.textDark, fontSize: 16),
      decoration: _fieldDecoration(hint: 'Select year'),
      items: List.generate(6, (i) => i + 1)
          .map((y) => DropdownMenuItem(value: y, child: Text('Year $y')))
          .toList(),
      onChanged: (v) => setState(() => _yearOfStudy = v),
    );
  }
}