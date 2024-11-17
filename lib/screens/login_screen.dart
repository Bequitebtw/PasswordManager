import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'password_meneger_screen.dart';
import 'setup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  Future<void> _checkMasterPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('masterPassword');
    final secretQuestion = prefs.getString('secretQuestion');
    final secretAnswer = prefs.getString('secretAnswer');

    if (savedPassword == null ||
        secretQuestion == null ||
        secretAnswer == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SetupScreen()),
      );
    } else if (_passwordController.text == savedPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PasswordManagerScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Неверный мастер пароль!')),
      );
    }
  }

  Future<void> _forgotPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final secretQuestion = prefs.getString('secretQuestion');
    final secretAnswer = prefs.getString('secretAnswer');

    if (secretQuestion != null && secretAnswer != null) {
      int incorrectAttempts = prefs.getInt('incorrectAttempts') ?? 0;
      DateTime? blockTime = prefs.getString('blockTime') != null
          ? DateTime.parse(prefs.getString('blockTime')!)
          : null;

      if (blockTime != null &&
          DateTime.now().isBefore(blockTime.add(Duration(minutes: 1)))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Попробуйте снова через 1 минуту')),
        );
        return;
      }

      if (blockTime != null &&
          DateTime.now().isAfter(blockTime.add(Duration(minutes: 1)))) {
        prefs.remove('incorrectAttempts');
        prefs.remove('blockTime');
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController answerController = TextEditingController();

          return AlertDialog(
            title: Text(secretQuestion!),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: answerController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Ваш ответ'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (answerController.text == secretAnswer) {
                      prefs.remove('Не правильный ответ');
                      Navigator.pop(context);
                      _showChangePasswordDialog();
                    } else {
                      incorrectAttempts++;
                      prefs.setInt('Не верная попытка: ', incorrectAttempts);
                      if (incorrectAttempts >= 3) {
                        prefs.setString('blockTime', DateTime.now().toString());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Три неправильных попытки. Попробуйте снова через 1 минуту')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Неправильный ответ! Попробуйте снова')),
                        );
                      }
                    }
                  },
                  child: Text('Ввести'),
                ),
              ],
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Нет данных для восстановления пароля!')),
      );
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final TextEditingController newPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Введите новый мастер пароль'),
          content: TextField(
            controller: newPasswordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Новый пароль'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                if (newPasswordController.text.isNotEmpty) {
                  prefs.setString('masterPassword', newPasswordController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Пароль успешно изменен!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Пароль не может быть пустым')),
                  );
                }
              },
              child: Text('Сменить пароль'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Отмена'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Мастер пароль'),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _checkMasterPassword,
                  child: Text('Войти'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _forgotPassword,
                  child: Text('Забыл пароль'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
