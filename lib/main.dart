import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/data_provider.dart';
import 'ui/home_page.dart';
import 'ui/log_page.dart';
import 'ui/recap_page.dart';
import 'ui/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<DataProvider>().isDarkMode;

    // Shared text theme using Space Grotesk — clean, geometric, developer-native
    final baseText = GoogleFonts.spaceGroteskTextTheme();

    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      textTheme: baseText,
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0B0F14),
      textTheme: GoogleFonts.spaceGroteskTextTheme(ThemeData.dark().textTheme),
    );

    return MaterialApp(
      title: 'DayStack',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        return Container(
          color: Colors.black,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: ClipRect(child: child),
            ),
          ),
        );
      },
      home: const AppLayout(),
    );
  }
}

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    LogPage(),
    RecapPage(),
    SettingsPage(),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem(label: 'Home',    icon: Icons.grid_view_rounded,         activeIcon: Icons.grid_view_rounded),
    _NavItem(label: 'Log',     icon: Icons.calendar_month_outlined,    activeIcon: Icons.calendar_month_rounded),
    _NavItem(label: 'Recap',   icon: Icons.area_chart_outlined,        activeIcon: Icons.area_chart),
    _NavItem(label: 'Settings',icon: Icons.settings_outlined,          activeIcon: Icons.settings_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<DataProvider>().isDarkMode;
    final navBg     = isDark ? const Color(0xFF0D1117) : Colors.white;
    final divider   = isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0);
    final active    = const Color(0xFF6366F1);
    final inactive  = isDark ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F14) : const Color(0xFFF7F9FC),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(top: BorderSide(color: divider, width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: List.generate(_navItems.length, (i) {
                final item = _navItems[i];
                final isActive = i == _currentIndex;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _currentIndex = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive ? active.withOpacity(0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive ? active : inactive,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                            color: isActive ? active : inactive,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _NavItem({required this.label, required this.icon, required this.activeIcon});
}
