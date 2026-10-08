import 'package:flutter/material.dart';
import 'package:gallery/app/theme/app_spacing.dart';
import 'package:gallery/core/widgets/app_svg_icon.dart';

class ExampleQueryTemplate {
  final String prefix;
  final String highlight;
  final String suffix;
  final String fullQuery;
  final String icon;

  const ExampleQueryTemplate({
    required this.prefix,
    required this.highlight,
    this.suffix = '',
    required this.fullQuery,
    required this.icon,
  });
}

/// Demonstrates advanced multi-modal conversational capabilities of the AI Gallery Assistant.
class ExampleQueriesView extends StatelessWidget {
  final ValueChanged<String> onQueryTap;

  const ExampleQueriesView({super.key, required this.onQueryTap});

  static const List<ExampleQueryTemplate> kExamples = [
    ExampleQueryTemplate(
      prefix: 'Show me all the pictures of ',
      highlight: 'hilly areas',
      suffix: '',
      fullQuery: 'Show me all the pictures of hilly areas',
      icon: AppIcons.image,
    ),
    ExampleQueryTemplate(
      prefix: 'What is the last date to pay the ',
      highlight: 'internet bill',
      suffix: '?',
      fullQuery: 'What is the last date to pay the internet bill?',
      icon: AppIcons.fileText,
    ),
    ExampleQueryTemplate(
      prefix: 'How much did I spend on ',
      highlight: 'subscription last month',
      suffix: '?',
      fullQuery: 'How much did I spend on subscription last month?',
      icon: AppIcons.slidersHorizontal,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: const [
            AppSvgIcon(
              AppIcons.messageCircle,
              color: Color(0xFF6B7280),
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              'Example Queries',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        // Example Cards
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: kExamples.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final example = kExamples[index];
            return Semantics(
              button: true,
              label: example.fullQuery,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  onTap: () => onQueryTap(example.fullQuery),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFF3F4F6),
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF4E5),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: AppSvgIcon(
                              example.icon,
                              color: const Color(0xFFFF7A00),
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14.5,
                                color: Color(0xFF1F2937),
                                height: 1.3,
                              ),
                              children: [
                                TextSpan(text: example.prefix),
                                TextSpan(
                                  text: example.highlight,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFF7A00),
                                  ),
                                ),
                                TextSpan(text: example.suffix),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const AppSvgIcon(
                          AppIcons.chevronRight,
                          color: Color(0xFF9CA3AF),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
