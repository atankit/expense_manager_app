import 'package:expense_manager/screens/home_screen.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(const PersonalExpenseManagerApp());
}

class PersonalExpenseManagerApp extends StatelessWidget {
  const PersonalExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expense Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
