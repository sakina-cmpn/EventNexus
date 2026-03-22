class SupabaseConfig {
  static const url = 'https://ispbjrjfwowsmdimdbin.supabase.co';

  static const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlzcGJqcmpmd293c21kaW1kYmluIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM5OTgwNzksImV4cCI6MjA4OTU3NDA3OX0.5IPZW3NjF8MoKzUsYG8xLlgGZDKNbZITN9sJEmB3FbA';

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}