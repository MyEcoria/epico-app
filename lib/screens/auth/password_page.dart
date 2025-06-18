import 'package:flutter/cupertino.dart';
import 'confirmation_page.dart';
import '../../manage/api_manage.dart';
import '../../logger.dart';

class PasswordScreen extends StatefulWidget {
  final String email;

  PasswordScreen({required this.email});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _hasMinLength = false;
  bool _hasDigit = false;
  bool _hasSpecialChar = false;
  String _passwordStrength = "";
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    AppLogger.log("Email from previous page: ${widget.email}"); // Example usage
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: CupertinoColors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(CupertinoIcons.exclamationmark_circle, color: CupertinoColors.destructiveRed),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(color: CupertinoColors.white),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 20,
                  onPressed: _hideErrorMessage,
                  child: Icon(CupertinoIcons.xmark, color: CupertinoColors.white, size: 20),
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
            Navigator.pop(context);
          },
        ),
        middle: const Text(
          "Sign up",
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Create a password",
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
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
                onPressed: _isPasswordValid
                    ? () async {
                    try {
                      final apiService = MusicApiService();
                      final response = await apiService.createUser(widget.email, _passwordController.text);
                      if (response['status'] == 'ok') {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ConfirmationPage(),
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
