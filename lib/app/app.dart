import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_shell.dart';
import 'theme/theme_cubit.dart';
import 'theme/theme_state.dart';

/// Root Application Widget.
/// Manages global theme state through [ThemeCubit].
class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          final themeDef = state.selectedTheme;
          return MaterialApp(
            title: 'AI Gallery',
            debugShowCheckedModeBanner: false,
            theme: themeDef.themeData,
            themeMode: themeDef.brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
