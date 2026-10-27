import 'package:shared_preferences/shared_preferences.dart';
import 'app_exception.dart';

/// Abstraksi kecil agar repository dapat diuji tanpa storage perangkat.
abstract interface class LocalStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class PreferencesLocalStore implements LocalStore {
  PreferencesLocalStore(this.preferences);
  final SharedPreferences preferences;
  static Future<PreferencesLocalStore> create() async =>
      PreferencesLocalStore(await SharedPreferences.getInstance());
  @override
  Future<String?> read(String key) async => preferences.getString(key);
  @override
  Future<void> write(String key, String value) async {
    if (!await preferences.setString(key, value)) {
      throw const AppException('Data belum tersimpan. Periksa ruang penyimpanan, lalu coba lagi.');
    }
  }
}

/// Digunakan hanya oleh test. Aplikasi normal memakai PreferencesLocalStore.
class MemoryLocalStore implements LocalStore {
  final Map<String, String> values = {};
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async { values[key] = value; }
}
