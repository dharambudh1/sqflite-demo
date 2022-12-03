import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_demo/model.dart';

class DetailsDatabase {
  static final DetailsDatabase instance = DetailsDatabase._init();

  static Database? _database;

  DetailsDatabase._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB('details.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INT NOT NULL';

    await db.execute('''
    CREATE TABLE $tableDetails (
    ${DetailsFields.id} $idType,
    ${DetailsFields.firstName} $textType,
    ${DetailsFields.lastName} $textType,
    ${DetailsFields.gender} $textType,
    ${DetailsFields.age} $intType
    )
    ''');
  }

  Future<Details> create(Details details) async {
    final db = await instance.database;
    final id = await db.insert(tableDetails, details.toJson());
    return details.copy(id: id);
  }

  Future<Details> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      tableDetails,
      columns: DetailsFields.values,
      where: '${DetailsFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Details.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Details>> readAllDetails() async {
    final db = await instance.database;
    final result = await db.query(tableDetails);
    return result.map((e) => Details.fromJson(e)).toList();
  }

  Future<int> update(Details details) async {
    final db = await instance.database;
    return db.update(
      tableDetails,
      details.toJson(),
      where: '${DetailsFields.id} = ?',
      whereArgs: [details.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableDetails,
      where: '${DetailsFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
