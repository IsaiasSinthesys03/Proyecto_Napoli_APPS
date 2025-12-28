import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration for CourierApp
class SupabaseConfig {
  SupabaseConfig._();

  static const String projectUrl = 'https://olrsqnoehkbswxcocqhq.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9scnNxbm9laGtic3d4Y29jcWhxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU1Nzk5MDIsImV4cCI6MjA4MTE1NTkwMn0.E4baeltNhgWwRwggFyXR_374h1GZuxvpVxWdaiQr0Ng';

  /// Initialize Supabase client
  static Future<void> initialize() async {
    await Supabase.initialize(url: projectUrl, anonKey: anonKey);
  }

  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get the current authenticated user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}
