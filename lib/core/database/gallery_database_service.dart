import 'package:gallery_ai_engine/gallery_ai_engine.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// Service managing the local SQLite database lifecycle, schema migrations,
/// and connection pooling for on-device AI search and document extraction.
class GalleryDatabaseService {
  final Database _db;

  GalleryDatabaseService(Database db) : _db = db;

  /// Exposes the underlying [Database] instance for queries and transactions.
  Database get db => _db;

  /// Factory constructor for unit tests, isolated CI runners, and in-memory execution.
  factory GalleryDatabaseService.inMemory() {
    final db = sqlite3.openInMemory();
    final service = GalleryDatabaseService(db);
    service.initializeSchema();
    return service;
  }

  /// Production factory initializing persistent on-device SQLite database storage.
  static Future<GalleryDatabaseService> openOnDevice({
    String fileName = 'gallery_ai.db',
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDir.path, fileName);
    final db = sqlite3.open(dbPath);
    final service = GalleryDatabaseService(db);
    service.initializeSchema();
    return service;
  }

  /// Executes DDL schema statements, enabling foreign keys and creating tables.
  void initializeSchema() {
    _db.execute('PRAGMA foreign_keys = ON;');
    _db.execute(GalleryDatabaseSchema.createTablesSql);
  }

  /// Closes and disposes the database connection.
  void close() {
    _db.dispose();
  }
}
