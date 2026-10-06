import 'package:shared_preferences/shared_preferences.dart';

/// Centralized service managing non-sensitive application preferences
/// backed by [SharedPreferences].
class PreferencesService {
  final SharedPreferences _prefs;

  static const String keyThemeId = 'selected_theme_id';

  PreferencesService(this._prefs);

  /// Retrieves the persisted theme identifier, or null if none is saved.
  String? getThemeId() {
    return _prefs.getString(keyThemeId);
  }

  /// Persists the selected theme identifier.
  Future<bool> setThemeId(String themeId) async {
    return _prefs.setString(keyThemeId, themeId);
  }

  /// Clears the persisted theme identifier.
  Future<bool> clearThemeId() async {
    return _prefs.remove(keyThemeId);
  }
}
