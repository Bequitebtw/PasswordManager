import 'package:flutter/material.dart';

class PasswordDialog extends StatefulWidget {
  final Function(String, String, String) onSave;
  final String initialPlatform;
  final String initialPassword;
  final String initialLogin;

  PasswordDialog({
    required this.onSave,
    this.initialPlatform = '',
    this.initialPassword = '',
    this.initialLogin = '',
  });

  @override
  _PasswordDialogState createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  late TextEditingController _platformController;
  late TextEditingController _passwordController;
  late TextEditingController _loginController;

  @override
  void initState() {
    super.initState();
    _platformController = TextEditingController(text: widget.initialPlatform);
    _passwordController = TextEditingController(text: widget.initialPassword);
    _loginController = TextEditingController(text: widget.initialLogin);
  }

  @override
  void dispose() {
    _platformController.dispose();
    _passwordController.dispose();
    _loginController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Password Details'),
      content: Column(
        children: [
          TextField(
            controller: _platformController,
            decoration: InputDecoration(labelText: 'Platform'),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          TextField(
            controller: _loginController,
            decoration: InputDecoration(labelText: 'Login'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final platform = _platformController.text;
            final password = _passwordController.text;
            final login = _loginController.text;
            if (platform.isNotEmpty &&
                password.isNotEmpty &&
                login.isNotEmpty) {
              widget.onSave(platform, password, login);
              Navigator.pop(context);
            }
          },
          child: Text('Save'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
