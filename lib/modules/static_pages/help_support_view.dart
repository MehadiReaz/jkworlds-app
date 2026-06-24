import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jkworlds/data/services/app_data_service.dart';
import 'package:jkworlds/app/routes/app_routes.dart';

class HelpSupportView extends StatefulWidget {
  const HelpSupportView({super.key});

  @override
  State<HelpSupportView> createState() => _HelpSupportViewState();
}

class _HelpSupportViewState extends State<HelpSupportView> {
  final TextEditingController _searchCtrl = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final RxInt _expandedFaqIndex = (-1).obs; // Track expanded FAQ index

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appData = Get.find<AppDataService>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('help_support'.tr),
        centerTitle: true,
      ),
      body: Obx(() {
        final page = appData.pages.firstWhereOrNull((p) => p.key == 'help_center');
        final allFaqs = appData.faqs;

        if (page == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Parse Help Topics
        final helpTopics = _parseHelpTopics(page.content);

        // Filter FAQs and Help Topics based on search query
        final query = _searchQuery.value.trim().toLowerCase();
        final filteredFaqs = allFaqs.where((faq) {
          return faq.question.toLowerCase().contains(query) ||
              faq.answer.toLowerCase().contains(query);
        }).toList();

        final filteredTopics = helpTopics.where((topic) {
          return topic.title.toLowerCase().contains(query) ||
              topic.content.toLowerCase().contains(query);
        }).toList();

        return Column(
          children: [
            // Search Bar header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              color: theme.scaffoldBackgroundColor,
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => _searchQuery.value = val,
                decoration: InputDecoration(
                  hintText: 'Search questions, topics...',
                  prefixIcon: Icon(Icons.search_rounded, color: cs.primary),
                  suffixIcon: Obx(() => _searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchCtrl.clear();
                            _searchQuery.value = '';
                          },
                        )
                      : const SizedBox()),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: cs.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Help Center Topics (Guides)
                    if (filteredTopics.isNotEmpty) ...[
                      Text(
                        'Guide Topics',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTopics.length,
                        itemBuilder: (context, index) {
                          final topic = filteredTopics[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                            ),
                            child: ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              childrenPadding: EdgeInsets.zero,
                              iconColor: cs.primary,
                              collapsedIconColor: cs.onSurfaceVariant,
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: cs.primary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      topic.number,
                                      style: TextStyle(
                                        color: cs.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      topic.title,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Divider(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    topic.content,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // FAQ Accordion
                    if (filteredFaqs.isNotEmpty) ...[
                      Text(
                        'Frequently Asked Questions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredFaqs.length,
                        itemBuilder: (context, index) {
                          final faq = filteredFaqs[index];
                          return Obx(() {
                            final isExpanded = _expandedFaqIndex.value == index;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isExpanded ? cs.primary : cs.outlineVariant.withValues(alpha: 0.3),
                                  width: isExpanded ? 1.5 : 1.0,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () {
                                    _expandedFaqIndex.value = isExpanded ? -1 : index;
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                faq.question,
                                                style: theme.textTheme.titleSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isExpanded ? cs.primary : cs.onSurface,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              isExpanded
                                                  ? Icons.keyboard_arrow_up_rounded
                                                  : Icons.keyboard_arrow_down_rounded,
                                              color: isExpanded ? cs.primary : cs.onSurfaceVariant,
                                            ),
                                          ],
                                        ),
                                        if (isExpanded) ...[
                                          const SizedBox(height: 12),
                                          const Divider(),
                                          const SizedBox(height: 6),
                                          Text(
                                            faq.answer,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: cs.onSurfaceVariant,
                                              height: 1.5,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Empty State
                    if (filteredTopics.isEmpty && filteredFaqs.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.help_outline_rounded, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'No matching results found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Try rephrasing your search or browse options below.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Contact Support Banner
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.support_agent_rounded, size: 36, color: cs.primary),
                          const SizedBox(height: 12),
                          Text(
                            'Still need help?',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'If you cannot find answers to your questions, feel free to reach out to our dedicated support team.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => Get.toNamed(AppRoutes.contactUs),
                            icon: const Icon(Icons.mail_outline_rounded),
                            label: const Text('Contact Support'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  List<_HelpTopic> _parseHelpTopics(String content) {
    final List<_HelpTopic> topics = [];
    final blocks = content.split('\n\n');

    for (final block in blocks) {
      final cleanBlock = block.trim();
      if (cleanBlock.isEmpty) continue;

      // Match patterns like "1. Booking Assistance"
      final match = RegExp(r'^(\d+)\.\s+(.*)').firstMatch(cleanBlock);
      if (match != null) {
        final number = match.group(1) ?? '';
        final titleAndBody = match.group(2) ?? '';

        final lines = titleAndBody.split('\n');
        final title = lines[0].trim();
        final body = lines.skip(1).join('\n').trim();

        topics.add(_HelpTopic(
          number: number,
          title: title,
          content: body,
        ));
      }
    }
    return topics;
  }
}

class _HelpTopic {
  final String number;
  final String title;
  final String content;

  _HelpTopic({
    required this.number,
    required this.title,
    required this.content,
  });
}
