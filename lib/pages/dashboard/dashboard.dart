import 'package:flutter/material.dart';

import '../../services/google_sheets.dart';
import '../../services/sheets_client.dart';

class Dashboard extends StatefulWidget {
  final String spreadsheetId;

  const Dashboard({
    required this.spreadsheetId,
    super.key,
  });

  @override
  State<Dashboard> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<Dashboard> {
  String? cellValue;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCellValue();
  }

  Future<void> loadCellValue() async {
    try {
      final client = await getSheetsClient();
      final sheets = GoogleSheetsService(widget.spreadsheetId, client);

      final value = await sheets.getCell('Net Worth Dashboard!H4'); // Assuming Sheet1 is the first tab
      setState(() {
        cellValue = value ?? 'Empty';
        isLoading = false;
      });
    } catch (e) {
      print('Error loading cell: $e');
      setState(() {
        cellValue = 'Error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(
          'Cell H4: $cellValue',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
