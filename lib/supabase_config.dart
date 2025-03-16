import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: "https://yiqhioqzyimnavogkigy.supabase.co",
      anonKey: "SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlpcWhpb3F6eWltbmF2b2draWd5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIwNTQzMzksImV4cCI6MjA1NzYzMDMzOX0.7aCwB2Xcd2qK95zxRzDmRs6ce9DhnjyNWHA8wkMrFjo",
    );
  }
}
