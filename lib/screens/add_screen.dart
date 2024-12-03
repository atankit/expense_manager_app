import 'package:expense_manager/helper/db_helper.dart';
import 'package:expense_manager/model/expense_model.dart';
import 'package:flutter/material.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense; // Use the Expense model

  const AddEditExpenseScreen({this.expense, super.key});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Food';
  DateTime _selectedDate = DateTime.now();

  FocusNode amount_focus = FocusNode();
  FocusNode desc_focus = FocusNode();

  final List<String> _item = ['Food', "Transportation", "Bills", "Other"];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _descriptionController.text = widget.expense!.description;
      _amountController.text = widget.expense!.amount.toStringAsFixed(2);
      _category = widget.expense!.category;
      _selectedDate = DateTime.parse(widget.expense!.date);
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return; // Form validation

    // Create the expense object
    final expense = Expense(
      id: widget.expense?.id,
      // Use null-aware operator if expense is null
      description: _descriptionController.text.trim(),
      amount: double.parse(_amountController.text),
      category: _category,
      date: _selectedDate.toIso8601String(),
    );

    // If no expense exists, insert a new expense
    if (widget.expense == null) {
      await DatabaseHelper.insertExpense(expense);
    } else {
      // Otherwise, update the existing expense
      await DatabaseHelper.updateExpense(expense);
    }

    // After saving, pop the screen to return to the previous one
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffe8ecf1),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                background_container(context),
                Positioned(
                  top: 160,
                  child: main_container(),
                ),
              ],
            ),
          ),
        ));
  }

  Container main_container() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      height: 460,
      width: 340,
      child: Column(
        children: [
          const SizedBox(height: 40),
          category(),
          const SizedBox(height: 20),
          description(),
          const SizedBox(height: 20),
          amount(),
          const SizedBox(height: 20),
          date_time(),
          const SizedBox(
            height: 60,
          ),
          saveButton(),
        ],
      ),
    );
  }

  Column background_container(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: Color(0xff1aa181),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      'Adding',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    Icon(
                      Icons.menu_sharp,
                      color: Colors.white,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget saveButton() {
    return GestureDetector(
      onTap: () {
        _saveExpense();
      },
      child: Container(
        alignment: Alignment.center,
        width: 300,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xff1aa181),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Text(
          'Save',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Padding category() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: 2,
            color: Color(0xffC5C5C5),
          ),
        ),
        child: DropdownButton<String>(
          value: _category,
          onChanged: ((value) {
            setState(() {
              _category = value!;
            });
          }),
          items: _item
              .map((e) => DropdownMenuItem(
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            child: Image.asset('images/${e}.png'),
                          ),
                          SizedBox(width: 10),
                          Text(
                            e,
                            style: TextStyle(fontSize: 18),
                          )
                        ],
                      ),
                    ),
                    value: e,
                  ))
              .toList(),
          selectedItemBuilder: (BuildContext context) => _item
              .map((e) => Row(
                    children: [
                      Container(
                        width: 42,
                        child: Image.asset('images/${e}.png'),
                      ),
                      SizedBox(width: 5),
                      Text(e)
                    ],
                  ))
              .toList(),
          hint: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Category',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          dropdownColor: Colors.white,
          isExpanded: true,
          underline: Container(),
        ),
      ),
    );
  }

  Padding description() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        focusNode: desc_focus,
        controller: _descriptionController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'Description',
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade500),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Color(0xffC5C5C5))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Color(0xff368983))),
        ),
      ),
    );
  }

  Padding amount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        keyboardType: TextInputType.number,
        focusNode: amount_focus,
        controller: _amountController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: 'Amount',
          labelStyle: TextStyle(fontSize: 17, color: Colors.grey.shade500),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Color(0xffC5C5C5))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: Color(0xff368983))),
        ),
      ),
    );
  }

  Widget date_time() {
    return Container(
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Color(0xffC5C5C5))),
      width: 300,
      child: TextButton(
        onPressed: () async {
          DateTime? newDate = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100));
          if (newDate == Null) return;
          setState(() {
            _selectedDate = newDate!;
          });
        },
        child: Text(
          'Date : ${_selectedDate.year} / ${_selectedDate.day} / ${_selectedDate.month}',
          style: TextStyle(
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
