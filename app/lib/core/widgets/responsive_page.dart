import 'package:flutter/material.dart';

/// Shared page layout that keeps content readable across phone, tablet, and
/// desktop widths.
class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    required this.child,
    this.maxWidth = 920,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 600 ? 20.0 : 32.0;

        return ListView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            24,
            horizontalPadding,
            32,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A screen title announced as a heading by assistive technologies.
class PageHeading extends StatelessWidget {
  const PageHeading(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.headlineLarge),
    );
  }
}

/// Consistent grouping for forms and other related page content.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.title,
    required this.child,
    super.key,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
