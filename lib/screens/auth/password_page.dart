/*
** EPITECH PROJECT, 2025
** password_page.dart
** File description:
** Password page for the Epico.
*/

import 'package:flutter/material.dart';
import 'confirmation_page.dart';
import '../../manage/api_manage.dart';
import '../../theme.dart';
import '../../manage/navigation_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PasswordScreen(email: 'your.name@epitech.eu'),
    );
  }
}

class PasswordScreen extends StatefulWidget {
  final String email;

  const PasswordScreen({required this.email, super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _hasMinLength = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;
  String _passwordStrength = '';
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
    _passwordController.dispose();
    _hideErrorMessage();
    super.dispose();
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasDigit = RegExp(r'[0-9]').hasMatch(password);
      _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

      if (password.isEmpty) {
        _passwordStrength = '';
      } else if (_hasMinLength && _hasDigit && _hasSpecialChar) {
        _passwordStrength = 'Strong';
      } else if (_hasMinLength) {
        _passwordStrength = 'Medium';
      } else {
        _passwordStrength = 'Weak';
      }
    });
  }

  bool get _isPasswordValid => _hasMinLength && _hasDigit && _hasSpecialChar;

  void _showErrorMessage(BuildContext context, String message) {
    if (!mounted) {
      return;
    }
    _hideErrorMessage();
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => Positioned(
        top: MediaQuery.of(overlayContext).viewPadding.top,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: _hideErrorMessage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Sign up',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Create a password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                hintText: 'Your password',
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your password must include',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildRequirementRow('At least 8 characters', _hasMinLength),
                        const SizedBox(height: 4),
                        _buildRequirementRow('At least 1 number', _hasDigit),
                        const SizedBox(height: 4),
                        _buildRequirementRow('At least 1 special character', _hasSpecialChar),
                      ],
                    ),
                  ),
                  _passwordStrength != ''
                      ? Text(
                          _passwordStrength,
                          style: TextStyle(
                            color: _passwordStrength == 'Strong'
                                ? Colors.green
                                : _passwordStrength == 'Medium'
                                    ? Colors.orange
                                    : Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isPasswordValid
                  ? () async {
                    final currentContext = context;
                    try {
                      final apiService = MusicApiService();
                      final response = await apiService.createUser(widget.email, _passwordController.text);
                      if (!currentContext.mounted) {
                        return;
                      }
                      if (response['status'] == 'ok') {
                        if (!currentContext.mounted) {
                          return;
                        }
                        NavigationHelper.pushFade(
                          currentContext,
                          const ConfirmationPage(),
                        );
                      } else {
                        if (!currentContext.mounted) {
                          return;
                        }
                        _showErrorMessage(currentContext, 'Failed to create user: ${response['message']}');
                      }
                    } catch (e) {
                      if (!currentContext.mounted) {
                        return;
                      }
                      _showErrorMessage(currentContext, 'Error: $e');
                    }
                    }
                  : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentColor,
                  disabledBackgroundColor: kAccentColor.withAlpha(128),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
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
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}