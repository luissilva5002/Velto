import 'package:flutter/material.dart';

class SavingsGoal {
  final String name;
  final int value;
  final int ceiling;
  final Color color;

  SavingsGoal({
    required this.name,
    required this.value,
    required this.ceiling,
    required this.color,
  });
}

class SavingsGoalDialog extends StatelessWidget {
  final Function(SavingsGoal) onGoalAdded;

  const SavingsGoalDialog({super.key, required this.onGoalAdded});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController valueController = TextEditingController();
    final TextEditingController ceilingController = TextEditingController();

    return AlertDialog(
      title: const Text('Enter Savings Goal Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Goal Name'),
          ),
          TextField(
            controller: valueController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Current Value'),
          ),
          TextField(
            controller: ceilingController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Ceiling'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (nameController.text.isEmpty ||
                valueController.text.isEmpty ||
                ceilingController.text.isEmpty) {
              // If fields are empty, do not add the goal.
              return;
            }

            final goal = SavingsGoal(
              name: nameController.text,
              value: int.tryParse(valueController.text) ?? 0,
              ceiling: int.tryParse(ceilingController.text) ?? 0,
              color: Colors.green, // You can choose the color based on your needs
            );

            Navigator.pop(context);
            onGoalAdded(goal); // Pass the goal data to the callback
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
