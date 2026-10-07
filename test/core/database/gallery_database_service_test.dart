import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/core/database/gallery_database_service.dart';

void main() {
  group('GalleryDatabaseService & Schema Tests', () {
    late GalleryDatabaseService dbService;

    setUp(() {
      dbService = GalleryDatabaseService.inMemory();
    });

    tearDown(() {
      dbService.close();
    });

    test('initializes schema and creates all core tables', () {
      final db = dbService.db;

      final tables = db.select(
        "SELECT name FROM sqlite_master WHERE type IN ('table', 'view') ORDER BY name;",
      );

      final tableNames = tables.map((row) => row['name'] as String).toSet();

      expect(tableNames, contains('photos'));
      expect(tableNames, contains('documents'));
      expect(tableNames, contains('documents_fts'));
      expect(tableNames, contains('cloud_queue'));
    });

    test('inserts and retrieves photo record with vector embedding', () {
      final db = dbService.db;
      final dummyEmbedding = Uint8List(512 * 4); // 512 float32 bytes

      db.execute(
        '''
        INSERT INTO photos (
          media_id, file_path, capture_date, latitude, longitude, city,
          classification, confidence, embedding, indexed_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        ''',
        [
          'photo_001',
          '/storage/emulated/0/DCIM/IMG_001.jpg',
          '2026-10-07T08:00:00Z',
          37.7749,
          -122.4194,
          'San Francisco',
          'Photo',
          0.98,
          dummyEmbedding,
          '2026-10-07T08:05:00Z',
        ],
      );

      final result = db.select(
        'SELECT media_id, classification, confidence FROM photos WHERE media_id = ?;',
        ['photo_001'],
      );

      expect(result.length, equals(1));
      expect(result.first['media_id'], equals('photo_001'));
      expect(result.first['classification'], equals('Photo'));
      expect(result.first['confidence'], equals(0.98));
    });

    test(
      'documents table enforces foreign key and cascading delete from photos',
      () {
        final db = dbService.db;

        // 1. Insert parent photo
        db.execute(
          '''
        INSERT INTO photos (
          media_id, file_path, capture_date, classification, confidence, embedding, indexed_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?);
        ''',
          [
            'doc_photo_001',
            '/storage/emulated/0/DCIM/receipt.jpg',
            '2026-10-07T09:00:00Z',
            'Document',
            0.99,
            Uint8List(512 * 4),
            '2026-10-07T09:01:00Z',
          ],
        );

        // 2. Insert document referencing photo
        db.execute(
          '''
        INSERT INTO documents (
          media_id, doc_type, raw_text, vendor, doc_date, currency,
          subtotal, tax, total, extraction_status, full_json, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        ''',
          [
            'doc_photo_001',
            'Financial',
            'Home Depot Total \$45.99 Tax \$3.80 Subtotal \$42.19',
            'Home Depot',
            '2026-10-07',
            'USD',
            42.19,
            3.80,
            45.99,
            'PASSED_OFFLINE',
            '{"vendor":"Home Depot","total":45.99}',
            '2026-10-07T09:02:00Z',
          ],
        );

        final docResult = db.select(
          'SELECT vendor, total FROM documents WHERE media_id = ?;',
          ['doc_photo_001'],
        );
        expect(docResult.length, equals(1));
        expect(docResult.first['vendor'], equals('Home Depot'));

        // 3. Delete parent photo -> Cascade deletes document
        db.execute('DELETE FROM photos WHERE media_id = ?;', ['doc_photo_001']);
        final afterDelete = db.select(
          'SELECT * FROM documents WHERE media_id = ?;',
          ['doc_photo_001'],
        );
        expect(afterDelete, isEmpty);
      },
    );

    test(
      'documents_fts triggers synchronize inserts, updates, and deletes',
      () {
        final db = dbService.db;

        // Insert parent photo
        db.execute(
          '''
        INSERT INTO photos (
          media_id, file_path, classification, confidence, embedding, indexed_at
        ) VALUES (?, ?, ?, ?, ?, ?);
        ''',
          [
            'fts_test_001',
            '/storage/receipt.jpg',
            'Document',
            0.95,
            Uint8List(512 * 4),
            '2026-10-07T10:00:00Z',
          ],
        );

        // Insert document
        db.execute(
          '''
        INSERT INTO documents (
          media_id, doc_type, raw_text, vendor, doc_date, currency,
          subtotal, tax, total, extraction_status, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        ''',
          [
            'fts_test_001',
            'Informational',
            'Certificate of Achievement in Flutter Artificial Intelligence',
            'Google Cloud',
            '2026-10-07',
            'USD',
            0.0,
            0.0,
            0.0,
            'INFORMATIONAL',
            '2026-10-07T10:01:00Z',
          ],
        );

        // Query FTS5 table
        final ftsMatch = db.select(
          "SELECT * FROM documents_fts WHERE documents_fts MATCH 'Artificial';",
        );
        expect(ftsMatch.length, equals(1));
        expect(ftsMatch.first['vendor'], equals('Google Cloud'));

        // Update document vendor
        db.execute(
          "UPDATE documents SET vendor = 'DeepMind' WHERE media_id = 'fts_test_001';",
        );
        final ftsAfterUpdate = db.select(
          "SELECT * FROM documents_fts WHERE documents_fts MATCH 'DeepMind';",
        );
        expect(ftsAfterUpdate.length, equals(1));

        // Delete document
        db.execute("DELETE FROM documents WHERE media_id = 'fts_test_001';");
        final ftsAfterDelete = db.select(
          "SELECT * FROM documents_fts WHERE documents_fts MATCH 'Artificial';",
        );
        expect(ftsAfterDelete, isEmpty);
      },
    );

    test('cloud_queue records failed items with status indexing', () {
      final db = dbService.db;

      db.execute(
        '''
        INSERT INTO cloud_queue (media_id, created_at, retry_count, last_error, status)
        VALUES (?, ?, ?, ?, ?);
        ''',
        [
          'queue_photo_001',
          '2026-10-07T10:05:00Z',
          0,
          'Math sanity check failed: |Subtotal + Tax - Total| > 0.05',
          'QUEUED',
        ],
      );

      final pending = db.select(
        "SELECT media_id, status FROM cloud_queue WHERE status = 'QUEUED';",
      );
      expect(pending.length, equals(1));
      expect(pending.first['media_id'], equals('queue_photo_001'));
    });
  });
}
