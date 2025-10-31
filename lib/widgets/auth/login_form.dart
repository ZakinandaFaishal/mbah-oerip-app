import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../utils/ui/input_styles.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final bool isLogin;
  final bool isLoading;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;

  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  final VoidCallback onSubmit;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.isLogin,
    required this.isLoading,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.fullNameController,
    required this.phoneController,
    required this.usernameController,
    required this.passwordController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            if (!isLogin) ...[
              TextFormField(
                controller: fullNameController,
                validator: (v) =>
                    (v?.isEmpty ?? true) ? 'Nama tidak boleh kosong' : null,
                decoration: buildInputDecoration(
                  "Nama Lengkap",
                  Icons.person_outline,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'Nomor telepon tidak boleh kosong';
                  if (t.length < 9) return 'Nomor telepon tidak valid';
                  return null;
                },
                decoration: buildInputDecoration(
                  "Nomor Telepon",
                  Icons.phone_outlined,
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: usernameController,
              validator: (v) =>
                  (v?.isEmpty ?? true) ? 'Username tidak boleh kosong' : null,
              decoration: buildInputDecoration(
                "Username",
                Icons.account_circle_outlined,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              validator: (v) =>
                  (v?.length ?? 0) < 5 ? 'Password minimal 5 karakter' : null,
              decoration: buildInputDecoration(
                "Password",
                Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppTheme.primaryOrange,
                  ),
                  onPressed: onToggleObscure,
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryOrange,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isLogin ? "Login" : "Daftar",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
