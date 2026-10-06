import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/data/mock_auth_repository.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/gallery/data/device_photo_repository.dart';
import '../features/gallery/domain/photo_repository.dart';
import '../features/gallery/presentation/cubit/gallery_cubit.dart';
import '../features/search/data/mock_ai_photo_search_repository.dart';
import '../features/search/domain/ai_photo_search_repository.dart';
import '../features/search/presentation/cubit/search_cubit.dart';
import 'router/app_router.dart';
import 'theme/theme_cubit.dart';
import 'theme/theme_state.dart';

/// Root Application Widget.
/// Manages global theme state, authentication state, and photo access with GoRouter.
class GalleryApp extends StatefulWidget {
  final AuthRepository? authRepository;
  final PhotoRepository? photoRepository;
  final AiPhotoSearchRepository? searchRepository;

  const GalleryApp({
    super.key,
    this.authRepository,
    this.photoRepository,
    this.searchRepository,
  });

  @override
  State<GalleryApp> createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  late final AuthRepository _authRepository;
  late final PhotoRepository _photoRepository;
  late final AiPhotoSearchRepository _searchRepository;
  late final AuthCubit _authCubit;
  late final GalleryCubit _galleryCubit;
  late final SearchCubit _searchCubit;
  late final ThemeCubit _themeCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authRepository = widget.authRepository ?? MockAuthRepository();
    _photoRepository = widget.photoRepository ?? DevicePhotoRepository();
    _searchRepository =
        widget.searchRepository ?? MockAiPhotoSearchRepository();
    _authCubit = AuthCubit(authRepository: _authRepository);
    _galleryCubit = GalleryCubit(photoRepository: _photoRepository);
    _searchCubit = SearchCubit(searchRepository: _searchRepository);
    _themeCubit = ThemeCubit();
    _router = AppRouter.createRouter(_authCubit);
  }

  @override
  void dispose() {
    _authCubit.close();
    _galleryCubit.close();
    _searchCubit.close();
    _themeCubit.close();
    if (widget.authRepository == null &&
        _authRepository is MockAuthRepository) {
      _authRepository.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>.value(value: _themeCubit),
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<GalleryCubit>.value(value: _galleryCubit),
        BlocProvider<SearchCubit>.value(value: _searchCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final themeDef = themeState.selectedTheme;
          return MaterialApp.router(
            title: 'AI Gallery',
            debugShowCheckedModeBanner: false,
            theme: themeDef.themeData,
            themeMode: themeDef.brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
