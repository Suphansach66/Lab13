import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/my_transaction.dart';
import '../providers/transaction_provider.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final MyTransaction? existingTx;

  const AddEditTransactionScreen({super.key, this.existingTx});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TransactionType _selectedType = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    if (widget.existingTx != null) {
      _titleController.text = widget.existingTx!.title;
      _amountController.text = widget.existingTx!.amount.toString();
      _selectedDate = widget.existingTx!.date;
      _selectedType = widget.existingTx!.type;
    }
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (widget.existingTx == null) {
      // Insert
      context.read<TransactionProvider>().addMyTransaction(
            title,
            amount,
            _selectedDate,
            _selectedType,
          );
    } else {
      // Update
      final updatedTx = MyTransaction(
        id: widget.existingTx!.id,
        title: title,
        amount: amount,
        date: _selectedDate,
        type: _selectedType,
      );
      context
          .read<TransactionProvider>()
          .updateTransaction(widget.existingTx!.id!, updatedTx);
    }

    Navigator.of(context).pop(); // ปิดหน้าฟอร์ม
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTx == null ? 'เพิ่มรายการ' : 'แก้ไขรายการ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'ชื่อรายการ'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'กรุณากรอกชื่อ' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'จำนวนเงิน'),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? 'กรุณากรอกจำนวนเงิน' : null,
              ),
              Row(
                children: [
                  Text(DateFormat.yMMMd().format(_selectedDate)),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('เลือกวันที่'),
                  ),
                ],
              ),
              DropdownButton<TransactionType>(
                value: _selectedType,
                items: const [
                  DropdownMenuItem(
                    value: TransactionType.income,
                    child: Text("รายรับ"),
                  ),
                  DropdownMenuItem(
                    value: TransactionType.expense,
                    child: Text("รายจ่าย"),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('บันทึก'),
              )
            ],
          ),
        ),
      ),
    );
  }
}