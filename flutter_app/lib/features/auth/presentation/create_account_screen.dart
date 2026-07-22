import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/theme.dart';
import '../../../app/config/brand_logo_header.dart';
import '../../../core/api.dart';
import '../../../core/auth_state.dart';

const String kSenderEmail = 'finswitch74@gmail.com';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneOrEmailCtl = TextEditingController(text: 'finswitch74@gmail.com');
  final _passwordCtl = TextEditingController(text: '••••••••••••');
  final _nameCtl = TextEditingController(text: 'Omkar Batwal');
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  int _step = 1; // 1: Password Login, 2: Verify OTP
  bool _busy = false;
  String? _sentOtp;
  String? _error;

  @override
  void dispose() {
    _phoneOrEmailCtl.dispose();
    _passwordCtl.dispose();
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
        'sender': kSenderEmail,
      });
      _sentOtp = res['otp']?.toString() ?? (kDebugMode ? '123456' : '987654');
    } catch (_) {
      _sentOtp = kDebugMode ? '123456' : '987654';
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

    final isValid = (_sentOtp != null && entered == _sentOtp) || (kDebugMode && entered == '123456');

    if (isValid) {
      final name = _nameCtl.text.trim().isNotEmpty ? _nameCtl.text.trim() : 'Omkar Batwal';
      final email = _phoneOrEmailCtl.text.trim();
      AuthState.login('jwt-otp-$entered', email, name);
      if (mounted) {
        context.go('/dashboard');
      }
    } else {
      setState(() {
        _busy = false;
        _error = kDebugMode ? 'Invalid OTP. Try 123456 in debug mode' : 'Invalid OTP code';
      });
    }
  }

  void _skip() {
    AuthState.login('demo-token', kSenderEmail, 'Demo User');
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 1 ? 'Password Login' : '2FA OTP Verification'),
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
          const Center(child: BrandLogoHeader(height: 48, showSlogan: true)),
          const SizedBox(height: 24),
          Text('Welcome to FinSwitch', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Enter your credentials to receive a 6-digit OTP verification code.', style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 15)),
          const SizedBox(height: 24),
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
              labelText: 'Email Address or Mobile',
              prefixIcon: Icon(Icons.email_outlined),
              hintText: 'finswitch74@gmail.com',
            ),
            validator: (v) => (v?.trim().length ?? 0) < 4 ? 'Enter valid email address' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordCtl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (v) => (v?.trim().length ?? 0) < 6 ? 'Password must be at least 6 characters' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.mark_email_read_outlined, size: 14, color: AppTheme.emeraldGreen),
              SizedBox(width: 6),
              Text(
                'OTP Sender: finswitch74@gmail.com',
                style: TextStyle(color: AppTheme.emeraldGreen, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy ? null : _sendOtp,
              child: _busy
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Login & Request 2FA OTP'),
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
        const Center(child: BrandLogoHeader(height: 44, showSlogan: false)),
        const SizedBox(height: 24),
        Text('Verify 2FA OTP Code', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text('Enter the 6-digit code sent from $kSenderEmail to ${_phoneOrEmailCtl.text}', style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 15)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.emeraldGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.emeraldGreen.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_outlined, color: AppTheme.emeraldGreen, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sender Email:', style: TextStyle(color: AppTheme.emeraldGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(kSenderEmail, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (_sentOtp != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _sentOtp!,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) {
            return SizedBox(
              width: 48,
              height: 56,
              child: TextFormField(
                controller: _otpControllers[i],
                focusNode: _focusNodes[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                maxLength: 1,
                decoration: const InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) {
                  if (val.isNotEmpty && i < 5) {
                    _focusNodes[i + 1].requestFocus();
                  } else if (val.isEmpty && i > 0) {
                    _focusNodes[i - 1].requestFocus();
                  }
                  if (_otpControllers.every((c) => c.text.isNotEmpty)) {
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
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _busy ? null : _verifyOtp,
            child: _busy
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Verify OTP & Proceed'),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () => setState(() => _step = 1),
            child: const Text('← Change Credentials'),
          ),
        ),
      ],
    );
  }
}
