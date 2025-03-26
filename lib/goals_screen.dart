import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/goal_provider.dart';
import '../models/goal.dart';
import '../models/milestone.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals & Progress'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveGoalsTab(),
          _buildCompletedGoalsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddGoalDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildActiveGoalsTab() {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, child) {
        final activeGoals = goalProvider.getActiveGoals();

        if (activeGoals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flag_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No active goals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set goals to track your mental health progress',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddGoalDialog();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add First Goal'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeGoals.length,
          itemBuilder: (context, index) {
            final goal = activeGoals[index];
            return _buildGoalCard(goal, goalProvider);
          },
        );
      },
    );
  }

  Widget _buildCompletedGoalsTab() {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, child) {
        final completedGoals = goalProvider.getCompletedGoals();

        if (completedGoals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No completed goals yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your completed goals will appear here',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedGoals.length,
          itemBuilder: (context, index) {
            final goal = completedGoals[index];
            return _buildGoalCard(goal, goalProvider);
          },
        );
      },
    );
  }

  Widget _buildGoalCard(Goal goal, GoalProvider goalProvider) {
    final milestones = goalProvider.getMilestonesForGoal(goal.id);
    final completedMilestones = milestones.where((m) => m.isCompleted).length;
    final progress = milestones.isEmpty ? 1.0 : completedMilestones / milestones.length;

    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0 && !goal.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showGoalDetailsDialog(goal, milestones);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      goal.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(goal.category).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getCategoryName(goal.category),
                      style: TextStyle(
                        color: _getCategoryColor(goal.category),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                goal.description,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isOverdue ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Target: ${DateFormat('MMM d, yyyy').format(goal.targetDate)}',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(width: 4),
                    Text(
                      '(Overdue)',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else if (!goal.isCompleted) ...[
                    const SizedBox(width: 4),
                    Text(
                      '($daysLeft days left)',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              if (milestones.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress: $completedMilestones/${milestones.length} milestones',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: goal.isCompleted ? Colors.green : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    goal.isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
              if (!goal.isCompleted && milestones.isEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _showAddMilestoneDialog(goal.id);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Milestones'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        goalProvider.completeGoal(goal.id);
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Complete'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalDetailsDialog(Goal goal, List<Milestone> milestones) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Consumer<GoalProvider>(
              builder: (context, goalProvider, child) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                goal.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            if (!goal.isCompleted)
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showDeleteGoalConfirmation(goal.id);
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(goal.category).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getCategoryName(goal.category),
                            style: TextStyle(
                              color: _getCategoryColor(goal.category),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          goal.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Created on: ${DateFormat('MMM d, yyyy').format(goal.createdAt)}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  'Target date: ${DateFormat('MMM d, yyyy').format(goal.targetDate)}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Milestones',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            if (!goal.isCompleted)
                              TextButton.icon(
                                onPressed: () {
                                  _showAddMilestoneDialog(goal.id);
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (milestones.isEmpty)
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.flag_outlined,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No milestones yet',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Break down your goal into smaller steps',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: milestones.length,
                            itemBuilder: (context, index) {
                              final milestone = milestones[index];
                              return CheckboxListTile(
                                value: milestone.isCompleted,
                                onChanged: goal.isCompleted
                                    ? null
                                    : (value) {
                                  if (value == true) {
                                    goalProvider.completeMilestone(milestone.id);
                                  }
                                },
                                title: Text(
                                  milestone.title,
                                  style: TextStyle(
                                    decoration: milestone.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: milestone.completedAt != null
                                    ? Text(
                                  'Completed on ${DateFormat('MMM d, yyyy').format(milestone.completedAt!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                )
                                    : null,
                                activeColor: Theme.of(context).colorScheme.primary,
                                checkColor: Colors.white,
                                controlAffinity: ListTileControlAffinity.leading,
                              );
                            },
                          ),
                        const SizedBox(height: 24),
                        if (!goal.isCompleted)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                goalProvider.completeGoal(goal.id);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Mark Goal as Complete',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Goal Completed',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'mood';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Goal'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Goal Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Category:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildCategoryChip('mood', 'Mood', selectedCategory, (category) {
                          setState(() {
                            selectedCategory = category;
                          });
                        }),
                        _buildCategoryChip('journal', 'Journal', selectedCategory, (category) {
                          setState(() {
                            selectedCategory = category;
                          });
                        }),
                        _buildCategoryChip('cbt', 'CBT', selectedCategory, (category) {
                          setState(() {
                            selectedCategory = category;
                          });
                        }),
                        _buildCategoryChip('relaxation', 'Relaxation', selectedCategory, (category) {
                          setState(() {
                            selectedCategory = category;
                          });
                        }),
                        _buildCategoryChip('other', 'Other', selectedCategory, (category) {
                          setState(() {
                            selectedCategory = category;
                          });
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Target Date'),
                      subtitle: Text(
                        DateFormat('MMMM d, yyyy').format(selectedDate),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );

                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final goalProvider = Provider.of<GoalProvider>(context, listen: false);

                      goalProvider.addGoal(
                        title: titleController.text,
                        description: descriptionController.text.isNotEmpty
                            ? descriptionController.text
                            : 'No description',
                        targetDate: selectedDate,
                        category: selectedCategory,
                      );

                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a title for your goal')),
                      );
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryChip(String value, String label, String selectedCategory, Function(String) onSelect) {
    final isSelected = selectedCategory == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onSelect(value);
        }
      },
      backgroundColor: Colors.grey[200],
      selectedColor: _getCategoryColor(value).withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? _getCategoryColor(value) : Colors.grey[800],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  void _showAddMilestoneDialog(String goalId) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Milestone'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Milestone Title',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final goalProvider = Provider.of<GoalProvider>(context, listen: false);

                  goalProvider.addMilestone(
                    goalId: goalId,
                    title: titleController.text,
                  );

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title for the milestone')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteGoalConfirmation(String goalId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Goal'),
          content: const Text('Are you sure you want to delete this goal? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final goalProvider = Provider.of<GoalProvider>(context, listen: false);
                goalProvider.deleteGoal(goalId);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'mood':
        return Colors.blue;
      case 'journal':
        return Colors.purple;
      case 'cbt':
        return Colors.green;
      case 'relaxation':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'mood':
        return 'Mood';
      case 'journal':
        return 'Journal';
      case 'cbt':
        return 'CBT';
      case 'relaxation':
        return 'Relaxation';
      default:
        return 'Other';
    }
  }
}

// TODO Implement this library.