import 'package:flutter/material.dart';
import 'package:velto/pages/budget/budget.dart';
import 'package:velto/pages/dashboard/dashboard.dart';
import 'package:velto/pages/investments/investments.dart';

class Home extends StatefulWidget {
  final int? selectedIndex;

  const Home({super.key, this.selectedIndex});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late int _selectedIndex;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const Dashboard(spreadsheetId: '1h116Ws8bJ6lBjgOavPXQIiqt_jLJF9VDPKYsk6TCUcg'),
      const Budget(),
      const Investments(spreadsheetId: '1h116Ws8bJ6lBjgOavPXQIiqt_jLJF9VDPKYsk6TCUcg'),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF013024),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.table_chart),
            label: 'Budget',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.candlestick_chart),
            label: 'Investments',
          ),
        ],
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

