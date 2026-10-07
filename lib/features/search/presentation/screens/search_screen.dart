import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery/app/theme/app_spacing.dart';
import 'package:gallery/app/theme/app_theme.dart';
import 'package:gallery/core/responsive/responsive.dart';
import 'package:gallery/core/widgets/adaptive/adaptive_button.dart';
import 'package:gallery/core/widgets/adaptive/adaptive_progress_indicator.dart';
import 'package:gallery/features/gallery/presentation/cubit/gallery_cubit.dart';
import 'package:gallery/features/gallery/presentation/screens/photo_viewer_screen.dart';
import 'package:gallery/features/gallery/presentation/widgets/photo_thumbnail_tile.dart';
import 'package:go_router/go_router.dart';

import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/suggested_prompts_view.dart';

/// Platform-adaptive AI natural-language search screen.
/// Implements suggested prompts, recent search history, responsive results grid,
/// and seamless navigation into PhotoViewerScreen (Rule 5.3).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

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
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;
    _focusNode.unfocus();
    context.read<SearchCubit>().search(query);
  }

  void _onSelectPrompt(String prompt) {
    _searchController.text = prompt;
    _focusNode.unfocus();
    context.read<SearchCubit>().search(prompt);
  }

  void _onClear() {
    _searchController.clear();
    context.read<SearchCubit>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return Scaffold(
      backgroundColor: colors.surfacePrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Top platform-adaptive search header
            _buildSearchHeader(context, isIOS),

            // Content body driven by SearchCubit
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return _buildLoadingView(context, state.query);
                  }

                  if (state is SearchError) {
                    return _buildErrorView(context, state);
                  }

                  if (state is SearchEmpty) {
                    return _buildEmptyView(context, state);
                  }

                  if (state is SearchSuccess) {
                    return _buildResultsView(context, state);
                  }

                  if (state is SearchInitial) {
                    return _buildInitialView(context, state);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context, bool isIOS) {
    final colors = context.colors;

    if (isIOS) {
      return Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.surfacePrimary,
          border: Border(bottom: BorderSide(color: colors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: CupertinoSearchTextField(
                controller: _searchController,
                focusNode: _focusNode,
                placeholder: "Search photos with AI (e.g. 'dogs')...",
                style: TextStyle(color: colors.textPrimary, fontSize: 15),
                placeholderStyle: TextStyle(
                  color: colors.textMuted,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  CupertinoIcons.sparkles,
                  color: colors.accent,
                  size: 18,
                ),
                onSubmitted: _onSearchSubmitted,
                onSuffixTap: _onClear,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Semantics(
              button: true,
              label: 'Cancel search',
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(40, 36),
                onPressed: () => context.pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: colors.accent, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xs,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.surfacePrimary,
          border: Border(bottom: BorderSide(color: colors.border)),
        ),
        child: Row(
          children: [
            Semantics(
              button: true,
              label: 'Back',
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                tooltip: 'Back',
                onPressed: () => context.pop(),
              ),
            ),
            Expanded(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  borderRadius: AppSpacing.borderRadiusFull,
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: colors.accent, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Semantics(
                        textField: true,
                        label: 'Search photos with natural language',
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: "Search photos with AI (e.g. 'dogs')...",
                            hintStyle: TextStyle(
                              color: colors.textMuted,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: _onSearchSubmitted,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _searchController,
                      builder: (context, value, _) {
                        if (value.text.isEmpty) return const SizedBox.shrink();
                        return Semantics(
                          button: true,
                          label: 'Clear search query',
                          child: GestureDetector(
                            onTap: _onClear,
                            child: Icon(
                              Icons.close_rounded,
                              color: colors.textSecondary,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildInitialView(BuildContext context, SearchInitial state) {
    final colors = context.colors;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Suggested prompts
        SuggestedPromptsView(
          prompts: state.suggestedPrompts,
          onPromptSelected: _onSelectPrompt,
        ),

        const SizedBox(height: AppSpacing.xl),

        // Recent search history
        if (state.recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isIOS ? CupertinoIcons.clock : Icons.history_rounded,
                    size: 16,
                    color: colors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.read<SearchCubit>().clearRecentSearches(),
                child: Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...state.recentSearches.map((query) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isIOS ? CupertinoIcons.search : Icons.search_rounded,
                size: 18,
                color: colors.textMuted,
              ),
              title: Text(
                query,
                style: TextStyle(color: colors.textPrimary, fontSize: 14),
              ),
              trailing: Icon(
                isIOS ? CupertinoIcons.arrow_up_left : Icons.north_west,
                size: 16,
                color: colors.textMuted,
              ),
              onTap: () => _onSelectPrompt(query),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildLoadingView(BuildContext context, String query) {
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AdaptiveProgressIndicator(size: AppSpacing.xxxl),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Searching photos for "$query"...',
            style: TextStyle(
              fontSize: 15,
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(BuildContext context, SearchSuccess state) {
    final colors = context.colors;
    final columns = Responsive.galleryColumns(context);
    final gutter = Responsive.horizontalGutter(context);
    final photoRepo = context.read<GalleryCubit>().photoRepository;

    return CustomScrollView(
      slivers: [
        // Results count header
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              gutter,
              AppSpacing.md,
              gutter,
              AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Found ${state.results.length} photos for "${state.query}"',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: _onClear,
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Responsive grid
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: gutter,
            vertical: AppSpacing.sm,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: AppSpacing.xs,
              crossAxisSpacing: AppSpacing.xs,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final photo = state.results[index];
              return PhotoThumbnailTile(
                photo: photo,
                photoRepository: photoRepo,
                onTap: () {
                  context.push(
                    '/photo-viewer',
                    extra: PhotoViewerArgs(
                      photos: state.results,
                      initialIndex: index,
                    ),
                  );
                },
              );
            }, childCount: state.results.length),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyView(BuildContext context, SearchEmpty state) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          Icon(
            Icons.search_off_rounded,
            size: AppSpacing.xxxl * 1.5,
            color: colors.textMuted,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No Photos Found',
            style: textTheme.headlineMedium?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We couldn\'t find any photos matching "${state.query}". Try a different natural-language prompt.',
            style: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          if (state.suggestedPrompts.isNotEmpty)
            SuggestedPromptsView(
              title: 'Try One of These Suggestions',
              prompts: state.suggestedPrompts,
              onPromptSelected: _onSelectPrompt,
            ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, SearchError state) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: AppSpacing.xxxl * 1.5,
              color: colors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Search Failed',
              style: textTheme.headlineMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.message,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AdaptiveButton(
              text: 'Try Again',
              onPressed: () => context.read<SearchCubit>().search(state.query),
            ),
          ],
        ),
      ),
    );
  }
}
