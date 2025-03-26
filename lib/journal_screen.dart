import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'journal_provider.dart';
import '../providers/user_provider.dart';
import 'journal_entry.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Consumer<JournalProvider>(
        builder: (context, journalProvider, child) {
          final entries = journalProvider.journalEntries;

          if (entries.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _buildJournalCard(entry);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEntryDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your journal is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start writing to track your thoughts and feelings',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showAddEntryDialog();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add First Entry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalCard(JournalEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _showEntryDetailsDialog(entry);
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
                      entry.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, yyyy').format(entry.timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.content,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (entry.tags != null && entry.tags!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: entry.tags!.map((tag) {
                    return Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.all(0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Journal Entries'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('All Entries'),
                leading: const Icon(Icons.all_inclusive),
                onTap: () {
                  Navigator.pop(context);
                  // No filter needed, already showing all
                },
              ),
              ListTile(
                title: const Text('This Week'),
                leading: const Icon(Icons.calendar_today),
                onTap: () {
                  Navigator.pop(context);
                  // Filter for this week
                },
              ),
              ListTile(
                title: const Text('By Tags'),
                leading: const Icon(Icons.tag),
                onTap: () {
                  Navigator.pop(context);
                  _showTagFilterDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTagFilterDialog() {
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    final allTags = journalProvider.getAllTags();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter by Tags'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allTags.length,
              itemBuilder: (context, index) {
                final tag = allTags[index];
                return ListTile(
                  title: Text(tag),
                  onTap: () {
                    Navigator.pop(context);
                    // Filter by selected tag
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showAddEntryDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final tagsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Journal Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                    border: OutlineInputBorder(),
                    hintText: 'anxiety, work, family',
                  ),
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
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  final journalProvider = Provider.of<JournalProvider>(context, listen: false);

                  List<String>? tags;
                  if (tagsController.text.isNotEmpty) {
                    tags = tagsController.text.split(',').map((tag) => tag.trim()).toList();
                  }

                  journalProvider.addJournalEntry(
                    titleController.text,
                    contentController.text,
                    tags: tags,
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Journal entry added')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title and content are required')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showEntryDetailsDialog(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(entry.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('MMMM d, yyyy - h:mm a').format(entry.timestamp),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  entry.content,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
                if (entry.tags != null && entry.tags!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Tags:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: entry.tags!.map((tag) {
                      return Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.all(0),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

