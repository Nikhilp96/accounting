import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<int> addTransaction(TransactionEntity transaction);
  Future<List<TransactionEntity>> getAllTransactions();
  Future<int> deleteTransaction(int id);
}