import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:video_compress/video_compress.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    var databasesPath = await getDatabasesPath();
    String dbPath = path.join(databasesPath, 'videos.db');
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE recorded_videos(id INTEGER PRIMARY KEY, path TEXT, thumbnail_path TEXT)');
        await db.execute(
            'CREATE TABLE merged_videos(id INTEGER PRIMARY KEY, path TEXT, thumbnail_path TEXT)');
      },
    );
  }

  Future<String> generateThumbnail(String videoPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final thumbnailPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_thumb.jpg';
    final thumbnailFile = await VideoCompress.getFileThumbnail(
      videoPath,
      quality: 50,
      position: -1,
    );
    await thumbnailFile.copy(thumbnailPath);
    return thumbnailPath;
  }

  Future<void> insertRecordedVideo(String videoPath) async {
    final thumbnailPath = await generateThumbnail(videoPath);
    final db = await database;
    await db.insert('recorded_videos', {'path': videoPath, 'thumbnail_path': thumbnailPath});
  }

  Future<void> insertMergedVideo(String videoPath) async {
    final thumbnailPath = await generateThumbnail(videoPath);
    final db = await database;
    await db.insert('merged_videos', {'path': videoPath, 'thumbnail_path': thumbnailPath});
  }

  Future<List<Map>> getRecordedVideos() async {
    final db = await database;
    return await db.query('recorded_videos');
  }

  Future<List<Map>> getMergedVideos() async {
    final db = await database;
    return await db.query('merged_videos');
  }
}
