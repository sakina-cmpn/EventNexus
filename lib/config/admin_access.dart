class AdminAccess {
  static const Set<String> _adminEmails = {
    'fullsd206@gmail.com',
    'rizvisakeena16@gmail.com',
  };

  static bool isAdminEmail(String? email) {
    if (email == null) return false;
    return _adminEmails.contains(email.trim().toLowerCase());
  }
}
