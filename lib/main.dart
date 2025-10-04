import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lottie/lottie.dart';
import 'package:pocket_habits/Notifiers/habits_state.dart' hide NotificationService;
import 'package:pocket_habits/Screens/splash_Screen.dart';
import 'package:pocket_habits/models/habit.dart';
import 'package:pocket_habits/models/mood_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_habits/providers/providers.dart';
import 'package:pocket_habits/theme/pallete.dart';
//import 'package:pocket_habits/services/notification_service.dart'; // Add this import

import 'Notifiers/completio_logs_state.dart';
import 'Notifiers/moods_state.dart';
import 'Screens/CalenderScreen.dart';
import 'Screens/habit_tile.dart';
import 'Screens/newHabit.dart';
import 'Screens/settings_Screen.dart';
import 'Screens/stats_Screen.dart';
import 'models/completion_log.dart';
import 'notifications/notificartion_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationService().initialize();

  await Hive.initFlutter();

  Hive.registerAdapter(CompletionLogAdapter());
  Hive.registerAdapter(HabitFrequencyAdapter());
  Hive.registerAdapter(MoodLogAdapter());
  Hive.registerAdapter(HabitAdapter());

  final habitBox = await Hive.openBox<Habit>('habits');
  final moodBox = await Hive.openBox<MoodLog>('moods');
  final completionBox = await Hive.openBox<CompletionLog>('completions');

  runApp(
    ProviderScope(
      overrides: [
        habitBoxProvider.overrideWithValue(habitBox),
        moodBoxProvider.overrideWithValue(moodBox),
        completionBoxProvider.overrideWithValue(completionBox),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    return MaterialApp(
      title: "Pocket Habits",
      theme: AppPalette.lightTheme,
      darkTheme: AppPalette.darkTheme,
      themeMode: themeNotifier.mode,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}




// Rest of your existing code...
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TodayScreen(),
    const CalendarScreen(),
    const StatsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}


class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const HeaderSection(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    FeelingSection(),
                    SizedBox(height: 24),
                    HabitsSection(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewHabitPage()),
                  );
                },
                child: const Text("Add New Habit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class HeaderSection extends ConsumerWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.06,
                backgroundImage: NetworkImage(
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuCVgKjgm8cOlZxmAz3DwGWGmGwYGNOm8Lm8cmMMnECszWgSuYhBpFsT8ihm4pHjPrXTY4sKdEqUDRNOQv1ApDuboVJJptZ7OTevyv1FLGNfmUpgb_2ncw-GmK6oy0mZle_UZQGYzv4aQ7SxEsiB-3y8X-rHWXBdQJ4UZf8GpqUcHq5AX6vxpoKciRLBoQlOdRLr8aZGrWKnCeu5vkqMEnpTNESIvpp46wMrhVqX1uoORVrXeQHqchqddrUK6GC4WSJNNBfuPZ_wUE5y",
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Welcome back!",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    "Alex",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            color: Colors.grey,
            onPressed: () async {
              // Show pending notifications
              final notifications = await NotificationService().getPendingNotifications();
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pending Notifications'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: notifications.map((notif) =>
                          ListTile(
                            title: Text(notif.title ?? 'No title'),
                            subtitle: Text(notif.body ?? 'No body'),
                          )
                      ).toList(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }
}

class FeelingSection extends ConsumerWidget {
  const FeelingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodNotifier = ref.read(moodsProvider.notifier);
    final hasMoodToday = moodNotifier.hasMoodForToday();

    final emojis = ["😞", "😐", "😊", "😄", "😍"];
    final moodLabels = ["Very Sad", "Neutral", "Happy", "Great", "Amazing"];

    if (hasMoodToday) {
      return const SizedBox.shrink();
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How are you feeling today?",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: emojis.asMap().entries
                  .map((entry) => GestureDetector(
                onTap: () async {
                  final rating = entry.key + 1;
                  await moodNotifier.addMoodLog(rating);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mood "${moodLabels[entry.key]}" ($rating/5) saved for today!'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.transparent,
                  ),
                  child: Column(
                    children: [
                      Text(
                        entry.value,
                        style: const TextStyle(fontSize: 36),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        moodLabels[entry.key],
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class HabitsSection extends ConsumerWidget {
  const HabitsSection({super.key});

  bool isHabitScheduledToday(Habit habit) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekday = today.weekday;

    switch (habit.frequency.type) {
      case 'daily':
        return habit.frequency.days.contains(weekday);
      case 'weekly':
        return habit.frequency.days.contains(weekday);
      case 'custom':
        return habit.frequency.days.contains(weekday);
      case 'monthly':
        return habit.frequency.days.contains(today.day);
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final todayHabits = habits.where((habit) => isHabitScheduledToday(habit)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today Habits",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        const SizedBox(height: 12),
        // Show empty state when no habits
        if (todayHabits.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add your Lottie animation here
                Container(
                  height: 200,
                  width: 200,
                  child: Lottie.asset(
                    'assets/animations/Empty box.json',
                    repeat: true,
                    animate: true,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "No habits for today",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Add your first habit to get started!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        else
        // Show habits list when habits exist
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  children: todayHabits.map((h) => HabitTile(
                    icon: h.icon,
                    title: h.name,
                    subtitle: h.subtype ?? "",
                    habit: h,
                  )).toList(),
                );
              } else {
                return Column(
                  children: todayHabits
                      .map((h) => HabitTile(
                    icon: h.icon,
                    title: h.name,
                    subtitle: h.subtype ?? "",
                    habit: h,
                  ))
                      .toList(),
                );
              }
            },
          ),
      ],
    );
  }
}


class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavItem(
              icon: Icons.home,
              label: "Today",
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            NavItem(
              icon: Icons.calendar_today,
              label: "Calendar",
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            NavItem(
              icon: Icons.bar_chart,
              label: "Stats",
              selected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            NavItem(
              icon: Icons.settings,
              label: "Settings",
              selected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF3F51B5) : Colors.grey;

    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
