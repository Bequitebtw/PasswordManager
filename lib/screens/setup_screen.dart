import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _secretQuestionController =
      TextEditingController();
  final TextEditingController _secretAnswerController = TextEditingController();

 
  Future<void> _checkMasterPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final masterPassword = prefs.getString('masterPassword');

    if (masterPassword != null && masterPassword.isNotEmpty) {
 
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkMasterPassword();
  }


  Future<void> _saveSetup() async {
    final prefs = await SharedPreferences.getInstance();
    final password = _passwordController.text;
    final secretAnswer = _secretAnswerController.text;

    if (password.isNotEmpty && secretAnswer.isNotEmpty) {
      await prefs.setString('masterPassword', password);
      await prefs.setString('secretQuestion', _secretQuestionController.text);
      await prefs.setString('secretAnswer', secretAnswer);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройка мастер пароля')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Мастер пароль'),
            ),
            TextField(
              controller: _secretQuestionController,
              decoration: const InputDecoration(labelText: 'Секретный вопрос'),
            ),
            TextField(
              controller: _secretAnswerController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Ответ на секретный вопрос'),
            ),
            ElevatedButton(
              onPressed: _saveSetup,
              child: const Text('Сохранить и войти'),
            ),
          ],
        ),
      ),
    );
  }
}
