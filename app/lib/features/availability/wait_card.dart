import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/localization/app_text.dart';
import 'wait_service.dart';

const waitLabels = {'available': 'Available', 'moderate': 'Getting busy', 'busy': 'Very busy', 'closed': 'Closed', 'unknown': 'Current wait unavailable'};
const waitColors = {'available': Colors.green, 'moderate': Colors.amber, 'busy': Colors.red};

class WaitCard extends StatefulWidget {
  const WaitCard({super.key});
  @override
  State<WaitCard> createState() => _WaitCardState();
}

class _WaitCardState extends State<WaitCard> with WidgetsBindingObserver {
  WaitSnapshot? _snapshot;
  bool _connected = false;
  int _request = 0;
  Timer? _poll, _tick;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final client = WaitService.client;
    if (client == null) return;
    _channel = client.channel('flutter-shop-wait-${identityHashCode(this)}').onPostgresChanges(event: PostgresChangeEvent.update, schema: 'public', table: 'shop_wait', callback: (_) => _refresh()).subscribe((status, error) {
      if (status == RealtimeSubscribeStatus.subscribed) {
        _refresh();
      } else if (mounted) {
        setState(() => _connected = false);
      }
    });
    _refresh();
    _poll = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
    _tick = Timer.periodic(const Duration(seconds: 10), (_) { if (mounted) setState(() {}); });
  }

  Future<void> _refresh() async {
    final request = ++_request;
    try {
      final data = await WaitService.read();
      if (!mounted || request != _request) return;
      final now = DateTime.now();
      setState(() {
        _snapshot = WaitSnapshot(data['status'] == null ? null : Map<String, dynamic>.from(data['status'] as Map), DateTime.parse(data['server_now'] as String), now);
        _connected = true;
      });
    } catch (_) {
      if (mounted && request == _request) setState(() => _connected = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && WaitService.client != null) _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _poll?.cancel(); _tick?.cancel();
    if (_channel != null) WaitService.client?.removeChannel(_channel!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _connected ? _snapshot?.status(DateTime.now()) ?? 'unknown' : 'unknown';
    final row = _snapshot?.row;
    return Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AppText('Current shop wait'),
      const SizedBox(height: 8),
      Semantics(liveRegion: true, child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 10, children: [
        Icon(Icons.circle, color: waitColors[status] ?? Colors.grey, size: 16),
        AppText(waitLabels[status]!, style: Theme.of(context).textTheme.titleLarge),
      ])),
      if (status != 'unknown' && status != 'closed') Text('${row!['wait_min']}–${row['wait_max']} ${tr(context, 'minutes')}'),
      const AppText('Estimated time until service starts. Wait may change.'),
      if (status != 'unknown') Text('${tr(context, 'Last updated')}: ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(DateTime.parse(row!['updated_at'] as String).toLocal()))}'),
      if (status == 'unknown') const AppText('Call for current wait: (619) 993-8536'),
    ])));
  }
}
