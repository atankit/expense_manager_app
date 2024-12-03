import 'package:flutter/material.dart';
import 'dart:io';
import 'package:expense_manager/helper/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


class ExportScreen extends StatefulWidget {

  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  DateTime? startDate;
  DateTime? endDate;

  void pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
    }
  }
  Future<void> exportExpenses(DateTime startDate, DateTime endDate) async {
    // Request storage permissions
    if (!await Permission.storage.request().isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Storage permission is required to export PDF.")),
      );
      return;
    }

    // Fetch expenses using DatabaseHelper
    final expenses = await DatabaseHelper.fetchExpenses(startDate, endDate);

    // Create the PDF
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context pdfContext) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text("Expense Report", style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Text(
              "Date Range: ${DateFormat('yyyy-MM-dd').format(startDate)} - ${DateFormat('yyyy-MM-dd').format(endDate)}",
            ),
            pw.SizedBox(height: 20),
            // pw.Table.fromTextArray(  // is deprecated and shouldn't be used
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Category', 'Description', 'Amount'],
              data: expenses.map((e) => [
                e['date'],
                e['category'],
                e['description'],
                e['amount'].toStringAsFixed(2),
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
            ),

            pw.SizedBox(height: 20),
            pw.Text("Generated on ${DateFormat('yyyy-MM-dd').format(DateTime.now())}"),
          ],
        ),
      ),
    );


    try {
      // Save the file to the Downloads folder
      final downloadsDir = Directory('/storage/emulated/0/Download');
      final fileName = "Expense_Report_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final outputFile = File("${downloadsDir.path}/$fileName");

      // Write the PDF file
      await outputFile.writeAsBytes(await pdf.save());

      // Notify user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF saved to Downloads folder: $fileName")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save PDF: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Export Expenses")),
      body:
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Align content at the top
          crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0), // Add padding around the content
              child: Column(
                mainAxisSize: MainAxisSize.min, // Shrinks the column vertically
                crossAxisAlignment: CrossAxisAlignment.center, // Aligns items at the center horizontally
                children: [
                  ElevatedButton(
                    onPressed: pickDateRange,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // Button background color
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
                    ),
                    child: Text(
                      "Select Date Range",
                      style: TextStyle(
                        color: Colors.white, // Text color
                        fontSize: 16, // Font size
                        fontWeight: FontWeight.bold, // Font weight
                      ),
                    ),
                  ),
                  if (startDate != null && endDate != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Selected Range: ${DateFormat('yyyy-MM-dd').format(startDate!)} - ${DateFormat('yyyy-MM-dd').format(endDate!)}",
                        style: TextStyle(
                          color: Colors.black54, // Text color
                          fontSize: 16, // Font size
                          fontWeight: FontWeight.w500, // Font weight
                        ),
                      ),
                    ),
                  SizedBox(height: 15,),
                  ElevatedButton(
                    onPressed: () {
                      if (startDate != null && endDate != null) {
                        exportExpenses(startDate!, endDate!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please select a date range first!"),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Button background color
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                      ),
                    ),
                    child: Text(
                      "Download PDF",
                      style: TextStyle(
                        color: Colors.white, // Text color
                        fontSize: 16, // Font size
                        fontWeight: FontWeight.bold, // Font weight
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )



    );
  }
}
