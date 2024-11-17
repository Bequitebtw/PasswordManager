class User {
  String masterPassword;
  String secretQuestion;
  String secretAnswer;

  User(
      {required this.masterPassword,
      required this.secretQuestion,
      required this.secretAnswer});
}
