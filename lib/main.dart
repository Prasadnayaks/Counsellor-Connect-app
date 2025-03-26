import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/counselor_provider.dart';
import 'services/firebase_service.dart';
import 'providers/user_provider.dart';
import 'providers/navigation_provider.dart';
import 'journal_provider.dart';
import 'appointment_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/achievement_provider.dart';
import 'mood_provider.dart';
import 'providers/cbt_provider.dart';
import 'splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    final firebaseService = FirebaseService();
    await firebaseService.init();

    runApp(MyApp(firebaseService: firebaseService));
  } catch (e) {
    print('Error during app initialization: $e');
    runApp(Scaffold(
      body: Center(
        child: Text('Failed to initialize app: $e'),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  final FirebaseService firebaseService;

  const MyApp({Key? key, required this.firebaseService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(firebaseService),
        ),
        ChangeNotifierProvider(
          create: (_) => NavigationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AchievementProvider(firebaseService),
        ),
        ChangeNotifierProvider(
          create: (_) => CounselorProvider(firebaseService),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationProvider(
            firebaseService,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => MoodProvider(
            firebaseService,
            achievementProvider: Provider.of<AchievementProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => JournalProvider(
            firebaseService,
            achievementProvider: Provider.of<AchievementProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AppointmentProvider(
            firebaseService,
            notificationProvider: Provider.of<NotificationProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ChatProvider(firebaseService),
        ),
        ChangeNotifierProvider(
          create: (context) => GoalProvider(
            firebaseService,
            notificationProvider: Provider.of<NotificationProvider>(context, listen: false),
            achievementProvider: Provider.of<AchievementProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => CBTProvider(
            firebaseService,
            achievementProvider: Provider.of<AchievementProvider>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Mental Health App',
        theme: AppTheme.lightTheme,
        //darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

