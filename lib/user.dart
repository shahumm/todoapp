import 'package:isar/isar.dart';
import 'package:todoapp/tasks.dart';

part 'user.g.dart';

@Collection()
class User {
  Id id = Isar.autoIncrement;
  late String name;
  final tasks = IsarLinks<Tasks>();
}
