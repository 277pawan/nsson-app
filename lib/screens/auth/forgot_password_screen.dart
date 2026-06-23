import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  bool _loading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();

    final isEmail = RegExp(
      r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);

    if (!isEmail) {
      _showSnackBar('Please enter a valid email address', isError: true);
      return;
    }

    setState(() => _loading = true);

    // Cache provider reference before any await
    final authProvider = context.read<AuthProvider>();

    try {
      final success = await authProvider.requestPasswordResetLink(email);

      if (!mounted) return;

      if (success) {
        setState(() {
          _submitted = true;
          _loading = false;
        });
        _showSnackBar('Password reset link sent');
        return;
      }

      setState(() => _loading = false);
      _showSnackBar(
        authProvider.error ?? 'Failed to send reset email',
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnackBar('Something went wrong: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final state = _messengerKey.currentState;
    if (state == null) return;
    state.hideCurrentSnackBar();
    state.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              if (mounted && Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            'Forgot Password',
            style: GoogleFonts.spaceGrotesk(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _submitted ? _buildSuccessState() : _buildRequestForm(),
        ),
      ),
    );
  }

  Widget _buildRequestForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),

        Text(
          'Reset your password by email',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Enter the email address linked to your account. We will send you a secure reset link.',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 28),

        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _loading ? null : _submit(),
          decoration: InputDecoration(
            hintText: 'Email address',
            prefixIcon: const Icon(Icons.mail_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'If the account exists, the backend will email a reset link valid for 1 hour.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 28),

        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Send Reset Link'),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48),

        Container(
          width: 84,
          height: 84,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: const BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.success,
            size: 40,
          ),
        ),

        Text(
          'Check your email',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'If an account with that email exists, a password reset link has been sent. Open the email, finish the reset, then return to the app and sign in.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 28),

        OutlinedButton(
          onPressed: () {
            if (mounted && Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}
