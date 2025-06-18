/*
** EPITECH PROJECT, 2025
** email_screen.dart
** File description:
** Email screen for the Deezer app.
** This file contains the UI and logic for the email input screen.
** It validates the email format and navigates to the password screen upon valid input.
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'password_page.dart';

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

class EmailScreen extends StatefulWidget {
  const EmailScreen({Key? key}) : super(key: key);

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isValidEmail = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    setState(() {
      final email = _emailController.text;
      _isValidEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
      _isValidEmail = _isValidEmail && email.endsWith('@epitech.eu');
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
            Navigator.pop(context);
          },
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Email",
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            CupertinoTextField(
              controller: _emailController,
              style: const TextStyle(color: CupertinoColors.white),
              textCapitalization: TextCapitalization.none,
              inputFormatters: [
                LowerCaseTextFormatter(),
              ],
              placeholder: 'your.name@epitech.eu',
              placeholderStyle: TextStyle(color: CupertinoColors.systemGrey),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.darkBackgroundGray,
                borderRadius: BorderRadius.circular(8),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: CupertinoButton.filled(
                onPressed: _isValidEmail
                    ? () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => PasswordScreen(email: _emailController.text),
                          ),
                        );
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
}
