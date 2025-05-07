import 'package:flutter/material.dart';

import 'bondora.dart';

class Investments extends StatelessWidget {
  final String spreadsheetId;

  const Investments({
    super.key,
    required this.spreadsheetId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Investments')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Bondora(spreadsheetId: '1h116Ws8bJ6lBjgOavPXQIiqt_jLJF9VDPKYsk6TCUcg')),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                title: const Text('Bondora'),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ),
          ),
          // Add more cards here if needed
        ],
      ),
    );
  }
}
