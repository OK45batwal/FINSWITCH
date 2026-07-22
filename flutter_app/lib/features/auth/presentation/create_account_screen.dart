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
  final _form = GlobalKey<FormState>();
  final _nameCtl = TextEditingController(text: 'Omkar Batwal');
  final _emailCtl = TextEditingController(text: 'omkar@example.com');
  final _phoneCtl = TextEditingController(text: '+91-9876543210');
  final _passCtl = TextEditingController(text: 'demo1234');
  bool _busy = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _phoneCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final r = await Api.post('/auth/register', {
        'email': _emailCtl.text.trim(),
        'password': _passCtl.text,
        'display_name': _nameCtl.text.trim(),
        'phone': _phoneCtl.text.trim(),
      });
      final t = r['access_token'] ?? '';
      AuthState.login(t, _emailCtl.text.trim(), _nameCtl.text.trim());
      if (mounted) context.go('/onboarding');
    } catch (_) {
      if (mounted) context.go('/onboarding');
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 20),
              Text('Get Started', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Create your FinSwitch account', style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 15)),
              const SizedBox(height: 32),
              TextFormField(controller: _nameCtl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)), validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _emailCtl, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), keyboardType: TextInputType.emailAddress, validator: (v) => v?.contains('@') == true ? null : 'Valid email required'),
              const SizedBox(height: 16),
              TextFormField(controller: _phoneCtl, decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)), keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              TextFormField(controller: _passCtl, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outlined), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure))), obscureText: _obscure, validator: (v) => (v?.length ?? 0) < 4 ? 'Min 4 characters' : null),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _busy ? null : _submit, child: _busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Create Account'))),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Already have an account?', style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 13)),
                TextButton(onPressed: () => context.go('/onboarding'), child: const Text('Skip')),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
