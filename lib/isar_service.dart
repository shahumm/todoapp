import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todoapp/tasks.dart';
import 'package:todoapp/user.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [TasksSchema, UserSchema],
      directory: dir.path,
      inspector: true,
    );
    return isar;
  }

  Future<void> saveTask(Tasks newTask) async {
    final isar = await db;
    isar.writeTxnSync<int>(() => isar.tasks.putSync(newTask));
  }
}
