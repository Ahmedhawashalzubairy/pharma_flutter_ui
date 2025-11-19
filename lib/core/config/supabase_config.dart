import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://jxjlvmlyleuvghytpmbs.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp4amx2bWx5bGV1dmdoeXRwbWJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1NjM0MTgsImV4cCI6MjA3OTEzOTQxOH0.HKoQE36HtLF5197bKMEQxNCRg85tBk5mcLUj99nPoxTR';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

// Database Tables
class DbTables {
  static const String users = 'users';
  static const String pharmacies = 'pharmacies';
  static const String branches = 'branches';
  static const String medicines = 'medicines';
  static const String orders = 'orders';
  static const String orderItems = 'order_items';
  static const String cart = 'cart';
}