import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_button.dart';
import '../widgets/campus_background.dart';
import '../widgets/app_logo.dart';
import '../widgets/connection_status.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nimController = TextEditingController();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _secretCodeController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = AppConstants.roleUser;
  bool _showSecretCode = false;

  @override
  void dispose() {
    _nimController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _secretCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.register(
      nim: _nimController.text.trim(),
      nama: _namaController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      peran: _selectedRole,
      kodeRahasia: _showSecretCode ? _secretCodeController.text.trim() : null,
    );

    if (success && mounted) {
      // Registration successful - always redirect to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login dengan akun Anda.'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Registrasi gagal'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CampusBackgroundScaffold(
      showOverlay: true,
      overlayOpacity: 0.2,
      body: ConnectionStatusProvider(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                           MediaQuery.of(context).padding.top -
                           MediaQuery.of(context).padding.bottom - 48,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GlassCard(
                    isDark: true,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // Header
                        _buildHeader(),

                        const SizedBox(height: 32),

                        // Register form
                        _buildRegisterForm(),

                        const SizedBox(height: 24),

                        // Login link
                        _buildLoginLink(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const AspirasiKuLogo(
          size: 80,
          showShadow: true,
        ),

        const SizedBox(height: 24),

        Text(
          'Bergabung dengan AspirasiKu',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Buat akun untuk mulai beraspirasi',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              // NIM field
              CustomTextField(
                controller: _nimController,
                label: 'NIM',
                hint: 'Masukkan NIM Anda',
                prefixIcon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'NIM tidak boleh kosong';
                  }
                  if (value.length < 8) {
                    return 'NIM minimal 8 karakter';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Name field
              CustomTextField(
                controller: _namaController,
                label: 'Nama Lengkap',
                hint: 'Masukkan nama lengkap Anda',
                prefixIcon: Icons.person_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  if (value.length < 2) {
                    return 'Nama minimal 2 karakter';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Email field
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Masukkan email Anda',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Password field
              CustomTextField(
                controller: _passwordController,
                label: 'Kata Sandi',
                hint: 'Masukkan kata sandi Anda',
                prefixIcon: Icons.lock_outlined,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kata sandi tidak boleh kosong';
                  }
                  if (value.length < AppConstants.minPasswordLength) {
                    return 'Kata sandi minimal ${AppConstants.minPasswordLength} karakter';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Confirm password field
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Konfirmasi Kata Sandi',
                hint: 'Masukkan ulang kata sandi Anda',
                prefixIcon: Icons.lock_outlined,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi kata sandi tidak boleh kosong';
                  }
                  if (value != _passwordController.text) {
                    return 'Kata sandi tidak cocok';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Role selection
              _buildRoleSelection(),
              
              // Secret code field (if reviewer selected)
              if (_showSecretCode) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _secretCodeController,
                  label: 'Kode Rahasia Peninjau',
                  hint: 'Masukkan kode rahasia untuk akun peninjau',
                  prefixIcon: Icons.key_outlined,
                  validator: (value) {
                    if (_showSecretCode && (value == null || value.isEmpty)) {
                      return 'Kode rahasia tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Register button
              LoadingButton(
                onPressed: _handleRegister,
                isLoading: authProvider.isLoading,
                child: const Text(
                  'Daftar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Akun',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              RadioListTile<String>(
                value: AppConstants.roleUser,
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                    _showSecretCode = false;
                  });
                },
                title: const Text('Mahasiswa'),
                subtitle: const Text('Akun untuk mahasiswa'),
                activeColor: AppColors.primary,
              ),

              const Divider(height: 1),

              RadioListTile<String>(
                value: AppConstants.roleReviewer,
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                    _showSecretCode = true;
                  });
                },
                title: const Text('Peninjau'),
                subtitle: const Text('Akun untuk admin/peninjau (memerlukan kode rahasia)'),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: Text(
            'Masuk di sini',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
