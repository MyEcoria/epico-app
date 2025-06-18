/*
** EPITECH PROJECT, 2025
** login_page.dart
** File description:
** Login page for the Deezer app.
** This file contains the UI and logic for the login screen.
** It validates the email and password, stores the authentication cookie,
** and navigates to the home page upon successful login.
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_page.dart';
import '../../manage/api_manage.dart';

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _hasMinLength = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;
  String _passwordStrength = "";
  bool _isEmailValid = false;
  final _secureStorage = const FlutterSecureStorage();
  String? _cookieValue;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _emailController.addListener(_validateEmail);
    _loadCookie();
  }

  Future<void> _loadCookie() async {
    String? value = await _secureStorage.read(key: 'auth');
    setState(() {
      _cookieValue = value;
    });
  }

  Future<void> _storeCookie(String value) async {
    await _secureStorage.write(key: 'auth', value: value);
    _loadCookie();
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
    _emailController.removeListener(_validateEmail);
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text;
    setState(() {
      _isEmailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      _isEmailValid = _isEmailValid && email.endsWith('@epitech.eu');
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasDigit = RegExp(r'[0-9]').hasMatch(password);
      _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

      if (password.isEmpty) {
        _passwordStrength = "";
      } else if (_hasMinLength && _hasDigit && _hasSpecialChar) {
        _passwordStrength = "Strong";
      } else if (_hasMinLength) {
        _passwordStrength = "Medium";
      } else {
        _passwordStrength = "Weak";
      }
    });
  }

  bool get _isPasswordValid => _hasMinLength && _hasDigit && _hasSpecialChar;
  bool get _isFormValid => _isPasswordValid && _isEmailValid;

  void _showErrorMessage(String message) {
    _hideErrorMessage();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewPadding.top,
        left: 0,
        right: 0,
        child: CupertinoPopupSurface(
          isSurfacePainted: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: CupertinoColors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.exclamationmark_circle, color: CupertinoColors.destructiveRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: CupertinoColors.white),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 20,
                  onPressed: _hideErrorMessage,
                  child: const Icon(CupertinoIcons.xmark, color: CupertinoColors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _hideErrorMessage() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        border: null,
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoColors.white,
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          },
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Login to your account",
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            CupertinoTextField(
              controller: _emailController,
              style: const TextStyle(color: CupertinoColors.white),
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [
                LowerCaseTextFormatter(),
              ],
              placeholder: "Your email",
              placeholderStyle: TextStyle(color: CupertinoColors.systemGrey),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.darkBackgroundGray,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: _passwordController,
              obscureText: _obscureText,
              style: const TextStyle(color: CupertinoColors.white),
              placeholder: "Your password",
              placeholderStyle: TextStyle(color: CupertinoColors.systemGrey),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.darkBackgroundGray,
                borderRadius: BorderRadius.circular(8),
              ),
              suffix: CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 20,
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                child: Icon(
                  _obscureText ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your password must include",
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildRequirementRow("At least 8 characters", _hasMinLength),
                        SizedBox(height: 4),
                        _buildRequirementRow("At least 1 number", _hasDigit),
                        SizedBox(height: 4),
                        _buildRequirementRow("At least 1 special character", _hasSpecialChar),
                      ],
                    ),
                  ),
                  _passwordStrength != ""
                      ? Text(
                          _passwordStrength,
                          style: TextStyle(
                            color: _passwordStrength == "Strong"
                                ? CupertinoColors.systemGreen
                                : _passwordStrength == "Medium"
                                    ? CupertinoColors.systemOrange
                                    : CupertinoColors.systemRed,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: CupertinoButton.filled(
                onPressed: _isFormValid
                    ? () async {
                        try {
                          final apiService = MusicApiService();
                          final response = await apiService.loginUser(_emailController.text, _passwordController.text);
                          if (response['status'] == 'ok') {
                            _storeCookie(response['cookie']);
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          } else {
                            _showErrorMessage('Failed to create user: ${response['message']}');
                          }
                        } catch (e) {
                          _showErrorMessage('Error: $e');
                        }
                      }
                    : null,
                padding: const EdgeInsets.symmetric(vertical: 14),
                borderRadius: BorderRadius.circular(8),
                disabledColor: CupertinoColors.systemBlue.withOpacity(0.5),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 16, color: CupertinoColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementRow(String text, bool isValid) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isValid ? CupertinoColors.systemGreen : CupertinoColors.transparent,
            border: isValid
                ? null
                : Border.all(color: CupertinoColors.systemGrey, width: 1),
          ),
          child: isValid
              ? const Icon(CupertinoIcons.check_mark, size: 14, color: CupertinoColors.white)
              : null,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
