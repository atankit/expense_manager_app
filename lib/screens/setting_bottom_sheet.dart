
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsBottomSheet extends StatefulWidget {
  const SettingsBottomSheet({super.key});

  @override
  State<SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<SettingsBottomSheet> {
  final List<String> _currencies = ['USD','INR', 'EUR' ];
  String _selectedCurrency = 'INR';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCurrency = prefs.getString('default_currency') ?? 'INR';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('default_currency', _selectedCurrency);

    // Notify the parent widget and pass the updated currency
    Navigator.pop(context, _selectedCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Default Currency',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 25),

          // Currency Dropdown with rounded corners
          Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: _selectedCurrency,
              items: _currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(
                    currency,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                  // print(_selectedCurrency);  ---- INR/USD/ERO
                });
              },
              isExpanded: true,
              underline: Container(), // Removes the default underline
            ),
          ),
          const SizedBox(height: 20),

          // Save Preferences Button with full width and custom styling
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                      backgroundColor: const Color(0xff1aa181), // Button color
              ),
              child: const Text(
                'Save Preferences',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
