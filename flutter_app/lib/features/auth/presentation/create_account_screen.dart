import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/theme.dart';
import '../../../core/api.dart';
import '../../../core/auth_state.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneOrEmailCtl = TextEditingController(text: '+91 9876543210');
  final _nameCtl = TextEditingController(text: 'Omkar Batwal');
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  int _step = 1; // 1: Input details, 2: Verify OTP
  bool _busy = false;
  String? _sentOtp;
  String? _error;

  @override
  void dispose() {
    _phoneOrEmailCtl.dispose();
    _nameCtl.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final input = _phoneOrEmailCtl.text.trim();
      final res = await Api.post('/auth/send-otp', {
        'target': input,
        'name': _nameCtl.text.trim(),
      });
      _sentOtp = res['otp']?.toString() ?? (kDebugMode ? '123456' : null);
    } catch (_) {
      _sentOtp = kDebugMode ? '123456' : null;
    }

    if (mounted) {
      setState(() {
        _busy = false;
        _step = 2;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final entered = _otpControllers.map((c) => c.text).join();
    if (entered.length < 6) {
      setState(() => _error = 'Please enter complete 6-digit OTP');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    const isDev = kDebugMode;
    final isValid = (_sentOtp != null && entered == _sentOtp) || (isDev && entered == '123456');

    if (isValid) {
      final name = _nameCtl.text.trim().isEmpty ? 'FinSwitch User' : _nameCtl.text.trim();
      final identifier = _phoneOrEmailCtl.text.trim();
      AuthState.login('token_$entered', identifier, name);
      if (mounted) context.go('/onboarding');
    } else {
      setState(() {
        _busy = false;
        _error = isDev ? 'Invalid OTP code. Try 123456 in dev mode' : 'Invalid OTP code';
      });
    }
  }

  void _skip() {
    AuthState.login('demo_token', 'demo@finswitch.app', 'Guest User');
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 1 ? 'Sign In / Register' : 'Verify OTP'),
        actions: [
          TextButton(onPressed: _skip, child: const Text('Skip')),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _step == 1 ? _buildStep1() : _buildStep2(),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text('Welcome to FinSwitch', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Enter your mobile number or email to receive a 6-digit verification code.', style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 15)),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nameCtl,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) => v?.trim().isEmpty == true ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneOrEmailCtl,
            decoration: const InputDecoration(
              labelText: 'Mobile Number or Email',
              prefixIcon: Icon(Icons.phone_android_outlined),
              hintText: '+91 9876543210 or user@example.com',
            ),
            validator: (v) => (v?.trim().length ?? 0) < 4 ? 'Enter valid phone number or email' : null,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy ? null : _sendOtp,
              child: _busy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Send Verification Code'),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: _skip,
              child: const Text('Continue as Guest'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text('Enter Verification Code', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('We sent a 6-digit OTP code to ${_phoneOrEmailCtl.text}.', style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 15)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Demo OTP: ${_sentOtp ?? "123456"}',
                  style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 48,
              height: 56,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  } else if (val.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                  if (index == 5 && val.isNotEmpty) {
                    _verifyOtp();
                  }
                },
              ),
            );
          }),
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _busy ? null : _verifyOtp,
            child: _busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Verify & Continue'),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => setState(() => _step = 1),
              child: const Text('Change Number'),
            ),
            TextButton(
              onPressed: _sendOtp,
              child: const Text('Resend OTP'),
            ),
          ],
        ),
      ],
    );
  }
}
