class Password {
  final int? id;
  final String group;
  final String name;
  final String login;
  final String password;

  Password({
    this.id,
    required this.group,
    required this.name,
    required this.login,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'password_group': group, // Changed from 'group' to 'password_group'
      'name': name,
      'login': login,
      'password': password,
    };
  }

  static Password fromMap(Map<String, dynamic> map) {
    return Password(
      id: map['id'],
      group: map['group'] ??
          map['password_group'] ??
          '', // Handle both field names
      name: map['name'] ?? '',
      login: map['login'] ?? '',
      password: map['password'] ?? '',
    );
  }
}
