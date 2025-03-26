import 'package:flutter/material.dart';
import 'challenge_selection.dart';

class AgeVerification extends StatelessWidget {
  const AgeVerification({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'po, how old are you?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'We would like to help you by providing appropriate support based on your age.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              _AgeButton(
                age: '18 years and older',
                color: Colors.blue.shade100,
                onTap: () => _navigateToNext(context),
              ),
              const SizedBox(height: 16),
              _AgeButton(
                age: '13-17 years old',
                color: Colors.teal.shade100,
                onTap: () => _navigateToNext(context),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateToNext(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: const Text('CONTINUE'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToNext(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChallengeSelection()),
    );
  }
}

class _AgeButton extends StatelessWidget {
  final String age;
  final Color color;
  final VoidCallback onTap;

  const _AgeButton({
    required this.age,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            age,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
