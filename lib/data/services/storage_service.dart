import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Thin wrapper around GetStorage (local key/value persistence).
class StorageService extends GetxService {
  static StorageService get to => Get.find();

  late final GetStorage _box;

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  T? read<T>(String key) => _box.read<T>(key);

  int readInt(String key, [int fallback = 0]) => (_box.read(key) as num?)?.toInt() ?? fallback;

  bool readBool(String key, [bool fallback = false]) => _box.read(key) as bool? ?? fallback;

  String? readString(String key) => _box.read(key) as String?;

  Map<String, dynamic> readMap(String key) {
    final v = _box.read(key);
    return v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
  }

  List<String> readStringList(String key) {
    final v = _box.read(key);
    return v is List ? v.map((e) => '$e').toList() : <String>[];
  }

  Future<void> write(String key, dynamic value) => _box.write(key, value);

  Future<void> remove(String key) => _box.remove(key);

  Future<void> eraseAll() => _box.erase();
}
