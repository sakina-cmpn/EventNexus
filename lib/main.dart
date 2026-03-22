import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  runApp(const EventNexusApp());
}

class EventNexusApp extends StatelessWidget {
  const EventNexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!SupabaseConfig.isConfigured) {
      return MaterialApp(
        title: 'EventNexus',
        debugShowCheckedModeBanner: false,
        home: const _SupabaseNotConfiguredScreen(),
      );
    }

    return MaterialApp(
      title: 'EventNexus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF311B92),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const SplashScreen(),
    );
  }
}

class _SupabaseNotConfiguredScreen extends StatelessWidget {
  const _SupabaseNotConfiguredScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12),
              Text(
                'Supabase not configured',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 10),
              Text(
                'Run with:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'flutter run --dart-define=SUPABASE_URL=YOUR_URL '
                '--dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
