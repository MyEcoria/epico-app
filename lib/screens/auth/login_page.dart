/*
** EPITECH PROJECT, 2025
** login_page.dart
** File description:
** Login page for the Deezer app.
** This file contains the UI and logic for the login screen.
** It validates the email and password, stores the authentication cookie,
** and navigates to the home page upon successful login.
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_page.dart';
import '../../manage/api_manage.dart';
import '../../theme.dart';
import '../../manage/navigation_helper.dart';

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
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: _hideErrorMessage,
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            NavigationHelper.pushFade(context, HomePage());
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Login to your account",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [
                LowerCaseTextFormatter(),
              ],
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                hintText: "Your email",
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                hintText: "Your password",
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey[400],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
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
                            color: Colors.white,
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
                                ? Colors.green
                                : _passwordStrength == "Medium"
                                    ? Colors.orange
                                    : Colors.red,
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
              child: ElevatedButton(
                onPressed: _isFormValid
                  ? () async {
                    try {
                      final apiService = MusicApiService();
                      final response = await apiService.loginUser(_emailController.text, _passwordController.text);
                      if (response['status'] == 'ok') {
                        _storeCookie(response['cookie']);
                        NavigationHelper.pushFade(context, HomePage());
                      } else {
                      _showErrorMessage('Failed to create user: ${response['message']}');
                      }
                    } catch (e) {
                      _showErrorMessage('Error: $e');
                    }
                    }
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentColor,
                  disabledBackgroundColor: kAccentColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 16, color: Colors.white),
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
            color: isValid ? Colors.green : Colors.transparent,
            border: isValid
                ? null
                : Border.all(color: Colors.grey, width: 1),
          ),
          child: isValid
              ? Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
