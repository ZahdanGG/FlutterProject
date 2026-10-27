/// Kontrak gateway; integrasi produksi harus memverifikasi callback di server.
abstract interface class PaymentService {
  Future<bool> simulate({required String orderId, required int amount, required bool success});
}

class DemoPaymentService implements PaymentService {
  const DemoPaymentService();
  @override
  Future<bool> simulate({required String orderId, required int amount, required bool success}) async {
    // Tidak membuka e-wallet, tidak menghasilkan QRIS, dan tidak memindahkan uang.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return success;
  }
}
