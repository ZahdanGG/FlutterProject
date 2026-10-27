import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import '../../../core/services/app_exception.dart';
import '../../../shared/models/user_profile.dart';

/// Autentikasi DEMO lokal; bukan penyedia identitas/server produksi.
/// Password tidak disimpan. Setiap akun mempunyai salt acak dan PBKDF2 sendiri.
class AuthRepository {
  AuthRepository({this.iterations = 120000, DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;
  final int iterations;
  final DateTime Function() _clock;
  final Map<String, _Account> _accounts = {};
  static const roles = ['Mahasiswa', 'Pekerja', 'Dosen/Staf', 'Lainnya'];

  static String? validateEmail(String value) {
    if (value.trim().isEmpty) return 'Email wajib diisi.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())) {
      return 'Masukkan alamat email yang valid.';
    }
    return null;
  }
  static String? validatePassword(String value) {
    if (value.length < 8) return 'Password minimal 8 karakter.';
    return null;
  }
  static String? validateConfirmation(String password, String confirmation) =>
      password == confirmation ? null : 'Konfirmasi password tidak cocok.';
  static String normalizeEmail(String value) => value.trim().toLowerCase();
  UserProfile? profileById(String? id) {
    if (id == null) return null;
    for (final account in _accounts.values) {
      if (account.profile.id == id) return account.profile;
    }
    return null;
  }

  Future<UserProfile> register({required String name, required String email,
    required String password, required String confirmPassword, required String role,
    String phone = '', String institution = '', String department = '',
    String studentId = '', String staffId = ''}) async {
    _validate(validateEmail(email));
    _validate(validatePassword(password));
    _validate(validateConfirmation(password, confirmPassword));
    if (name.trim().length < 2) throw const AppException('Nama minimal 2 karakter.');
    if (!roles.contains(role)) throw const AppException('Pilih peran yang tersedia.');
    final normalized = normalizeEmail(email);
    if (_accounts.containsKey(normalized)) throw const AppException('Email sudah terdaftar. Silakan masuk.');
    final salt = _randomBytes(16);
    final hash = await _derive(password, salt, iterations);
    final profile = UserProfile(id: base64UrlEncode(_randomBytes(18)), name: name.trim(),
      email: normalized, phone: phone.trim(), role: role, institution: institution.trim(),
      department: department.trim(), studentId: studentId.trim(), staffId: staffId.trim());
    _accounts[normalized] = _Account(profile: profile, salt: base64Encode(salt),
      passwordHash: base64Encode(hash), iterations: iterations);
    return profile;
  }

  Future<UserProfile> login({required String email, required String password}) async {
    _validate(validateEmail(email));
    if (password.isEmpty) throw const AppException('Password wajib diisi.');
    final account = _accounts[normalizeEmail(email)];
    if (account == null) throw const AppException('Email atau password salah.');
    final hash = await _derive(password, base64Decode(account.salt), account.iterations);
    if (!_equal(hash, base64Decode(account.passwordHash))) {
      throw const AppException('Email atau password salah.');
    }
    return account.profile;
  }

  Future<String> requestPasswordReset(String email) async {
    _validate(validateEmail(email));
    final account = _accounts[normalizeEmail(email)];
    if (account == null) throw const AppException('Akun demo belum ditemukan di perangkat ini.');
    final token = base64UrlEncode(_randomBytes(18));
    account.resetHash = base64Encode((await Sha256().hash(utf8.encode(token))).bytes);
    account.resetExpires = _clock().add(const Duration(minutes: 10));
    return token;
  }

  Future<void> resetPassword({required String email, required String token,
    required String password, required String confirmPassword}) async {
    _validate(validatePassword(password));
    _validate(validateConfirmation(password, confirmPassword));
    final account = _accounts[normalizeEmail(email)];
    if (account == null || account.resetHash == null || account.resetExpires == null ||
        !_clock().isBefore(account.resetExpires!)) {
      throw const AppException('Kode reset tidak valid atau sudah kedaluwarsa.');
    }
    final candidate = (await Sha256().hash(utf8.encode(token))).bytes;
    if (!_equal(candidate, base64Decode(account.resetHash!))) {
      throw const AppException('Kode reset tidak valid atau sudah kedaluwarsa.');
    }
    await _replacePassword(account, password);
    account.resetHash = null;
    account.resetExpires = null;
  }

  Future<void> changePassword({required String userId, required String currentPassword,
    required String password, required String confirmPassword}) async {
    final account = _byId(userId);
    await login(email: account.profile.email, password: currentPassword);
    _validate(validatePassword(password));
    _validate(validateConfirmation(password, confirmPassword));
    await _replacePassword(account, password);
    account.resetHash = null;
    account.resetExpires = null;
  }

  void updateProfile(UserProfile updated) {
    final account = _byId(updated.id);
    if (updated.name.trim().length < 2) throw const AppException('Nama minimal 2 karakter.');
    _validate(validateEmail(updated.email));
    final normalized = normalizeEmail(updated.email);
    final existing = _accounts[normalized];
    if (existing != null && existing.profile.id != updated.id) {
      throw const AppException('Email sudah digunakan oleh akun lain.');
    }
    if (!roles.contains(updated.role)) throw const AppException('Peran tidak valid.');
    final previousEmail = account.profile.email;
    account.profile = updated.copyWith(name: updated.name.trim(), email: normalized,
      phone: updated.phone.trim(), institution: updated.institution.trim(), department: updated.department.trim());
    if (previousEmail != normalized) {
      _accounts.remove(previousEmail);
      account.resetHash = null;
      account.resetExpires = null;
    }
    _accounts[normalized] = account;
  }

  Future<void> _replacePassword(_Account account, String password) async {
    final previous = await _derive(password, base64Decode(account.salt), account.iterations);
    if (_equal(previous, base64Decode(account.passwordHash))) {
      throw const AppException('Password baru harus berbeda dari password lama.');
    }
    final salt = _randomBytes(16);
    account.passwordHash = base64Encode(await _derive(password, salt, iterations));
    account.salt = base64Encode(salt);
    account.iterations = iterations;
  }
  _Account _byId(String id) => _accounts.values.firstWhere((a) => a.profile.id == id,
      orElse: () => throw const AppException('Sesi tidak valid. Silakan masuk kembali.'));
  void _validate(String? error) { if (error != null) throw AppException(error); }
  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List.generate(length, (_) => random.nextInt(256));
  }
  Future<List<int>> _derive(String password, List<int> salt, int rounds) async {
    final key = await Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: rounds, bits: 256)
        .deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);
    return key.extractBytes();
  }
  bool _equal(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var different = 0;
    for (var i = 0; i < a.length; i++) { different |= a[i] ^ b[i]; }
    return different == 0;
  }

  /// Dipakai hanya oleh persistence internal, jangan dicetak ke log/UI.
  Map<String, dynamic> toJson() => {
    'accounts': _accounts.values.map((account) => account.toJson()).toList(),
  };
  void restore(Map<String, dynamic> json) {
    _accounts.clear();
    for (final item in json['accounts'] as List? ?? const []) {
      final account = _Account.fromJson(Map<String, dynamic>.from(item as Map));
      _accounts[account.profile.email] = account;
    }
  }
}

class _Account {
  _Account({required this.profile, required this.salt, required this.passwordHash,
    required this.iterations, this.resetHash, this.resetExpires});
  UserProfile profile;
  String salt, passwordHash;
  int iterations;
  String? resetHash;
  DateTime? resetExpires;
  Map<String, dynamic> toJson() => {'profile': profile.toJson(), 'salt': salt,
    'passwordHash': passwordHash, 'iterations': iterations,
    'resetHash': resetHash, 'resetExpires': resetExpires?.toIso8601String()};
  factory _Account.fromJson(Map<String, dynamic> json) => _Account(
    profile: UserProfile.fromJson(Map<String, dynamic>.from(json['profile'] as Map)),
    salt: json['salt'] as String, passwordHash: json['passwordHash'] as String,
    iterations: json['iterations'] as int, resetHash: json['resetHash'] as String?,
    resetExpires: json['resetExpires'] == null ? null : DateTime.parse(json['resetExpires'] as String));
}
