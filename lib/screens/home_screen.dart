import 'package:flutter/material.dart';
import 'package:expense_manager/screens/add_screen.dart';
import 'package:expense_manager/helper/db_helper.dart';
import 'package:expense_manager/model/expense_model.dart';
import 'package:expense_manager/screens/export_screen.dart';
import 'package:expense_manager/screens/setting_bottom_sheet.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Expense> _expenses = []; // Update to use Expense model
  double _totalAmount = 0.0;
  String _currencySymbol = '\₹'; // Default symbol

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
    _loadDefaultCurrency();
  }

  Future<void> _fetchExpenses() async {
    final expenses = await DatabaseHelper.getAllExpenses();
    setState(() {
      _expenses = expenses;
      _totalAmount = expenses.fold(
        0.0,
        (sum, expense) => sum + expense.amount,
      );
    });
  }

  Future<void> _deleteExpense(int? id) async {
    await DatabaseHelper.deleteExpense(id!);
    _fetchExpenses();
  }

  Future<void> _loadDefaultCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final currency = prefs.getString('default_currency') ?? 'INR';
      _currencySymbol = _getCurrencySymbol(currency);
    });
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      default:
        return '\₹';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe8ecf1),
      body: Column(
        children: [
          top_design(context, _currencySymbol, _totalAmount),
          const SizedBox(
            height: 10,
          ),
          Container(child: buttons_design()),
          const SizedBox(
            height: 15,
          ),
          all_expense_top(),
          get_all_expenses(),
        ],
      ),
    );
  }

  Column top_design(
      BuildContext context, String currencySymbol, double totalAmount) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 240,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff1aa181),
                Color(0xff16c295)
              ], // Attractive gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4), // Subtle shadow for depth
              ),
            ],
          ),
          child: Stack(
            children: [
              // Align the title to the top-left
              Positioned(
                top: 40,
                left: 15,
                child: Row(
                  children: const [
                    Icon(
                      Icons.monetization_on_sharp,
                      size: 28,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Personal Expense Manager',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 110,
                left: 0,
                right: 0, // Center-align horizontally
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withOpacity(0.15), // Translucent box
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        '$currencySymbol ${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Total Spent',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Row buttons_design() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
      children: [
        // PDF Generator Button

        Expanded(
          child: Container(
            height: 40, // Set height
            margin: const EdgeInsets.symmetric(
                horizontal: 5), // Space between buttons
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff1aa181), Color(0xff16c295)], // Gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30), // Rounded edges
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExportScreen(),
                  ),
                ).then((_) => _fetchExpenses());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // Gradient background
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "PDF Generator",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        // Setting Button
        Expanded(
          child: Container(
            height: 40, // Set height
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff1aa181), Color(0xff16c295)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),

            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled:
                      true, // Allows the sheet to expand dynamically
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => const SettingsBottomSheet(),
                ).then((value) {
                  if (value != null) {
                    // Update the currency symbol when the value is returned
                    setState(() {
                      _currencySymbol =
                          _getCurrencySymbol(value); // Update the symbol
                    });
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Setting",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        // Add Expense Button
        Expanded(
          child: Container(
            height: 40, // Set height
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff1aa181), Color(0xff16c295)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),

            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddEditExpenseScreen()),
                ).then((_) => _fetchExpenses());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Add Expense",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Container all_expense_top() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Expenses History',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 19,
              color: Colors.black,
            ),
          ),
          Text(
            'See all',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Container get_all_expenses() {
    return Container(
      child: Expanded(
        child: _expenses.isEmpty
            ? const Center(
                child: Text(
                  'No expenses found. Add some!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: _expenses.length,
                itemBuilder: (context, index) {
                  final expense = _expenses[index];
                  return Dismissible(
                    key: Key(expense.id.toString()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _deleteExpense(expense.id);
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(
                            'images/${expense.category}.png',
                            height: 40,
                          ),
                        ),
                        title: Text(
                          expense.description,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '${expense.category} • ${DateFormat.yMMMd().format(DateTime.parse(expense.date))}',
                          style: TextStyle(color: Colors.black),
                        ),
                        trailing: Text(
                          '${_currencySymbol}${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.redAccent,
                          ),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddEditExpenseScreen(expense: expense),
                          ),
                        ).then((_) => _fetchExpenses()),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
