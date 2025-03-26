import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cbt_provider.dart';

class ProblemSolvingScreen extends StatefulWidget {
  const ProblemSolvingScreen({Key? key}) : super(key: key);

  @override
  _ProblemSolvingScreenState createState() => _ProblemSolvingScreenState();
}

class _ProblemSolvingScreenState extends State<ProblemSolvingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Problem definition
  final _problemController = TextEditingController();
  final _goalController = TextEditingController();

  // Solutions
  final List<Map<String, dynamic>> _solutions = [];
  final _solutionController = TextEditingController();
  final _prosController = TextEditingController();
  final _consController = TextEditingController();

  // Chosen solution
  String? _chosenSolution;
  final _actionPlanController = TextEditingController();

  // Notes and insights
  final _notesController = TextEditingController();
  final _insightsController = TextEditingController();

  // Step tracking
  int _currentStep = 0;

  @override
  void dispose() {
    _problemController.dispose();
    _goalController.dispose();
    _solutionController.dispose();
    _prosController.dispose();
    _consController.dispose();
    _actionPlanController.dispose();
    _notesController.dispose();
    _insightsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Problem Solving'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 4) {
              if (_validateCurrentStep()) {
                setState(() {
                  _currentStep += 1;
                });
              }
            } else {
              _saveSession();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(_currentStep < 4 ? 'Continue' : 'Save'),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Define the Problem'),
              content: _buildProblemDefinitionStep(),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: const Text('Generate Solutions'),
              content: _buildGenerateSolutionsStep(),
              isActive: _currentStep >= 1,
            ),
            Step(
              title: const Text('Evaluate Solutions'),
              content: _buildEvaluateSolutionsStep(),
              isActive: _currentStep >= 2,
            ),
            Step(
              title: const Text('Choose a Solution'),
              content: _buildChooseSolutionStep(),
              isActive: _currentStep >= 3,
            ),
            Step(
              title: const Text('Create Action Plan'),
              content: _buildActionPlanStep(),
              isActive: _currentStep >= 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemDefinitionStep() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    const Text(
    'Clearly define the problem you want to solve. Be specific about whats troubling you.',
    style: TextStyle(fontSize: 16),
    ),
    const SizedBox(height: 16),
    TextFormField(
    controller: _problemController,
    decoration: const InputDecoration(
    labelText: 'Problem',
    hintText: 'What problem are you facing?',
    border: OutlineInputBorder(),
    ),
    maxLines: 3,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please describe the problem';
    }
    return null;
    },
    ),
    const SizedBox(height: 16),
    TextFormField(
    controller: _goalController,
    decoration: const InputDecoration(
    labelText: 'Goal',
    hintText: 'What would you like to achieve?',
    border: OutlineInputBorder(),
    ),
    maxLines: 2,
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Please describe your goal';
    }
    return null;
    },
    ),
    ],
    );
  }

  Widget _buildGenerateSolutionsStep() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
    const Text(
    'Brainstorm as many potential solutions as possible. Dont judge them yet, just list them all.',
    style: TextStyle(fontSize: 16),
    ),
    const SizedBox(height: 16),
    TextFormField(
    controller: _solutionController,
    decoration: const InputDecoration(
    labelText: 'Potential Solution',
    hintText: 'Enter a possible solution',
    border: OutlineInputBorder(),
    ),
    ),
    const SizedBox(height: 16),
    ElevatedButton.icon(
    onPressed: _addSolution,
    icon: const Icon(Icons.add),
    label: const Text('Add Solution'),
    style: ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 50),
    ),
    ),
    const SizedBox(height: 16),
    if (_solutions.isNotEmpty) ...[
    const Text(
    'Added Solutions:',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    ),
    ),
    const SizedBox(height: 8),
    ..._solutions.map((solution) => _buildSolutionItem(solution)),
    ],
    ],
    );
  }

  Widget _buildSolutionItem(Map<String, dynamic> solution) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(solution['solution']),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            setState(() {
              _solutions.remove(solution);
              if (_chosenSolution == solution['solution']) {
                _chosenSolution = null;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildEvaluateSolutionsStep() {
    if (_solutions.isEmpty) {
      return const Text(
        'Please add at least one solution in the previous step.',
        style: TextStyle(fontSize: 16, color: Colors.red),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Evaluate each solution by listing its pros and cons.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Select Solution to Evaluate',
            border: OutlineInputBorder(),
          ),
          items: _solutions.map<DropdownMenuItem<String>>((solution) {
            return DropdownMenuItem<String>(
              value: solution['solution'], // Ensure this is a String
              child: Text(
                solution['solution'],
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _solutionController.text = value ?? '';
              // Find if this solution already has pros/cons
              final existingSolution = _solutions.firstWhere(
                    (s) => s['solution'] == value,
                orElse: () => {'pros': '', 'cons': ''},
              );
              _prosController.text = existingSolution['pros'] ?? '';
              _consController.text = existingSolution['cons'] ?? '';
            });
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _prosController,
          decoration: const InputDecoration(
            labelText: 'Pros',
            hintText: 'What are the advantages of this solution?',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _consController,
          decoration: const InputDecoration(
            labelText: 'Cons',
            hintText: 'What are the disadvantages of this solution?',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _updateSolutionEvaluation,
          child: const Text('Save Evaluation'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Evaluated Solutions:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._solutions
            .where((s) => (s['pros'] != null && s['pros'].isNotEmpty) ||
            (s['cons'] != null && s['cons'].isNotEmpty))
            .map((solution) => _buildEvaluatedSolutionItem(solution)),
      ],
    );
  }

  Widget _buildEvaluatedSolutionItem(Map<String, dynamic> solution) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              solution['solution'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (solution['pros'] != null && solution['pros'].isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pros: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(solution['pros']),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
            if (solution['cons'] != null && solution['cons'].isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cons: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(solution['cons']),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChooseSolutionStep() {
    if (_solutions.isEmpty) {
      return const Text(
        'Please add at least one solution in the previous steps.',
        style: TextStyle(fontSize: 16, color: Colors.red),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Based on your evaluation, choose the best solution to implement.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        ...List.generate(_solutions.length, (index) {
          final solution = _solutions[index];
          return RadioListTile<String>(
            title: Text(solution['solution']),
            subtitle: Text(
              'Pros: ${solution['pros'] ?? 'None'}\nCons: ${solution['cons'] ?? 'None'}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            value: solution['solution'],
            groupValue: _chosenSolution,
            onChanged: (value) {
              setState(() {
                _chosenSolution = value;
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildActionPlanStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create an action plan for implementing your chosen solution: $_chosenSolution',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _actionPlanController,
          decoration: const InputDecoration(
            labelText: 'Action Plan',
            hintText: 'What specific steps will you take? When will you do them?',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please create an action plan';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        const Text(
          'Notes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            hintText: 'Add any additional notes about this problem-solving session...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const Text(
          'Insights',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _insightsController,
          decoration: const InputDecoration(
            hintText: 'What did you learn from this problem-solving exercise?',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  void _addSolution() {
    if (_solutionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a solution')),
      );
      return;
    }

    setState(() {
      // Check if solution already exists
      final existingIndex = _solutions.indexWhere(
            (s) => s['solution'] == _solutionController.text,
      );

      if (existingIndex == -1) {
        // Add new solution
        _solutions.add({
          'solution': _solutionController.text,
          'pros': '',
          'cons': '',
        });
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This solution already exists')),
        );
      }

      _solutionController.clear();
    });
  }

  void _updateSolutionEvaluation() {
    if (_solutionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a solution to evaluate')),
      );
      return;
    }

    setState(() {
      final index = _solutions.indexWhere(
            (s) => s['solution'] == _solutionController.text,
      );

      if (index != -1) {
        _solutions[index]['pros'] = _prosController.text;
        _solutions[index]['cons'] = _consController.text;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evaluation saved')),
        );

        _solutionController.clear();
        _prosController.clear();
        _consController.clear();
      }
    });
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _formKey.currentState!.validate();
      case 1:
        if (_solutions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please add at least one solution')),
          );
          return false;
        }
        return true;
      case 2:
        final evaluatedSolutions = _solutions.where(
              (s) => (s['pros'] != null && s['pros'].isNotEmpty) ||
              (s['cons'] != null && s['cons'].isNotEmpty),
        ).length;

        if (evaluatedSolutions == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please evaluate at least one solution')),
          );
          return false;
        }
        return true;
      case 3:
        if (_chosenSolution == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please choose a solution')),
          );
          return false;
        }
        return true;
      case 4:
        return _formKey.currentState!.validate();
      default:
        return true;
    }
  }

  void _saveSession() {
    if (_formKey.currentState!.validate()) {
      final cbtProvider = Provider.of<CBTProvider>(context, listen: false);

      // Create session data
      final sessionData = {
        'problem': _problemController.text,
        'goal': _goalController.text,
        'solutions': _solutions,
        'chosenSolution': _chosenSolution,
        'actionPlan': _actionPlanController.text,
      };

      // Save the session
      cbtProvider.saveSession(
        title: 'Problem Solving',
        technique: 'problem_solving',
        data: sessionData,
        durationMinutes: 30,
        notes: _notesController.text,
        insights: _insightsController.text,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session saved successfully')),
      );

      // Navigate back
      Navigator.pop(context);
    }
  }
}

