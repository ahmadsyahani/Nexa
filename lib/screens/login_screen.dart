import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/main_navigation.dart';
import '../services/api_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final EtholApiService _apiService = EtholApiService();

  bool _isLoading = false;
  bool _obscureText = true;

  // Set ke false untuk menggunakan API asli
  final bool _useBypass = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('NetID dan Password jangan kosong bro!');
      return;
    }

    setState(() => _isLoading = true);

    try {
      var response;
      if (_useBypass) {
        await Future.delayed(const Duration(seconds: 1));
        response = {
          'error': false,
          'data': {
            'nama': 'Ahmad Syahani',
            'nrp': '3123500000',
            'semester': '4',
            'status': 'Aktif',
          },
        };
      } else {
        response = await _apiService.getProfile(email, password);
      }

      if (mounted) {
        if (response != null && response['error'] == false) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_email', email);
          await prefs.setString('saved_password', password);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavigation(
                profileData: response,
                email: email,
                password: password,
              ),
            ),
          );
        } else {
          _showErrorSnackBar('Login Gagal. Cek lagi NetID atau Passwordmu.');
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString().contains('401')
            ? 'NetID atau Password salah.'
            : 'Gagal terhubung ke server Ethol!';
        _showErrorSnackBar(errorMsg);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- LOGO WORDMARK (DYNAMIC SWITCH & GLOW) ---
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: isDark
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withOpacity(0.2),
                                blurRadius: 50,
                                spreadRadius: 1,
                              ),
                            ]
                          : [],
                    ),
                    child: Image.asset(
                      isDark
                          ? 'assets/images/Nexa_wordmark_light.png'
                          : 'assets/images/Nexa_wordmark.png',
                      height: 50,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 64),

                Text(
                  'Selamat Datang!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'PlusJakartaSans',
                    color: isDark ? Colors.white : const Color(0xFF111827),
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masuk dengan NetID ETHOL untuk melanjutkan.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
                const SizedBox(height: 48),

                _buildModernTextField(
                  controller: _emailController,
                  hint: 'NetID / Email',
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                ),
                const SizedBox(height: 18),
                _buildModernTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  obscure: _obscureText,
                  isDark: isDark,
                  onToggleVisibility: () =>
                      setState(() => _obscureText = !_obscureText),
                ),
                const SizedBox(height: 40),

                M3BouncyButton(
                  onTap: _isLoading ? null : _handleLogin,
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      // LOGIKA: Putih pas Dark Mode, Gelap pas Light Mode
                      color: isDark
                          ? Colors.white
                          : const Color.fromARGB(255, 17, 12, 4),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isDark
                                      ? Colors.white
                                      : const Color.fromARGB(255, 17, 12, 4))
                                  .withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              // Loading juga ikut berubah warnanya
                              color: isDark
                                  ? const Color(0xFF111827)
                                  : Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Masuk',
                            style: TextStyle(
                              // Teks jadi Hitam pas tombol Putih, dan sebaliknya
                              color: isDark
                                  ? const Color(0xFF111827)
                                  : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'PlusJakartaSans',
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscure : false,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF111827),
          fontFamily: 'PlusJakartaSans',
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class M3BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const M3BouncyButton({super.key, required this.child, this.onTap});
  @override
  State<M3BouncyButton> createState() => _M3BouncyButtonState();
}

class _M3BouncyButtonState extends State<M3BouncyButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (widget.onTap != null) {
          setState(() => _isPressed = false);
          widget.onTap!();
        }
      },
      onTapCancel: () {
        if (widget.onTap != null) setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}
