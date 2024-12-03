class Expense {
  final int? id;
  final String description;
  final double amount;
  final String category;
  final String date;

  Expense({
    this.id, // id is nullable
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
  });

  // Convert the Expense object to a Map to insert or update it in the database
  Map<String, dynamic> toMap() {
    return {
      'id': id, // id can be null
      'description': description,
      'amount': amount,
      'category': category,
      'date': date,
    };
  }

  // You might already have a fromMap() method for converting from Map to object
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      category: map['category'],
      date: map['date'],
    );
  }
}
