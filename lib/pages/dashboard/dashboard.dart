import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velto/pages/dashboard/widgets/goalDialog.dart';
import '../dashboard/widgets/goals.dart';
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
  static const String _prefsKey = 'goal_cards';
  final Map<String, String?> cellValues = {};
  bool isLoading = true;
  List<Widget> cards = [];

  @override
  void initState() {
    super.initState();
    loadDashboardData();
    _loadCardsFromPrefs();
  }

  Future<void> loadDashboardData() async {
    try {
      final client = await getSheetsClient();
      final sheets = GoogleSheetsService(widget.spreadsheetId, client);

      final cells = {
        'B4': 'Debit',
        'E4': 'Credit',
        'H4': 'Savings',
        'H6': 'Interest',
        'I6': 'Next Deposit',
        'H10': 'Assets',
        'H11': 'Passive',
        'H12': 'Working Capital',
      };

      final fetched = <String, String?>{};
      for (final cell in cells.keys) {
        final value = await sheets.getCell('Net Worth Dashboard!$cell');
        fetched[cell] = value;
      }

      setState(() {
        cellValues.addAll(fetched);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveCardsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final List<Map> cardData = cards.map((widget) {
      if (widget is CardWrapper && widget.child is GoalCard) {
        final goal = widget.child as GoalCard;
        return {
          'cardId': goal.cardId,
          'name': goal.name,
          'value': goal.value,
          'ceiling': goal.ceiling,
          'color': goal.color.value,
        };
      }
      return {};
    }).toList();

    await prefs.setString(_prefsKey, jsonEncode(cardData));
  }

  Future<void> _loadCardsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_prefsKey);
    if (data == null) return;

    final List<dynamic> decoded = jsonDecode(data);
    setState(() {
      cards = decoded.map((card) {
        final map = Map<String, dynamic>.from(card);
        return CardWrapper(
          cardId: map['cardId'],
          child: GoalCard(
            name: map['name'],
            value: map['value'],
            ceiling: map['ceiling'],
            color: Color(map['color']),
            cardId: map['cardId'],
            onDelete: deleteCard,
          ),
        );
      }).toList();
    });
  }

  void deleteCard(String cardId) {
    setState(() {
      cards.removeWhere(
              (widget) => widget is CardWrapper && widget.cardId == cardId);
    });
    _saveCardsToPrefs();
  }

  void addCard({
    required String name,
    required int value,
    required int ceiling,
    required Color color,
  }) {
    final cardId = DateTime.now().millisecondsSinceEpoch.toString();
    final goalCard = GoalCard(
      name: name,
      value: value,
      ceiling: ceiling,
      color: color,
      cardId: cardId,
      onDelete: deleteCard,
    );

    setState(() {
      cards.add(CardWrapper(cardId: cardId, child: goalCard));
    });

    _saveCardsToPrefs();
  }

  Widget _buildValueRow(String label, String? value, {bool bold = false}) {
    final textStyle = TextStyle(
        fontSize: 16, fontWeight: bold ? FontWeight.bold : FontWeight.normal);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text(value ?? '-', style: textStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildValueRow('Debit', cellValues['B4']),
                    _buildValueRow('Credit', cellValues['E4']),
                    _buildValueRow('Savings', cellValues['H4']),
                    const Divider(),
                    _buildValueRow('# Interest', cellValues['H6']),
                    _buildValueRow('# Next Deposit', cellValues['I6']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildValueRow('Assets', cellValues['H10'],
                        bold: true),
                    _buildValueRow('Passive', cellValues['H11']),
                    _buildValueRow('Working Capital',
                        cellValues['H12'], bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Column(children: cards),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomMenu(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBottomMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.savings),
                title: const Text('Add Savings Goal'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return SavingsGoalDialog(
                        onGoalAdded: (goalData) {
                          addCard(
                            name: goalData.name,
                            value: goalData.value,
                            ceiling: goalData.ceiling,
                            color: goalData.color,
                          );
                                                },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class CardWrapper extends StatelessWidget {
  final String cardId;
  final Widget child;

  const CardWrapper({
    super.key,
    required this.cardId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => child;
}