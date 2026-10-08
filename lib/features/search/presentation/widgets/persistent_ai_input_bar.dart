import 'package:flutter/material.dart';
import 'package:gallery/core/widgets/app_svg_icon.dart';

/// Elevated persistent AI input capsule anchored above the safe area / keyboard.
/// Contains sparkles branding, natural-language query TextField, voice search trigger,
/// and circular AI orange submit button.
class PersistentAiInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onMicTap;
  final bool isLoading;

  const PersistentAiInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    this.onMicTap,
    this.isLoading = false,
  });

  void _handleSubmit() {
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      onSubmitted(text);
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          // Sparkles AI Identity
          const Padding(
            padding: EdgeInsets.only(left: 8, right: 6),
            child: AppSvgIcon(
              AppIcons.sparkles,
              color: Color(0xFFFF7A00),
              size: 22,
            ),
          ),

          // Query Input TextField
          Expanded(
            child: Semantics(
              label: 'Search photos with natural language',
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSubmit(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
                decoration: const InputDecoration(
                  hintText: "Search photos with AI (e.g. 'dogs', 'bills', 'Hassan')...",
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Microphone / Voice Trigger
          Semantics(
            button: true,
            label: 'Start voice search',
            child: InkWell(
              onTap: onMicTap,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: AppSvgIcon(
                  AppIcons.coffee, // Microphone fallback icon from assets
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Circular AI Orange Send Button
          Semantics(
            button: true,
            label: 'Send message',
            child: Material(
              color: const Color(0xFFFF7A00),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: isLoading ? null : _handleSubmit,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const AppSvgIcon(
                            AppIcons.arrowRight,
                            color: Colors.white,
                            size: 20,
                            quarterTurns: 3,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
