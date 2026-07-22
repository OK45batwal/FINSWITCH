import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/theme.dart';
import '../../../app/config/brand_logo_header.dart';
import '../../../core/auth_state.dart';

const String kOfficialSupportEmail = 'finswitch74@gmail.com';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController(text: 'finswitch74@gmail.com');
  final _passwordCtl = TextEditingController(text: 'password123');
  final _nameCtl = TextEditingController(text: 'Omkar Batwal');

  bool _isRegisterMode = false;
  bool _rememberMe = true;
  bool _showPassword = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passwordCtl.dispose();
    _nameCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    final name = _nameCtl.text.trim().isNotEmpty ? _nameCtl.text.trim() : 'Omkar Batwal';
    final email = _emailCtl.text.trim();
    AuthState.login('token-auth-success', email, name);

    if (mounted) {
      context.go('/dashboard');
    }
  }

  void _skip() {
    AuthState.login('demo-token', kOfficialSupportEmail, 'Demo User');
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isRegisterMode ? 'Create Account' : 'Sign In'),
        actions: [
          TextButton(onPressed: _skip, child: const Text('Skip')),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Center(child: BrandLogoHeader(height: 48, showSlogan: true)),
                const SizedBox(height: 24),
                Text(
                  _isRegisterMode ? 'Create Your Account' : 'Welcome Back',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  _isRegisterMode
                      ? 'Sign up to start tracking your portfolio with AI insights.'
                      : 'Sign in to access your stock market dashboard & portfolio.',
                  style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Mode Toggle Segmented Control
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.borderOf(context).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() { _isRegisterMode = false; _error = null; }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isRegisterMode ? AppTheme.cardOf(context) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: !_isRegisterMode ? AppTheme.textOf(context) : AppTheme.mutedOf(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() { _isRegisterMode = true; _error = null; }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isRegisterMode ? AppTheme.cardOf(context) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Register',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _isRegisterMode ? AppTheme.textOf(context) : AppTheme.mutedOf(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (_isRegisterMode) ...[
                  TextFormField(
                    controller: _nameCtl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => v?.trim().isEmpty == true ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  controller: _emailCtl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                    hintText: 'finswitch74@gmail.com',
                  ),
                  validator: (v) => (v?.trim().length ?? 0) < 4 || !v!.contains('@') ? 'Enter a valid email address' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordCtl,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                      tooltip: _showPassword ? 'Hide Password' : 'Show Password',
                    ),
                  ),
                  validator: (v) => (v?.trim().length ?? 0) < 6 ? 'Password must be at least 6 characters' : null,
                ),

                if (!_isRegisterMode) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: AppTheme.emeraldGreen,
                            onChanged: (v) => setState(() => _rememberMe = v ?? true),
                          ),
                          const Text('Remember me', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                      TextButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Password reset link sent to ${_emailCtl.text}')),
                        ),
                        child: const Text('Forgot password?', style: TextStyle(color: AppTheme.emeraldGreen, fontSize: 13)),
                      ),
                    ],
                  ),
                ],

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                ],

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_isRegisterMode ? 'Create Account' : 'Sign In'),
                  ),
                ),

                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => setState(() { _isRegisterMode = !_isRegisterMode; _error = null; }),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: AppTheme.mutedOf(context), fontSize: 13),
                        children: [
                          TextSpan(text: _isRegisterMode ? 'Already have an account? ' : 'Don\'t have an account? '),
                          TextSpan(
                            text: _isRegisterMode ? 'Sign In' : 'Register',
                            style: const TextStyle(color: AppTheme.emeraldGreen, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Official Support Email Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardOf(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderOf(context), width: 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.mark_email_read_outlined, size: 16, color: AppTheme.emeraldGreen),
                      SizedBox(width: 8),
                      Text('Official Support: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        kOfficialSupportEmail,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
