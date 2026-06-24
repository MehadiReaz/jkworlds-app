import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jkworlds/data/services/app_data_service.dart';

class TermsConditionsView extends StatelessWidget {
  const TermsConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = Get.find<AppDataService>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('terms_of_service'.tr),
        centerTitle: true,
      ),
      body: Obx(() {
        final page = appData.pages.firstWhereOrNull((p) => p.key == 'terms');
        if (page == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildDocumentLayout(
          context: context,
          title: page.title,
          content: page.content,
          cs: cs,
          theme: theme,
        );
      }),
    );
  }

  Widget _buildDocumentLayout({
    required BuildContext context,
    required String title,
    required String content,
    required ColorScheme cs,
    required ThemeData theme,
  }) {
    // Parse content into blocks
    final blocks = content.split('\n\n');

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header icon & description
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.gavel_rounded, color: cs.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last updated: June 2026',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32, thickness: 1.2),

            // Document body
            ...blocks.map((block) {
              final cleanBlock = block.trim();
              if (cleanBlock.isEmpty) return const SizedBox();

              // Check if block starts with a number (e.g. "1. Acceptance of Terms")
              final RegExp headerRegex = RegExp(r'^\d+\.\s+');
              if (headerRegex.hasMatch(cleanBlock)) {
                // Split title and the rest of the block if there is a newline in it
                final lines = cleanBlock.split('\n');
                final sectionTitle = lines[0];
                final sectionBody = lines.skip(1).join('\n').trim();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sectionTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cs.primary,
                        ),
                      ),
                      if (sectionBody.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          sectionBody,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.55,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              // Normal paragraph
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  cleanBlock,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
              );
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
