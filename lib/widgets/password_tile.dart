import 'package:flutter/material.dart';
import 'package:pass_meneger/models/password_model.dart';

class PasswordItem extends StatelessWidget {
  final Password password;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  PasswordItem(
      {required this.password, required this.onDelete, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(password.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
