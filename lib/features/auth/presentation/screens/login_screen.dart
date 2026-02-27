import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authViewModelProvider.notifier).login(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.dashboard);
    } else {
      final error = ref.read(authViewModelProvider).error ?? AppStrings.unknownError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height - 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: AppSizes.xxl),

                // ── Logo / Title ───────────────────────────────────────
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    size: 44,
                    color: AppColors.textOnPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSizes.xs),
                Text(
                  'Sign in to continue',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSizes.xl),

                // ── Form ──────────────────────────────────────────────
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email field
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                        decoration: const InputDecoration(
                          labelText: AppStrings.email,
                          hintText: AppStrings.emailHint,
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Password field
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _onLogin(),
                        validator: Validators.required,
                        decoration: InputDecoration(
                          labelText: AppStrings.password,
                          hintText: AppStrings.passwordHint,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: AppSizes.buttonHeight,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _onLogin,
                          child: authState.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.textOnPrimary,
                                  ),
                                )
                              : const Text(AppStrings.login),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
