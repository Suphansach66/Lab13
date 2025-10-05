import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/my_transaction.dart';
import 'add_edit_transaction_screen.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('รายรับ-รายจ่าย')),
      body: Consumer<TransactionProvider>(
        builder: (context, txProvider, child) {
          if (txProvider.transactions.isEmpty) {
            return const Center(child: Text('ไม่มีรายการ'));
          }
          return ListView.builder(
            itemCount: txProvider.transactions.length,
            itemBuilder: (ctx, i) {
              final tx = txProvider.transactions[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tx.type == TransactionType.income
                        ? Colors.green
                        : Colors.red,
                    child: Text(tx.type == TransactionType.income ? 'รับ' : 'จ่าย'),
                  ),
                  title: Text(tx.title),
                  subtitle: Text(DateFormat.yMMMd().format(tx.date)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) =>
                                AddEditTransactionScreen(existingTx: tx),
                          ));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () {
                          context
                              .read<TransactionProvider>()
                              .deleteTransaction(tx.id!);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => const AddEditTransactionScreen(),
          ));
        },
      ),
    );
  }
}