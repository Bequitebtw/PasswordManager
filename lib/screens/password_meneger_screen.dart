import 'package:flutter/material.dart';
import 'package:pass_meneger/models/password_model.dart';
import 'package:pass_meneger/provider/theme_provider.dart';
import 'package:pass_meneger/services/database_helper.dart';
import 'password_form_screen.dart';
import 'package:provider/provider.dart';

class PasswordManagerScreen extends StatefulWidget {
  @override
  _PasswordManagerScreenState createState() => _PasswordManagerScreenState();
}

class _PasswordManagerScreenState extends State<PasswordManagerScreen> {
  List<Password> _passwords = [];
  List<Password> _filteredPasswords = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  TextEditingController _searchController = TextEditingController();
  String? _selectedGroup;
  List<String> _groups =
      ["Все", "Работа", "Соц. Сети", "Личное", "Остальное"].toSet().toList();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPasswords();
    _searchController.addListener(_filterPasswords);
    _selectedGroup = _groups.first;
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPasswords);
    super.dispose();
  }

  void _loadPasswords() async {
    List<Password> passwords = await _dbHelper.getPasswords();
    setState(() {
      _passwords = passwords;
      _filterPasswords();
    });
  }

  void _filterPasswords() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (_selectedGroup == "Все") {
        _filteredPasswords = _passwords.where((password) {
          return password.name.toLowerCase().contains(query) ||
              password.group.toLowerCase().contains(query);
        }).toList();
      } else {
        _filteredPasswords = _passwords.where((password) {
          return (password.group.toLowerCase() ==
                  _selectedGroup!.toLowerCase()) &&
              (password.name.toLowerCase().contains(query) ||
                  password.group.toLowerCase().contains(query));
        }).toList();
      }
    });
  }

  void _addPassword() async {
    final newPassword = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordFormScreen(),
      ),
    ) as Password?;

    if (newPassword != null) {
      _loadPasswords();
    }
  }

  void _deletePassword(int id) async {
    await DatabaseHelper.instance.deletePassword(id);
    _loadPasswords();
  }

  void _editPassword(Password password) async {
    final updatedPassword = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordFormScreen(password: password),
      ),
    );

    if (updatedPassword is Password) {
      _loadPasswords();
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Менеджер Паролей'),
      ),
      body: _currentIndex == 0
          ? _buildPasswordManagerScreen()
          : SettingsScreen(
              onPasswordsDeleted: () {
                setState(() {
                  _passwords = [];
                  _filteredPasswords = [];
                });
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: 'Пароли',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _addPassword,
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildPasswordManagerScreen() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Поиск',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 10),
              DropdownButton<String>(
                value: _selectedGroup,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGroup = newValue;
                    _filterPasswords();
                  });
                },
                items: _groups.map<DropdownMenuItem<String>>((String group) {
                  return DropdownMenuItem<String>(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount:
                _filteredPasswords.isEmpty ? 1 : _filteredPasswords.length,
            itemBuilder: (context, index) {
              if (_filteredPasswords.isEmpty) {
                return Center(child: Text('Добавьте пароль 🤗'));
              }

              final password = _filteredPasswords[index];
              return ListTile(
                title: Text(password.name),
                subtitle: Text(password.group),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deletePassword(password.id!),
                ),
                onTap: () => _editPassword(password),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final VoidCallback onPasswordsDeleted;

  const SettingsScreen({
    Key? key,
    required this.onPasswordsDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Настройки',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Тема приложения',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Светлая тема'),
                      leading: Radio<ThemeMode>(
                        value: ThemeMode.light,
                        groupValue: themeProvider.themeMode,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            themeProvider.toggleTheme(value);
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Темная тема'),
                      leading: Radio<ThemeMode>(
                        value: ThemeMode.dark,
                        groupValue: themeProvider.themeMode,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            themeProvider.toggleTheme(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Опасная зона',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      title: const Text(
                        'Удалить все пароли',
                        style: TextStyle(color: Colors.red),
                      ),
                      subtitle: const Text(
                        'Это действие нельзя отменить',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () => _showDeleteConfirmationDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Подтверждение удаления'),
          content: const Text(
            'Вы уверены, что хотите удалить ВСЕ пароли? '
            'Это действие нельзя будет отменить!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success =
                    await DatabaseHelper.instance.deleteAllPasswords();

                if (!context.mounted) return;

            
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Все пароли успешно удалены'
                          : 'Произошла ошибка при удалении паролей',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );

                if (success) {
                  onPasswordsDeleted(); 
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }
}
