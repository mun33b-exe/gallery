import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery/app/theme/app_spacing.dart';
import 'package:gallery/core/responsive/responsive.dart';
import 'package:gallery/features/gallery/data/mock_photo_repository.dart';
import 'package:gallery/features/gallery/domain/photo_model.dart';
import 'package:gallery/features/gallery/domain/photo_repository.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/gallery/presentation/screens/photo_viewer_screen.dart';
import 'package:go_router/go_router.dart';

import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/ai_search_header.dart';
import '../widgets/conversation_message_view.dart';
import '../widgets/example_queries_view.dart';
import '../widgets/persistent_ai_input_bar.dart';
import '../widgets/recent_searches_chips.dart';
import '../widgets/suggested_searches_grid.dart';

/// Conversational "AI Gallery Search" screen matching design specification.
/// Features a spacious white-first layout, bold header, 2-column pastel suggested searches,
/// horizontal recent searches, highlighted example queries, continuous conversational feed,
/// rich photo/document/financial evidence cards, and a persistent bottom AI input bar.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchCubit>().loadInitial();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;
    _focusNode.unfocus();
    _searchController.text = query;
    context.read<SearchCubit>().search(query);
    _scrollToBottom();
  }

  void _openPhotoViewer(List<PhotoModel> photos, int initialIndex) {
    context.push(
      '/photo-viewer',
      extra: PhotoViewerArgs(photos: photos, initialIndex: initialIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gutter = Responsive.horizontalGutter(context);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            // Top Section & Conversation / Search Feed
            Expanded(
              child: BlocConsumer<SearchCubit, SearchState>(
                listener: (context, state) {
                  if (state.messages.isNotEmpty) {
                    _scrollToBottom();
                  }
                },
                builder: (context, state) {
                  PhotoRepository photoRepo;
                  try {
                    photoRepo = context.read<GalleryCubit>().photoRepository;
                  } catch (_) {
                    photoRepo = MockPhotoRepository();
                  }
                  final hasMessages = state.messages.isNotEmpty;

                  return CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      // Header: Collapsible Sliver Header with Circular Back Button, Title & Subtitle, and Frosted Blur
                      AiSearchHeader(
                        onBackTap: () {
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                      ),

                      // If conversation has messages, render conversational feed
                      if (hasMessages) ...[
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: gutter),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final message = state.messages[index];
                              return ConversationMessageView(
                                message: message,
                                photoRepository: photoRepo,
                                onPhotoTap: (photo, idx) {
                                  _openPhotoViewer(message.photos, idx);
                                },
                                onSeeAllPhotos: () {
                                  if (message.photos.isNotEmpty) {
                                    _openPhotoViewer(message.photos, 0);
                                  }
                                },
                              );
                            }, childCount: state.messages.length),
                          ),
                        ),

                        // Loading typing indicator
                        if (state is SearchLoading)
                          SliverPadding(
                            padding: EdgeInsets.all(gutter),
                            sliver: const SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFFFF7A00),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Error state in conversation
                        if (state is SearchError)
                          SliverPadding(
                            padding: EdgeInsets.all(gutter),
                            sliver: SliverToBoxAdapter(
                              child: _buildErrorView(context, state),
                            ),
                          ),

                        // Empty search feedback
                        if (state is SearchEmpty)
                          SliverPadding(
                            padding: EdgeInsets.all(gutter),
                            sliver: SliverToBoxAdapter(
                              child: _buildEmptyNotice(context, state.query),
                            ),
                          ),
                      ] else ...[
                        // Initial Search Exploration Feed (Suggested Searches, Recents, Example Queries)
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: gutter),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // Suggested Searches 2-Column Grid
                              SuggestedSearchesGrid(
                                onSearchTap: _onSearchSubmitted,
                              ),

                              const SizedBox(height: AppSpacing.xl),

                              // Recent Searches Chips
                              if (state is SearchInitial &&
                                  state.recentSearches.isNotEmpty) ...[
                                RecentSearchesChips(
                                  recentSearches: state.recentSearches,
                                  onSelectRecent: _onSearchSubmitted,
                                  onClear: () {
                                    context
                                        .read<SearchCubit>()
                                        .clearRecentSearches();
                                  },
                                ),
                                const SizedBox(height: AppSpacing.xl),
                              ],

                              // Example Queries
                              ExampleQueriesView(
                                onQueryTap: _onSearchSubmitted,
                              ),

                              const SizedBox(height: AppSpacing.xl),
                            ]),
                          ),
                        ),
                      ],

                      // Bottom spacing padding so content is never obscured by the persistent input bar
                      const SliverToBoxAdapter(child: SizedBox(height: 84)),
                    ],
                  );
                },
              ),
            ),

            // Persistent Floating AI Input Capsule anchored at the bottom
            Padding(
              padding: EdgeInsets.fromLTRB(
                gutter,
                AppSpacing.xs,
                gutter,
                AppSpacing.sm,
              ),
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  return PersistentAiInputBar(
                    controller: _searchController,
                    focusNode: _focusNode,
                    isLoading: state is SearchLoading,
                    onSubmitted: _onSearchSubmitted,
                    onMicTap: () {
                      _onSearchSubmitted(
                        'Show me all the pictures of hilly areas',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNotice(BuildContext context, String query) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: const [
          Text(
            'No Photos Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try One of These Suggestions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, SearchError state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Column(
        children: [
          const Text(
            'Search Failed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFFBE123C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            state.message,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () {
              context.read<SearchCubit>().search(state.query);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A00),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
