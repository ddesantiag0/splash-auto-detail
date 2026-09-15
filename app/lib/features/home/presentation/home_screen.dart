import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.onStartBooking, super.key});

  final VoidCallback onStartBooking;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _StatusPill(),
              const SizedBox(height: 20),
              Text(
                'Professional care for your vehicle.',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Start an appointment request, tell us about your vehicle, '
                'and let Splash Auto Detail confirm the right service.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onStartBooking,
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('Request an appointment'),
              ),
              const SizedBox(height: 32),
              const Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _InfoCard(
                    icon: Icons.schedule_rounded,
                    title: 'Business hours',
                    body: 'Mon–Fri 8:15 AM–5 PM\nSat 8:15 AM–2 PM',
                  ),
                  _InfoCard(
                    icon: Icons.location_on_outlined,
                    title: 'Chula Vista',
                    body: '851 Showroom Pl\nChula Vista, CA 91914',
                  ),
                  _InfoCard(
                    icon: Icons.phone_outlined,
                    title: 'Questions?',
                    body: '(619) 993-8536\nCall during business hours',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x2222C55E),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x5522C55E)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, color: AppColors.success, size: 18),
          SizedBox(width: 8),
          Text(
            'Family-operated in Chula Vista',
            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.accent),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(body),
            ],
          ),
        ),
      ),
    );
  }
}
