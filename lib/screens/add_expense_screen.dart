import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/hive_service.dart';

import '../utils/app_colors.dart';
import '../utils/helpers.dart';
import 'package:uuid/uuid.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expenseToEdit;
  final VoidCallback? onSaved;

  const AddExpenseScreen({super.key, this.expenseToEdit, this.onSaved});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _otherNameController;
  TextEditingController? _purchasedItemsController; // Nullable for lazy init
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedCategories = [];
  String? _selectedPaymentMode;

  final List<String> _allCategories = [
    'Milk', 'Grocery', 'Food', 'Vegetables', 'Petrol', 'Zepto', 'BigBasket', 'Swiggy', 'Zomato' ,
    'Flipkart', 'Amazon', 'EMI', 'Electricity Bill', 'Rent','Mobile Recharge', 'Wifi Bill' , 'Gas Bill', 'Snacks', 'Savings' , 'Travel Expenses', 'Others' 
  ];

  final List<String> _paymentModes = ['Credit Card', 'GPay', 'Cash','Debit Card'];

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      _amountController = TextEditingController(text: widget.expenseToEdit!.amount.toStringAsFixed(0));
      _otherNameController = TextEditingController(text: widget.expenseToEdit!.otherName ?? '');
      // _purchasedItemsController init moved to build for Hot Reload safety
      _selectedDate = widget.expenseToEdit!.date;
      _selectedCategories = List.from(widget.expenseToEdit!.categories);
      _selectedPaymentMode = widget.expenseToEdit!.paymentMode;
    } else {
      _amountController = TextEditingController();
      _otherNameController = TextEditingController();
      // _purchasedItemsController init moved to build
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _otherNameController.dispose();
    _purchasedItemsController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized (Hot Reload fix)
    _purchasedItemsController ??= TextEditingController(
      text: widget.expenseToEdit?.purchasedItems ?? ''
    );

    bool isEditing = widget.expenseToEdit != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Expense' : 'Add Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date Picker
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(Helpers.formatDate(_selectedDate)),
              ),
            ),
            const SizedBox(height: 16),
            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter amount';
                if (double.tryParse(value) == null) return 'Invalid amount';
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Categories
            const Text('Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _allCategories.map((cat) {
                final isSelected = _selectedCategories.contains(cat);
                return FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(cat);
                      } else {
                        _selectedCategories.remove(cat);
                      }
                    });
                  },
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary.withOpacity(0.3),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            if (_selectedCategories.isEmpty)
              const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Please select at least one category', style: TextStyle(color: AppColors.error))),
            
            const SizedBox(height: 16),
            
            // Mode of Payment
            const Text('Mode of Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _paymentModes.map((mode) {
                final isSelected = _selectedPaymentMode == mode;
                return FilterChip(
                  label: Text(mode),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPaymentMode = selected ? mode : null;
                    });
                  },
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.primary.withOpacity(0.3),
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            if (_selectedPaymentMode == null)
              const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Please select a payment mode', style: TextStyle(color: AppColors.error))),
            
            const SizedBox(height: 16),
            
            // Purchased Items (Optional)
            TextFormField(
              controller: _purchasedItemsController,
              decoration: const InputDecoration(
                labelText: 'What did you buy?',
                border: OutlineInputBorder(),
                helperText: 'E.g., Milk, Bread, Shirt',
              ),
              // No validator needed
            ),

            const SizedBox(height: 16),
            // Other Name
            if (_selectedCategories.contains('Others'))
              TextFormField(
                controller: _otherNameController,
                decoration: const InputDecoration(
                  labelText: 'Expense Name',
                  border: OutlineInputBorder(),
                  helperText: 'Required for "Others" category',
                ),
                validator: (value) {
                  if (_selectedCategories.contains('Others') && (value == null || value.isEmpty)) {
                    return 'Please specify the expense name';
                  }
                  return null;
                },
              ),

            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _saveExpense,
                child: Text(isEditing ? 'Update Expense' : 'Save Expense', style: const TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select at least one category')));
        return;
      }

      if (_selectedPaymentMode == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a payment mode')));
        return;
      }

      final amount = double.parse(_amountController.text);

      // Just use time based ID if no UUID package, or just Random. 
      // I forgot to add uuid package. I'll use DateTime.now().toString() as ID for simplicity.
      final newId = widget.expenseToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

      final expense = Expense(
        id: newId,
        date: _selectedDate,
        amount: amount,
        categories: List.from(_selectedCategories), // Fix: Create new list copy
        otherName: _otherNameController.text.isEmpty ? null : _otherNameController.text,
        purchasedItems: _purchasedItemsController?.text.isEmpty ?? true ? null : _purchasedItemsController!.text,
        paymentMode: _selectedPaymentMode!,
      );

      if (widget.expenseToEdit != null) {
        // Replace existing expense
        if (widget.expenseToEdit!.isInBox) {
           await HiveService.expenseBox.put(widget.expenseToEdit!.key, expense);
        }
      } else {
        await HiveService.addExpense(expense);
        
        // Check Notification Logic

      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Expense saved successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      if (widget.onSaved != null) {
        // Tab Input Mode
        widget.onSaved!();
        // Reset form for next use since this screen stays in IndexedStack
        setState(() {
          _amountController.clear();
          _otherNameController.clear();
          _purchasedItemsController?.clear();
          _selectedCategories.clear();
          _selectedPaymentMode = null;
          _selectedDate = DateTime.now();
        });
      } else {
        // Pushed Mode (Edit)
        if (mounted) Navigator.pop(context);
      }
    }
  }
}
