/// Definitive SQLite Schema DDL and SQL query templates for Edge-First AI Gallery.
class GalleryDatabaseSchema {
  static const int schemaVersion = 1;

  /// Creates all core tables: photos, documents, cloud_queue, and documents_fts.
  static const String createTablesSql = '''
    -- 1. Photos and Media Table
    CREATE TABLE IF NOT EXISTS photos (
      media_id TEXT PRIMARY KEY,
      file_path TEXT NOT NULL,
      capture_date TEXT,
      latitude REAL,
      longitude REAL,
      city TEXT,
      classification TEXT NOT NULL,
      confidence REAL NOT NULL,
      embedding BLOB NOT NULL,
      indexed_at TEXT NOT NULL
    );

    CREATE INDEX IF NOT EXISTS idx_photos_capture_date ON photos(capture_date);
    CREATE INDEX IF NOT EXISTS idx_photos_classification ON photos(classification);
    CREATE INDEX IF NOT EXISTS idx_photos_city ON photos(city);

    -- 2. Documents & Financial Data Table
    CREATE TABLE IF NOT EXISTS documents (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      media_id TEXT NOT NULL UNIQUE REFERENCES photos(media_id) ON DELETE CASCADE,
      doc_type TEXT NOT NULL,
      raw_text TEXT NOT NULL,
      vendor TEXT,
      doc_date TEXT,
      currency TEXT DEFAULT 'USD',
      subtotal REAL,
      tax REAL,
      total REAL,
      extraction_status TEXT NOT NULL,
      full_json TEXT,
      user_edited INTEGER DEFAULT 0,
      updated_at TEXT NOT NULL
    );

    CREATE INDEX IF NOT EXISTS idx_documents_doc_type ON documents(doc_type);
    CREATE INDEX IF NOT EXISTS idx_documents_status ON documents(extraction_status);
    CREATE INDEX IF NOT EXISTS idx_documents_vendor ON documents(vendor);
    CREATE INDEX IF NOT EXISTS idx_documents_doc_date ON documents(doc_date);

    -- 3. SQLite FTS5 Full-Text Search for Informational Documents & OCR text
    CREATE VIRTUAL TABLE IF NOT EXISTS documents_fts USING fts5(
      media_id UNINDEXED,
      raw_text,
      vendor,
      content='documents',
      content_rowid='id'
    );

    -- FTS Triggers to keep search index synchronized
    CREATE TRIGGER IF NOT EXISTS trg_documents_ai AFTER INSERT ON documents BEGIN
      INSERT INTO documents_fts(rowid, media_id, raw_text, vendor)
      VALUES (new.id, new.media_id, new.raw_text, new.vendor);
    END;

    CREATE TRIGGER IF NOT EXISTS trg_documents_ad AFTER DELETE ON documents BEGIN
      INSERT INTO documents_fts(documents_fts, rowid, media_id, raw_text, vendor)
      VALUES('delete', old.id, old.media_id, old.raw_text, old.vendor);
    END;

    CREATE TRIGGER IF NOT EXISTS trg_documents_au AFTER UPDATE ON documents BEGIN
      INSERT INTO documents_fts(documents_fts, rowid, media_id, raw_text, vendor)
      VALUES('delete', old.id, old.media_id, old.raw_text, old.vendor);
      INSERT INTO documents_fts(rowid, media_id, raw_text, vendor)
      VALUES (new.id, new.media_id, new.raw_text, new.vendor);
    END;

    -- 4. Cloud Escalation Fallback Queue (Only for failed financial documents)
    CREATE TABLE IF NOT EXISTS cloud_queue (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      media_id TEXT NOT NULL UNIQUE,
      created_at TEXT NOT NULL,
      retry_count INTEGER DEFAULT 0,
      last_error TEXT,
      status TEXT DEFAULT 'QUEUED'
    );

    CREATE INDEX IF NOT EXISTS idx_cloud_queue_status ON cloud_queue(status);
  ''';

  // --- Analytical & Retrieval Query Templates ---

  /// Aggregates expenses by currency over a date range.
  static const String queryFinancialAnalytics = '''
    SELECT 
      currency, 
      SUM(total) AS sum_total, 
      COUNT(*) AS receipt_count,
      MIN(doc_date) AS min_date,
      MAX(doc_date) AS max_date
    FROM documents
    WHERE extraction_status IN ('PASSED_OFFLINE', 'CLOUD_RESOLVED')
      AND total IS NOT NULL
      AND (? IS NULL OR doc_date >= ?)
      AND (? IS NULL OR doc_date <= ?)
    GROUP BY currency;
  ''';

  /// Full-text search for informational documents (CNIC, bonafide, certificates).
  static const String queryFtsInformationalDocs = '''
    SELECT 
      d.media_id,
      p.file_path,
      d.doc_type,
      d.raw_text,
      d.vendor,
      snippet(documents_fts, 1, '<b>', '</b>', '...', 15) AS snippet
    FROM documents_fts f
    JOIN documents d ON d.id = f.rowid
    JOIN photos p ON p.media_id = d.media_id
    WHERE documents_fts MATCH ?
    ORDER BY rank
    LIMIT ?;
  ''';

  /// Retrieve all pending items from the cloud escalation queue.
  static const String queryPendingCloudQueue = '''
    SELECT q.id, q.media_id, p.file_path, q.retry_count
    FROM cloud_queue q
    JOIN photos p ON p.media_id = q.media_id
    WHERE q.status = 'QUEUED' AND q.retry_count < 3
    ORDER BY q.created_at ASC
    LIMIT ?;
  ''';
}
