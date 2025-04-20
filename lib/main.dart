import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test/pages/about_page.dart';
import 'package:test/pages/favorite_page.dart';
import 'package:test/pages/history_page.dart';
import 'package:test/pages/login_page.dart';
import 'package:test/pages/map_page.dart';
import 'package:test/pages/settings_page.dart';
import 'package:test/geo_point.dart';
import 'package:test/big_model.dart';

//for debug
void main() {
  runApp(
    ChangeNotifierProvider(create: (context) => BigModel(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wanderlust Itinerary Planner',
      theme: ThemeData(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          headlineSmall: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.teal[900],
          ),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal[700],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: LoginPage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Top Navigation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true, // For modern Material Design
      ),
      home: const MainNavigationPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    MapPage(),
    AboutPage(),
    HistoryPage(),
    FavoritePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Navigation App'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.blue.shade800,
            child: Row(
              children: [
                _buildNavButton(0, Icons.home, 'Home'),
                _buildNavButton(1, Icons.info, 'About'),
                _buildNavButton(2, Icons.history, 'History'),
                _buildNavButton(3, Icons.favorite, 'Favorite'),
                _buildNavButton(4, Icons.settings, 'Settings'),
              ],
            ),
          ),
        ),
      ),
      body: _pages[_currentIndex],
    );
  }

  Widget _buildNavButton(int index, IconData icon, String label) {
    return Expanded(
      child: Material(
        color:
            _currentIndex == index ? Colors.blue.shade600 : Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
