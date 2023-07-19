import 'package:isar/isar.dart';
import 'package:todoapp/user.dart';

part 'tasks.g.dart';

@Collection()
class Tasks {
  Id id = Isar.autoIncrement;
  late String title;
  late bool isCompleted = false;
  late DateTime createdAt;

  @Backlink(to: "tasks")
  final user = IsarLink<User>();
}
