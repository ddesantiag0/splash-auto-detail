import 'package:flutter/material.dart';

import '../../../core/localization/app_text.dart';

import '../../../core/widgets/responsive_page.dart';
import '../domain/booking_draft.dart';
import '../domain/booking_validation.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({this.now, super.key});

  /// Optional clock for deterministic date-picker tests.
  final DateTime Function()? now;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  DetailService _service = DetailService.wax;
  DateTime? _preferredDate;

  @override
  void dispose() {
    _vehicleController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate(FormFieldState<DateTime> field) async {
    final today = DateUtils.dateOnly(widget.now?.call() ?? DateTime.now());
    final lastDate = DateTime(today.year, today.month, today.day + 180);
    var initialDate = _preferredDate;
    if (initialDate == null ||
        initialDate.isBefore(today) ||
        initialDate.isAfter(lastDate)) {
      initialDate = DateTime(today.year, today.month, today.day + 1);
    }
    // Keep the existing Sunday restriction without defaulting to a disabled day.
    if (initialDate.weekday == DateTime.sunday) {
      initialDate = DateTime(
        initialDate.year, initialDate.month, initialDate.day + 1,
      );
    }
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      currentDate: today,
      firstDate: today,
      lastDate: lastDate,
      selectableDayPredicate: (date) => date.weekday != DateTime.sunday,
    );
    if (!mounted || selected == null) return;

    setState(() => _preferredDate = selected);
    field.didChange(selected);
  }

  void _reviewRequest() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final draft = BookingDraft(
      service: _service,
      vehicle: _vehicleController.text,
      customerName: _nameController.text,
      phone: _phoneController.text,
      preferredDate: _preferredDate!,
      notes: _notesController.text,
    );

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const AppText('Review your request'),
        content: Text(
          '${tr(context, draft.service.label)}\n'
          '${draft.vehicle}\n'
          '${_formatDate(draft.preferredDate)}\n\n'
          '${tr(context, 'No request has been sent yet. Secure backend submission and '
              'business confirmation will be connected in the next phase.')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const AppText('Keep editing'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      MaterialLocalizations.of(context).formatMediumDate(date);

  @override
  Widget build(BuildContext context) {
    return ResponsivePage(
      maxWidth: 760,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeading('Request wax or polishing'),
            const SizedBox(height: 8),
            AppText(
              'Regular services are first come, first served. Use this '
              'form only for wax or polishing work. Splash Auto Detail '
              'will confirm the request before an appointment is set.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            SectionCard(
              title: '1. Choose a service',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: DetailService.values
                    .map(
                      (service) => ChoiceChip(
                        label: AppText(service.label),
                        selected: _service == service,
                        onSelected: (_) => setState(() => _service = service),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: '2. Tell us about the vehicle',
              child: TextFormField(
                controller: _vehicleController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: tr(context, 'Year, make, and model'),
                  hintText: tr(context, 'Example: 2022 Tesla Model 3'),
                ),
                validator: (value) => !BookingValidation.hasRequiredText(value)
                    ? tr(context, 'Enter the vehicle year, make, and model.')
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: '3. Pick a preferred date',
              child: FormField<DateTime>(
                initialValue: _preferredDate,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value == null
                    ? tr(context, 'Choose a preferred appointment date.')
                    : null,
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _chooseDate(field),
                      icon: const Icon(Icons.event_outlined),
                      label: AppText(
                        _preferredDate == null
                            ? 'Choose a date'
                            : _formatDate(_preferredDate!),
                      ),
                    ),
                    if (field.hasError) ...[
                      const SizedBox(height: 8),
                      Semantics(
                        liveRegion: true,
                        child: AppText(
                          field.errorText!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: '4. Contact information',
              child: AutofillGroup(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      decoration: InputDecoration(labelText: tr(context, 'Full name')),
                      validator: (value) =>
                          !BookingValidation.hasRequiredText(value)
                              ? tr(context, 'Enter your name.')
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      decoration:
                          InputDecoration(labelText: tr(context, 'Phone number')),
                      validator: (value) =>
                          !BookingValidation.hasValidPhone(value)
                              ? tr(context, 'Enter a valid 10-digit phone number.')
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: tr(context, 'Notes (optional)'),
                        hintText:
                            tr(context, 'Tell us about stains, paint condition, or concerns.'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _reviewRequest,
                icon: const Icon(Icons.fact_check_outlined),
                label: const AppText('Review request'),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Flexible(
                  child: AppText(
                    'Submission is intentionally disabled until the backend '
                    'is connected.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
