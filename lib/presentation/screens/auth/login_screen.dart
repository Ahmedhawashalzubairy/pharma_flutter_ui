import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../business_logic/auth/auth_cubit.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          } else if (state is AuthAuthenticated) {
            // Navigate to home
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xxl),
                    
                    // Logo
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          size: 60,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    Text(
                      'Pharmax',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: AppSpacing.xs),
                    
                    Text(
                      'مرحباً بك في فارماكس',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: AppSpacing.xxl),
                    
                    // Email Field
                    CustomTextField(
                      label: 'البريد الإلكتروني',
                      hint: 'أدخل بريدك الإلكتروني',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال البريد الإلكتروني';
                        }
                        if (!value.contains('@')) {
                          return 'يرجى إدخال بريد إلكتروني صحيح';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Password Field
                    CustomTextField(
                      label: 'كلمة المرور',
                      hint: 'أدخل كلمة المرور',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال كلمة المرور';
                        }
                        if (value.length < 6) {
                          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSpacing.sm),
                    
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          // Navigate to forgot password
                        },
                        child: const Text('نسيت كلمة المرور؟'),
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Login Button
                    CustomButton(
                      text: 'تسجيل الدخول',
                      onPressed: _handleLogin,
                      isLoading: isLoading,
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'مستخدم جديد؟',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/signup');
                          },
                          child: const Text('إنشاء حساب'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.md),
                    
                    // Guest Login
                    CustomButton(
                      text: 'تسجيل الدخول كضيف',
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
                      isOutlined: true,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}