import 'package:supabase_flutter/supabase_flutter.dart';

class WaitService {
  static SupabaseClient? client;
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static Future<void> initialize() async {
    if (url.isEmpty || key.isEmpty) return;
    await Supabase.initialize(url: url, anonKey: key);
    client = Supabase.instance.client;
  }

  static Future<Map<String, dynamic>> read() async {
    final result = await client!.rpc('read_shop_wait').timeout(const Duration(seconds: 10));
    return Map<String, dynamic>.from(result as Map);
  }
}

class WaitSnapshot {
  WaitSnapshot(this.row, this.serverNow, this.received);
  final Map<String, dynamic>? row;
  final DateTime serverNow;
  final DateTime received;

  DateTime now(DateTime deviceNow) => serverNow.add(deviceNow.difference(received));
  String status(DateTime deviceNow) {
    final value = row;
    if (value == null) return 'unknown';
    final expires = DateTime.tryParse(value['expires_at']?.toString() ?? '');
    final updated = DateTime.tryParse(value['updated_at']?.toString() ?? '');
    final time = now(deviceNow);
    if (expires == null || updated == null || !expires.isAfter(time) || updated.isAfter(time.add(const Duration(minutes: 1)))) return 'unknown';
    final status = value['status'];
    if (!['available', 'moderate', 'busy', 'closed'].contains(status)) return 'unknown';
    if (status != 'closed') {
      final min = value['wait_min'];
      final max = value['wait_max'];
      if (min is! int || max is! int || min < 0 || max < min || max > 240) return 'unknown';
    }
    return status as String;
  }
}
