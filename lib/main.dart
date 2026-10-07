import 'package:flutter/material.dart';
import 'package:gallery_ai_engine/gallery_ai_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/ai/onnx_model_service.dart';
import 'core/database/gallery_database_service.dart';
import 'core/services/preferences_service.dart';
import 'features/auth/data/supabase_auth_repository.dart';
import 'features/gallery/data/device_photo_repository.dart';
import 'features/search/data/on_device_ai_photo_search_repository.dart';

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

  // Initialize local SQLite database
  final databaseService = await GalleryDatabaseService.openOnDevice();

  // Initialize on-device ONNX runtime
  final onnxService = OnnxModelService();
  await onnxService.initialize();

  final textEngine = TextEngine(
    runner: (modelName, tokens, shape) =>
        onnxService.runTextModel(modelName, tokens, shape),
  );

  final photoRepository = DevicePhotoRepository();
  final searchRepository = OnDeviceAiPhotoSearchRepository(
    databaseService: databaseService,
    textEngine: textEngine,
    preferencesService: preferencesService,
    photoRepository: photoRepository,
  );

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
