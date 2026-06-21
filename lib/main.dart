import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'widgets/main_navigation.dart';
import 'services/api_services.dart';
import 'screens/splash_screen.dart';
import 'package:workmanager/workmanager.dart';
import 'services/notification_service.dart';
import 'package:home_widget/home_widget.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('saved_email');
      final password = prefs.getString('saved_password');
      final lastNotifCount = prefs.getInt('last_notif_count') ?? 0;

      if (email != null && password != null) {
        // Initialize NotificationService since it's a new isolate
        await NotificationService().init();
        
        final apiService = EtholApiService();
        final response = await apiService.getNotif(email, password, refresh: true);
        
        if (response != null && response['error'] == false) {
          final List<dynamic> notifs = response['data'] ?? [];
          if (notifs.length > lastNotifCount) {
            // Show new notification
            final latestNotif = notifs.first;
            await NotificationService().showNotification(
              id: 0,
              title: 'Notifikasi Baru',
              body: latestNotif['keterangan'] ?? 'Ada pemberitahuan baru di Nexa',
            );
            await prefs.setInt('last_notif_count', notifs.length);
          } else if (notifs.length < lastNotifCount) {
            await prefs.setInt('last_notif_count', notifs.length);
          }
        }

        // Fetch tugas for Widget Update
        final tugasResponse = await apiService.getTugas(email, password, refresh: true);
        if (tugasResponse != null && tugasResponse['error'] == false) {
          final List<dynamic> tugasList = tugasResponse['data'] ?? [];
          final undoneTasks = tugasList.where((t) => t['submited'] == false).toList();
          
          String nearestDeadline = "Deadline: -";
          if (undoneTasks.isNotEmpty) {
             // Find closest deadline if possible, for now just get the first one or "-"
             final firstTask = undoneTasks.firstWhere((t) => t['deadline'] != null, orElse: () => undoneTasks.first);
             nearestDeadline = "Deadline: ${firstTask['deadline'] ?? '-'}";
          }
          
          await HomeWidget.saveWidgetData<String>('undone_tasks', 'Tugas Belum Selesai: ${undoneTasks.length}');
          await HomeWidget.saveWidgetData<String>('nearest_deadline', nearestDeadline);
          await HomeWidget.updateWidget(
            name: 'AppWidgetProvider',
            androidName: 'AppWidgetProvider',
          );
        }
      }
    } catch (e) {
      debugPrint("Background task error: $e");
    }
    return Future.value(true);
  });
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<String> languageNotifier = ValueNotifier('id');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications and background fetch
  await NotificationService().init();
  await NotificationService().requestPermissions();
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: false,
  );
  Workmanager().registerPeriodicTask(
    "1",
    "backgroundNotifTask",
    frequency: const Duration(minutes: 15),
  );

  final prefs = await SharedPreferences.getInstance();

  final isDark = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  final savedLang = prefs.getString('selectedLanguage') ?? 'id';
  languageNotifier.value = savedLang;

  final String? email = prefs.getString('saved_email');
  final String? password = prefs.getString('saved_password');

  Widget startWidget = const LoginScreen();

  if (email != null &&
      password != null &&
      email.isNotEmpty &&
      password.isNotEmpty) {
    try {
      final profile = await EtholApiService().getProfile(
        email,
        password,
        refresh: true,
      );

      if (profile != null && profile['error'] == false) {
        startWidget = MainNavigation(
          profileData: profile,
          email: email,
          password: password,
        );
      }
    } catch (e) {
      debugPrint("Auto-login failed: $e");
      startWidget = const LoginScreen();
    }
  }

  runApp(MyApp(homeScreen: startWidget));
}

class MyApp extends StatelessWidget {
  final Widget homeScreen;
  const MyApp({super.key, required this.homeScreen});

  @override
  Widget build(BuildContext context) {
    // 👇 3. Bungkus dengan Notifier Bahasa
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, currentMode, child) {
            return MaterialApp(
              title: 'Nexa',
              debugShowCheckedModeBanner: false,
              locale: Locale(lang),

              themeMode: currentMode,

              // --- TEMA TERANG ---
              theme: ThemeData(
                fontFamily: 'PlusJakartaSans',
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF346EE0),
                ),
                useMaterial3: true,
                scaffoldBackgroundColor: const Color(0xFFF7F7F7),
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: SharedAxisPageTransitionsBuilder(
                      transitionType: SharedAxisTransitionType.horizontal,
                    ),
                    TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
                      transitionType: SharedAxisTransitionType.horizontal,
                    ),
                  },
                ),
              ),

              // --- TEMA GELAP ---
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                fontFamily: 'PlusJakartaSans',
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF346EE0),
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
                scaffoldBackgroundColor: const Color(0xFF111827),
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: SharedAxisPageTransitionsBuilder(
                      transitionType: SharedAxisTransitionType.horizontal,
                    ),
                    TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
                      transitionType: SharedAxisTransitionType.horizontal,
                    ),
                  },
                ),
              ),

              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
