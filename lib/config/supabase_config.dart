class SupabaseConfig {
  /// Provide these via:
  /// `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
  ///
  /// You can also override with:
  /// `--dart-define=NEXT_PUBLIC_SUPABASE_URL=...`
  /// `--dart-define=NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY=...`
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: String.fromEnvironment(
      'NEXT_PUBLIC_SUPABASE_URL',
      defaultValue: 'https://ispbjrjfwowsmdimdbin.supabase.co',
    ),
  );

  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: String.fromEnvironment(
      'NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY',
      defaultValue: 'sb_publishable_YE6pXH69dNi_AcbA0-eTMA_vey4gwD-',
    ),
  );

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
