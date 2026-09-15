import 'package:flutter/material.dart';

import '../../../core/localization/app_text.dart';

import '../../../core/widgets/responsive_page.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsivePage(
      maxWidth: 760,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeading('Your garage'),
          const SizedBox(height: 8),
          AppText(
            'Customer sign-in, saved vehicles, appointment history, and '
            'service reminders will live here after authentication is connected.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          const Card(
            child: ListTile(
              leading: Icon(Icons.garage_outlined),
              title: AppText('No saved vehicles yet'),
              subtitle: AppText(
                'Vehicle profiles are part of the customer-account phase.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
