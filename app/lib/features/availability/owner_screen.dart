import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/localization/app_text.dart';
import 'wait_card.dart';
import 'wait_service.dart';

class OwnerScreen extends StatefulWidget {
  const OwnerScreen({super.key});
  @override
  State<OwnerScreen> createState() => _OwnerScreenState();
}

class _OwnerScreenState extends State<OwnerScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  StreamSubscription<void>? _auth;
  bool _owner = false, _busy = false;
  String? _message;
  String? _status;
  int? _min, _max, _version;
  int _valid = 30;
  final _presets = const [(0,15), (15,30), (30,45), (45,60), (60,90), (90,120), (120,180), (180,240)];

  @override
  void initState() {
    super.initState();
    final client = WaitService.client;
    if (client == null) return;
    _auth = client.authChanges.stream.listen((_) {
      if (!mounted) return;
      // Run database work after the authentication callback releases its lock.
      scheduleMicrotask(_loadOwner);
    });
    _loadOwner();
  }

  Future<void> _loadOwner() async {
    final client = WaitService.client!;
    final signedIn = client.signedIn;
    if (!mounted) return;
    setState(() { _owner = false; _version = null; });
    if (!signedIn) return;
    try {
      await client.checkOwner();
      if (!mounted || !client.signedIn) return;
      final data = await WaitService.read();
      if (!mounted || !client.signedIn) return;
      final row = data['status'] as Map<String, dynamic>?;
      setState(() {
        _owner = true;
        _version = row?['version'] as int?;
        _status = row?['status'] as String?;
        _min = row?['wait_min'] as int?;
        _max = row?['wait_max'] as int?;
        _valid = row?['valid_minutes'] as int? ?? 30;
      });
    } catch (_) {
      if (mounted) setState(() => _message = 'Unable to load owner access. Check your connection and retry.');
    }
  }

  Future<void> _signIn() async {
    setState(() { _busy = true; _message = null; });
    try {
      await WaitService.client!.signIn(_email.text.trim(), _password.text).timeout(const Duration(seconds: 15));
      _password.clear();
    } catch (_) {
      if (mounted) setState(() => _message = 'Sign-in failed. Check your email, password, and connection.');
    } finally { if (mounted) setState(() => _busy = false); }
  }

  Future<void> _save() async {
    final status = _status;
    if (status == null || _version == null || (status != 'closed' && (_min == null || _max == null))) {
      setState(() => _message = 'Choose a status and estimated wait first.');
      return;
    }
    setState(() { _busy = true; _message = null; });
    try {
      final row = await WaitService.client!.save({
        'status': status, 'wait_min': status == 'closed' ? null : _min,
        'wait_max': status == 'closed' ? null : _max, 'valid_minutes': _valid,
      }, _version!).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      if (row == null) {
        await _loadOwner();
        if (mounted) setState(() => _message = 'The status changed or your access changed. Review the latest values before updating.');
      } else {
        setState(() { _version = row['version'] as int; _message = 'Saved. Customers can now see this update.'; });
      }
    } catch (_) {
      if (mounted) setState(() { _version = null; _message = 'Update could not be confirmed. Reload before trying again.'; });
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  void dispose() { _auth?.cancel(); _email.dispose(); _password.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final client = WaitService.client;
    final signedIn = client?.signedIn ?? false;
    return Scaffold(
      appBar: AppBar(title: const AppText('Owner controls')),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600), child: ListView(padding: const EdgeInsets.all(20), children: [
        const WaitCard(),
        if (client == null) const AppText('Owner access is not connected yet.'),
        if (client != null && !signedIn) ...[
          const AppText('Sign in with your own owner account.'),
          AutofillGroup(child: Column(children: [
            TextField(controller: _email, keyboardType: TextInputType.emailAddress, autofillHints: const [AutofillHints.username], decoration: InputDecoration(labelText: tr(context, 'Email'))),
            TextField(controller: _password, obscureText: true, autofillHints: const [AutofillHints.password], decoration: InputDecoration(labelText: tr(context, 'Password')), onSubmitted: (_) { if (!_busy) _signIn(); }),
          ])),
          const SizedBox(height: 16),
          FilledButton(onPressed: _busy ? null : _signIn, child: const AppText('Sign in')),
        ],
        if (_owner && signedIn) ...[
          const SizedBox(height: 16),
          const AppText('Choose current status'),
          Wrap(spacing: 8, runSpacing: 8, children: ['available','moderate','busy','closed'].map((status) => ChoiceChip(
            label: AppText(waitLabels[status]!), avatar: Icon(Icons.circle, size: 16, color: waitColors[status] ?? Colors.grey),
            selected: _status == status, onSelected: _busy ? null : (_) => setState(() => _status = status),
          )).toList()),
          if (_status != 'closed') ...[
            const SizedBox(height: 16),
            const AppText('Estimated time until service starts'),
            Wrap(spacing: 8, runSpacing: 8, children: _presets.map((range) => ChoiceChip(
              label: Text('${range.$1}–${range.$2} ${tr(context, 'minutes')}'), selected: _min == range.$1 && _max == range.$2,
              onSelected: _busy ? null : (_) => setState(() { _min = range.$1; _max = range.$2; }),
            )).toList()),
          ],
          const SizedBox(height: 16),
          const AppText('Hide this estimate unless refreshed within:'),
          Wrap(spacing: 8, children: [15,30,60].map((minutes) => ChoiceChip(label: Text('$minutes ${tr(context, 'minutes')}'), selected: _valid == minutes, onSelected: _busy ? null : (_) => setState(() => _valid = minutes))).toList()),
          const SizedBox(height: 16),
          FilledButton(onPressed: _busy || _version == null ? null : _save, child: AppText(_busy ? 'Saving…' : 'Update wait')),
        ],
        if (signedIn) ...[
          TextButton(onPressed: _busy ? null : _loadOwner, child: const AppText('Reload latest status')),
          TextButton(onPressed: _busy ? null : () async {
            try { await client!.signOut(); }
            catch (_) { if (mounted) setState(() => _message = 'Sign-out failed. Please retry.'); }
          }, child: const AppText('Sign out')),
        ],
        if (_message != null) Semantics(liveRegion: true, child: Padding(padding: const EdgeInsets.all(12), child: AppText(_message!))),
      ]))),
    );
  }
}
