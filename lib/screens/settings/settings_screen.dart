import 'package:flutter/material.dart';
import 'package:message_board/models/app_user.dart';
import 'package:message_board/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppUser? _user;
  bool _loading = true;
  bool _saving = false;
  String? _errorMessage;
  String? _successMessage;

  final _dobController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _dob;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final appUser = await AuthService.instance.getCurrentAppUser();
      if (!mounted) return;

      setState(() {
        _user = appUser;
        _loading = false;
      });

      if (appUser?.dob != null) {
        _dob = appUser!.dob;
        _dobController.text = _formatDate(appUser.dob!);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load settings.';
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_user == null) return;

    final currentUser = AuthService.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _errorMessage = 'No logged in user.';
      });
      return;
    }

    final newEmail = _newEmailController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isNotEmpty && newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'New password and confirmation do not match.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Update DOB if changed
      if (_dob != null) {
        await AuthService.instance.updateDob(_dob!);
      }

      // Update email if provided and different
      if (newEmail.isNotEmpty && newEmail != currentUser.email) {
        await AuthService.instance.updateEmail(newEmail);
      }

      // Update password if provided
      if (newPassword.isNotEmpty) {
        await AuthService.instance.updatePassword(newPassword);
      }

      setState(() {
        _successMessage = 'Settings saved successfully.';
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Failed to save settings. You may need to re-login before changing email/password.';
      });
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService.instance.signOut();
    // AuthGate will take care of redirecting to LoginScreen
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final currentUser = AuthService.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your account and personal information.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              if (_successMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    _successMessage!,
                    style: const TextStyle(color: Colors.green),
                  ),
                ),

              if (currentUser != null) ...[
                Text(
                  'Current email',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser.email ?? '(no email)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],

              // DOB
              TextField(
                controller: _dobController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date of birth',
                  hintText: 'Select your DOB',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today_outlined),
                    onPressed: _pickDob,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Change login information',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _newEmailController,
                decoration: const InputDecoration(
                  labelText: 'New email (optional)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New password (optional)',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm new password',
                  prefixIcon: Icon(Icons.lock_reset_outlined),
                ),
                obscureText: true,
              ),

              const SizedBox(height: 24),

              _saving
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveSettings,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Save settings'),
                        ),
                      ),
                    ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}