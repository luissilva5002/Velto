import 'package:flutter/material.dart';

class GoalCard extends StatefulWidget {
  final String name;
  final int value;
  final int ceiling;
  final Color color;
  final String cardId; // Unique identifier for the goal
  final Function(String) onDelete; // Callback for deleting the card using the goalId

  const GoalCard({
    super.key,
    required this.name,
    required this.value,
    required this.ceiling,
    required this.color,
    required this.cardId, // Accept goalId
    required this.onDelete, // Accept the delete callback
  });

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(widget.name, style: const TextStyle(fontSize: 16)),
                        SizedBox(width: 8),
                        Text("${widget.value.toString()}€", style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.grey.shade500),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                            return AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: const Text('Are you sure you want to delete this goal?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(), // Dismiss
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(); // Close the dialog
                                    widget.onDelete(widget.cardId);    // Proceed with delete
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Progress'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: widget.value / widget.ceiling,
                        minHeight: 10,
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        color: widget.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${(widget.value / widget.ceiling * 100).round()}%'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
