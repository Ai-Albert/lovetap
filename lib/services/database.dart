import 'package:cloud_firestore/cloud_firestore.dart';
import 'api_path.dart';
import 'firestore_service.dart';

abstract class Database {
  Future<void> deleteData();
}

class FirestoreDatabase implements Database {
  FirestoreDatabase({required this.uid});
  final String uid;
  final _service = FirestoreService.instance;

  // Deleting all of a user's data prior to account deletion
  @override
  Future<void> deleteData() async {
  }
}