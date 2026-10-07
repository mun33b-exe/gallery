import 'package:shared_preferences/shared_preferences.dart';

/// Centralized service managing non-sensitive application preferences
/// backed by [SharedPreferences].
class PreferencesService {
  final SharedPreferences _prefs;

  static const String keyThemeId = 'selected_theme_id';
  static const String keyRecentSearches = 'recent_ai_searches';

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

  /// Retrieves stored recent search queries, maintaining recency order.
  List<String> getRecentSearches() {
    return _prefs.getStringList(keyRecentSearches) ?? [];
  }

  /// Saves a search query to the recent searches list with deduplication and LRU ordering.
  Future<bool> saveRecentSearch(String query, {int maxItems = 10}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return false;

    final current = List<String>.from(getRecentSearches());
    current.remove(trimmed);
    current.insert(0, trimmed);

    if (current.length > maxItems) {
      current.removeRange(maxItems, current.length);
    }

    return _prefs.setStringList(keyRecentSearches, current);
  }

  /// Clears all stored recent searches.
  Future<bool> clearRecentSearches() async {
    return _prefs.remove(keyRecentSearches);
  }
}
