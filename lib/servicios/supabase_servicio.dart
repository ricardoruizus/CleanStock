import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _url = 'TU_PROJECT_URL';
  static const String _anonKey = 'TU_ANON_KEY';

  static Future<void> inicializar() async {
    await Supabase.initialize(
      url: _url,
      anonKey: _anonKey,
    );
  }

  static SupabaseClient get cliente => Supabase.instance.client;
}