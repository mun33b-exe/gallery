import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/services/preferences_service.dart';
import 'features/auth/data/supabase_auth_repository.dart';
import 'features/gallery/data/device_photo_repository.dart';
import 'features/search/data/mock_ai_photo_search_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase backend authentication
  await Supabase.initialize(
    url: 'https://izjmjwwvcnzurcjfrlfh.supabase.co',
    // ignore: deprecated_member_use
    anonKey: 'sb_publishable_16NW4ffBDwgUbv4x9ElR1g_FWq9Ljw7',
  );

  // Initialize local preferences persistence
  final sharedPrefs = await SharedPreferences.getInstance();
  final preferencesService = PreferencesService(sharedPrefs);

  final photoRepository = DevicePhotoRepository();
  final searchRepository = MockAiPhotoSearchRepository();

  runApp(
    GalleryApp(
      authRepository: SupabaseAuthRepository(
        supabaseClient: Supabase.instance.client,
      ),
      photoRepository: photoRepository,
      searchRepository: searchRepository,
      preferencesService: preferencesService,
    ),
  );
}
