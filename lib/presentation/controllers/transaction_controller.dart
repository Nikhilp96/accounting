import 'package:get/get.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionController extends GetxController {
  final TransactionRepository repository;
  final GetTransactionsUseCase getTransactionsUseCase;

  TransactionController({
    required this.repository,
    required this.getTransactionsUseCase,
  });

  var transactions = <TransactionEntity>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    isLoading.value = true;
    try {
      final data = await getTransactionsUseCase.call();
      transactions.assignAll(data);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTransaction(String type, double amount, String description) async {
    final newTx = TransactionEntity(
      type: type,
      amount: amount,
      description: description,
      date: DateTime.now(),
    );
    await repository.addTransaction(newTx);
    fetchTransactions(); // Refresh list after adding
  }
}