import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/analytics_service.dart';

class OnboardingScreen extends StatefulWidget {
  final AnalyticsService analyticsService;
  final VoidCallback onComplete;

  const OnboardingScreen({
    Key? key,
    required this.analyticsService,
    required this.onComplete,
  }) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to MindfulMe',
      description: 'Your personal mental wellness companion for a happier, healthier you.',
      animationAsset: 'assets/animations/welcome.json',
      backgroundColor: Colors.purple[50]!,
    ),
    OnboardingPage(
      title: 'Track Your Mood',
      description: 'Log your emotions daily to identify patterns and gain insights into your mental wellbeing.',
      animationAsset: 'assets/animations/mood_tracking.json',
      backgroundColor: Colors.blue[50]!,
    ),
    OnboardingPage(
      title: 'Practice CBT Techniques',
      description: 'Access proven cognitive behavioral therapy exercises to manage stress and anxiety.',
      animationAsset: 'assets/animations/cbt.json',
      backgroundColor: Colors.green[50]!,
    ),
    OnboardingPage(
      title: 'Relax and Meditate',
      description: 'Guided relaxation exercises to help you find calm in your busy day.',
      animationAsset: 'assets/animations/meditation.json',
      backgroundColor: Colors.orange[50]!,
    ),
    OnboardingPage(
      title: 'Your Journey Begins',
      description: 'Take the first step toward better mental health today.',
      animationAsset: 'assets/animations/journey.json',
      backgroundColor: Colors.pink[50]!,
    ),
  ];

  @override
  void initState() {
    super.initState();
    widget.analyticsService.logScreenView('onboarding');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.analyticsService.logEvent('onboarding_completed');
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              widget.analyticsService.logEvent('onboarding_page_viewed', {'page': index + 1});
            },
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Container(
                color: page.backgroundColor,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          page.animationAsset,
                          height: 300,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 100,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text('Back'),
                        )
                      else
                        const SizedBox(width: 80),
                      ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: Text(
                          _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                        ),
                      ),
                      if (_currentPage < _pages.length - 1)
                        TextButton(
                          onPressed: () {
                            widget.analyticsService.logEvent('onboarding_skipped', {'from_page': _currentPage + 1});
                            widget.onComplete();
                          },
                          child: const Text('Skip'),
                        )
                      else
                        const SizedBox(width: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String animationAsset;
  final Color backgroundColor;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.animationAsset,
    required this.backgroundColor,
  });
}

