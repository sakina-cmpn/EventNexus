class AppUser {
  final String id;
  final String email;
  final String? name;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.createdAt,
  });
}
