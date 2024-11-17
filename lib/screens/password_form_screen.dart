import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pass_meneger/services/database_helper.dart';
import 'package:pass_meneger/services/encryption_helper.dart';
import 'package:pass_meneger/models/password_model.dart';

class PasswordFormScreen extends StatefulWidget {
  final Password? password;
  PasswordFormScreen({this.password});

  @override
  _PasswordFormScreenState createState() => _PasswordFormScreenState();
}

class _PasswordFormScreenState extends State<PasswordFormScreen> {
  final _nameController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isRepeatPasswordVisible = false;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final List<String> groups =
      ["Работа", "Соц. Сети", "Личное", "Остальное"].toSet().toList();
  String? selectedGroup;

  @override
  void initState() {
    super.initState();
    if (widget.password != null) {
      _nameController.text = widget.password!.name;
      _loginController.text = widget.password!.login;
      try {
        _passwordController.text =
            EncryptionHelper.decryptPassword(widget.password!.password);
        _repeatPasswordController.text =
            EncryptionHelper.decryptPassword(widget.password!.password);
      } catch (e) {
        print("Ошибка расшифровки: $e");
        _passwordController.text = "";
        _repeatPasswordController.text = "";
      }
      selectedGroup = widget.password!.group;
    } else {
      selectedGroup = groups.isNotEmpty ? groups[0] : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.password == null
            ? 'Добавить новый пароль'
            : 'Редактировать Пароль'),
        actions: widget.password != null
            ? [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: _passwordController.text));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Пароль скопирован в буффер обмена!')));
                  },
                ),
              ]
            : [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: selectedGroup,
              onChanged: (newGroup) {
                setState(() {
                  selectedGroup = newGroup;
                });
              },
              items: groups.map<DropdownMenuItem<String>>((String group) {
                return DropdownMenuItem<String>(
                  value: group,
                  child: Text(group),
                );
              }).toList(),
              hint: const Text('Выберите группу'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(labelText: 'Логин'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Пароль',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
            ),
            const SizedBox(height: 10),
            if (widget.password == null)
              TextField(
                controller: _repeatPasswordController,
                decoration: InputDecoration(
                  labelText: 'Повторите пароль',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isRepeatPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isRepeatPasswordVisible = !_isRepeatPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isRepeatPasswordVisible,
              ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.isEmpty ||
                        _loginController.text.isEmpty ||
                        _passwordController.text.isEmpty ||
                        (widget.password == null &&
                            _repeatPasswordController.text.isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Заполните все поля!')),
                      );
                      return;
                    }

                    if (_passwordController.text ==
                            _repeatPasswordController.text ||
                        widget.password != null) {
                      final encryptedPassword =
                          EncryptionHelper.encryptPassword(
                              _passwordController.text);

                      if (widget.password != null) {
                        await _dbHelper.updatePassword(
                          id: widget.password!.id!,
                          group: selectedGroup ?? '',
                          name: _nameController.text,
                          login: _loginController.text,
                          password: encryptedPassword,
                        );

                        if (!mounted) return;
                        Navigator.pop(
                            context,
                            Password(
                              id: widget.password!.id,
                              group: selectedGroup ?? '',
                              name: _nameController.text,
                              login: _loginController.text,
                              password: encryptedPassword,
                            ));
                      } else {
                        final newPassword = Password(
                          group: selectedGroup ?? '',
                          name: _nameController.text,
                          login: _loginController.text,
                          password: encryptedPassword,
                        );

                        await _dbHelper.insertPassword(newPassword);

                        if (!mounted) return;
                        Navigator.pop(context, newPassword);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Пароли не совпадают')));
                    }
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
